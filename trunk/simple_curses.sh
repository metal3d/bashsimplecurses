#!/bin/bash

LASTCOLS=0
BUFFER="/tmp/deskbar.buffer"


on_kill(){
    echo "Closing bashbar..."
    rm -rf $BUFFER
    exit 0
}
trap on_kill SIGINT SIGTERM


term_init(){
    tput clear >> $BUFFER
    tput cup 0 0 >> $BUFFER
}

window(){
    title=$1
    color=$2      

    cols=$(tput cols)
    if [[ "$3" != "" ]]; then
        cols=$3
    fi
    len=$(echo "$1" | echo $(($(wc -c)-1)))
    left=$(((cols/2) - (len/2) -1))

    #draw up line
    clean_line
    echo -ne "\033(0l\033(B"
    for i in `seq 3 $cols`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0k\033(B"
    #next line, draw title
    echo 
    tput sc
    clean_line
    echo -ne "\033(0x\033(B"
    tput cuf $left
    case $color in
        green)
            echo -n -e "\E[01;32m"
            ;;
        red)
            echo -n -e "\E[01;31m"
            ;;
        grey)
            echo -n -e "\E[01;37m"
            ;;
        blue)
            echo -n -e "\E[01;34m"
            ;;
    esac
    
    
    echo $title
    tput rc
    tput cuf $cols
    echo -ne "\033(0x\033(B"
    echo -n -e "\e[00m"
    echo
    #then draw bottom line for title
    addsep
    #reset color
    LASTCOLS=$cols

}

addsep (){
    echo -ne "\033(0t\033(B"
    for i in `seq 3 $cols`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0u\033(B"
    echo
}

clean_line(){
    tput sc
    tput el
    tput rc
}
append(){
    clean_line
    tput sc
    echo -ne "\033(0x\033(B"
    len=$(echo "$1" | wc -c )
    len=$((len-1))
    left=$((LASTCOLS/2 - len/2 -1))
    tput cuf $left
    echo $1
    tput rc
    tput cuf $((LASTCOLS-1))
    echo -ne "\033(0x\033(B"
    echo
}

append_tabbed(){
    [[ "$3" != "" ]] && delim=$3 || delim=":"
    clean_line
    tput sc
    echo -ne "\033(0x\033(B"
    len=$(echo "$1" | wc -c )
    len=$((len-1))
    left=$((LASTCOLS/$2)) 
    for i in `seq 0 $(($2))`; do
        tput rc
        tput cuf $((left*i+1))
        echo "`echo $1 | cut -f$((i+1)) -d"$delim"`" 
    done
    tput rc
    tput cuf $((LASTCOLS-1))
    echo -ne "\033(0x\033(B"
    echo

}

endwin(){
    echo -ne "\033(0m\033(B"
    for i in `seq 3 $LASTCOLS`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0j\033(B"
    echo
}

refresh (){
    cat $BUFFER
    echo "" > $BUFFER
}




main_loop (){
    term_init
    [[ "$1" == "" ]] && time=1 || time=$1
    while [[ 1 ]];do
        main >> $BUFFER
        tput ed >> $BUFFER
        refresh
        sleep $time
        tput cup 0 0 >> $BUFFER
    done
}
