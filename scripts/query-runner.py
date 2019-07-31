import multiprocessing as mp
import socket
import os
import json
import time
import uuid
from benchmarkloadrunner import benchmark_auto_run
from benchmark_streams import streams
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


def summarize_benchmark(pids,task_uuid):
        iamconnectioninfo = IamConnection()
        with connect(database=iamconnectioninfo.db,
                     host=iamconnectioninfo.hostname_plus_port,
                     user=iamconnectioninfo.username,
                     password=iamconnectioninfo.password) as conn:
            cursor = conn.cursor()
            # TODO: group on xid rather than label to free up query group usage
            # Aggregate compile time / exec time / queue time for all queries in all streams in the task
            sql = f"with compile_agg as (select query,datediff(us,min(starttime),max(endtime))/1000::NUMERIC as compile_ms from svl_compile group by 1)   select trim(label) as label,listagg(sq.query,',') within group (order by sq.query) as query_ids, min(sq.starttime) as redshift_query_start, max(sq.endtime) as redshift_query_end, sum(total_queue_time)/1000::NUMERIC as sum_queue_ms,sum(compile_ms) as sum_compile_ms from stl_query sq join stl_wlm_query wq using(query) join compile_agg ca using(query) where sq.pid in ({pids}) group by 1 order by 1"
            cursor.execute(sql)
            ret = CursorByName(cursor)
            with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
                cur = conn.cursor()
                for row in ret:
                    # Update server side query runtime data for each query in the task
                    cur.execute(
                        f"""UPDATE benchmark_query_status SET redshift_query_start='{row['redshift_query_start']}',redshift_query_end='{row['redshift_query_end']}',total_queue_time_ms={row['sum_queue_ms']},total_compile_time_ms={row['sum_compile_ms']},query_ids='{row['query_ids']}' WHERE benchmark_query_template='{row['label']}' and task_uuid='{task_uuid}'"""
                    )


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
        args_dict['sql']['task_request_time'] = f'to_timestamp({time.time()})'
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
        if args_dict['sql']['task_status'] == 'active':
            args_dict['sql']['task_start_time'] = f'to_timestamp({time.time()})'
        elif args_dict['sql']['task_status'] == 'complete':
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

def run_benchmark(stream, sequence, task_uuid, inp_json):
    worker_pid=mp.current_process().pid
    scale = inp_json['scale']
    tpc_benchmark = inp_json['function']

    proc_dict[worker_pid] = {
        'task_uuid' : task_uuid,
        'stream' : stream,
        'scale' : scale,
        'benchmark' : tpc_benchmark,
        'json_args' : inp_json
    }

    schema = f"{tpc_benchmark}_{scale}"
    working_dir = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks'

    iamconnectioninfo = IamConnection()
    with connect(database=iamconnectioninfo.db,
                 host=iamconnectioninfo.hostname_plus_port,
                 user=iamconnectioninfo.username,
                 password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        cursor.execute('select pg_backend_pid()')
        autorun_pid = int("".join(
            filter(str.isdigit, str(cursor.fetchone()))))
        cursor.execute(f'set search_path to {schema};set enable_result_cache_for_session to false')
        for i, query in enumerate(sequence):
            sql_file = f'{stream}.query{query}.sql'
            sql_path = f'{working_dir}/{tpc_benchmark}/streams/{scale}/{stream}/{sql_file}'
            sql = open(sql_path, 'r').read()
            exec_info = dict(type='insert',task_uuid=task_uuid,client_starttime=f'to_timestamp({time.time()})',sql_path=sql_path,pid=autorun_pid,stream=stream,stream_ident=i,query=sql_file,tpc_benchmark=tpc_benchmark,scale=scale)
            postgres_writer_queue.put(exec_info)
            cursor.execute(f"set query_group to '{stream}.query{query}.sql';{sql}")
            exec_info = dict(type='update',task_uuid=task_uuid,stream_ident=i,client_endtime=f'to_timestamp({time.time()})')
            postgres_writer_queue.put(exec_info)
    return worker_pid


def callback(worker_pid):
    worker_queue.get()
    task_uuid = proc_dict[worker_pid]['task_uuid']
    del proc_dict[worker_pid]

    # All workers are done, update task status and tell the parent process to process next queued task if applicable
    if worker_queue.empty() is True:
        # tell postgres writer to summarize the run async
        pg_writer_args = {'type': 'summarize','task_uuid': task_uuid}
        postgres_writer_queue.put(pg_writer_args)
        task_status = {'type': 'update', 'uuid': task_uuid, 'sql': {'task_status': 'complete'}}
        # mark task completed
        update_task_status(task_status)
        path = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts'
        task_uuid, queued_json = get_queued_task()
        if task_uuid is not None:
            # key to be checked in order to prevent infinite loop of task
            queued_json['already_queued'] = ''
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(f'{path}/queryrunner.socket')
            sock_msg = str(queued_json).replace("'",'"').encode('UTF-8')
            s.send(sock_msg)
            s.close()


def supported_functions():
    switch = {
        'tpcds': run_benchmark,
        'tpch': run_benchmark
    }
    return switch

def postgres_writer():
    while True:
        msg = postgres_writer_queue.get()
        with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
            cursor = conn.cursor()
            if msg["type"] == 'insert':
                sql = f"""INSERT INTO benchmark_query_status(task_uuid,tpc_benchmark,scale,stream,pid,query_order_in_stream,benchmark_query_template,template_file_path,client_starttime) values('{msg["task_uuid"]}','{msg["tpc_benchmark"]}','{msg["scale"]}','{msg["stream"]}','{msg["pid"]}','{msg["stream_ident"]}','{msg["query"]}','{msg["sql_path"]}',{msg["client_starttime"]})"""
                cursor.execute(sql)
            if msg["type"] == 'update':
                cursor.execute(
                    f"""UPDATE benchmark_query_status SET client_endtime={msg["client_endtime"]} where task_uuid='{msg["task_uuid"]}' and query_order_in_stream='{msg["stream_ident"]}'"""
                )
            if msg["type"] == 'summarize':
                task_uuid = msg['task_uuid']
                cursor.execute(f"select distinct pid from benchmark_query_status where task_uuid = '{task_uuid}'")
                ret = CursorByName(cursor)
                pidlist = ''
                for row in ret:
                    pidlist += str(row['pid']) + ','
                pidlist = pidlist[:-1]
                summarize_benchmark(pidlist, task_uuid)
        conn.close()


def dict_has_key(dict, key):
    if key in dict:
        return True
    return False


def get_queued_task():
    # return the task_uuid and json arguments for the oldest non-started task
    task_uuid = None
    task_json = None
    with connect(dbname='postgres',host='0.0.0.0',user='postgres') as conn:
        cursor = conn.cursor()
        # Get the task_uuid and request json for the top item in the queue
        cursor.execute('select task_uuid,task_request from task_status where task_request_time in (select max(task_request_time) from task_status where task_start_time is null)')
        ret = CursorByName(cursor)
        for row in ret:
            task_uuid = row['task_uuid']
            task_json = row['task_request']
    return task_uuid, task_json


if __name__ == '__main__':

    # call benchmarkloadrunner.py function which both loads data/runs power query for tpch/ds
    # TODO: Come up with mechanism to prevent benchmarkloadrunner from always running when query-runner starts
    benchmark_auto_run()

    path = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts'

    if os.path.exists(f'{path}/queryrunner.socket'):
        os.remove(f'{path}/queryrunner.socket')

    serversocket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    serversocket.bind(f'{path}/queryrunner.socket')
    serversocket.listen()

    manager = mp.Manager()
    proc_dict = manager.dict()
    postgres_writer_queue = manager.Queue()
    # define input queues
    pool = mp.Pool(processes=40)
    pool.apply_async(postgres_writer)
    # queue for determining if an inflight task is done
    worker_queue = mp.SimpleQueue()

    while True:
        clientsocket, addr = serversocket.accept()

        msg = clientsocket.recv(16384).decode()
        inp_json = json.loads(msg)

        # verify function is supported
        functions = supported_functions()
        function_name = inp_json['function']
        concurrency = inp_json['concurrency']

        try:
            if function_name not in functions:
                raise ValueError
        except ValueError:
            clientsocket.send(f"Supplied function '{function_name}'is not supported".encode('UTF-8'))
            clientsocket.close()
            continue

        clientsocket.close()

        if not dict_has_key(inp_json, 'already_queued'):
            json_formatted = str(inp_json).replace("'",'"')
            sql_dict = dict(task_name=function_name,task_version='1.0',task_path=f'{path}/query-runner.py',task_concurrency=concurrency,task_status='queued',task_request=json_formatted)
            task_status = dict(type='insert',sql=sql_dict)
            update_task_status(task_status)

        if worker_queue.empty() is True:
            task_uuid, queued_json = get_queued_task()
            sql_dict = dict(task_status='active')
            task_status = dict(type='update',uuid=task_uuid,sql=sql_dict)
            update_task_status(task_status)

            for stream in sorted(streams[function_name].keys())[:concurrency]:
                pool.apply_async(functions[function_name], (stream, streams[function_name][stream], task_uuid, inp_json), callback=callback)
                worker_queue.put(True)