
rescFromObjPath
{
  *pref_resc = ""
  foreach (*r in select RESC_NAME,META_RESC_ATTR_NAME,META_RESC_ATTR_VALUE 
                 where META_RESC_ATTR_NAME = 'irods_cache::resc_from_coll')
  {
    *y = *r.META_RESC_ATTR_VALUE
    if  ($objPath like *r.META_RESC_ATTR_VALUE) {
      *pref_resc = *r.RESC_NAME
    }
  }
  *status = 1
  if ( *pref_resc != "" ) {
    *status = 0 # -> success
    writeLine("serverLog", "preferred -- [*pref_resc]")
    msiSetDefaultResc("*pref_resc","preferred")
  }
  *status
}

acSetRescSchemeForRepl {
    if (0 != rescFromObjPath) { msiSetDefaultResc("demoResc","preferred") }
}
acSetRescSchemeForCreate {
    if (0 != rescFromObjPath) { msiSetDefaultResc("demoResc","preferred") }
}

