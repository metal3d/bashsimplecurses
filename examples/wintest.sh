#!/bin/bash

source $(dirname $0)/../simple_curses.sh
main(){
    window "Test 1" "red" "33%"
        append "First simple window"
        addsep
        append_command "cal"
        endwin

        window "Tree files" "gree" "33%"
        if [[ -x `which tree 2> /dev/null` ]]; then
            append_command "tree -L 2 -C -A ./"
        else
            append "Please install tree command"
        fi
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

    window "Let's play with libcaca" "green" "33%"
        command="img2txt $(dirname $0)/../tux.gif -y 12 -W 45 -d ordered2 -f utf8"
        append "$command"
        if [[ -x `which img2txt 2> /dev/null` ]]; then
            append_command "$command"
        else
            append "You should install caca-utils"
        fi
    endwin

    col_right
    move_up

    window "Test 5" "red" "34%"
        append "We can add some little windows... rememeber that very long lines are wrapped to fit window !" "left"
    endwin

    window "Tabbed values" "red" "34%"
        append_tabbed "colomn1:column2:column3" 3
        append_tabbed "val 1:val 2:val 3" 3
        append_tabbed "val 4:val 5:val 6" 3
    endwin

    window "Little" "green" "12%"
        append "This is a simple\nlittle window"
    endwin

    col_right

    window "Other window" "blue" "22%"
        append "And this is\nanother little window"
    endwin
}
main_loop
