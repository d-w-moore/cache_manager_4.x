main { 
  if (*objectPath != '') { testp(*objectPath) }
}

testp(*name) 
{
    #msiSplitPath(*name,*coll,*data)
    msiString2KeyValPair("*ma",*ka)
    msiString2KeyValPair("*ms",*ks)
    msiString2KeyValPair("*mr",*kr)
    *c='.';*j=0
    for(*i=0;*c!="";*i=*i+1) {
      msiSubstr(*debug,str(*i),"1",*c);
      if (*c == "a") {
          msiAssociateKeyValuePairsToObj(*ka,"*name","*otype")
      }
      else if (*c == "s") {
          msiSetKeyValuePairsToObj(*ks,"*name","*otype")
      }
      else if (*c == "r") {
          msiRemoveKeyValuePairsFromObj(*kr,"*name","*otype")
      }
    }
    #msiSubstr($debug,*x,1,*y)
}

input *objectPath=$'/tempZone/home/rods/dude1.r', *ma=$'',*ms=$'',*mr=$'', *debug='asr', *otype='-d'
output ruleExecOut
