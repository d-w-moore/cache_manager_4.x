main{
# remove AVUS with matching *key from data object at *objpath
#
#                                         *match is "like" for like comparison
#                                         *match is "" for equality comparison
  #remove_data_AVUs_matching_key(*objpath, *key, *match)

  #msiString2KeyValPair("b=b%bb=c",*k)
  #msiAssociateKeyValuePairsToObj(*k,"pt0","-R")

# find_resc_AVUs_matching_key("pt0","a%","like",*kvp)
# writeLine("stdout","*kvp")

  #msiRemoveKeyValuePairsFromObj(*kvp,"pt0","-R")
}

find_resc_AVUs_matching_key(*rescname, *like_pattern, *kvpairs)
{
    #*keylist = list()
    #*vallist = list()

    foreach (*x in select META_RESC_ATTR_NAME, META_RESC_ATTR_VALUE where RESC_NAME = '*rescname' and 
                    META_RESC_ATTR_NAME like "*like_pattern")
    {
        *name  = *x.META_RESC_ATTR_NAME
        *kvpairs.*name =  *x.META_RESC_ATTR_VALUE
    }
}

remove_data_AVUs_matching_key(*dobjPath,*Key, *matchType)
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

#input *rescname=$"cch1", *key=$"^x", *match=$"like"
#input *objpath=$"/tempZone/home/rods/VERSION.json", *key=$"x", *match=$"like"
input null
output ruleExecOut
