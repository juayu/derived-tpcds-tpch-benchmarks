import boto3
import sh
import os
try:
    import botocore_amazon.monkeypatch
    is_amzn = True
except:
    is_amzn = False

from botocore.client import ClientError

if is_amzn is True:
    GIT_ROOT = sh.git("rev-parse", "--show-toplevel").strip()
    new_env = os.environ.copy()
    os.environ["AWS_CONFIG_FILE"] = f'{GIT_ROOT}/aws.cfg'

class IamConnection:

    def __get_cluster_info(self, session):
        """
        Get information from describeClusters for use in IAM auth and identifying the endpoint/port/db

        :return:
        map containing tag value pairs and the hostname 'hostname'
        """
        try:
            client = session.client("redshift")
            response = client.describe_clusters(TagKeys=['tpcds','tpch','port','stack_name'])
            hostname = response['Clusters'][0]['Endpoint']['Address']
            iamrole = response['Clusters'][0]['IamRoles'][0]['IamRoleArn']
            tags = response['Clusters'][0]['Tags']
            tagMap = {'hostname': hostname,'iamrole': iamrole}
            for d in tags:
                tagMap.update(eval("{'"+d["Key"] + "': '" + d["Value"]+"'}"))
            return tagMap
        except ClientError as e:
            if e.response['Error']['Code'] == 'ClusterNotFound':
                print("ERROR: ClusterIdentifier does not refer to an existing cluster")
            elif e.response['Error']['Code'] == 'InvalidTagFault':
                print('ERROR: Invalid Tag')
            else:
                print("ERROR: Unexpected error: %s" % e)

    def __get_cluster_credentials(self, session, clusteridentifier, dbUser, dbName):
        """
        :param clusterIdentifier:
        :param dbUser:
        :param dbName:
        :return:
        returns a dict containing the 'username' and 'password' from getClusterCredentials
        """
        try:
            client = session.client("redshift")
            response = client.get_cluster_credentials(
                DbUser=dbUser,
                DbName=dbName,
                ClusterIdentifier=clusteridentifier,
                DurationSeconds=3600,
                AutoCreate=False
            )
            creds = {'username': response['DbUser'], 'password': response['DbPassword']}

            return(creds)
        except ClientError as e:
            if e.response['Error']['Code'] == 'UnsupportedOperation':
                print("ERROR: Unsupported Operation. HTTP 400")
            elif e.response['Error']['Code'] == 'ClusterNotFound':
                print('ERROR: ClusterNotFound ' + clusteridentifier)
            else:
                print("ERROR: Unexpected error: %s" % e)

    def __init__(self):
        session = boto3.session.Session()
        cluster_info = self.__get_cluster_info(session)
        cluster_creds = self.__get_cluster_credentials(session, cluster_info["stack_name"], cluster_info["master_user"],
                                             cluster_info["db_name"])
        self.password = cluster_creds['password']
        self.username = cluster_creds['username']
        self.hostname = cluster_info['hostname']
        self.port = cluster_info['port']
        if is_amzn is True:
            self.hostname = '34.196.76.41'
        self.hostname_plus_port = f'{self.hostname}:{self.port}'
        self.port = cluster_info['port']
        self.iamrole = cluster_info['iamrole']
        self.db = cluster_info['db_name']
        self.tpcds = cluster_info['tpcds']
        self.tpch = cluster_info['tpch']
        self.tpcds_autorun = cluster_info['autorun_tpcds']
        self.tpch_autorun = cluster_info['autorun_tpch']
