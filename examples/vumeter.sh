#!/bin/bash
#
#   ./vumeter.sh
#   This examples shows two components: a vumeter and a blinkenlights.
#   The vumeter shows a constant value, while the blinkenlights show variable
#   status of each light until the progress exceeds maxprogress, then returns 255
#
source $(dirname $0)/../simple_curses.sh
progress=0
maxprogress=97
main(){
    window "waiting for bar to move" "red" "33%" "blue"
    vumeter "RVol" "15" "25" "30" "green" "red" "gray"
    blinkenlights "Blinken" "green" "red" "gray" "black" $((progress % 2 )) $((progress % 3 )) $((progress % 5 )) $((progress % 7 )) $((progress % 9 )) $((progress % 6 ))
    endwin
}
update(){
    sleep 1
    progress=$(( progress + 1))
    [ "$progress" -gt "$maxprogress" ] && return 255
    return 0
}
main_loop update
