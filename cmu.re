# -- config

IRodsVersion() { 41 }

	#---#

trace_hierarchy (*cname,*map,*hier)
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

	#---#

list_get_str (*L, *i) {
  if (*i < 0) { *i = size(*L) + *i }
  if (*i < size(*L) && *i >= 0) then
      str(elem(*L,*i))
  else
      ""
}
	#---#

is_compound (*resc_name) {
    *found = false
    foreach (*n in select RESC_NAME
     where RESC_TYPE_NAME = 'compound' 
     and RESC_NAME = '*resc_name') 
    {
      *found = true
    }
*found
}


        # note -- dwm -- :  for "partial hierarchy" ending in compoundName
	# feed result of this routine to is_compound()
        # -  if this fails, add ";*" to end, repeat is_compound()

top_or_next_lowest_in_resc_hier (*hier_string)
{
  *getL = trimr(*hier_string,";")
  *getR = triml(*getL,";") # here, if getL = getR then root is only element left
  while (*getR != *getL) { # if getR has ';', peel off left elements
    *getL = *getR
    *getR = triml(*getR,";")
  }
*getR # retval
}
	#---#

reverse_list (*L) 
{
  *s=size(*L)
  *M=list()
  for (*i=0; *i<*s; *i = *i + 1) { *M=cons(elem(*L,*i),*M) }
  *M
}
	#---#

unset_All_meta_on_compound_resc (*resc_name)
{
    msiString2KeyValPair("",*kvp)
    foreach (*rm in select META_RESC_ATTR_NAME, META_RESC_ATTR_VALUE
     where RESC_NAME = '*resc_name' and RESC_TYPE_NAME = 'compound') 
    {
        *Key = *rm.META_RESC_ATTR_NAME
        *kvp.*Key = *rm.META_RESC_ATTR_VALUE
    }
    *x = errorcode(msiRemoveKeyValuePairsFromObj( *kvp, *resc_name, "-R"))
*x==0;
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

trim_trailing_whitespace (*strg) 
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

trim_leading_whitespace (*strg) 
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

trim_surrounding_whitespace (*strg) {
  trim_leading_whitespace( trim_trailing_whitespace( *strg ))
}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# =-=-= strip off ws, *tag and '=' writing rhs value into *val  =-=-=
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

get_context_value (*tag_eq_val , *tag , *val ) 
{
    *success = false
    *kv = trim_leading_whitespace (*s)
    msiStrlen( *kv, *kvlen )
    msiStrlen( *tag, *taglen )
    *eq_rhs = triml (*kv, *tag)
    msiStrlen( *eq_rhs, *eq_rhs_len )
    if (int(*eq_rhs_len) + int(*taglen) == int(*kvlen))
    {
        *eqtrim = trim_leading_whitespace(*eq_rhs)
        msiStrlen(*eqtrim,*eqtrimLen)
        *rhs = triml(*eqtrim,"=")
        msiStrlen(*rhs,*rhsLen)
        if (int(*rhsLen) + 1 == int(*eqtrimLen)) {
            *val = *rhs
            *success = true
        }
    }
*success ;
}
