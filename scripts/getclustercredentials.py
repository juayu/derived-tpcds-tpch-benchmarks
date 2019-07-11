#!/usr/bin/env python3

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
    dbuser = response['DbUser']
    dbpwd = response['DbPassword']
    print(dbuser + ' ' + dbpwd)
except ClientError as e:
    if e.response['Error']['Code'] == 'UnsupportedOperation':
        print("ERROR: Unsupported Operation. HTTP 400")
    elif e.response['Error']['Code'] == 'ClusterNotFound':
        print('ERROR: ClusterNotFound ' + clusterIdentifier)
    else:
        print("ERROR: Unexpected error: %s" % e)
