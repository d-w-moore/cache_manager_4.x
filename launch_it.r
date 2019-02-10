f{test}
test{

  delay ("<PLUSET>*delaytime</PLUSET>") {
            writeLine("serverLog","*mything")
  }
}
input  *delaytime=$'10s',*mything=$'whatsup +++++++++++++++++++++'
output ruleExecOut
