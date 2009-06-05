#!/bin/bash
#simple curses library to create windows on terminal
#
#author: Patrice Ferlet metal3d@copix.org
#licence: new BSD


#Usefull variables
LASTCOLS=0
BUFFER="/tmp/deskbar.buffer"$RANDOM
POSX=0
POSY=0
LASTWINPOS=0

#call on SIGINT and SIGKILL
#it removes buffer before to stop
on_kill(){
    echo "Exiting"
    rm -rf $BUFFER
    exit 0
}
trap on_kill SIGINT SIGTERM


#initialize terminal
term_init(){
    POSX=0
    POSY=0
    tput clear >> $BUFFER
}


#change line
_nl(){
    POSY=$((POSY+1))
    tput cup $POSY $POSX >> $BUFFER
    #echo 
}


move_up(){
    set_position $POSX 0
}

col_right(){
    left=$((LASTCOLS+POSX))
    set_position $left $LASTWINPOS
}

#put display coordinates
set_position(){
    POSX=$1
    POSY=$2
}


#Append a windo on POSX,POSY
window(){
    LASTWINPOS=$POSY
    title=$1
    color=$2      
    tput cup $POSY $POSX 
    cols=$(tput cols)
    cols=$((cols))
    if [[ "$3" != "" ]]; then
        cols=$3
        if [ $(echo $3 | grep "%") ];then
            cols=$(tput cols)
            cols=$((cols))
            w=$(echo $3 | sed 's/%//')
            cols=$((w*cols/100))
        fi
    fi
    len=$(echo "$1" | echo $(($(wc -c)-1)))
    left=$(((cols/2) - (len/2) -1))

    #draw up line
    clean_line
    echo -ne "\033(0l\033(B"
    for i in `seq 3 $cols`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0k\033(B"
    #next line, draw title
    _nl

    tput sc
    clean_line
    echo -ne "\033(0x\033(B"
    tput cuf $left
    #set title color
    case $color in
        green)
            echo -n -e "\E[01;32m"
            ;;
        red)
            echo -n -e "\E[01;31m"
            ;;
        blue)
            echo -n -e "\E[01;34m"
            ;;
        grey|*)
            echo -n -e "\E[01;37m"
            ;;
    esac
    
    
    echo $title
    tput rc
    tput cuf $((cols-1))
    echo -ne "\033(0x\033(B"
    echo -n -e "\e[00m"
    _nl
    #then draw bottom line for title
    addsep
    
    LASTCOLS=$cols

}

#append a separator, new line
addsep (){
    clean_line
    echo -ne "\033(0t\033(B"
    for i in `seq 3 $cols`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0u\033(B"
    _nl
}


#clean the current line
clean_line(){
    tput sc
    #tput el
    tput rc
    
}


#add text on current window
append(){
    text=$(echo $1 | fold -w $LASTCOLS -s)
    rbuffer="/tmp/scursesbuffer."$RANDOM
    echo  -e "$text" > $rbuffer
    while read a; do
        _append "$a"
    done < $rbuffer
    rm -f $rbuffer
}
_append(){
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
    _nl
}

#add separated values on current window
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
    _nl
}

#close the window display
endwin(){
    clean_line
    echo -ne "\033(0m\033(B"
    for i in `seq 3 $LASTCOLS`; do echo -ne "\033(0q\033(B"; done
    echo -ne "\033(0j\033(B"
    _nl
}

#refresh display
refresh (){
    cat $BUFFER
    echo "" > $BUFFER
}



#main loop called
main_loop (){
    term_init
    [[ "$1" == "" ]] && time=1 || time=$1
    while [[ 1 ]];do
        tput cup 0 0 >> $BUFFER
        tput il $(tput lines) >>$BUFFER
        main >> $BUFFER 
        tput cup $(tput lines) $(tput cols) >> $BUFFER 
        refresh
        sleep $time
        POSX=0
        POSY=0
    done
}
