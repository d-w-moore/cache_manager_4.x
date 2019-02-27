#!/bin/bash

query_format() {
  tr ',' '\012' | \
  awk '$1~/[0-9]+/{ sub("[0-9]+",X" = \047&\047",$1); print $1;X=" ||" }'
}
column_format() {
  tr ',' '\012' | \
  grep -v '[][]'
}

list_rules_from_pattern() { 
  local ptn=${1:-"%"}
  local fmt=$2
  irule "*x=prune_rule_ids_as_string(true,'$ptn') ; writeLine('stdout','*x')" null ruleExecOut  | ${fmt}_format
}

pattern="%prune_cache%(\"$rescName\"%"

R=$(((RANDOM<<16)^$$))
for num in cmp10 cmp11; do
        irule 'delay("<PLUSET>30s</PLUSET><EF>30</EF>") {prune_cache_test("'$num'","'$R'","15")}' null null 
done

#;;
#   print) 
#     echo === "$pattern"
#     list_rules_from_pattern $pattern column
#     echo === 
#     genquery_comparison=$(list_rules_from_pattern $pattern query)
#     echo $genquery_comparison
#     ;;
#   stop)
#     iqdel $(list_rules_from_pattern $pattern column)
#     ;;
# esac
#done

##	call rule in  /etc/irods/cmu.re
#	irule all_compound_resources null ruleExecOut
