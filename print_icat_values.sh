#!/bin/bash


if [[ $1 = *-lc* ]]; then
  irule 'foreach (*z in select RESC_NAME where RESC_TYPE_NAME = "compound") {writeLine("stdout",*z.RESC_NAME)}' \
   null ruleExecOut
elif [[ $1 = *-lr* ]]; then
  output=$(
  irule '*l=prune_rule_ids_as_string(true,"") 
   writeLine("stdout","*l")' null ruleExecOut | tr , \\012 # |grep -v '[][]'
  )
  echo "$output"
fi
# Turn square brackets to parens 
#    awk '/[][]/{sub("[[]","(",$1);sub("[]]",")",$1);print $1}'
# -- put quotes around number and comma afterward --
#awk '$1~/[0-9]+/{sub("[0-9]+","\047&\047,",$1);print $1}'

# irule 'delay("<PLUSET>1s</PLUSET><EF>30s</EF>"){writeLine("serverLog","hello---")}' null null
# irule 'delay("<PLUSET>1s</PLUSET><EF>30s</EF>"){writeLine("serverLog","goodbye---")}' null null
# irule "foreach (*z in select RULE_EXEC_ID where RULE_EXEC_ID in ('13366')) {writeLine('stdout',*z.RULE_EXEC_ID)}" \
#   null ruleExecOut
# 13366 writeLine("serverLog","hello---") 
# 13367 writeLine("serverLog","goodbye---") 
# irule "foreach (*z in select RULE_EXEC_ID where RULE_EXEC_ID in ('13366')) {writeLine('stdout',*z.RULE_EXEC_ID)}" \
#   null ruleExecOut
# 13366
# irule "foreach (*z in select RULE_EXEC_ID where RULE_EXEC_ID in ('13367')) {writeLine('stdout',*z.RULE_EXEC_ID)}" null ruleExecOut
# 13367
#  # will hve to do RULE_EXEC_ID = 'a' || = 'b' || = 'c' ... (in irule)

 '/[][]/{ X="" } ; $1~/[0-9]+/{sub("[0-9]+",X" = \047&\047,",$1);print $1;X=" ||"}'

Y=$(
  irule 'writeLine("stdout",prune_rule_ids_as_string(true,""))' null ruleExecOut|tr , \\012|awk -f oreq.awk
)
irule "
  foreach (*rule in select RULE_EXEC_ID,RULE_EXEC_NAME where RULE_EXEC_ID $Y) {
    writeLine('stdout',*rule.RULE_EXEC_NAME ++ ' -> ' ++ *rule.RULE_EXEC_ID)
  }"  null ruleExecOut

X=$(((RANDOM<<16)+$$));irule '*u=unique_string('$X')prune("cmp10","*u","2")' null ruleExecOut

#X=$(((RANDOM<<16)+$$))
irule ' *u=unique_string(0)prune("cmp10","*u","2")' null ruleExecOut

