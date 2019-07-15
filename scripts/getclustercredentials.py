#!/usr/bin/env python3

import sys
from iamconnectioninfo import IamConnection

if len(sys.argv) != 4 :
	print("Invalid number of arguments. Usage: ./getclustercredentials.py cluster_identifier db_user db_name")
	sys.exit(1)

cluster_identifier=sys.argv[1]
db_user=sys.argv[2]
db_name=sys.argv[3]

iam_info = IamConnection(cluster_identifier, db_user, db_name)
ret_val = f'{iam_info.username} {iam_info.password}'

print(ret_val)

