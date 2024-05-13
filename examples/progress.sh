#!/bin/bash
#
#   ./progress.sh
#
#   Shows animated progress bar.
#   returns 255 when progress exceeds maxprogress
#
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
pushd "$SCRIPT_DIR" || exit
source ../simple_curses.sh
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
