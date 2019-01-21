main {
  *r=""; 
  *n="";
  test (*dpath,*rescRoot,*r,*n)
}
test (*dp, *r,  *role, *nfound ) {
    msiSplitPath(*dp,*C,*D)
    *Did = ""
    *hierlist = list()
    foreach (*p in select DATA_NAME,COLL_NAME,RESC_HIER where
     RESC_HIER like '*rescRoot;%' and DATA_NAME = "*D" and COLL_NAME = '*C')
    {
         *Did = *p.DATA_ID
         *hierlist = cons(*p.RESC_HIER, *hierlist)
    }
    if (*debug != '') { writeLine("stdout","results of query = ") }
    writeLine("stdout"," did = *Did , Hier list = *hierlist " )
    msisync_to_archive("*CacheRescName","*P","*C/*D" );
    *hierlist
}
input  *dpath='',*debug='0'
output ruleExecOut
