#!/bin/bash

source $(dirname $0)/simple_curses.sh

main(){
    window "Test 1" "red" "33%"
    append "First simple window"
    endwin

    col_right 
    move_up

    window "Test 2" "red" "33%"
    append "Multiline is allowed !!!\nLike this :)"
    append "This is a new col here."
    endwin

    window "Test 3" "red" "33%"
    append "We can had some text, log..."
    endwin
    window "Test 4" "grey" "33%"
    append "Example using command"
    append "`date`"
    append "I only ask for date"
    endwin
    
    col_right 
    move_up
    window "Test 5" "red" "34%"
    append "We can add some little windows... rememeber that very long lines are wrapped to fit window !"
    endwin

    window "Little" "green" "12%"
    append "this is a simple\nlittle window"
    endwin
    col_right
    window "Other window" "blue" "22%"
    append "And this is\nanother little window"
    endwin

}
main_loop
