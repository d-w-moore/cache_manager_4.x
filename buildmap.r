testmain {

    build_root_lookup(*m)

    foreach (*n in *m) {
        *rt = *m.*n
        writeLine("stderr", "compound [*n] has root: [*rt]")
    }

}

build_root_lookup(*map)
{
  msiString2KeyValPair("",*map)
  foreach (*c in select RESC_TYPE_NAME,RESC_NAME where RESC_TYPE_NAME = 'compound')
  {
      *n = *c.RESC_NAME
      trace_hier(*n,*m11,*p)
      *map.*n = root_in_resc_hier(*p)
      writeLine("stderr"," compound - *n ")
  }
}


# -- copied in, nominally changed: -- dwm--
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

# -- this is for iRODS 4.1:
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

INPUT  null
OUTPUT ruleExecOut
