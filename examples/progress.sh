#!/bin/bash
#
#   ./progress.sh
#
#   Shows animated progress bar.
#   returns 255 when progress exceeds maxprogress
#
source $(dirname $0)/../simple_curses.sh
progress=0
maxprogress=97
main(){
    window "waiting for bar to move" "red" "33%" "blue"
    progressbar 20 $progress $maxprogress "cyan" "blue"
    endwin
}
update(){
    sleep 0.2
    progress=$(( progress + 1))
    [ "$progress" -gt "$maxprogress" ] && return 255
    return 0
}
main_loop update
