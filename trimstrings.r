maintest
{
  foreach (*hier in split (*rescHier,'/')) 
  {
    *hier = trim_surrounding_whitespace(*hier)
    *n = top_or_next_lowest_in_resc_hier (*hier)
    writeLine("stdout","top or next lowest node in [*hier] : *n")
  }
}

trim_trailing_whitespace(*strg) 
{
    msiStrlen(*strg,*ln)
    *ln = int(*ln)
    *s = ""
    if (*ln > 0) { msiSubstr(*strg,str(*ln-1),"1",*s) }
    while (*ln > 0 && (*s == "\t" || *s == " " || *s == "\n")) {
      *ln = *ln - 1
      # chop off last character and get new last character
      msiStrchop(*strg,*tmp) 
      *strg = *tmp
      if (*ln > 0) {msiSubstr(*strg,str(*ln-1),"1",*s)} else {*s = ""}
    }
*strg
}

trim_leading_whitespace(*strg) 
{
    msiStrlen(*strg,*ln)
    *ln = int(*ln)
    *s = ""
    if (*ln > 0) { msiSubstr(*strg,"0","1",*s) }
    while (*ln > 0 && (*s == "\t" || *s == " " || *s == "\n")) {
      *ln = *ln - 1
      # chop off first character and get new first character
      msiSubstr(*strg, "1", str(*ln), *tmp)
      if (*ln > 0) { msiSubstr(*tmp,"0","1",*s) } else { *s="" }
      *strg = *tmp
    }
*strg
}

trim_surrounding_whitespace(*strg) {
  trim_leading_whitespace( trim_trailing_whitespace( *strg ))
}

top_or_next_lowest_in_resc_hier(*hier_string) 
{
  *getL = trimr(*hier_string,";")
  *getR = triml(*getL,";") # here, if getL = getR then root is only element left
  while (*getR != *getL) { # if getR has ';', peel off left elements
    *getL = *getR
    *getR = triml(*getR,";")
  }
*getR # retval
}

input *rescHier=$'  root;cmp;cch / root;a;cmp2;arc2  / cmp3;cch3 / root '
output ruleExecOut
