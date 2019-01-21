main {
        test
}

test {
  msiString2KeyValPair(*initkv, *kvp)
  KVP_lookup_with_default(*kvp,*key,*v,"null")
  writeLine("stdout","\t: [*v]")
}

KVP_lookup_with_default(*kvPairs, *key, *val, *default)
{
  *val = *default
  *found = 0
  *k=""
  foreach (*k in *kvPairs) { 
    if (*k == *key) {*val = *kvPairs.*key; *found=1; break}
  }
  *found
}


input  *initkv=$'a=b%c=d',*key=$'c'
output ruleExecOut
