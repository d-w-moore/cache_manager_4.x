pep_resource_close_post  (*DObj)
{
  pep_resource_close_HOOK ( *DObj, "_post")
}

pep_resource_close_HOOK ( *DObj, *annotation )
{
      writeLine("serverLog","----> pep_resource_close / *annotation " )
      msiGetIcatTime(*tm, "unix")
      *dataId = ""
      *KVP = $KVPairs
# -- debug --> # foreach (*k in *KVP) { writeLine("serverLog", *k ++ " => " ++ *KVP.*k) }
      *path = *KVP.logical_path
      *hier = *KVP.resc_hier
      writeLine("serverLog","----+   path = *path ;  hier = *hier")
      if (getDataObjectIDFromPathAndResc(*path, *hier, *dataId))
      {
          *candidate = top_or_next_lowest_in_resc_hier(*hier)
          *is_comp_resc = is_compound_resource( *candidate )
          if (*is_comp_resc) {
                *meta."irods_cache_mgt::atime::*hier" = "*tm"
                msiSetKeyValuePairsToObj( *meta , *path , "-d" )
          }
          writeLine("serverLog","----+   data id = [*dataId] ; time = [*tm] ")
      }
      writeLine("serverLog","<---- pep_resource_close / *annotation " )
}

getDataObjectIDFromPathAndResc(*path,*hier,*dataId)
{
    msiSplitPath(*path,*coll,*base)
    *status = false
    *dataId = ""
    foreach (*dobj in select DATA_ID where DATA_NAME = '*base' and COLL_NAME = '*coll'  and DATA_RESC_HIER = '*hier')
    {
      *status = true
      *dataId = *dobj.DATA_ID
    }
*status;
}


