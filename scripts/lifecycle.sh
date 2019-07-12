#@IgnoreInspection BashAddShebang
sudo yum -y install postgresql96.x86_64
mkdir -p /home/ec2-user/SageMaker/Redshift/bin/  
mkdir /home/ec2-user/SageMaker/Redshift/assets/  

echo '#!/bin/bash  
if [  -z "$PGCONNECT_TIMEOUT"  ]; then 
	export PGCONNECT_TIMEOUT=10
fi

isIAM=true


if [[ "$*" == *'\''--no-iam'\''* ]] ; then 
	args="$*"
	cmd="psql ${args//--no-iam/}"
    exec $cmd
	exit 0
else


# TODO: reduce number of describe calls, pass full describe output to jq and then handle parsing logic client side 
redshiftTags=$(aws redshift describe-clusters --query "Clusters[*].[[Tags[?Key=='\''master-user'\''].Value],[Tags[?Key=='\''stack-name'\''].Value],[Tags[?Key=='\''db-name'\''].Value],[Tags[?Key=='\''port'\''].Value]]" --output text)

redshiftTagArray=(${redshiftTags// / })
userName=${redshiftTagArray[0]}
clusterIdentifier=${redshiftTagArray[1]}
database=${redshiftTagArray[2]}
port=${redshiftTagArray[3]}


hostName=$(aws redshift describe-clusters --cluster-identifier $clusterIdentifier --query '\''Clusters[*].Endpoint.Address'\'' --output text)

# TODO: add checks if connection attributes changed versus tagging 
# TODO: Support all psql arguments. Easiest to just strip away authentication parameters all of the time (except for --no-iam) and then just append arguments ( $* )
# will still need to ta still assign hostname arg to a variable for use in looking up cluster identifier 

                while [ "$#" -gt 0 ]; do
                  case "$1" in
                        -h) hostName="$2"; shift 2;;
                        -U) userName="$2"; shift 2;;
                        -d) database="$2"; shift 2;;
                        -p) port="$2"; shift 2;;
                        -f) file="$2"; shift 2;;
                        -c) cmd=""$2""; shift 2;;
                        -t) tuples="-t"; shift 1;;

                        --host=*) hostName="${1#*=}"; shift 1;;
                        --userName=*) userName="${1#*=}"; shift 1;;
                        --dbName=*) database="${1#*=}"; shift 1;;
                        --port=*) port="${1#*=}"; shift 1;;
                        --file=*) file="${1#*=}"; shift 1;;
                        --command=*) cmd=""${1#*=}""; shift 1;;
                        --tuples-only) tuples="-t"; shift 1;;
                        --host|--userName|--database|--port|--command|--tuples-only) echo "$1 requires an argument" >&2; exit 1;;

                        -*) echo "unknown option: $1" >&2; exit 1;;
                        #  other parameters get captured here  *) do whatever with $1; shift 1;;
                  esac
                done

clusterIdentifier=${hostName%%.*}

credstring=$(/home/ec2-user/SageMaker/Redshift/bin/getclustercredentials.py $userName $clusterIdentifier $database)

IFS='\'' '\'' read -a arr <<< "$credstring"
iamUser=${arr[0]}

                if [  "$iamUser" == "ERROR:"  ]; then
                        # print out error string passed from ClientError response
                        echo $credstring
                else
                        export PGPASSWORD=${arr[1]};

                        if [ -z "$file" ] && [ -z "$cmd" ]; then
                            psql -h $hostName -p $port -d $database -U $iamUser $tuples
                        elif [ ! -z "$file" ]  && [ -z "$cmd" ]; then
							echo "2"
                            psql -h $hostName -p $port -d $database -U $iamUser --file="$file" $tuples
						elif [ -z "$file" ] && [ ! -z "$cmd" ]; then
                            psql -h $hostName -p $port -d $database -U $iamUser --command="$cmd" $tuples 
						else
                            psql -h $hostName -p $port -d $database -U $iamUser --command="$cmd" --file="$file" $tuples
						fi
                fi
fi' >  /home/ec2-user/SageMaker/Redshift/bin/psql  
  
echo '#!/usr/bin/env python3  
  
import boto3  
import sys  
from botocore.exceptions import ClientError  
  
if len(sys.argv) != 4 :  
	print("Invalid number of arguments. Usage: ./getclustercredentials.py username clusterIdentifier DbName")  
	sys.exit(1)  
  
dbUser=sys.argv[1]  
clusterIdentifier=sys.argv[2]  
dbName=sys.argv[3]  
try:  
    client = boto3.client("redshift")  
    response = client.get_cluster_credentials(  
        DbUser=dbUser,  
        DbName=dbName,  
        ClusterIdentifier=clusterIdentifier,  
        DurationSeconds=3600,  
        AutoCreate=False  
    )  
    dbuser = response["DbUser"]  
    dbpwd = response["DbPassword"]  
    print(dbuser + '\'' '\'' + dbpwd)
except ClientError as e:  
    if e.response["Error"]["Code"] == "UnsupportedOperation":  
        print("ERROR: Unsupported Operation. HTTP 400")  
    elif e.response["Error"]["Code"] == "ClusterNotFound":  
        print("ERROR: ClusterNotFound " + clusterIdentifier)  
    else:  
        print("ERROR: Unexpected error: %s" % e)  
' > /home/ec2-user/SageMaker/Redshift/bin/getclustercredentials.py

echo '#!/bin/bash
scaleTpcds=$(aws redshift describe-clusters --query "Clusters[*].[[Tags[?Key=='\''tpcds'\''].Value]]" --output text)
#scaleTpch=$(aws redshift describe-clusters --query "Clusters[*].[[Tags[?Key=='\''tpch'\''].Value]]" --output text)
autorun=$(aws redshift describe-clusters --query "Clusters[*].[[Tags[?Key=='\''autorun'\''].Value]]" --output text)
iamRole=$(aws redshift describe-clusters --tag-keys port cluster-identifier db-name master-user stack-name dbUser --query '\''Clusters[*].IamRoles[*].IamRoleArn'\'' --output text)

sudo sqlite3 /home/ec2-user/SageMaker/Redshift/assets/redshift.db "CREATE TABLE IF NOT EXISTS load_status(tablename VARCHAR(128), dataset VARCHAR(15), status VARCHAR(10), load_start TIMESTAMP, load_end TIMESTAMP, rows_d BIGINT, size_d INT, query_id INT, copy_sql VARCHAR(512))"


sudo sqlite3 /home/ec2-user/SageMaker/Redshift/assets/redshift.db <<END_SQL
CREATE TABLE IF NOT EXISTS load_status(tablename VARCHAR(128), dataset VARCHAR(15), status VARCHAR(10), load_start TIMESTAMP, load_end TIMESTAMP, rows_d BIGINT, size_d INT, query_id INT, copy_sql VARCHAR(512));
END_SQL

if [ ! -z "$scaleTpcds" ]; then

dataset="TPC-DS $scaleTpcds"
schema="tpcds_$scaleTpcds"

/home/ec2-user/SageMaker/Redshift/bin/psql -c "create schema if not exists $schema;set search_path to $schema" -f /home/ec2-user/SageMaker/derived-tpc-ds-queries/ddl.sql  >/dev/null 2>&1

tableArr=( store_sales catalog_sales web_sales web_returns store_returns catalog_returns call_center catalog_page customer_address customer customer_demographics date_dim household_demographics income_band inventory item promotion reason ship_mode store time_dim warehouse web_page web_site )

for i in "${tableArr[@]}"
do
    tblSizeSQL="select count(*) from stv_blocklist join pg_class on stv_blocklist.tbl=pg_class.oid where relname="\'\''"$i"\'\''""
	tblSizeBefore=$(/home/ec2-user/SageMaker/Redshift/bin/psql -t -c "$tblSizeSQL")
    sudo sqlite3 /home/ec2-user/SageMaker/Redshift/assets/redshift.db "INSERT INTO load_status values("\'\''"$i"\'\''","\'\''"$dataset"\'\''",'\''inflight'\'',CURRENT_TIMESTAMP,null,null,null,null,null);"
	copySQL="copy $schema.$i from '\''s3://rgs-artifacts/tpcds/"$scaleTpcds"/textfile/manifest/"$i"_manifest'\'' iam_role '\''"$iamRole"'\'' gzip delimiter '\''|'\'' COMPUPDATE OFF MANIFEST;select pg_last_copy_id();"
    copyExec=$(/home/ec2-user/SageMaker/Redshift/bin/psql -t -c "$copySQL")
	queryId=$copyExec
	rowCountSQL="select sum(lines_scanned) from stl_load_commits where query=$queryId"
    rowCountExec=$(/home/ec2-user/SageMaker/Redshift/bin/psql -t -c "$rowCountSQL")
	tblSizeAfter=$(/home/ec2-user/SageMaker/Redshift/bin/psql -t -c "$tblSizeSQL")
	sizeDiff=$(($tblSizeAfter-$tblSizeBefore))
    sudo sqlite3 /home/ec2-user/SageMaker/Redshift/assets/redshift.db "UPDATE load_status SET status='\''completed'\'',load_end=CURRENT_TIME,rows_d=$rowCountExec,size_d=$sizeDiff,query_id=$queryId  WHERE tablename="\'\''"$i"\'\''" and status='\''inflight'\''"
done

		if [ "$autorun" == true ]; then
		/home/ec2-user/SageMaker/Redshift/bin/psql -c "set search_path to $schema" -f /home/ec2-user/SageMaker/derived-tpc-ds-queries/query_1.sql  >/dev/null 2>&1
		fi

fi

#if [ ! -z "$scaleTpch" ]; then
#
# TODO: add data to bucket and copy/paste above SQL after modifying S3 path + tableArr
#
#		if [ "$autorun" == true ]; then
#
#		fi
#fi
' > /home/ec2-user/SageMaker/Redshift/bin/autorun.sh

sudo chmod a+x /home/ec2-user/SageMaker/Redshift/bin/autorun.sh /home/ec2-user/SageMaker/Redshift/bin/getclustercredentials.py /home/ec2-user/SageMaker/Redshift/bin/psql  

sudo nohup /home/ec2-user/SageMaker/Redshift/bin/autorun.sh >/home/ec2-user/autorun.out 2>&1 &