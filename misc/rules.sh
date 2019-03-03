#!/bin/bash

ROUTINE=prune_cache_test
[ $# -ge 1 ] && Resc_List="$1"
: ${Resc_List:=""}

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


select name in quit list-compound-{short,long} chg-rescs run-schedule run-now \
               del-rules del-meta list-rules interrupt
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
      LIST_ALL=$(irule 'enum_compound_resources("stdout",false)' null ruleExecOut)
      LIST_ALL=$(echo $LIST_ALL)
      echo >&2 "___ Current Resc_List ($Resc_List) ___ "
      read -p "enter resources list >> " New_Resc_List
      case $New_Resc_List in 
        \*)  Resc_List=$LIST_ALL;;
        \-*) Resc_List="" ;;
        "")  ;;
        *)   Resc_List=$New_Resc_List;;
      esac
      ;;
    run-schedule)
      for Resc in $Resc_List; do
        rules_running=$(list_rules_from_pattern "%prune_cache%\"$Resc\"%" column)
        if [ -n "$rules_running" ]; then echo >&2 "*** '$Resc' already scheduled" ; break; fi
        STREAM=serverLog
        UNIQ=$(irule "writeLine('stdout',calculate_unique())"  "*stream=$STREAM%*uniq=0" ruleExecOut)
        echo >&2 "unique tag = $UNIQ"
        irule 'delay("<PLUSET>30s</PLUSET><EF>30</EF>") {'$ROUTINE'("'$Resc'","'$UNIQ'","15")}' null null 
      done
      ;;
    run-now)
      MetaId=$(((RANDOM<<16)^$$))
      echo >&2 "Sleeping to ensure unique timepoint for metadata tags ... " ; sleep 3; echo "done"
      for Resc in $Resc_List; do
        STREAM=stdout
        UNIQ=$(irule "writeLine('stdout',calculate_unique())"  "*stream=$STREAM%*uniq=$MetaId" ruleExecOut)
        echo >&2 "unique tag = $UNIQ"
        irule $ROUTINE'("'$Resc'","'$UNIQ'","15")' null ruleExecOut
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
      exec 9<&- # destroy keyboard connection
      ;;
    list-scheduled-by-resc)
      for $Resc in Resc_List; do
        echo -n Resc '===> '
        rules_running=$(list_rules_from_pattern "%prune_cache%\"$Resc\"%" column)
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
        response='n'
        Prompt="Rules for $Resc : $rules_to_delete"
        [ -n "$rules_to_delete" ] && read -p "$Prompt ; delete (Y|N)? " response
        case $response in 
          [yY]*) iqdel $rules_to_delete && echo '** success';; 
        esac
      done
      ;;
  esac
done

