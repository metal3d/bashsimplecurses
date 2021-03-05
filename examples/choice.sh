#!/bin/bash
#
#   ./choice "choice1" "choice2" "choice3"
#   returns 255 if none chosen
#   returns number of choice if one chosen
#
source $(dirname $0)/../simple_curses.sh
declare -a SELECTABLES
while [[ $# -gt 0 ]]; do
  # shellcheck disable=SC2034
  case "$1" in
  -- ) shift; break ;;
  * ) SELECTABLES+=("$1"); shift ;;
  esac
done
# SELECTABLES=( "$@" )
arraylen=${#SELECTABLES[@]}
selected=0
lastselected=$selected

main(){
    window "Date" "blue" "33%"
       append "Date is"
       append "`date`"
    endwin

    window "pick one" "red" "33%" "blue"

    local count
    count=0
    for i in ${SELECTABLES[@]};do
        bgcolor="black"
        color="blue"
        [ "$selected" == "$count" ] && {
            bgcolor="blue"
            color="red"
        }
        append "$i" $color $bgcolor
        count=$(( count + 1 ))
    done
    endwin
    lastselected=$selected
}
update(){
    local ret
    local success

    read -r -n 1 -s -t 1 ret
    success=$?

    if [ "$success" -lt 128 ]; then
        if [ "$ret" == $'\e' ];then
            read -sN2 -r k1
            success=$?
            ret+=${k1}
        fi

        case $ret in
            [0-9])
                selected=$(( $ret - 1 ))
            ;;
            $'\e[A'|$'\e[D')
                selected=$(( selected - 1 ))
                [ "$selected" -lt "0" ] && selected=$(( arraylen - 1))
            ;;
            $'\e[B'|$'\e[C')
                selected=$(( selected + 1 ))
                [ "$selected" == "$arraylen" ] && selected="0"
            ;;
            $'\e')
                return 255
            ;;
            *)
                return $(( $lastselected + 1 ))
            ;;
        esac
    fi

    return 0
}

main_loop "$@"
