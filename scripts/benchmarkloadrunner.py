import multiprocessing as mp
import os
import uuid
from datetime import datetime
from iamconnectioninfo import IamConnection
from pgdb import connect


class CursorByName():
    """Use description to map column index to name per PEP 249"""
    def __init__(self, cursor):
        self._cursor = cursor

    def __iter__(self):
        return self

    def __next__(self):
        row = self._cursor.__next__()

        return {
            description[0]: row[col]
            for col, description in enumerate(self._cursor.description)
        }


def update_task_status(args_dict):
    """Function that updates the postgres task_status table.
    Required top level attributes are:
    ----
    type: insert | update .  insert generates a uuid
    sql: dict containing column names as attributes. Values is what will be updated/inserted into the table.
    uuid: Required when "type":"update"
    """
    if (args_dict['type'] == "insert"):
        args_dict['sql']['task_uuid'] = uuid.uuid4()
        args_dict['sql']['task_start_time'] = datetime.utcnow().strftime(
            "%Y-%m-%d %H:%M:%S.%f")
        cols = ''
        vals = ''
        for key in args_dict['sql']:
            cols += key + ','
            val = args_dict['sql'][key]
            vals += f"'{val}',"
        cols = cols[:-1]
        vals = vals[:-1]
        insert_sql = f'insert into task_status({cols}) values({vals})'
        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(insert_sql)

        return args_dict['sql']['task_uuid']

    elif args_dict['type'] == "update" and 'uuid' in args_dict:
        task_uuid = args_dict['uuid']
        if args_dict['sql']['task_status'] == 'complete':
            args_dict['sql']['task_end_time'] = datetime.utcnow().strftime(
                "%Y-%m-%d %H:%M:%S.%f")
        set_clause = ''
        for key in args_dict['sql']:
            val_tmp = args_dict['sql'][key]
            set_clause += f"{key}='{val_tmp}',"
        set_clause = set_clause[:-1]
        update_sql = f"update task_status set {set_clause} where task_uuid='{task_uuid}'"
        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(update_sql)
            

def summarize_benchmark(iamconnectioninfo, tpcds_pid, tpch_pid):

    if tpcds_pid is not None or tpch_pid is not None:
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            if tpcds_pid is not None:
                cursor.execute(f"with compile_agg as (select query,datediff(us,min(starttime),max(endtime))/1000::NUMERIC as compile_ms from svl_compile group by 1)   select trim(label) as label,listagg(sq.query,',') within group (order by sq.query) as query_ids, min(sq.starttime) as redshift_query_start, max(sq.endtime) as redshift_query_end, sum(total_queue_time)/1000::NUMERIC as sum_queue_ms,sum(compile_ms) as sum_compile_ms from stl_query sq join stl_wlm_query wq using(query) join compile_agg ca using(query) where sq.pid={tpcds_pid} group by 1 order by 1")
                ret = CursorByName(cursor)

                with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                    cur = conn.cursor()
                    for row in ret:
                        cur.execute(
                            f"UPDATE benchmark_query_status SET redshift_query_start=\'{row['redshift_query_start']}\',redshift_query_end=\'{row['redshift_query_end']}\',total_queue_time_ms={row['sum_queue_ms']},total_compile_time_ms={row['sum_compile_ms']},query_ids=\'{row['query_ids']}\' WHERE benchmark_query_template=\'{row['label']}\'"
                        )
            if tpch_pid is not None:
                cursor.execute(f"with compile_agg as (select query,datediff(us,min(starttime),max(endtime))/1000::NUMERIC as compile_ms from svl_compile group by 1)   select trim(label) as label,listagg(sq.query,',') within group (order by sq.query) as query_ids, min(sq.starttime) as redshift_query_start, max(sq.endtime) as redshift_query_end, sum(total_queue_time)/1000::NUMERIC as sum_queue_ms,sum(compile_ms) as sum_compile_ms from stl_query sq join stl_wlm_query wq using(query) join compile_agg ca using(query) where sq.pid={tpcds_pid} group by 1 order by 1")
                ret = CursorByName(cursor)

                with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                    cur = conn.cursor()
                    for row in ret:
                        cur.execute(
                            f"UPDATE benchmark_query_status SET redshift_query_start=\'{row['redshift_query_start']}\',redshift_query_end=\'{row['redshift_query_end']}\',total_queue_time_ms={row['sum_queue_ms']},total_compile_time_ms={row['sum_compile_ms']},query_ids=\'{row['query_ids']}\' WHERE benchmark_query_template=\'{row['label']}\'"
                        )



def autorun_benchmark(iamconnectioninfo, tpc_benchmark, working_dir, streams, task_uuid,
                      postgres_writer_queue):
        stream = list(streams)[0]
        scale = getattr(iamconnectioninfo,tpc_benchmark)
        schema = f'{tpc_benchmark}_{scale}'
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('select pg_backend_pid()')
            autorun_pid = int("".join(
                filter(str.isdigit, str(cursor.fetchone()))))
            cursor.execute(
                f'set search_path to {schema};set enable_result_cache_for_session to false'
            )
            if tpc_benchmark == "tpcds":
                num_queries = 99
            # tpch
            else:
                num_queries = 22
            for i in range(1, num_queries + 1):
                query = streams[stream][i - 1]
                query_tpl = f'{query}.tpl'
                sql_path = f'{working_dir}/{tpc_benchmark}/streams/{scale}/{stream}/{i}.query{query}.tpl'
                print(sql_path)
                sql = open(sql_path, 'r').read()
                time_start = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f")
                exec_info = {
                    'type': 'insert',
                    'task_uuid': task_uuid,
                    'client_starttime': time_start,
                    'sql_path': sql_path,
                    'pid': autorun_pid,
                    'stream': stream,
                    'stream_ident': i,
                    'query': query_tpl,
                    'tpc_benchmark': tpc_benchmark,
                    'scale': scale
                }
                postgres_writer_queue.put(exec_info)
                cursor.execute(f"set query_group to '{query_tpl}';{sql}")
                time_end = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f")
                exec_info = {
                    'type': 'update',
                    'task_uuid': task_uuid,
                    'stream_ident': i,
                    'client_endtime': time_end
                }
                postgres_writer_queue.put(exec_info)

            
        return autorun_pid


def load_ddl(iamconnectioninfo, working_dir):
    with connect(database=iamconnectioninfo.db,
                 host=iamconnectioninfo.hostname_plus_port,
                 user=iamconnectioninfo.username,
                 password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        # tpcds
        if iamconnectioninfo.tpcds != '':
            ddl = open(f'{working_dir}/ddl/tpcds-ddl.sql', 'r').read()
            schema = 'tpcds_{}'.format(iamconnectioninfo.tpcds)
            cursor.execute('create schema if not exists %s' % (schema))
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(ddl)
        # tpch
        if iamconnectioninfo.tpcds != '':
            ddl = open(f'{working_dir}/ddl/tpch-ddl.sql', 'r').read()
            schema = 'tpch_{}'.format(iamconnectioninfo.tpch)
            cursor.execute('create schema if not exists %s' % (schema))
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(ddl)

    # task status tables for monitoring
    with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
        cursor = conn.cursor()
        cursor.execute(open(f'{working_dir}/ddl/task_status.sql', 'r').read())
        cursor.execute(open(f'{working_dir}/ddl/task_load_status.sql', 'r').read())
        cursor.execute(open(f'{working_dir}/ddl/benchmark_query_status.sql', 'r').read())
        cursor.execute(open(f'{working_dir}/ddl/benchmark_table_row_counts.sql', 'r').read())



def load_tpcds(iamconnectioninfo, num_worker_process, task_uuid, tables_already_loaded):
    data_set = 'tpcds'
    tpcds_tables = [
        'store_sales', 'catalog_sales', 'web_sales', 'web_returns',
        'store_returns', 'catalog_returns', 'call_center', 'catalog_page',
        'customer_address', 'customer', 'customer_demographics', 'date_dim',
        'household_demographics', 'income_band', 'inventory', 'item',
        'promotion', 'reason', 'ship_mode', 'store', 'time_dim', 'warehouse',
        'web_page', 'web_site'
    ]
    if tables_already_loaded['tpcds_schema_exists'] is False:
        tpcds_ingest_table_list = tpcds_tables
    else:
        # Truncate mismatched tables
        scale = getattr(iamconnectioninfo, data_set)
        schema = '{}_{}'.format(data_set, scale)
        tpcds_ingest_table_list = [x for x in tpcds_tables if x not in tables_already_loaded['tpcds']]
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            for tbl in tpcds_ingest_table_list:
                cursor.execute(f"TRUNCATE {tbl}")

    tpcds_table_queue = mp.JoinableQueue()
    for tbl in tpcds_ingest_table_list:
        tpcds_table_queue.put(tbl)

    processes = []
    for i in range(num_worker_process):
        tpcds_worker_process = mp.Process(target=load_worker,
                                          args=(tpcds_table_queue, data_set, task_uuid),
                                          daemon=True,
                                          name='{}_worker_process_{}'.format(
                                              data_set, i))
        tpcds_worker_process.start()
        processes.append(tpcds_worker_process)

    tpcds_table_queue.join()


def load_tpch(iamconnectioninfo, num_worker_process, task_uuid, tables_already_loaded):
    data_set = 'tpch'
    tpch_tables = [
        'nation', 'region', 'part', 'supplier', 'partsupp', 'customer',
        'orders', 'lineitem'
    ]
    if tables_already_loaded['tpch_schema_exists'] is False:
        tpch_ingest_table_list = tpch_tables
    else:
        # Truncate mismatched tables
        scale = getattr(iamconnectioninfo, data_set)
        schema = '{}_{}'.format(data_set, scale)
        tpch_ingest_table_list = [x for x in tpch_tables if x not in tables_already_loaded['tpch']]
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            for tbl in tpch_ingest_table_list:
                cursor.execute(f"TRUNCATE {tbl}")

    tpch_table_queue = mp.JoinableQueue()
    for tbl in tpch_ingest_table_list:
        tpch_table_queue.put(tbl)

    processes = []
    for i in range(num_worker_process):
        tpch_worker_process = mp.Process(target=load_worker,
                                         args=(tpch_table_queue, data_set, task_uuid),
                                         daemon=True,
                                         name='{}_worker_process_{}'.format(
                                             data_set, i))
        tpch_worker_process.start()
        processes.append(tpch_worker_process)

    tpch_table_queue.join()


def load_worker(queue, data_set, task_uuid):

    while True:
        tbl = queue.get()
        print('Processing %s (MP: %s) ' % (tbl, mp.current_process().name))
        iamconnectioninfo = IamConnection()

        scale = getattr(iamconnectioninfo, data_set)
        schema = '{}_{}'.format(data_set, scale)

        bucket = 'redshift-managed-loads-datasets-us-east-1'
        copy_sql = f"COPY {tbl} FROM 's3://{bucket}/dataset={data_set}/size={scale}/table={tbl}/{tbl}.manifest' iam_role '{iamconnectioninfo.iamrole}' gzip delimiter '|' COMPUPDATE OFF MANIFEST"
        copy_sql_double_quoted = copy_sql.translate(str.maketrans({"'": r"''"}))

        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(
                f"INSERT INTO task_load_status(task_uuid,tablename,dataset,status,load_start,querytext) values('{task_uuid}','{tbl}','{schema}','inflight',timezone('utc', now()),'{copy_sql_double_quoted}')")

        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(copy_sql)
            cursor.execute('select pg_last_copy_id()')
            query_id = int("".join(filter(str.isdigit,
                                          str(cursor.fetchone()))))
            cursor.execute('select count(*) from %s' % (tbl))
            row_count = int("".join(filter(str.isdigit,
                                           str(cursor.fetchone()))))
            cursor.execute(
                'select count(*) from stv_blocklist where tbl=\'%s.%s\'::regclass::oid'
                % (schema, tbl))
            block_count = int("".join(
                filter(str.isdigit, str(cursor.fetchone()))))

            

        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(
                'UPDATE task_load_status SET status=\'complete\',load_end=timezone(\'utc\', now()), '
                'query_id=%s,rows_d=%s, size_d=%s WHERE tablename=\'%s\' and dataset=\'%s\''
                % (query_id, row_count, block_count, tbl, schema))

            

        queue.task_done()


def pg_writer(queue):
    while True:
        msg = queue.get()
        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            if msg["type"] == 'insert':
                cursor.execute(
                    f'INSERT INTO benchmark_query_status(task_uuid,tpc_benchmark,scale,stream,pid,query_order_in_stream,benchmark_query_template,template_file_path,client_starttime) values(\'{msg["task_uuid"]}\',\'{msg["tpc_benchmark"]}\',\'{msg["scale"]}\',\'{msg["stream"]}\',\'{msg["pid"]}\',\'{msg["stream_ident"]}\',\'{msg["query"]}\',\'{msg["sql_path"]}\',\'{msg["client_starttime"]}\')'
                )
            if msg["type"] == 'update':
                cursor.execute(
                    f'UPDATE benchmark_query_status _path SET client_endtime=\'{msg["client_endtime"]}\' where task_uuid=\'{msg["task_uuid"]}\' and query_order_in_stream=\'{msg["stream_ident"]}\''
                )
        conn.close()
        queue.task_done()


def validate_rowcounts(iamconnectioninfo,tpcds_scale,tpch_scale):
    tables_matched_rowcounts = {}
    if tpcds_scale != '' or tpch_scale != '':
        # check if schema exists
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            if tpcds_scale != '':
                cursor.execute(f"select count(*) from pg_namespace where nspname='tpcds_{tpcds_scale}'")
                for row in cursor.fetchone():
                    if row == 1:
                        tables_matched_rowcounts['tpcds_schema_exists'] = True
                        redshift_rowcounts = {}
                        pg_rowcounts = {}
                        cursor.execute(f"""select "table",tbl_rows::int from svv_table_info where schema='tpcds_{tpcds_scale}'""")
                        ret = CursorByName(cursor)
                        for row in ret :
                            redshift_rowcounts[row['table']] = row['tbl_rows']
                        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                            cur = conn.cursor()
                            cur.execute(f"select * from benchmark_table_row_counts where benchmark='tpcds_{tpcds_scale}'")
                            pg_ret = CursorByName(cur)
                            for row in pg_ret :
                                pg_rowcounts[row['table_name']] = row['rowcount']
                        set1 = set(redshift_rowcounts.items())
                        set2 = set(pg_rowcounts.items())
                        tables_matched_rowcounts['tpcds'] = [*dict(set1 & set2).keys()]
                    else:
                        tables_matched_rowcounts['tpcds_schema_exists'] = False
            if tpch_scale != '':
                cursor.execute(f"select count(*) from pg_namespace where nspname='tpch_{tpch_scale}'")
                for row in cursor.fetchone():
                    if row == 1:
                        tables_matched_rowcounts['tpch_schema_exists'] = True
                        redshift_rowcounts = {}
                        pg_rowcounts = {}
                        # schema exists
                        cursor.execute(f"""select "table",tbl_rows::int from svv_table_info where schema='tpch_{tpch_scale}'""")
                        ret = CursorByName(cursor)
                        for row in ret :
                            redshift_rowcounts[row['table']] = row['tbl_rows']
                        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                            cur = conn.cursor()
                            cur.execute(f"select * from benchmark_table_row_counts where benchmark='tpch_{tpch_scale}'")
                            pg_ret = CursorByName(cur)
                            for row in pg_ret :
                                pg_rowcounts[row['table_name']] = row['rowcount']
                        set1 = set(redshift_rowcounts.items())
                        set2 = set(pg_rowcounts.items())
                        tables_matched_rowcounts['tpch'] = [*dict(set1 & set2).keys()]
                    else:
                        tables_matched_rowcounts['tpch_schema_exists'] = False
    return tables_matched_rowcounts

# main function
def benchmark_auto_run():
    iamconnectioninfo = IamConnection()
    tpcds_scale = iamconnectioninfo.tpcds.lower()
    tpch_scale = iamconnectioninfo.tpch.lower()

    # local env for development
    if os.path.exists('/Users/bschur/derived-tpcds-tpch-benchmarks'):
        working_dir = '/Users/bschur/derived-tpcds-tpch-benchmarks'
    else:
        working_dir = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks'

    # load DDL. Includes both DDL in the postgres DB for monitoring as well as tpcds/tpcdh tables
    if iamconnectioninfo.tpcds != '' or iamconnectioninfo.tpch != '':
        load_ddl(iamconnectioninfo, working_dir)

    # returns a dict containing keys tpcds/tpch , each with values being a list of table names with matching rowcounts per the postgres table benchmark_table_row_counts
    matched_table_names = {
        'tpch': [],
        'tpcds': [],
        'tpch_schema_exists': False,
        'tpcds_schema_exists': False,
    }


    # TODO: READD THIS once we have rowcounts for all scale factors
    # validate_rowcounts(iamconnectioninfo,tpcds_scale,tpch_scale)


    # load TPCDS
    if iamconnectioninfo.tpcds != '':
        num_tpcds_workers = 2
        task_status = {'type': 'insert', 'sql': {'task_name': 'load_tpcds', 'task_version': '1.0',
                                                 'task_path': '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts/benchmark-load-runner.py',
                                                 'task_concurrency': num_tpcds_workers, 'task_status': 'inflight', }}
        task_uuid = update_task_status(task_status)
        load_tpcds(iamconnectioninfo, num_tpcds_workers, task_uuid, matched_table_names)
        task_status = {'type': 'update', 'uuid': task_uuid, 'sql': {'task_status': 'complete', }}
        update_task_status(task_status)

    # load TPCH
    if iamconnectioninfo.tpch != '':
        num_tpch_workers = 2
        task_status = {'type': 'insert', 'sql': {'task_name': 'load_tpch', 'task_version': '1.0',
                                                 'task_path': '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts/benchmark-load-runner.py',
                                                 'task_concurrency': num_tpch_workers, 'task_status': 'inflight', }}
        task_uuid = update_task_status(task_status)
        load_tpch(iamconnectioninfo, num_tpch_workers, task_uuid, matched_table_names)
        task_status = {'type': 'update', 'uuid': task_uuid, 'sql': {'task_status': 'complete', }}
        update_task_status(task_status)

    # Only a single stream is defined for both tpch/ds as we're running the power test for both. The list maps to the query template number in the stream
    streams = {
        'power': [
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
            37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
            54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
            71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87,
            88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99
        ]
    }

    postgres_writer_queue = mp.JoinableQueue()
    pg_process = mp.Process(target=pg_writer,
                            args=(postgres_writer_queue,),
                            daemon=True,
                            name='pg_writer_process')

    pg_process.start()

    # autorun benchmarks
    tpcds_pid = None
    tpch_pid = None

    # autorun TPCDS
    if iamconnectioninfo.tpcds_autorun and iamconnectioninfo.tpcds != '':
        task_status = {'type': 'insert', 'sql': {'task_name': 'run_tpcds', 'task_version': '1.0',
                                                 'task_path': '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts/benchmark-load-runner.py',
                                                 'task_concurrency': 1, 'task_status': 'inflight', }}
        task_uuid = update_task_status(task_status)
        tpcds_pid = autorun_benchmark(iamconnectioninfo, 'tpcds', working_dir,
                                      streams, task_uuid, postgres_writer_queue)
        task_status = {'type': 'update', 'uuid': task_uuid, 'sql': {'task_status': 'complete', }}
        update_task_status(task_status)

    # autorun TPCH
    if iamconnectioninfo.tpch_autorun and iamconnectioninfo.tpch != '':
        task_status = {'type': 'insert', 'sql': {'task_name': 'run_tpch', 'task_version': '1.0',
                                                 'task_path': '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts/benchmark-load-runner.py',
                                                 'task_concurrency': 1, 'task_status': 'inflight', }}
        task_uuid = update_task_status(task_status)
        tpch_pid = autorun_benchmark(iamconnectioninfo, 'tpch', working_dir, streams, task_uuid, postgres_writer_queue)
        task_status = {'type': 'update', 'uuid': task_uuid, 'sql': {'task_status': 'complete', }}
        update_task_status(task_status)

    postgres_writer_queue.join()

    summarize_benchmark(iamconnectioninfo, tpcds_pid, tpch_pid)
