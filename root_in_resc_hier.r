main{
  *root_resc = root_in_resc_hier(*hierstring)
  writeLine("stdout","extracted root of hier -> [*root_resc]")
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

INPUT *hierstring=$"pt1;cmp;cch"
OUTPUT ruleExecOut
