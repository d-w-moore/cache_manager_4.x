main { test_main }

set_and_check_resc_meta: input string * input string * input string * output string * input string -> integer

test_main {
    *check = ""; *s = 0
    if (*resc_name != '') {

        *s = set_and_check_resc_meta(*resc_name,*k,*v,*check,"*guard") 

        if (*s >= 1) { writeLine("stdout","success: [*k] -> [*v] set on resc=[*resc_name].") }
        else if (*s == 0) {
            writeLine("stdout","failure due to guard conflict")
        }
        else if (*s == -1) {
            writeLine("stdout","failure, contention or multiple values on setting metadata")
        }
        else  { 
            *t = -(*s)
            writeLine("stdout", "too many kvpairs (*t)\nHint: someone is using " ++ 
                                "msiAssociateKeyValuePairsToObj(...)")
        }
    }
}

set_and_check_resc_meta(*resc,*key,*value,*retrieved, *guardstring)
{
    *vallist = list()
    foreach (*x in select META_RESC_ATTR_VALUE,META_RESC_ATTR_NAME,RESC_NAME
                    where META_RESC_ATTR_NAME = '*key' and RESC_NAME = '*resc')
    {
        *vallist = cons(*x.META_RESC_ATTR_VALUE, *vallist)
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
            writeLine("stdout","preexist = [] ; guardstring = [*guardstring]")
            *success = 0
        } else {
            msiString2KeyValPair("*key=*value",*kvp)
            msiSetKeyValuePairsToObj(*kvp,"*resc","-R")
        }
    }
    #=============
    if (*success == 1) {
        *tries = 0
        foreach (*x in select META_RESC_ATTR_VALUE,META_RESC_ATTR_NAME,RESC_NAME
         where META_RESC_ATTR_NAME = '*key' and RESC_NAME = '*resc')
        {
            *tries = *tries + 1
            if (*tries == 1) {
               *retrieved = *x.META_RESC_ATTR_VALUE
               if (*value != *retrieved) { *success = -1  }  # contention
            }
            else {           #  More than one value set....
               *success = -1 #  We could chg this to return a positive value > 1
                             #  (Then only a return value of '1' would be a clear success)
            }
        }
    }
*success
}

input *resc_name=$'pt1', *k=$'aa', *v=$'bb', *guard=$''
output ruleExecOut
