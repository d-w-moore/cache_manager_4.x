#!/usr/bin/env python

from __future__ import  print_function
import itertools
from pprint import pprint
import os, sys
from irods.session import iRODSSession
import irods.keywords as kw
import atexit

import session_util

try:
    env_file = os.environ['IRODS_ENVIRONMENT_FILE']
except KeyError:
    env_file = os.path.expanduser('~/.irods/irods_environment.json')

def getBasenameOfFilePath(path):
  return  os.path.basename( os.path.abspath(path) ) 

session = iRODSSession(irods_env_file=env_file) 

@atexit.register
def session_cleanup():
    global session
    s = session; session = None
    s.cleanup()

