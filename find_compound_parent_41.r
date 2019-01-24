test_find_compound_parent {
        *parent = find_compound_parent_and_leaf_roles(*inp_resc_name , *is_leaf, *leaves)
        if (*parent != '') { 
            writeLine("stdout","parent:   " ++ *parent)
            writeLine("stdout","cache:   " ++ *leaves.cache)
            writeLine("stdout","archive: " ++ *leaves.archive)
        }
}

# this is for iRODS 4.1.x
# ---
#   if we have the name of only one leaf or just the compound resource, return
#    the name of the compound resc & output a lookup of the two children indexed by role

find_compound_parent_and_leaf_roles(*inpName, *isLeaf, *leaf_lookup)
{
    *par=""
    *strg=""
    if (*isLeaf == 0) {
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

input *inp_resc_name=$'', *is_leaf=$1
output ruleExecOut
