import multiprocessing as mp
from iamconnectioninfo import IamConnection
from pgdb import connect

def load_worker(queue, ds):
    while True:
        msg = queue.get()
        print('Processing %s (MP: %s) ' % (msg, mp.current_process().name))
        iamconnectioninfo = IamConnection()

        scale = getattr(iamconnectioninfo,ds)
        searchpath = '{}_{}'.format(ds,scale)

        copy_sql = 'COPY {} from \'s3://rgs-artifac/home/ec2-user/SageMaker/{}/textfile/manifest/{}_manifest\' iam_role \'{}\' gzip delimiter \'|\'  COMPUPDATE OFF MANIFEST'.format(msg, ds, scale, msg, iamconnectioninfo.iamrole)
        copy_sql_escaped = 'COPY {} from \'\'s3://rgs-artifacts/tpc/home/ec2-user/SageMaker/textfile/manifest/{}_manifest\'\' iam_role \'\'{}\'\' gzip delimiter \'\'|\'\'  COMPUPDATE OFF MANIFEST'.format(msg, scale, msg, iamconnectioninfo.iamrole)

        with connect(dbname='postgres', user='ec2-user') as conn:
            cursor = conn.cursor()
            cursor.execute('INSERT INTO load_status(tablename,dataset,status,load_start,querytext) values(\'%s\',\'%s\',\'inflight\',timezone(\'utc\', now()),\'%s\');' % (msg,searchpath,copy_sql_escaped))

        with connect(database=iamconnectioninfo.db,host=iamconnectioninfo.hostname_plus_port,user=iamconnectioninfo.username,password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (searchpath))
            cursor.execute(copy_sql)
            cursor.execute('select pg_last_copy_id()')
            query_id = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
            cursor.execute('select count(*) from %s' % (msg))
            row_count = int("".join(filter(str.isdigit, str(cursor.fetchone()))))
            cursor.execute('select count(*) from stv_blocklist where tbl=\'%s.%s\'::regclass::oid' % (searchpath,msg))
            block_count = int("".join(filter(str.isdigit, str(cursor.fetchone()))))

        with connect(dbname='postgres', user='ec2-user') as conn:
            cursor = conn.cursor()
            cursor.execute('UPDATE load_status SET status=\'complete\',load_end=timezone(\'utc\', now()), query_id=%s,rows_d=%s, size_d=%s WHERE tablename=\'%s\' and dataset=\'%s\'' % (query_id,row_count,block_count,msg,searchpath))

        queue.task_done()

if __name__=='__main__':

    iamconnectioninfo = IamConnection()
    working_dir = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/'

    # load DDL
    with connect(database=iamconnectioninfo.db,host=iamconnectioninfo.hostname_plus_port,user=iamconnectioninfo.username,password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        # tpcds
        ddl = open(working_dir + 'tpcds-ddl.sql', 'r')
        searchpath = 'tpcds_{}'.format(iamconnectioninfo.tpcds)
        cursor.execute('create schema if not exists %s' % (searchpath))
        cursor.execute('set search_path to %s' % (searchpath))
        cursor.execute(ddl.read())
        # tpch
        ddl = open(working_dir + 'tpch-ddl.sql', 'r')
        searchpath = 'tpch_{}'.format(iamconnectioninfo.tpch)
        cursor.execute('create schema if not exists %s' % (searchpath))
        cursor.execute('set search_path to %s' % (searchpath))
        cursor.execute(ddl.read())


    with connect(dbname='postgres', user='ec2-user') as conn:
        cursor = conn.cursor()
        cursor.execute('CREATE TABLE IF NOT EXISTS load_status(tablename VARCHAR(128), dataset VARCHAR(15), status VARCHAR(10), load_start TIMESTAMP, load_end TIMESTAMP, rows_d BIGINT, size_d INT, query_id INT, querytext VARCHAR(512))')

    # load TPCDS
    num_tpcds_workers = 2
    tpcds_table_list = ['store_sales', 'catalog_sales', 'web_sales', 'web_returns', 'store_returns', 'catalog_returns',
                  'call_center', 'catalog_page', 'customer_address', 'customer', 'customer_demographics', 'date_dim',
                  'household_demographics', 'income_band', 'inventory', 'item', 'promotion', 'reason', 'ship_mode',
                  'store', 'time_dim', 'warehouse', 'web_page', 'web_site']

    tpcds_table_queue = mp.JoinableQueue()
    for tbl in tpcds_table_list:
        tpcds_table_queue.put(tbl)

    dataset='tpcds'
    processes = []
    for i in range(num_tpcds_workers):
        tpcds_worker_process = mp.Process(target=load_worker, args=(tpcds_table_queue, dataset), daemon=True, name='{}_worker_process_{}'.format(dataset, i))
        tpcds_worker_process.start()
        processes.append(tpcds_worker_process)

    tpcds_table_queue.join()

    if iamconnectioninfo.tpcds_autorun == 'true':
        with connect(database=iamconnectioninfo.db,host=iamconnectioninfo.hostname_plus_port,user=iamconnectioninfo.username,password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            tpcds_sql = open(working_dir + 'tpcds-queries.sql', 'r')
            cursor.execute(tpcds_sql.read())

    # load TPCH
    num_tpch_workers = 2
    tpch_table_list = ['nation', 'region', 'part', 'supplier', 'partsupp', 'customer', 'orders', 'lineitem']

    tpch_table_queue = mp.JoinableQueue()
    for tbl in tpch_table_list:
        tpch_table_queue.put(tbl)

    dataset='tpch'
    processes = []
    for i in range(num_tpch_workers):
        tpch_worker_process = mp.Process(target=load_worker, args=(tpch_table_queue, dataset), daemon=True, name='{}_worker_process_{}'.format(dataset, i))
        tpch_worker_process.start()
        processes.append(tpch_worker_process)

    tpch_table_queue.join()

    if iamconnectioninfo.tpch_autorun == 'true':
        with connect(database=iamconnectioninfo.db,host=iamconnectioninfo.hostname_plus_port,user=iamconnectioninfo.username,password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            tpcds_sql = open(working_dir + 'tpch-queries.sql', 'r')
            cursor.execute(tpcds_sql.read())
