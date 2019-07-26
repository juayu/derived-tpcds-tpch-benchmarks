import multiprocessing as mp
import socket
import os
import json
import datetime
import time
from icecream import ic
from benchmarkloadrunner import benchmark_auto_run
from iamconnectioninfo import IamConnection
from pgdb import connect

streams = {
    'power': [
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
        37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
        54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
        71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87,
        88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99
    ],
    'stream_0': [
        1,2,3
    ],
    'stream_1' : [
        4,5,6
    ]
}


def worker(queue):
    inp_json = json.loads(queue)
    function_name = inp_json['function']

    switch = {'tpcds': tpcds, 'tpch': tpch}
    switch[function_name](inp_json)
    return


def tpcds(inp_json):
    ic(f"start {datetime.datetime.utcnow()} {mp.current_process().pid}")
    print(inp_json)


def benchmark_worker(stream_queue):
    print('hi')



def tpch(inp_json):
    return inp_json


if __name__ == '__main__':

    # call benchmarkloadrunner.py function which both loads data/runs power query for tpch/ds
    #benchmark_auto_run()

    path = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts'
    if not os.path.exists(path):
        path = '/Users/bschur/RedshiftGoldStandard/scripts'

    if os.path.exists(f'{path}/queryrunner.socket'):
        os.remove(f'{path}/queryrunner.socket')

    serversocket = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

    serversocket.bind(f'{path}/queryrunner.socket')
    serversocket.listen()

    # define input queues
    pool = mp.Pool(processes=3)

    while True:
        clientsocket, addr = serversocket.accept()
        msg = clientsocket.recv(4096).decode()
        clientsocket.close()
        print('before apply async')
        # parse results and pass to function
        ## get out concurrency from json object

        for stream in streams:
            pool.apply_async(worker, args=(stream,), cbk)




        #print(f"{datetime.datetime.utcnow()} end | pid = {mp.current_process().pid}")

