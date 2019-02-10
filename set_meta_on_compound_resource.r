main{
     *status = true
     if (!set_meta_on_compound_resc(*comp_resc_name, *k, *value))
     {
         *status = false
         unset_meta_on_compound_resc(*comp_resc_name, *k )
     }
     writeLine("stdout", "status of set = [*status]" )
     if (*sleep_secs_after_set_meta > 0) { writeLine("stdout", "sleeping...")
                                           msiSleep("*sleep_secs_after_set_meta","0") }
     if (*status) { unset_meta_on_compound_resc( *comp_resc_name,*k) }
}

unset_All_meta_on_compound_resc( *resc_name )
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

set_meta_on_compound_resc ( *resc_name, *kvp, *set_value )
{
   *match = false
   *Key = "irods_cache::reserve_resc"

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
   # return : bool value  (successful set without collision)
   *match && size(*unequal) < 1
}



input *comp_resc_name=$'cmp10', *sleep_secs_after_set_meta=$0, *value=$'immediate'
output ruleExecOut

