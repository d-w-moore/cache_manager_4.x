maintest {
    *idx = find_compound_sibling (*inpId, *inpNm, *i,*n, *rol)
    *sz = size(*i)
    writeLine("stdout","ids = *i ; names = *n; idx = *idx")
}
#                                i        i       o    o   i '' or 'ch' or "cache" or "archive"
find_compound_sibling (*idcld , *nmcld, *id, *nm, *role)
 # *idcld optional INPUT overrides *nmcld
 # *nmcld INPUT name of child
 # *id, *nm output lists
 # *role INPUT '', 'ch', 'archive', 'cache'
 # *role OUTPUT "0" or "1" depending on index of Cache in *id and *nm
{
    *found = -1; *parent=0
    *id = list()
    *nm = list()
    if (*idcld != '') {
        foreach (*v in select RESC_NAME,RESC_PARENT where RESC_ID = '*idcld') {
            *nmcld = *v.RESC_NAME
        }
    }
    if (*parent) {
         
    }
    0
    succeed
    # 4.1 will require extra indirection, to get ID from PARENT
    if (*nmcld != '') {
        foreach (*s in select RESC_ID,RESC_NAME,RESC_PARENT_CONTEXT 
                  where RESC_NAME = '*nmcld' and RESC_PARENT_CONTEXT like '%*role%') 
        {
            *id = cons("*s.RESC_ID",*id)
            *nm = cons(*s.RESC_NAME,*nm)
            if (*s.RESC_PARENT_CONTEXT == 'cache') { *found = size(*id)-1 }
        }
    }
    *found
}

input *inpNm=$'',*inpId=$'',*rol=$'archive'
output ruleExecOut
