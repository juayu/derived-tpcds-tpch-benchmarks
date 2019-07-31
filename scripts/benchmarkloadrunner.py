import multiprocessing as mp
import uuid
import time
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
    if (args_dict['type'] == 'insert'):
        args_dict['sql']['task_uuid'] = uuid.uuid4()
        args_dict['sql']['task_start_time'] = f'to_timestamp({time.time()})'
        cols = ''
        vals = ''
        for key in args_dict['sql']:
            cols += key + ','
            val = args_dict['sql'][key]
            # prevent quotes from being added to to_timestamp
            if str(val).find('to_timestamp') == -1:
                vals += f"'{val}',"
            else:
                vals += f"{val},"
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
            args_dict['sql']['task_end_time'] = f'to_timestamp({time.time()})'
        set_clause = ''
        for key in args_dict['sql']:
            val_tmp = args_dict['sql'][key]
            if str(val_tmp).find('to_timestamp') == -1:
                set_clause += f"{key}='{val_tmp}',"
            else:
                set_clause += f"{key}={val_tmp},"
        set_clause = set_clause[:-1]
        # set_clause consists of a variable number of Key=Value pairs that are comma delimited in a string. Keys of args_dict map to columns in the postgres database in the task_status table
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
                            f"""UPDATE benchmark_query_status SET redshift_query_start='{row['redshift_query_start']}',redshift_query_end='{row['redshift_query_end']}',total_queue_time_ms={row['sum_queue_ms']},total_compile_time_ms={row['sum_compile_ms']},query_ids='{row['query_ids']}' WHERE benchmark_query_template='{row['label']}'"""
                        )
            if tpch_pid is not None:
                cursor.execute(f"with compile_agg as (select query,datediff(us,min(starttime),max(endtime))/1000::NUMERIC as compile_ms from svl_compile group by 1)   select trim(label) as label,listagg(sq.query,',') within group (order by sq.query) as query_ids, min(sq.starttime) as redshift_query_start, max(sq.endtime) as redshift_query_end, sum(total_queue_time)/1000::NUMERIC as sum_queue_ms,sum(compile_ms) as sum_compile_ms from stl_query sq join stl_wlm_query wq using(query) join compile_agg ca using(query) where sq.pid={tpcds_pid} group by 1 order by 1")
                ret = CursorByName(cursor)

                with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                    cur = conn.cursor()
                    for row in ret:
                        cur.execute(
                            f"""UPDATE benchmark_query_status SET redshift_query_start='{row['redshift_query_start']}',redshift_query_end='{row['redshift_query_end']}',total_queue_time_ms={row['sum_queue_ms']},total_compile_time_ms={row['sum_compile_ms']},query_ids='{row['query_ids']}' WHERE benchmark_query_template='{row['label']}'"""
                        )



def autorun_benchmark(tpc_benchmark, working_dir, streams, task_uuid,
                      postgres_writer_queue):
        iamconnectioninfo = IamConnection()
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
                sql_path = f'{working_dir}/{tpc_benchmark}/streams/{scale}/{stream}/0.query{query}.sql'
                sql = open(sql_path, 'r').read()
                exec_info = dict(type='insert',task_uuid=task_uuid,client_starttime=f'to_timestamp({time.time()})',sql_path=sql_path,pid=autorun_pid,stream=stream,stream_ident=i,query=query_tpl,tpc_benchmark=tpc_benchmark,scale=scale)
                postgres_writer_queue.put(exec_info)
                cursor.execute(f"set query_group to '{query_sql}';{sql}")
                exec_info = dict(type='update',task_uuid=task_uuid,stream_ident=i,client_endtime=f'to_timestamp({time.time()})',)
                postgres_writer_queue.put(exec_info)
        return autorun_pid

# TODO: Determine if this should be moved into create lifecycle depending on whether this is reused outside of initial autorun
def create_rowcounts(working_dir):
    with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
        cursor = conn.cursor()
        cursor.execute(open(f'{working_dir}/ddl/benchmark_table_row_counts.sql', 'r').read())
        cursor.execute('TRUNCATE benchmark_table_row_counts')
        cursor.execute(open(f'{working_dir}/rowcounts.sql', 'r').read())


def load_ddl(iamconnectioninfo, working_dir):
    with connect(database=iamconnectioninfo.db,
                 host=iamconnectioninfo.hostname_plus_port,
                 user=iamconnectioninfo.username,
                 password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        # tpcds
        if iamconnectioninfo.tpcds is not None:
            ddl = open(f'{working_dir}/ddl/tpcds-ddl.sql', 'r').read()
            schema = 'tpcds_{}'.format(iamconnectioninfo.tpcds)
            cursor.execute('create schema if not exists %s' % (schema))
            cursor.execute('set search_path to %s' % (schema))
            cursor.execute(ddl)
        # tpch
        if iamconnectioninfo.tpch is not None:
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



def load_tpcds(num_worker_process, task_uuid, tables_already_loaded):
    iamconnectioninfo = IamConnection()
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


def load_tpch(num_worker_process, task_uuid, tables_already_loaded):
    iamconnectioninfo = IamConnection()
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
        iamconnectioninfo = IamConnection()

        scale = getattr(iamconnectioninfo, data_set)
        schema = '{}_{}'.format(data_set, scale)

        bucket = 'redshift-managed-loads-datasets-us-east-1'
        copy_sql = f"COPY {tbl} FROM 's3://{bucket}/dataset={data_set}/size={scale}/table={tbl}/{tbl}.manifest' iam_role '{iamconnectioninfo.iamrole}' gzip delimiter '|' COMPUPDATE OFF MANIFEST"
        copy_sql_double_quoted = copy_sql.translate(str.maketrans({"'": r"''"}))

        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(
                f"INSERT INTO task_load_status(task_uuid,tablename,dataset,status,load_start,querytext) values('{task_uuid}','{tbl}','{schema}','active',timezone('utc', now()),'{copy_sql_double_quoted}')")

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
                f"""'select count(*) from stv_blocklist where tbl='{schema}.{tbl}'::regclass::oid"""
            )
            block_count = int("".join(
                filter(str.isdigit, str(cursor.fetchone()))))

        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            cursor.execute(
                f"""UPDATE task_load_status SET status='complete',load_end=timezone('utc', now()), '
                'query_id={query_id},rows_d={row_count}, size_d={block_count} WHERE tablename='{tbl}' and dataset='{schema}'"""
                )

        queue.task_done()


def pg_writer(queue):
    while True:
        msg = queue.get()
        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            if msg["type"] == 'insert':
                cursor.execute(
                    f"""INSERT INTO benchmark_query_status(task_uuid,tpc_benchmark,scale,stream,pid,query_order_in_stream,benchmark_query_template,template_file_path,client_starttime) values('{msg["task_uuid"]}','{msg["tpc_benchmark"]}','{msg["scale"]}','{msg["stream"]}','{msg["pid"]}','{msg["stream_ident"]}','{msg["query"]}','{msg["sql_path"]}',{msg["client_starttime"]})"""
                )
            if msg["type"] == 'update':
                cursor.execute(
                    f"""UPDATE benchmark_query_status SET client_endtime={msg["client_endtime"]} where task_uuid='{msg["task_uuid"]}' and query_order_in_stream='{msg["stream_ident"]}'"""
                )
        conn.close()
        queue.task_done()


def validate_rowcounts(iamconnectioninfo,tpcds_scale,tpch_scale):
    tables_matched_rowcounts = {}
    if tpcds_scale is not None or tpch_scale is not None:
        # check if schema exists
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            if tpcds_scale is not None:
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
            if tpch_scale is not None:
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
    if iamconnectioninfo.tpcds is not None:
        tpcds_scale = iamconnectioninfo.tpcds.lower()
    else:
        tpcds_scale = None
    if iamconnectioninfo.tpch is not None:
        tpch_scale = iamconnectioninfo.tpch.lower()
    else:
        tpch_scale = None
    tpcds_autorun = iamconnectioninfo.tpcds_autorun
    tpch_autorun = iamconnectioninfo.tpch_autorun

    working_dir = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks'

    # populate postgres DB with rowcounts needed for validation
    create_rowcounts(working_dir)

    # returns a dict containing keys tpcds/tpch , each with values being a list of table names with matching rowcounts per the postgres table benchmark_table_row_counts
    matched_table_names = validate_rowcounts(iamconnectioninfo,tpcds_scale,tpch_scale)


    # load DDL. Includes both DDL in the postgres DB for monitoring as well as tpcds/tpcdh tables
    if tpcds_scale is not None or tpch_scale is not None:
        load_ddl(iamconnectioninfo, working_dir)

    # load TPCDS
    if tpcds_scale is not None:
        num_tpcds_workers = 2
        sql_dict = dict(task_name='load_tpcds',task_version='1.0',task_path=f'{working_dir}/scripts/benchmarkloadrunner.py',task_concurrency=num_tpcds_workers,task_status='active')
        task_status = dict(type='insert',sql=sql_dict)
        task_uuid = update_task_status(task_status)
        load_tpcds(num_tpcds_workers, task_uuid, matched_table_names)
        sql_dict = dict(task_status='complete')
        task_status = dict(type='update',uuid=task_uuid,sql=sql_dict)
        update_task_status(task_status)

    # load TPCH
    if tpch_scale is not None:
        num_tpch_workers = 2
        sql_dict = dict(task_name='load_tpch',task_version='1.0',task_path=f'{working_dir}/scripts/benchmarkloadrunner.py',task_concurrency=num_tpch_workers,task_status='active')
        task_status = dict(type='insert',sql=sql_dict)
        task_uuid = update_task_status(task_status)
        load_tpch(num_tpch_workers, task_uuid, matched_table_names)
        sql_dict = dict(task_status='complete')
        task_status = dict(type='update',uuid=task_uuid,sql=sql_dict)
        update_task_status(task_status)

    # Only a single stream is defined for both tpch/ds as we're running the power test for both. The list maps to the query template number in the stream
    streams = {
        0: [
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


    # autorun TPCDS
    if tpcds_autorun and tpcds_scale is not None:
        sql_dict = dict(task_name='run_tpcds',task_version='1.0',task_path=f'{working_dir}/scripts/benchmarkloadrunner.py',task_concurrency=1,task_status='active')
        task_status = dict(type='insert',sql=sql_dict)
        task_uuid = update_task_status(task_status)
        tpcds_pid = autorun_benchmark('tpcds', working_dir, streams, task_uuid, postgres_writer_queue)
        sql_dict = dict(task_status='complete')
        task_status = dict(type='update',uuid=task_uuid,sql=sql_dict)
        update_task_status(task_status)
    else:
        tpcds_pid = None

    # autorun TPCH
    if tpch_autorun and tpch_scale is not None:
        sql_dict = dict(task_name='run_tpch',task_version='1.0',task_path=f'{working_dir}/scripts/benchmarkloadrunner.py',task_concurrency=1,task_status='active')
        task_status = dict(type='insert',sql=sql_dict)
        task_uuid = update_task_status(task_status)
        tpch_pid = autorun_benchmark('tpch', working_dir, streams, task_uuid, postgres_writer_queue)
        sql_dict = dict(task_status='complete')
        task_status = dict(type='update',uuid=task_uuid,sql=sql_dict)
        update_task_status(task_status)
    else:
        tpch_pid = None

    postgres_writer_queue.join()

    summarize_benchmark(iamconnectioninfo, tpcds_pid, tpch_pid)
