sleepMilliseconds(*ms) {
   if (*ms < 0.0) { *ms = 0.000; }
   *s = (*ms / 1000.0)
   *s_integer  = int(floor(*s) + 0.01)
   *s_fraction = (*ms - double(*s_integer * 1000.0))/1000.0
   *i = str(*s_integer)
   *u = str(*s_fraction * 1000000.0)
   *retv = msiSleep (*i, *u)
}

doubleToThreshold(*ms,*thresh_ms,*sleep) 
{
  if (*thresh_ms<0) {*thresh_ms = 0} 
  *y = *ms * 2.0 + 0.001;
  if (*sleep) {sleepMilliseconds(*ms)}
  if (*y > *thresh_ms) { *y = double(*thresh_ms) }
  *ms = *y
}


#---> probably don't need --> as only  use for setting dobj AVUS is to update  atime -- dwm
set_and_check_dataObj_meta(*dataObjPath, *key, *value, *retrieved, *guardstring)
{
    msiSplitPath(*dataObjPath, *collName, *dataName)
    *vallist = list()
    foreach (*x in select META_DATA_ATTR_VALUE,META_DATA_ATTR_NAME,DATA_NAME,COLL_NAME
                    where META_DATA_ATTR_NAME = '*key' and DATA_NAME = '*dataName' and COLL_NAME = '*collName')
    {
        *vallist = cons(*x.META_DATA_ATTR_VALUE, *vallist)
    }
    *listsize = size(*vallist)
    #=============
    *success = 1
    if (*listsize > 1) {
        *success = (0 - *listsize)
    }
    else {
        *match = false
        if (*listsize == 1 && *guardstring != "") {
            *preexist = elem(*vallist,0)
            *match = false
            if (*guardstring like '^*') {
                *match = (*preexist like regex *guardstring)
            } else {
                *match = (*preexist like *guardstring)
            }
        }
        if (*match) {
            #writeLine("stdout","preexist = [] ; guardstring = [*guardstring]")
            *success = 0
        } else {
            msiString2KeyValPair("*key=*value",*kvp)
            msiSetKeyValuePairsToObj(*kvp,"*dataObjPath","-d")
        }
    }
    #=============
    if (*success == 1) {
        *tries = 0
        foreach (*x in select META_DATA_ATTR_VALUE,META_DATA_ATTR_NAME,DATA_NAME
         where META_DATA_ATTR_NAME = '*key' and DATA_NAME = '*dataName' and COLL_NAME = '*collName')
        {
            *tries = *tries + 1
            if (*tries == 1) {
               *retrieved = *x.META_DATA_ATTR_VALUE
               if (*value != *retrieved) { *success = -1  }  # contention
            }
            else {
               *success = -1 
               # if (*success > 0) { *success = *tries } # this would detect multiple matches
            }
        }
    }
*success  # -- 1 indicates success ; any other return value conveys possible error condition
}
#---> dwm
