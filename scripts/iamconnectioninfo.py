import boto3
import sh
import os

try:
    import botocore_amazon.monkeypatch
    is_amzn = True
    stack_name_path = '/Users/bschur/RedshiftGoldStandard/scripts/stackname.txt'
except:
    is_amzn = False
    stack_name_path = '/home/ec2-user/SageMaker/Redshift/assets/metadata/stackname.txt'

from botocore.client import ClientError

if is_amzn is True:
    GIT_ROOT = sh.git("rev-parse", "--show-toplevel").strip()
    new_env = os.environ.copy()
    os.environ["AWS_CONFIG_FILE"] = f'{GIT_ROOT}/aws.cfg'

class IamConnection:

    def __get_cluster_info(self, session):
        """
        :param session:
        Get information from describeClusters for use in IAM auth and identifying the endpoint/port/db
        :return:
        map containing tag value pairs and the hostname 'hostname'
        """
        try:
            client = session.client("redshift")
            stack_name = open(stack_name_path,'r').readline().rstrip('\n')
            response = client.describe_clusters(TagKeys=['stack_name'], TagValues=[stack_name])
            hostname = response['Clusters'][0]['Endpoint']['Address']
            iamrole = response['Clusters'][0]['IamRoles'][0]['IamRoleArn']
            tags = response['Clusters'][0]['Tags']
            tagMap = {'hostname': hostname,'iamrole': iamrole}
            tagMap.update({tag.get('Key'): tag.get('Value') for tag in tags})
            return tagMap
        except ClientError as e:
            if e.response['Error']['Code'] == 'ClusterNotFound':
                print("ERROR: ClusterIdentifier does not refer to an existing cluster")
                raise
            elif e.response['Error']['Code'] == 'InvalidTagFault':
                print('ERROR: Invalid Tag')
                raise
            else:
                print("ERROR: Unexpected error: %s" % e)
                raise

    def __get_cluster_credentials(self, session, cluster_identifier, dbUser, dbName):
        """
        :param session:
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
                ClusterIdentifier=cluster_identifier,
                DurationSeconds=3600,
                AutoCreate=False
            )
            return {'username': response['DbUser'], 'password': response['DbPassword']}
        except ClientError as e:
            if e.response['Error']['Code'] == 'UnsupportedOperation':
                print("ERROR: Unsupported Operation. HTTP 400")
                raise
            elif e.response['Error']['Code'] == 'ClusterNotFound':
                print(f'ERROR: ClusterNotFound {cluster_identifier}')
                raise
            else:
                print(f'ERROR: Unexpected error: {e}')
                raise

    def __init__(self, cluster_identifier=None, master_user=None, db_name=None):

        session = boto3.session.Session()
        cluster_info = self.__get_cluster_info(session)

        if cluster_identifier is None:
            cluster_identifier = f'{cluster_info["stack_name"]}-{cluster_info["short_uuid"]}'

        if master_user is None:
            master_user = cluster_info["master_user"]

        if db_name is None:
            db_name = cluster_info['db_name']

        cluster_creds = self.__get_cluster_credentials(session, cluster_identifier, master_user,
                                             db_name)
        self.password = cluster_creds['password']
        self.username = cluster_creds['username']
        self.hostname = cluster_info['hostname']
        self.port = cluster_info['port']
        if is_amzn is True:
            self.hostname = '34.196.76.41'
        self.hostname_plus_port = f'{self.hostname}:{self.port}'
        self.port = cluster_info['port']
        self.iamrole = cluster_info['iamrole']
        self.db = db_name
        self.tpcds = cluster_info['tpcds']
        self.tpch = cluster_info['tpch']
        self.tpcds_autorun = cluster_info['autorun_tpcds']
        self.tpch_autorun = cluster_info['autorun_tpch']