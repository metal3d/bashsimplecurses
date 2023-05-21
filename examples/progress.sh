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
    window "waiting for bar to move" "red" "33%"
    progressbar "100%" "$progress" "$maxprogress" "green" "gray"
    endwin
}
update(){
    sleep 0.1
    progress=$((progress+1))
    [ "$progress" -gt "$maxprogress" ] && progress=0
    return 0
}
main_loop "$@"
