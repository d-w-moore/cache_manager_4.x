sleepMilliseconds(*ms) {
   if (*ms < 0.0) { *ms = 0.000; }
   *s = (*ms / 1000.0)
   *s_integer  = int(floor(*s) + 0.01)
   *s_fraction = (*ms - double(*s_integer * 1000.0))/1000.0
   *i = str(*s_integer)
   *u = str(*s_fraction * 1000000.0)
   *retv = msiSleep (*i, *u)
}

doubleToThreshold(*ms,*thresh_ms,*sleep) 
{
  if (*thresh_ms<0) {*thresh_ms = 0} 
  *y = *ms * 2.0 + 0.001;
  if (*sleep) {sleepMilliseconds(*ms)}
  if (*y > *thresh_ms) { *y = double(*thresh_ms) }
  *ms = *y
}

unset_All_meta_on_compound_resc (*resc_name)
{
    msiString2KeyValPair("",*kvp)
    foreach (*rm in select META_RESC_ATTR_NAME, META_RESC_ATTR_VALUE
     where RESC_NAME = '*resc_name' and RESC_TYPE_NAME = 'compound')
    {
        *Key = *rm.META_RESC_ATTR_NAME
        *kvp.*Key = *rm.META_RESC_ATTR_VALUE
    }
    *x = errorcode(msiRemoveKeyValuePairsFromObj( *kvp, *resc_name, "-R"))
*x==0;
}
