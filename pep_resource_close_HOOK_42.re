

pep_resource_close_post  (*Inst, *DObj, *other)  
{
  pep_resource_close_HOOK ( *DObj, "_post") 
}

pep_resource_close_HOOK ( *DObj, *annotation ) 
{
    writeLine("serverLog","----> pep_resource_close / *annotation " )
    msiGetIcatTime(*tm, "unix")
    *dataId = ""
    *path = *DObj.logical_path
    *hier = *DObj.resc_hier
    writeLine("serverLog","----+   path = *path ;  hier = *hier")
    if (getDataObjectIDFromPathAndResc(*path, *hier, *dataId))
    {
        writeLine("serverLog","----+   data id = [*dataId] ; time = [*tm]")
    }
    writeLine("serverLog","<---- pep_resource_close / *annotation " )
}


getDataObjectIDFromPathAndResc(*path,*hier,*dataId)
{   
    msiSplitPath(*path,*coll,*base)
    *status = false
    *dataId = ""
    foreach (*dobj in select DATA_ID where DATA_NAME = '*base' and COLL_NAME = '*coll' and DATA_RESC_HIER = '*hier')
    {
      *status = true
      *dataId = *dobj.DATA_ID
    }
    *status
}

