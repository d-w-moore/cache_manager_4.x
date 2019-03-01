#!/bin/bash

resc_meta_key=$(irule 'writeLine("stdout",cache_task_reserve_key)' null ruleExecOut)

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

rule_pattern="%prune_cache%(\"$rescName\"%"

Resc_List=""

select name in list-compound-{short,long} chg-rescs \
               run-schedule del-rules \
               list-rules interrupt quit
do
  case $name in
    list-compound-short)
      LIST=$(irule 'enum_compound_resources("stdout",false)' null ruleExecOut)
      echo "All compound resources: " $LIST
      ;;
    list-compound-long)
      irule 'enum_compound_resources("stdout",true)' null ruleExecOut
      ;;
    chg-rescs)
      read -p "enter resources list >> " Resc_List
      ;;
    run-schedule)
      for resc in $Resc_List; do
        rules_running=$(list_rules_from_pattern "%prune_cache%\"$resc\"%" column)
        if [ -n "$rules_running" ]; then echo >&2 "*** '$resc' already scheduled" ; break; fi
        irule 'delay("<PLUSET>30s</PLUSET><EF>30</EF>") {prune_cache_test("'$resc'","'0'","15")}' null null 
#       irule 'launch_prune_operation("'$resc'")' null null 
      done
      ;;
    run-now)
      MetaId=$(((RANDOM<<16)^$$))
      for Resc in $Resc_List
      do
        #irule 'launch_prune("'$Resc'","'$MetaId'","15")}' null null
        irule "launch_prune_operation('$Resc')"  "'*stream=stdout%*uniq=$MetaId'" null
      done;;
    interrupt)
      exec 9</dev/tty
      irule 'enum_compound_resources("stdout",true)' null ruleExecOut  | awk '$2 != "" { print $1 " " $2 }' \
       |while read resc num; do
          response=""
          while [ "$response" = "" ]; do
            read -u9 -p "interrupt ($resc '$num')? " response
            case $response in [Yy]*) [[ $num = ~* ]] || imeta set -R $resc "$resc_meta_key" "~$num";;
                              [nN]*) break;; "");; ""*) echo >&2 "bad response" ;;
            esac
          done
        done
      exec 9<&-
      ;;
    list-scheduled-by-resc)
      for $resc in Resc_List; do
        echo -n Resc '===> '
        rules_running=$(list_rules_from_pattern "%prune_cache%\"$resc\"%" column)
        echo "( $rules_running )"
      done
      ;;
    list-rules)
      iqstat ;;
    quit) break;;
    del-meta)
      for Resc in  $Resc_List; do :
        imeta rmw -R $Resc irods_cache_mgt::reserve_resc ~% 2>/dev/null
      done
    ;;
    del-rules)
      for Resc in  $Resc_List; do :
        rules_to_delete=$(list_rules_from_pattern "%prune_cache%\"$Resc\"%" column)
        read -p 'delete (Y|N)? '  response
        case $response in 
          [yY]*) iqdel $rules_to_delete && echo '** success';; 
        esac
      done
      ;;
  esac
done

