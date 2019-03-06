testmain {
   trace_hier(*cchname,*m,*h)
   *l = trace_hier(*cchname,*m,*h)
   writeLine ("stdout", "list [*l] map [*m] hier [*h]")
   if (*syncObj != '')  {
       msiSplitPath(*syncObj,*coll,*basen)
       writeLine("stdout","[*coll] [*basen]")
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
                               and DATA_RESC_HIER like '%;*cchname')
             {
               *cache_replnum = *getrepl.DATA_REPL_NUM
             }
             if (*cache_replnum != '') {
               writeLine("stdout","TRIM repl from CACHE: number is " ++ "*cache_replnum")
               msiDataObjTrim('*C/*D','null','*cache_replnum','1','1',*trim_status)
               writeLine("stdout","--- trim status = [*trim_status]")
             } else { writeLine("stdout", "************** NULL cache replnum ******************") }
           }
       } else {
         writeLine("stdout","skipping ...")
       }
       writeLine("stdout","commands - msisync_to_archive('*h', '*P', '*C/*D')")
       writeLine("stdout","           msiDataObjTrim('*C/*D','null','*cache_replnum','1','1',\*trim_status)")
   }
}

trace_hier(*cname,*map,*hier) {
  msiString2KeyValPair( "", *lin )
  msiString2KeyValPair( "", *par)
  msiString2KeyValPair( "", *id2n )
  msiString2KeyValPair( "", *n2id )
  msiString2KeyValPair( "", *map )
  foreach (*y in select RESC_NAME,RESC_ID,RESC_PARENT) {
     *name = *y.RESC_NAME
     *parent = *y.RESC_PARENT
     *idnum = *y.RESC_ID
     *lin."*name" = "*parent"
     *id2n."id_*idnum" = *name
     *n2id."*name" = "*idnum"
     *par.*name = *parent
  }

  ## writeLine("stderr", "par = *par")
  ## writeLine("stderr", "\n----------id2n:")
  foreach (*z  in *id2n ) {
    *nam = *id2n."*z"
    ## writeLine ("stderr", "*z -> *nam ")
  }

  ## == convert ; par holds id, not name , if vsn >= 42

  ##writeLine("stderr", "----------(par->map):")
  foreach (*z  in *par ) {
      *hold = *par.*z
      *nm = *hold
      if (*vsn >= 42) { 
          #writeLine("stderr", " [*z] id_*hold") 
          if (*hold != "") { *nm = *id2n."id_*hold" } 
      }
      ## writeLine ("stderr"," *z *hold *nm")
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

# irule -F  SimpleGH_42w41.r "*cchname='cch'" "*vsn=41" "*syncObj='/tempZone/home/rods/aa'" 2>/dev/null

input *cchname=$'',*vsn=$42, *syncObj=$'', *doSync=$0
output ruleExecOut

