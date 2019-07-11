import multiprocessing as mp
import socket
import os
import json
from iamconnectioninfo import IamConnection
from pgdb import connect


def is_json_argument_required(i):
    options = {
            'tpch': True,
            'tpcds': True
            #'burst': True,
            # ...
            # ...
          }
    return options[i]


def worker(queue):
    while True:
        msg = queue.get()

        func_name = msg[0]
        args = msg[1]
        has_argument = is_json_argument_required(func_name)

        if has_argument is True and args == '':
            # Json argument is required for given function name but it was not supplied
            # exit(1)
            queue.task_done()

        if has_argument is True:
            eval(func_name+'(' + args + ')')
        else:
            eval(func_name+'()')

        queue.task_done()

def tpcds():
    iamconnectioninfo = IamConnection()
    with connect(database=iamconnectioninfo.db, host=iamconnectioninfo.hostname_plus_port, user=iamconnectioninfo.username,
                 password=iamconnectioninfo.password) as conn:
        cursor = conn.cursor()
        cursor.execute('select current_user')
        print(cursor.fetchall())
    #  do whatever
    #  sql = open('/path/to/sql', 'r')
    #  cursor.execute(sql.read())


def tpch(args):
    args_json = json.loads(json.dumps(args))
    print(args_json["quiz"]["sport"])


if __name__ == '__main__':

    # Cannot bind if socket exist
    if os.path.exists('./queryrunner.socket'):
        os.remove('./queryrunner.socket')

    serversocket = socket.socket(
        socket.AF_UNIX, socket.SOCK_STREAM)

    serversocket.bind('./queryrunner.socket')

    # queue up to 10 socket connections
    serversocket.listen(10)

    # define input queues
    queue = mp.JoinableQueue()

    while True:
        clientsocket, addr = serversocket.accept()
        msg = clientsocket.recv(4096)
        inp = msg.decode().split('|', 1)
        clientsocket.close()
        queue.put(inp)

        processes = []
        num_workers=1
        for i in range(num_workers):
            worker_process = mp.Process(target=worker, args=(queue,), daemon=True, name='worker_process_{}'.format(i))
            worker_process.start()
            processes.append(worker_process)

        queue.join()