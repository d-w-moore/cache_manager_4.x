main{
    *srchtype="SOMESTR"
    *s=meta_query_fields(*srchtype)
    writeLine("stdout","[*s]")
    *srchtype="*typ"
    *s=meta_query_fields(*srchtype)
    writeLine("stdout","[*s]")
}
meta_query_fields(*obj_type) {
    
    *obj_field = ""
    foreach( *t in list("USER","DATA","COLL","RESC"))
    {
        if (*t == *obj_type) {
            *obj_field = *t
        }
    }
    *meta_fields = ""
    if (*obj_field != "") {
        foreach( *f in list("NAME,", "VALUE,", "UNITS,", "ID")) {
            *meta_fields = *meta_fields ++ ("META_" ++ *obj_field ++ "_ATTR_"  ++ *f )
        }
    }
    *meta_fields
}
input  *typ=$"RESC"
output ruleExecOut
