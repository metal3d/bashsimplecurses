#!/bin/bash
#
#   ./choice "choice1" "choice2" "choice3"
#   returns 255 if none chosen
#   returns number of choice if one chosen
#   
source ./simple_curses.sh
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
