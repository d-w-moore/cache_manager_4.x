main { 

    *parentname = find_compound_parent_and_leaf_roles (*rescn , (*isleaf != 0), *lookup)
    writeLine("stdout", "parent name = *parentname")
    writeLine("stdout", "lookup      = [*lookup]")

}

IRodsVersion { 43 }

find_compound_parent_and_leaf_roles(*inpName, *isLeaf, *leaf_lookup)
{
    if (IRodsVersion >= 42)  then  find_compound_parent_and_leaf_roles_42(*inpName,*isLeaf,*leaf_lookup)
                             else  find_compound_parent_and_leaf_roles_41(*inpName,*isLeaf,*leaf_lookup)
}


find_compound_parent_and_leaf_roles_42(*inpName, *isLeaf, *leaf_lookup)
{
    writeLine("stdout","***42")

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

input *rescn=$"",*isleaf=$0
output ruleExecOut
