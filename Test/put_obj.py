from __future__ import print_function
from iRODS_util  import ( get_session_object, 
                          split_path
                        )
import sys, os

s = get_session_object()

arg = sys.argv[1:] and sys.argv[1]

if arg:

    (dirN, baseN) = split_path(arg, os.path.abspath)
    print ('basename =',   baseN )
    print ('dirname  =',   dirN)
    if (s)

else:
    print( 'need one argument, the filename')
    sys.exit(1)


