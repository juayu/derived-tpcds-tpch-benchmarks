import multiprocessing as mp
import socket
import os
import json
from benchmarkloadrunner import benchmark_auto_run
from iamconnectioninfo import IamConnection
from pgdb import connect


def worker(queue):
    while True:
        inp_json = json.loads(queue.get())
        function_name = inp_json['function']

        switch = {'tpcds': tpcds, 'tpch': tpch}
        switch[function_name](inp_json)
        queue.task_done()


def tpcds(inp_json):
    # This is just to show how to connect once in the function
    iamconnectioninfo = IamConnection()
    with connect(database=iamconnectioninfo.db,
                 host=iamconnectioninfo.hostname_plus_port,
                 user=iamconnectioninfo.username,
                 password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        cursor.execute('select current_user')
        print(cursor.fetchall())


def tpch(inp_json):
    return inp_json


if __name__ == '__main__':

    # call benchmarkloadrunner.py function which both loads data/runs power query for tpch/ds
    benchmark_auto_run()
    exit(1)

    path = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts'
    if not os.path.exists(path):
        path = '/Users/bschur/RedshiftGoldStandard/scripts'

    if os.path.exists(f'{path}/queryrunner.socket'):
        os.remove(f'{path}/queryrunner.socket')

    serversocket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    # TODO: plan is to make this non blocking, need to test
    serversocket.bind(f'{path}/queryrunner.socket')

    # queue up to 10 socket connections
    serversocket.listen(10)

    # define input queues
    inp_queue = mp.JoinableQueue()

    while True:

        clientsocket, addr = serversocket.accept()
        msg = clientsocket.recv(4096).decode()
        clientsocket.close()
        inp_queue.put(msg)

        processes = []
        num_workers = 1
        for i in range(num_workers):
            worker_process = mp.Process(target=worker,
                                        args=(inp_queue, ),
                                        daemon=True,
                                        name='worker_process_{}'.format(i))
            worker_process.start()
            processes.append(worker_process)

        inp_queue.join()
