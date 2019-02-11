trace_hier(*cname,*map,*hier) 
{
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
##    if (*vsn >= 42) { 
##        if (*hold != "") { *nm = *id2n."id_*hold" } 
##    }
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

root_in_resc_hier(*h)
{
  *r = *h
  *t = triml(*h,';')
  if (*t != *h) {
    msiStrlen(*h, *hl)
    msiStrlen(*t, *tl)
    msiSubstr(*h,"0",str(int(*hl)-int(*tl)-1),*r)
  }
*r
}

