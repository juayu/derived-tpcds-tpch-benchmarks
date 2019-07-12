#!/usr/bin/python3

import socket
import sys, json

def is_valid_json(myjson):
  try:
    json.loads(myjson)
  except ValueError:
    return False
  return True

if len(sys.argv) != 2:
  print("Requires single argument which is the runner_functionion name in the query runner. Arguments can be passed to stdin as json")
  exit(1)

json_arg=''
# Verify is stdin exists
is_not_stdin = sys.stdin.isatty()
if is_not_stdin is False:
  json_arg = sys.stdin.read()


if is_valid_json(json_arg) is False and is_not_stdin is False:
  print('Invalid Json passed to stdin')
  print(json_arg)
  exit(1)

runner_function = str(sys.argv[1]+'|')

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.connect('./queryrunner.socket')

if is_not_stdin is False:
  s.send(runner_function.encode('UTF-8'))
else:
  s.send(runner_function.encode('UTF-8'))
  s.send(json_arg.encode('UTF-8'))

s.close()