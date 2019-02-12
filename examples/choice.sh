#!/bin/bash
#
#   ./choice "choice1" "choice2" "choice3"
#   returns 255 if none chosen
#   returns number of choice if one chosen
#
source $(dirname $0)/../simple_curses.sh
declare -a SELECTABLES
SELECTABLES=( "$@" )
arraylen=${#SELECTABLES[@]}
selected=0
lastselected=$selected

main(){
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
    #read -n 1 -s -t 1 ret
    read -n 1 -s ret
    success=$?
    read -sN1 -t 0.0001 k1
    read -sN1 -t 0.0001 k2
    read -sN1 -t 0.0001 k3
    ret+=${k1}${k2}${k3}

    [ "$success" == "0" ] && {
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
    }

    return 0
}
main_loop update
