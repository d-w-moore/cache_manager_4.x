f{test}

test{
  delay ( *delay ++ *repeat ) { prune_cache ; writeLine("serverLog","*logString") }
}
input *delay=$"<PLUSET>60s</PLUSET>",*repeat=$"<EF>60s</EF>",*logString=$' ++++ any string ++++'
output ruleExecOut
