testmain{
  trace_hier(*cchname,*iRodsVsn,*h)
   *l = trace_hier(*cchname,*m,*h)
   writeLine ("stdout", "list [*l] map [*m] hier [*h]")
   if (*syncObj != '') {
       msiSplitPath(*syncObj,*coll,*basen)
           writeLine("stdout","[*coll] [*basen]")
       foreach (*x in select DATA_PATH,DATA_NAME,COLL_NAME,DATA_REPL_NUM where DATA_RESC_HIER = '*h'
                              and COLL_NAME = '*coll' and DATA_NAME = '*basen')
       {
           *P = *x.DATA_PATH
           *C=*x.COLL_NAME
           *D=*x.DATA_NAME
           writeLine("stdout","repl_num = " ++ *x.DATA_REPL_NUM ++ " - *C/*D on [*h]" )
       }
       if (*doSync != 0) {
         *status = msisync_to_archive("*h", "*P", "*C/*D")
         writeLine("stdout","--- sync status = [*status]")
       } else {
         writeLine("stdout"," msisync_to_archive(*h, *P, *C/*D)")
       }
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

  foreach (*z  in *id2n ) {
    *nam = *id2n."*z"
  }

  foreach (*z  in *par ) {
      *hold = *par.*z
      *nm = *hold
      if (*vsn >= 42) {
          if (*hold != "") { *nm = *id2n."id_*hold" }
      }
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

input *cchname=$'',*iRodsVsn=$42, *syncObj=$'', *doSync=$0
output ruleExecOut
