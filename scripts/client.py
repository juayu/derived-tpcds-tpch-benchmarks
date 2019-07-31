#!/usr/bin/python3

import socket
import argparse
import json
from voluptuous import Schema, Required, All, Length, MultipleInvalid

schema = Schema({Required('json'): All(str, Length(min=4))})

parser = argparse.ArgumentParser()
parser.add_argument(
    '--json',
    help=
    'Please provide a single json object surrounded by single quotes (e.g python client.py --json \'{"function":"tpcds"}\'). TODO: Required attributes in the json/reference goes here',
    required=True)
json_conf = vars(parser.parse_args())

try:
    schema(json_conf)
except MultipleInvalid as e:
    raise e

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
path = '/home/ec2-user/SageMaker/derived-tpcds-tpch-benchmarks/scripts'

s.connect(f'{path}/queryrunner.socket')

s.send(json_conf['json'].encode('UTF-8'))

out_json = json.loads(json_conf['json'])

# TODO: determine when it is appropriate for the runner to send messages back to the client.
if out_json['function'] == 'status':
    ret = s.recv(16384).decode()
    print(ret)

s.close()
