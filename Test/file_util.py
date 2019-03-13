from __future__ import print_function
from iRODS_util import ( get_session,
                         split_path,
                         get_iRODS_home
                       )
import getopt
import sys, os


def get_data_obj_by_name( name ):
    s = get_session() 
    n = iRODS_home() + '/' + name
    s.get(n)

def put_data_obj_in_resc( localpath, resc ):
    s = get_session()
    (dirN, baseN) = split_path(localpath, os.path.abspath)
    #print ('basename =',   baseN )
    #print ('dirname  =',   dirN)
    if s:
        s.data_objects.put(  localpath, get_iRODS_home() + "/" + baseN , destRescName = resc )

if __name__ ==  '__main__':
    if len(sys.argv[1:])  >= 2:
        put_data_obj_in_resc ( sys.argv[1], resc=sys.argv[2] )
    else: print("need 2 args",file=sys.stderr); sys.exit(2)
