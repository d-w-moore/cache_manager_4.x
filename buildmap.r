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

INPUT  null
OUTPUT ruleExecOut
