from __future__ import  print_function
import os, sys
from irods.session import iRODSSession


def split_path ( path , path_op = lambda x : x):
    modpath = path_op (path) 
    return [ f(modpath) for f in ( os.path.dirname, os.path.basename ) ]

# == module globals

session = None
Debug = False

#--------------------------------------------------------------------------------

def connect_to_iRODS():
    try:
        env_file = os.environ['IRODS_ENVIRONMENT_FILE']
    except KeyError:
        env_file = os.path.expanduser('~/.irods/irods_environment.json')
    s = iRODSSession(irods_env_file=env_file) 
    return s

def get_session():
    global session
    old_ses = session
    if session is None:
        session = connect_to_iRODS()
    if (session is not None) and (old_ses is None):
        import atexit
        @atexit.register
        def f():
            global session
            s = session; session = None
            s.cleanup()
            if Debug: print("cleaning up iRODS session object.",file=sys.stderr)
    return session

def get_iRODS_home( ses = None ) :
    ses = (ses or session)
    if ses is not None:  return '/{}/home/{}'.format(ses.zone,ses.username)
    raise RuntimeError('No iRODS connection exists ')

