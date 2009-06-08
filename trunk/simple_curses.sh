#!/bin/bash
#simple curses library to create windows on terminal
#
#author: Patrice Ferlet metal3d@copix.org
#license: new BSD
#
#create_buffer patch by Laurent Bachelier

create_buffer(){
  # Try to use SHM, then $TMPDIR, then /tmp
  if [ -d "/dev/shm" ]; then
    BUFFER_DIR="/dev/shm"
  elif [ -z $TMPDIR ]; then
    BUFFER_DIR=$TMPDIR
  else
    BUFFER_DIR="/tmp"
  fi

  [[ "$1" != "" ]] &&  buffername=$1 || buffername="bashsimplecurses"

  # Try to use mktemp before using the unsafe method
  if [ -x `which mktemp` ]; then
    mktemp --tmpdir=${BUFFER_DIR} ${buffername}.XXXXXXXXXX
  else
    echo "${BUFFER_DIR}/bashsimplecurses."$RANDOM
  fi
}

#Usefull variables
LASTCOLS=0
BUFFER=`create_buffer`
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

#initialize chars to use
_TL="\033(0l\033(B"
_TR="\033(0k\033(B"
_BL="\033(0m\033(B"
_BR="\033(0j\033(B"
_SEPL="\033(0t\033(B"
_SEPR="\033(0u\033(B"
_VLINE="\033(0x\033(B"
_HLINE="\033(0q\033(B"
init_chars(){    
    if [[ "$ASCIIMODE" != "" ]]; then
        if [[ "$ASCIIMODE" == "ascii" ]]; then
            _TL="+"
            _TR="+"
            _BL="+"
            _BR="+"
            _SEPL="+"
            _SEPR="+"
            _VLINE="|"
            _HLINE="-"
        fi
    fi
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
    echo -ne $_TL
    for i in `seq 3 $cols`; do echo -ne $_HLINE; done
    echo -ne $_TR
    #next line, draw title
    _nl

    tput sc
    clean_line
    echo -ne $_VLINE
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
    echo -ne $_VLINE
    echo -n -e "\e[00m"
    _nl
    #then draw bottom line for title
    addsep
    
    LASTCOLS=$cols

}

#append a separator, new line
addsep (){
    clean_line
    echo -ne $_SEPL
    for i in `seq 3 $cols`; do echo -ne $_HLINE; done
    echo -ne $_SEPR
    _nl
}


#clean the current line
clean_line(){
    tput sc
    #tput el
    tput rc
    
}


#add text on current window
append_file(){
    [[ "$1" != "" ]] && align="left" || align=$1
    while read l;do
        _append "$l" $align
    done < "$1"
}
append(){
    text=$(echo -e $1 | fold -w $((LASTCOLS-2)) -s)
    rbuffer="/dev/shm/scursesbuffer."$RANDOM
    echo  -e "$text" > $rbuffer
    while read a; do
        _append "$a" $2
    done < $rbuffer
    rm -f $rbuffer
}
_append(){
    clean_line
    tput sc
    echo -ne $_VLINE
    len=$(echo "$1" | wc -c )
    len=$((len-1))
    left=$((LASTCOLS/2 - len/2 -1))
    
    [[ "$2" == "left" ]] && left=0

    tput cuf $left
    echo -e "$1"
    tput rc
    tput cuf $((LASTCOLS-1))
    echo -ne $_VLINE
    _nl
}

#add separated values on current window
append_tabbed(){
    [[ "$3" != "" ]] && delim=$3 || delim=":"
    clean_line
    tput sc
    echo -ne $_VLINE
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
    echo -ne $_VLINE
    _nl
}

#append a command output
append_command(){
    buff=`create_buffer command`
    echo -e "`$1`" > $buff 2>&1
    append_file $buff "no"
    rm -f $buff
}

#close the window display
endwin(){
    clean_line
    echo -ne $_BL
    for i in `seq 3 $LASTCOLS`; do echo -ne $_HLINE; done
    echo -ne $_BR
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
    init_chars
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
