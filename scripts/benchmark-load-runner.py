import multiprocessing as mp
from iamconnectioninfo import IamConnection
from pgdb import connect

def autorun_tpcds(iamconnectioninfo, working_dir):

    if iamconnectioninfo.tpcds_autorun == 'True' and iamconnectioninfo.tpcds == '':
        tpcds_sql = open(working_dir + 'tpcds-queries.sql', 'r')
        schema = 'tpcds_{}'.format(iamconnectioninfo.tpch)
        with connect(database=iamconnectioninfo.db, host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username, password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(tpcds_sql.read())
            cursor.execute('select pg_backend_pid()')
            autorun_pid = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
        return autorun_pid


def autorun_tpch(iamconnectioninfo, working_dir):

    if iamconnectioninfo.tpch_autorun == 'True' and iamconnectioninfo.tpch != '':
        tpch_sql = open(working_dir + 'tpcds-queries.sql', 'r')
        schema = 'tpcds_{}'.format(iamconnectioninfo.tpch)
        with connect(database=iamconnectioninfo.db, host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username, password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(tpch_sql.read())
            cursor.execute('select pg_backend_pid()')
            autorun_pid = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
        return autorun_pid


def load_ddl(iamconnectioninfo, working_dir):
    if iamconnectioninfo.tpcds != '' and iamconnectioninfo.tpcds != '' :
        with connect(database=iamconnectioninfo.db, host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username, password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            # tpcds
            if iamconnectioninfo.tpcds != '' :
                ddl = open(working_dir + 'tpcds-ddl.sql', 'r')
                schema = 'tpcds_{}'.format(iamconnectioninfo.tpcds)
                cursor.execute('create schema if not exists %s' % (schema))
                cursor.execute('set search_path to %s' % (schema))
                cursor.execute(ddl.read())
            # tpch
            if iamconnectioninfo.tpcds != '' :
                ddl = open(working_dir + 'tpch-ddl.sql', 'r')
                schema = 'tpch_{}'.format(iamconnectioninfo.tpch)
                cursor.execute('create schema if not exists %s' % (schema))
                cursor.execute('set search_path to %s' % (schema))
                cursor.execute(ddl.read())


        with connect(dbname='postgres', user='ec2-user') as conn:
            cursor = conn.cursor()
            cursor.execute('CREATE TABLE IF NOT EXISTS load_status(tablename VARCHAR(128), dataset VARCHAR(15), '
                           'status VARCHAR(10), load_start TIMESTAMP, load_end TIMESTAMP, rows_d BIGINT, size_d INT, '
                           'query_id INT, querytext VARCHAR(512))')


def load_tpcds(num_worker_process):
    tpcds_table_list = ['store_sales', 'catalog_sales', 'web_sales', 'web_returns', 'store_returns', 'catalog_returns',
                        'call_center', 'catalog_page', 'customer_address', 'customer', 'customer_demographics', 'date_dim',
                        'household_demographics', 'income_band', 'inventory', 'item', 'promotion', 'reason', 'ship_mode',
                        'store', 'time_dim', 'warehouse', 'web_page', 'web_site']

    tpcds_table_queue = mp.JoinableQueue()
    for tbl in tpcds_table_list:
        tpcds_table_queue.put(tbl)

    dataset='tpcds'
    processes = []
    for i in range(num_worker_process):
        tpcds_worker_process = mp.Process(target=load_worker, args=(tpcds_table_queue, dataset),
                                          daemon=True, name='{}_worker_process_{}'.format(dataset, i))
        tpcds_worker_process.start()
        processes.append(tpcds_worker_process)

    tpcds_table_queue.join()

def load_tpch(num_worker_process):
    tpch_table_list = ['nation', 'region', 'part', 'supplier', 'partsupp', 'customer', 'orders', 'lineitem']

    tpch_table_queue = mp.JoinableQueue()
    for tbl in tpch_table_list:
        tpch_table_queue.put(tbl)

    dataset='tpch'
    processes = []
    for i in range(num_worker_process):
        tpch_worker_process = mp.Process(target=load_worker, args=(tpch_table_queue, dataset),
                                         daemon=True, name='{}_worker_process_{}'.format(dataset, i))
        tpch_worker_process.start()
        processes.append(tpch_worker_process)

    tpch_table_queue.join()


def load_worker(queue, data_set):

    while True:
        tbl = queue.get()
        print('Processing %s (MP: %s) ' % (tbl, mp.current_process().name))
        iamconnectioninfo = IamConnection()

        scale = getattr(iamconnectioninfo, data_set)
        schema = '{}_{}'.format(data_set, scale)

        copy_sql = 'COPY {} from \'s3://rgs-artifacts/{}/{}/textfile/manifest/{}_' \
                   'manifest\' iam_role \'{}\' gzip delimiter \'|\'  ' \
                   'COMPUPDATE OFF MANIFEST'.format(tbl, data_set, scale, tbl, iamconnectioninfo.iamrole)
        copy_sql_escaped = 'COPY {} from \'\'s3://rgs-artifacts/{}/{}/textfile/manifest/{}_' \
                   'manifest\'\' iam_role \'\'{}\'\' gzip delimiter \'\'|\'\'  ' \
                   'COMPUPDATE OFF MANIFEST'.format(tbl, data_set, scale, tbl, iamconnectioninfo.iamrole)

        with connect(dbname='postgres', user='ec2-user') as conn:
            cursor = conn.cursor()
            cursor.execute('INSERT INTO load_status(tablename,dataset,status,load_start,querytext) '
                           'values(\'%s\',\'%s\',\'inflight\',timezone(\'utc\', now()),\'%s\');' %
                           (tbl, schema, copy_sql_escaped))

        with connect(database=iamconnectioninfo.db, host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username, password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(copy_sql)
            cursor.execute('select pg_last_copy_id()')
            query_id = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
            cursor.execute('select count(*) from %s' % (tbl))
            row_count = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
            cursor.execute('select count(*) from stv_blocklist where tbl=\'%s.%s\'::regclass::oid' % (schema, tbl))
            block_count = int("".join(filter(str.isdigit, str(cursor.fetchone()))))

        with connect(dbname='postgres', user='ec2-user') as conn:
            cursor = conn.cursor()
            cursor.execute('UPDATE load_status SET status=\'complete\',load_end=timezone(\'utc\', now()), '
                           'query_id=%s,rows_d=%s, size_d=%s WHERE tablename=\'%s\' and dataset=\'%s\'' %
                           (query_id, row_count, block_count, tbl, schema))

        queue.task_done()

if __name__=='__main__':

    iamconnectioninfo = IamConnection()
    working_dir = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/'
    #working_dir = '/Users/bschur/derived-tpcds-tpch-benchmarks/'

    # load DDL
    load_ddl(iamconnectioninfo, working_dir)

    # load TPCDS
    load_tpcds(2)

    # load TPCH
    load_tpch(2)

    # autorun tpcds
    tpcds_pid = autorun_tpcds(iamconnectioninfo, working_dir)

    # if tpcds_pid is not None:
    #     # update postgres
    #
    # # autorun tpch
    # tpch_pid = autorun_tpch(iamconnectioninfo, working_dir)
    #
    # if tpch_pid is not None:
    #     # update postgres
    #
    # SNS NOTIFY
