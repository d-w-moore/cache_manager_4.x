main{
# remove AVUS with matching *key from data object at *objpath
#
#                                         *match is "like" for like comparison
#                                         *match is "" for equality comparison
  remove_AVUs_matching_key(*objpath, *key, *match)
}

remove_AVUs_matching_key(*dobjPath,*Key, *matchType)
{
    msiSplitPath(*dobjPath,*dobjColl,*dobjName)
    *keylist = list()
    *vallist = list()
    foreach (*x in select META_DATA_ATTR_NAME , META_DATA_ATTR_VALUE
              where COLL_NAME = '*dobjColl' and DATA_NAME = '*dobjName')
    {
        *name = *x.META_DATA_ATTR_NAME
        *value = *x.META_DATA_ATTR_VALUE
        if (*matchType == 'like') {
            if (*name like *Key ) {
                *keylist = cons(*name ,*keylist)
                *vallist = cons(*value,*vallist)
            }
        }
        else {
            if (*name == *Key ) {
                *vallist = cons(*value,*vallist)
            }
        }
    }
    *nVal = size(*vallist) 
    writeLine("stdout","removing:")
    for (*i = 0; *i < *nVal ; *i = *i+1) {
        *v = elem(*vallist,*i)
        if (*matchType == 'like') {
          *Key = elem(*keylist,*i)
        }
        msiString2KeyValPair("*Key=*v",*k )
        writeLine("stdout","*Key *v")
        msiRemoveKeyValuePairsFromObj(*k,"*dobjPath","-d")
    }
}

input *objpath=$"/tempZone/home/rods/VERSION.json", *key=$"x", *match=$"like"
output ruleExecOut
