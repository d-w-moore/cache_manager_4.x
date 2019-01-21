maintest {
    find_compound_children (*inpId, *inpNm, *i,*n, *ctx)
    writeLine('stdout','i = *i ; n = *n ; ctx = *ctx')
}
#                                i        i       o    o   i '' or 'ch' or "cache" or "archive"
find_compound_children (*idcld , *nmcld, *id, *nm, *cx) 
{
  *cx=list()
  *id=list()
  *nm=list()
  *ptemp = ''

  foreach (*p in select RESC_NAME,RESC_PARENT where RESC_NAME = '*nmcld') { *ptemp = *p.RESC_PARENT }
  if (*ptemp == '') {
      foreach (*p in select RESC_ID,RESC_PARENT where RESC_ID = '*idcld') { *ptemp = *p.RESC_PARENT }
  }
  *parent = ''
  if (*ptemp != '') {
     foreach (*q in select RESC_ID,RESC_NAME where RESC_TYPE_NAME = 'compound') { 
#       # 4.2
        if (*q.RESC_ID == "*ptemp") {*parent = "*ptemp"}
#       # 4.1
#       #if (*p.RESC_NAME == *ptemp) {*parent = *ptemp}
     }
  }

   if (*parent != '') {
      foreach (*r in  select RESC_ID,RESC_NAME,RESC_PARENT_CONTEXT where RESC_PARENT = '*parent') {
         *cx = cons(*r.RESC_PARENT_CONTEXT,*cx)
         *id = cons(*r.RESC_ID , *id)
         *nm = cons(*r.RESC_NAME , *nm)
      }
   }
   *parent
}

input *inpNm=$'',*inpId=$''
output ruleExecOut
