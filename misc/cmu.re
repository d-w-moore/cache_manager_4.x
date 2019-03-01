# -- begin configuration

IRodsVersion { 41 }

cache_task_reserve_key { "irods_cache_mgt::reserve_resc" }

threshold_for_delay_trim { ( 1000.0 ^ 2 ) * 500.0 } # bytes

default_trim_age { 86400 }

# -- end configuration

unique_string(*rand_32_bit_int)
{
  msiGetSystemTime(*tm,"unix")
  *bignum = 2^24
  *uniq = int(*tm)%int(*bignum)
str(double("*rand_32_bit_int")*(*bignum) + *uniq);
}

launch_prune_operation(*resc)
{
  get_cmdline_tokens(*U,*S)
  writeLine("stdout","[*U] [*S]")
  if (double(*U) == 0) {
    *S="serverLog"
    delay("<PLUSET>1s</PLUSET><EF>30s</EF>"){
      prune_cache_test (*resc, unique_string(*U), "10")  #stream
    }
  }
  else {
      prune_cache_test (*resc, unique_string(*U), "10")  #stream
  }
}
## -> a mini-test of the real prune_cache routine

prune_cache_test(*comp_resc,*unique,*waitsecs)
{
    *stream = (if int(*unique) == 0 then "stdout"  else "serverLog")
    *waitSec = (if "*waitsecs" == "" then "0" else "*waitsecs")
    if (set_meta_on_compound_resc (*comp_resc, *kvp, *unique))
    {
        #msiSleep("*waitSec","0")
        for (*i=0;*i<2;*i=*i+1) {
            msiSleep(str( int(int("*waitSec")/2)) ,"0")
            #writeLine("*stream","--> [*i] loop")
            if (*i == 0 && 0 > test_meta_on_compound_resc(*comp_resc, *kvp, *unique)) { break }
        }
    }
    unset_meta_on_compound_resc (*comp_resc, *kvp)
}

prune_cache_for_compound_resource_LRU ( *comp_resc, *unique, *stream )
{
    # 1 ) lock resource and test successful, unlock if not

    if (set_meta_on_compound_resc (*comp_resc, *kvp, *unique)) {

        msiGetIcatTime(*current_time , "unix")
        *context_list = get_context_string_elements_for_resc (*comp_resc)
        *age_off_seconds = default_trim_age()
        *bytes_usage_threshold  = -1.0;

        foreach ( *element in *context_list ) {
            if (get_context_value (*element, "irods_cache_mgt::trim_minimum_age",*age_off_seconds_str)) {
                *age_off_seconds = int(abs(int(*age_off_seconds_str)))
            }
            else if (get_context_value (*element, "irods_cache_mgt::trim_threshold_usage",*bytes_usage_str)) {
                *bytes_usage_threshold = abs(double(*bytes_usage_str))
            }
        }

    # 2 ) get hierarchy info , data usage in cache, and a list of all data objects stamped with an access time

        trace_hierarchy( *comp_resc, *map, *hier_string)
        find_compound_parent_and_leaf_roles( *comp_resc , false , *roles )
        *full_hier_to_cache =  *hier_string ++ ";" ++ *roles.cache
        *full_hier_to_archive =  *hier_string ++ ";" ++ *roles.archive

        *bytes_used = 0.0
        if (*bytes_usage_threshold  > 0.0 ) {
          foreach (*d in select DATA_ID, DATA_NAME, DATA_SIZE, COLL_NAME, DATA_RESC_HIER
                   where DATA_RESC_HIER = "*full_hier_to_cache")
          {  # check DATA_REPL_STATUS for cache copy?
             *bytes_used = *bytes_used + double( *d.DATA_SIZE )
          }
        }

        if (*bytes_used > *bytes_usage_threshold )
        {
            msiString2KeyValPair("",*archive_repl_status)

            foreach (*ar in select DATA_ID, DATA_NAME, COLL_NAME, META_DATA_ATTR_NAME, order(META_DATA_ATTR_VALUE),DATA_REPL_STATUS
                     where DATA_RESC_HIER = "*full_hier_to_archive" and META_DATA_ATTR_NAME like "irods_cache_mgt::atime::%")
            {
                *dataId = *ar.DATA_ID
                *archive_repl_status.*dataId = *ar.DATA_REPL_STATUS
            }

            foreach (*ch in select DATA_ID, DATA_NAME, COLL_NAME, META_DATA_ATTR_NAME, order(META_DATA_ATTR_VALUE),
                                  DATA_PATH, DATA_SIZE
                     where DATA_RESC_HIER = "*full_hier_to_cache"
                       and META_DATA_ATTR_NAME like "irods_cache_mgt::atime::%")
            {
                *access_time = double(*ch.META_DATA_ATTR_VALUE)
                if (*access_time + *age_off_seconds < *current_time) {
                    *success = is_eligible_for_trim( *comp_resc , *ch.DATA_ID, *ar.DATA_REPL_STATUS );
                    *success = attempt_trim( *comp_resc , *ch.DATA_ID, *ch.DATA_SIZE, *ch.DATA_PATH,
                                             *full_hier_to_cache, *full_hier_to_archive, *errmsg )
                    if (!*success)  {
                        writeLine(*stream , *errmsg)
                    }
                    if (0 > test_meta_on_compound_resc(*comp_resc, *kvp, *unique)) { break }
                }
            }
        }
        msiGetIcatTime(*current_icat_time, "unix")
        tag_atime_on_dataobjs_not_yet_tagged (*full_hier_to_cache, *current_icat_time)
    }
    unset_meta_on_compound_resc (*comp_resc, *kvp)
}

####################
####################

is_eligible_for_trim (*rescName,*dataId,*archStatus) {
  if (*archStatus == '0') {
     #msisync....
  }
#return
  true
}

tag_atime_on_dataobjs_not_yet_tagged ( *cache_hier, *time)
{
	msiString2KeyValPairs("",*all_cache_dataobjs)
        foreach (*d in select DATA_ID, DATA_NAME, COLL_NAME, META_DATA_ATTR_NAME
                 where DATA_RESC_HIER = "*cache_hier"
                 ) {
             *dataId = *d.DATA_ID
             *dataName = *d.DATA_NAME
             *collName = *d.COLL_NAME
             *all_cache_datobjs.*dataId = "*collName/*dataName"
         }
         foreach (*d in select DATA_ID
                  where DATA_RESC_HIER = "*cache_hier" and META_DATA_ATTR_NAME like "irods_cache_mgt::atime::%"
                  ) {
             *dataId = *d.DATA_ID
             *all_cache_datobjs.*dataId = ""
         }
         foreach (*alld in *all_cache_datobjs)
         {
              *logical_path = *all_cache_datobjs.*alld
              if (*logical_path != "") {
                  if (*all_cache_datobjs.*alld != "") {
  	            *k."irods_cache_mgt::atime::*alld" = *time
                    msiSetKeyValuePairsToObj( *k, *logical_path, "-d")
                  }
              }
         }
}

attempt_trim (*compound, *dataid, *datasize, *phys_path,
              *hier_Cache, *hier_Archive, *msgout)
{
    *msgout = ""
    *status = true
    if (double(*datasize) > threshold_for_delay_trim) {
        # *** schedule in delay queue ; leave status true for success
        *msgout = "delayed"
    }
    else {
        *so_far = true
        # attempt a sync-to-archive operation
        #  ... *so_far =  *so_far && (test of operation success)
        # if successful, and archive and cache have good repl's, then attempt trim
        if ( ! *so_far # failure
        ) {
            *status = false
        }
    }
*status
}

get_cmdline_tokens(*Unique,*Stream) {
    *Stream = ""
    *Unique = ""
    *errcode1 = errorcode( { *Unique = str(*uniq)   } )   # gateway and src-of-truth for uniq & strm info
    *errcode2 = errorcode( { *Stream = str(*stream) } ) # entered on command line
    #### $ irule '*e=get_cmdline_tokens(*u,*s);*l=writeLine("stdout","*e/*u/*s")' \
    #               "*uniq=$$%*stream=serverLog" ruleExecOut
    #--> 0/4213/serverLog
if (*errcode1 != 0) then *errcode1 else *errcode2;
}

prune_dummy { writeLine ("serverLog", "dummy_prune_cache_Routine") }

#---

prune_rule_ids_as_string(*pad,*lkstring)
{
    str(prune_rule_ids_as_list(*pad,*lkstring))
}

prune_rule_ids_as_list(*padElements,*likePattern)
{
    if (*likePattern == "") { *likePattern =  "%" }
    *delaylist = if *padElements then list("") else list()
    foreach (*rule in select RULE_EXEC_ID,RULE_EXEC_NAME where RULE_EXEC_NAME like "*likePattern") {
         *delaylist = cons( *rule.RULE_EXEC_ID , *delaylist )
    }
    if (*padElements) { *delaylist=cons("",*delaylist) }
*delaylist;
}
	#---#

trace_hierarchy (*cname,*map,*hier)
{
  msiString2KeyValPair( "", *parent)
  msiString2KeyValPair( "", *id2n )
  msiString2KeyValPair( "", *n2id )
  msiString2KeyValPair( "", *map )

  *irodsvsn = IRodsVersion()

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
      if (*irodsvsn >= 42 && *tmp != "") { *nm = *id2n.*tmp }
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

find_resource_node_types (*kvp,*filter) {
    foreach (*n in select RESC_NAME, RESC_TYPE_NAME)
    {
        *name = *n.RESC_NAME
        *type = *n.RESC_TYPE_NAME
        if (*filter=="" || *filter == *type) {
            *kvp.*name = *type
        }
    }
*kvp
}

enum_compound_resources (*console_stream, *print_busy_tag)
{
    msiString2KeyValPair("",*retval)
    *Key = ""
    if (*print_busy_tag) { *Key = cache_task_reserve_key }
    foreach (*c in select RESC_NAME where RESC_TYPE_NAME = 'compound')
    {
        *n = *c.RESC_NAME
        *Value = ""
        if (*Key!="") {
          foreach (*d in select RESC_NAME, META_RESC_ATTR_NAME, META_RESC_ATTR_VALUE
                   where RESC_NAME = '*n' and META_RESC_ATTR_NAME = '*Key')
          {
            *Value = *d.META_RESC_ATTR_VALUE
          }
        }
        if (*Value != "") {*n = "*n\t*Value"}
        *retval.*n = "*Value"
        if (*console_stream != "") { writeLine("*console_stream","*n") }
    }
*retval
}

is_compound_resource (*name)
{
    find_resource_node_types(*rescl,"compound")
    *flag = false
    foreach (*k in *rescl) {
        if (*k == *name) { *flag = true }
    }
*flag;
}
        # note , for partial hierarchy ending in compoundName:
	# give result of following routine to is_compound_resource(*name)
        #   if , add ";*" to end, repeat is_compound()

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

unset_meta_on_compound_resc( *resc_name, *kvp )
{
    *x = errorcode(msiRemoveKeyValuePairsFromObj( *kvp, *resc_name, "-R"))
    if (*x == 0) { msiString2KeyValPair("",*kvp) }
}

test_meta_on_compound_resc ( *resc_name, *kvp, *test_value )
{
  *match = 0
  *Key = cache_task_reserve_key
  foreach (*x in select RESC_NAME, META_RESC_ATTR_VALUE
           where META_RESC_ATTR_NAME =  '*Key' and RESC_NAME = '*resc_name'
             and META_RESC_ATTR_VALUE = '*test_value' || = '~*test_value' )
  {
    *val = *x.META_RESC_ATTR_VALUE
    msiSubstr(*val,"0","1",*v1st);
    if (*v1st == "~") { *match = -1 } else { *match = 1 }
  }
  #if (*match < 0) {msiString2KeyValPair("*Key=~*test_value",*kvp) }
  if (*match < 1) {msiString2KeyValPair("",*kvp) }
*match
}

set_meta_on_compound_resc ( *resc_name, *kvp, *set_value )
{
   *match = false
   *Key = cache_task_reserve_key

   *rescN = ""
   foreach (*x in select RESC_NAME, RESC_TYPE_NAME
            where RESC_NAME = '*resc_name' and RESC_TYPE_NAME = 'compound')
   {
       *rescN = *x.RESC_NAME
   }

   if (*rescN != "") {
     *kvp."*Key" = "*set_value"
     msiAssociateKeyValuePairsToObj( *kvp, *rescN, "-R")
   }

   *equal = ""       # - must be nonzero length for successful set
   *unequal = list() # - for colliding keys
   foreach (*x in select RESC_NAME, META_RESC_ATTR_VALUE
            where META_RESC_ATTR_NAME =  '*Key' and RESC_NAME = '*resc_name' )
   {
       if (*set_value == *x.META_RESC_ATTR_VALUE) {
           *match = true
       }
       else {
           *unequal = cons( *x.META_RESC_ATTR_VALUE, *unequal)
       }
   }
   if (!*match) { msiString2KeyValPair("",*kvp) }
   # return : bool value (successful metadata set without collision)
   *match && size(*unequal) < 1
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

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

trim_surrounding_whitespace (*strg) {
  trim_leading_whitespace( trim_trailing_whitespace( *strg ))
}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

get_context_string_elements_for_resc (*rescN)
{
  *l = list()
  foreach (*r in select RESC_NAME , RESC_CONTEXT where RESC_NAME = '*rescN')
  {
    foreach (*expr in split(*r.RESC_CONTEXT , ";"))
    {
      *l = cons( *expr , *l)
    }
  }
*l;
}

# =-=-= strip off ws, *tag and '=' writing rhs value into *val  =-=-=
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

get_context_value (*stringElement , *tag , *val )
{
    *success = false
    *keqv = trim_leading_whitespace (*stringElement)
    msiStrlen( *keqv, *keqvlen )
    msiStrlen( *tag, *taglen )
    *eq_rhs = triml (*keqv, *tag)
    msiStrlen( *eq_rhs, *eq_rhs_len )
    if (int(*eq_rhs_len) + int(*taglen) == int(*keqvlen))
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

println (*s) { writeLine("stdout",*s) }

# ===

find_compound_parent_and_leaf_roles(*inpName, *isLeaf, *leaf_lookup)
{
    if (IRodsVersion >= 42)
     then  find_compound_parent_and_leaf_roles_42(*inpName, *isLeaf, *leaf_lookup)
     else  find_compound_parent_and_leaf_roles_41(*inpName, *isLeaf, *leaf_lookup)
}

find_compound_parent_and_leaf_roles_42(*inpName, *isLeaf, *leaf_lookup)
{
println("\*42")
    msiString2KeyValPair("",*idmap)

    foreach (*r in select RESC_ID,RESC_NAME where RESC_TYPE_NAME = 'compound') {
        *id = *r.RESC_ID
        *idmap.*id = *r.RESC_NAME
    }

    *par = ""
    foreach (*r in select RESC_NAME, RESC_PARENT_CONTEXT, RESC_PARENT
               where RESC_PARENT_CONTEXT = 'cache' || = 'archive')
    {
        *nm=""
        foreach (*try in *idmap) {
            if (*r.RESC_PARENT == *try) { *nm = *idmap.*try }
        }
        if (*nm != "") {
            *par = *nm
            *ctx = *r.RESC_PARENT_CONTEXT
            *leaf_lookup.*ctx = *r.RESC_NAME
        }
    }
*par;
}

find_compound_parent_and_leaf_roles_41(*inpName, *isLeaf, *leaf_lookup)
{
    *par=""
    *strg=""
    if (!*isLeaf) {
        foreach (*x in select RESC_NAME,RESC_CHILDREN where RESC_TYPE_NAME = 'compound') {
            if (*x.RESC_NAME == '*inpName') {
                *par = '*inpName'; *strg = *x.RESC_CHILDREN
            }
        }
    }
    else {
        foreach (*x in select RESC_NAME,RESC_CHILDREN where RESC_TYPE_NAME = 'compound') {
            *y=*x.RESC_NAME
            *z=*x.RESC_CHILDREN
            if (*z like '*inpName{*' || *z like '*;*inpName{*')      #--lol--}}
            {
                 *par = *y
                 *strg = *z
            }
        }
    }
    foreach (*s in split(*strg,";")) {
        *t = ""
        if (*s like "*{cache}*") {*t = "cache"}     # *sib keys are "cache","archive"
        if (*s like "*{archive}*") {*t = "archive"}
        if (*t != "") {
            *parsed = split(*s,"{")
            *leaf_lookup.*t = elem(*parsed,0)              # *sib values are leaf names
        }
    }
    *par
}
