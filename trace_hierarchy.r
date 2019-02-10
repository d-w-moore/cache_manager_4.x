testmain {

   *l = irf_trace_hierarchy(*cchname,*m,*h)
   writeLine("stdout","*h")
   if (*syncObj == '')  {
       *irodsvsn = IRodsVersion
       writeLine("stdout", "test irods vsn value = " ++ str(*irodsvsn) )
       writeLine("stdout", "test irods vsn type =  " ++ type(*irodsvsn) )
   }
   else {

       msiSplitPath(*syncObj,*coll,*basen)

       *P = ''

       foreach (*x in select DATA_PATH,DATA_NAME,COLL_NAME,DATA_REPL_NUM where DATA_RESC_HIER = '*h' 
                              and COLL_NAME = '*coll' and DATA_NAME = '*basen')
       {
           *P=*x.DATA_PATH
           *C=*x.COLL_NAME
           *D=*x.DATA_NAME
           writeLine("stdout","repl_num = " ++ *x.DATA_REPL_NUM ++ " - *C/*D on [*h]" )
       }

       if (*P != '' && *doSync != 0) {
         *sync_status = msisync_to_archive("*h", "*P", "*C/*D")
         writeLine("stdout","--- sync status = [*sync_status]")
           if (*sync_status == 0 && *doSync > 1) {
             *trimStatus = -999
             *cache_replnum = ''
#            # -- get cache repl_num for trim
             foreach (*getrepl in select DATA_REPL_NUM
                               where DATA_NAME = '*D' and COLL_NAME = '*C'
                               and DATA_RESC_NAME = '*cchname')
             {
               *cache_replnum = *getrepl.DATA_REPL_NUM
             }
             if (*cache_replnum != '') {
               writeLine("stdout","TRIM repl from CACHE: number is " ++ "*cache_replnum")
               msiDataObjTrim('*C/*D','null','*cache_replnum','1','1',*trim_status)
               writeLine("stdout","--- trim status = [*trim_status]")
             }
           }
       } else {
         writeLine("stdout","skipping ...")
       }
   }
}

irf_trace_hierarchy (*cname,*map,*hier)
{
  msiString2KeyValPair( "", *parent)
  msiString2KeyValPair( "", *id2n )
  msiString2KeyValPair( "", *n2id )
  msiString2KeyValPair( "", *map )

  foreach (*y in select RESC_NAME,RESC_ID,RESC_PARENT) {
     *name = *y.RESC_NAME
     *parent.*name = *y.RESC_PARENT
     *idnum = *y.RESC_ID
     *id2n.*idnum = *name
     *n2id.*name = *idnum
  }

  foreach (*z  in *parent ) {
      *tmp = *parent.*z  # __ in irods <= 41 this is a resource name,
      *nm = *tmp         #    but in irods >= 42 it's a numeric ID
      if (IRodsVersion() >= 42 && *tmp != "") { *nm = *id2n.*tmp }
      *map.*z = *nm
  }

  *lst = list()
  *hier = ""
  *p ="*cname"
  while(*p != "") {
      if (*hier == "") { *hier = *p }
      else { *hier = *p ++ ";" ++ *hier }
      *id = *n2id.*p
      *lst = cons(*id,*lst)
      *p = *map.*p
  }

*lst
}

IRodsVersion() { *vsn }

# try with args "*cchname='$RNAME'" "*vsn=41" "*syncObj='/tempZone/home/rods/myfile'"

input *cchname=$'',*vsn=$42, *syncObj=$'', *doSync=$0
output ruleExecOut

