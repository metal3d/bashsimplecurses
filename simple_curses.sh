#!/bin/bash
#simple curses library to create windows on terminal
#
#author: Patrice Ferlet metal3d@copix.org
#license: new BSD
#
#create_buffer patch by Laurent Bachelier
#
#restriction to local variables and
#rename variables to ones which will not collide
#by Markus Mikkolainen
#
#support for bgcolors by Markus Mikkolainen
#
#support for delay loop function (instead of sleep,
#enabling keyboard input) by Markus Mikkolainen

VERSION="dev"

bsc_create_buffer(){
    # Try to use SHM, then $TMPDIR, then /tmp
    if [ -d "/dev/shm" ]; then
        BUFFER_DIR="/dev/shm"
    elif [ -n "$TMPDIR" ]; then
        BUFFER_DIR="$TMPDIR"
    else
        BUFFER_DIR="/tmp"
    fi

    local buffername
    [[ "$1" != "" ]] &&  buffername=$1 || buffername="bashsimplecurses"

    # Try to use mktemp before using the unsafe method
    if [ -x `which mktemp` ]; then
        #mktemp --tmpdir=${BUFFER_DIR} ${buffername}.XXXXXXXXXX
        mktemp ${BUFFER_DIR}/${buffername}.XXXXXXXXXX
    else
        rand=`LC_ALL=C tr -dc '[[:alnum:]]' < /dev/urandom | head -c 10`
        echo "${BUFFER_DIR}/bashsimplecurses.$rand"
    fi
}

#Usefull variables
BSC_BUFFER=$(bsc_create_buffer)
BSC_STDERR=$(bsc_create_buffer stderr)
BSC_INPUT_BUFFER=""

reset_layout() {
    BSC_COLLFT=0
    BSC_COLWIDTH=0
    BSC_COLWIDTH_MAX=0
    BSC_WLFT=0
    # Height are not dynamically updated
    # Only at window and endwin call
    # Height of the current window
    BSC_WNDHGT=0
    # Height of the bottom of the current window
    BSC_COLHGT=0
    # Heigh of the bottom of the current column
    BSC_COLBOT=0
    # Height of the maximum bottom ever
    BSC_COLHGT_MAX=0
    # Flags to code the lib user window placement request
    BSC_NEWWIN_TOP_REQ=0
    BSC_NEWWIN_RGT_REQ=0
}

clean_env(){
    rm -rf "$BSC_BUFFER"
    reset_colors
    tput cnorm
    tput cvvis
    stty icanon
    [ -n "${OLD_IFS+x}" ] && IFS="$OLD_IFS"
    setterm -cursor on
}
#call on SIGINT and SIGKILL
#it removes buffer before to stop
bsc_on_kill(){
    clean_env
    exit 15
}

BSC_SIGINT=0
bsc_flag_sigint()
{
    # Defer sigint processing because otherwise commands are pushed into BSC_BUFFER due to redirect in main_loop, which is deleted in clean_env ...
    # This does not seem to be problematic with SIGKILL
    # lets admit it this handling of SIGINT is tedious
    BSC_SIGINT=1
}
trap bsc_on_kill SIGTERM
trap bsc_flag_sigint SIGINT

#initialize terminal
bsc_term_init(){
    if [ "$BSC_MODE" == dashboard ]; then
        tput clear
    fi
    # tput civis
    stty -icanon
}


#change line
bsc__nl(){
    BSC_WNDHGT=$((BSC_WNDHGT+1))
    tput cud1
    tput cub "$(tput cols)"
    [ "$BSC_WLFT" -gt 0 ] && tput cuf "$BSC_WLFT"
    tput sc
}


function move_up(){
    BSC_NEWWIN_TOP_REQ=1
}

function col_right(){
    BSC_NEWWIN_RGT_REQ=1
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
_DIAMOND="\033(00\033(B"
_BLOCK="\033(01\033(B"
_SPINNER=('-' '\' '|' '/')

function bsc_init_chars() {
    if [[ -z "$BSC_ASCIIMODE" && $LANG =~ .*\.UTF-8 ]] ; then BSC_ASCIIMODE=utf8; fi
    if [[ "$BSC_ASCIIMODE" != "" ]]; then
        if [[ "$BSC_ASCIIMODE" == "ascii" ]]; then
            _TL="+"
            _TR="+"
            _BL="+"
            _BR="+"
            _SEPL="+"
            _SEPR="+"
            _VLINE="|"
            _HLINE="-"
            _DIAMOND="*"
            _BLOCK="#"
        fi
        if [[ "$BSC_ASCIIMODE" == "utf8" ]]; then
            _TL="\xE2\x94\x8C"
            _TR="\xE2\x94\x90"
            _BL="\xE2\x94\x94"
            _BR="\xE2\x94\x98"
            _SEPL="\xE2\x94\x9C"
            _SEPR="\xE2\x94\xA4"
            _VLINE="\xE2\x94\x82"
            _HLINE="\xE2\x94\x80"
            _DIAMOND="\xE2\x97\x86"
            _BLOCK="\xE2\x96\x88"
        fi
    fi
}

backtotoprow () {
    local travelback
    travelback=$1

    # Testing if layout would require non destructive scrolling
    nbrows=$(tput lines)
    scrollback=$(( travelback - nbrows ))
    if [ $scrollback -gt 0 ]; then
        #    tput rin $scrollback
        #    travelback=$(( travelback - scrollback ))
        echo "Warning: Current layout is exceeding terminal size. This will break window top alignment. Increase terminal height/reduce window content for proper rendering." >&2
    fi
    [ "$travelback" -gt 0 ] && tput cuu "$travelback"
}

#Append a window
function window() {
    local title
    local color
    local bgcolor
    title=$1
    color=$2
    bgcolor=$4

    [ "$VERBOSE" -eq 2 ] && echo "Begin of window $title" >&2

    # Manage new window position
    case "$BSC_NEWWIN_TOP_REQ$BSC_NEWWIN_RGT_REQ" in
        "00" )
            # Window is requested to be displayed under the previous one
            ;;
        "01" )
            # Window is requested to be displayed to the right of the last one

            BSC_WLFT=$(( BSC_WLFT + BSC_COLWIDTH ))
            [ $BSC_WLFT -gt 0 ] && tput cuf $(( BSC_WLFT ))
            backtotoprow "$BSC_WNDHGT"
            BSC_COLHGT=$(( BSC_COLHGT - BSC_WNDHGT ))
            ;;
        "10" )
            # Window is requested to be displayed overwriting the ones above (??!??)
            # Instead, we reset the layout, enabling more possibilities
            tput cud $(( BSC_COLHGT_MAX - BSC_COLBOT ))
            reset_layout
            ;;
        "11" )
            # Window is requested to be displayed in a new column starting from top
            backtotoprow "$BSC_COLHGT"

            BSC_COLLFT=$(( BSC_COLLFT + BSC_COLWIDTH_MAX ))
            BSC_WLFT=$BSC_COLLFT

            BSC_COLHGT=0
            BSC_COLBOT=0
            BSC_COLWIDTH_MAX=0
            ;;
        * )
            echo "Unexpected window position requirement"
            clean_env
            exit 1
    esac

    # Reset window position mechanism for next window
    BSC_NEWWIN_TOP_REQ=0
    BSC_NEWWIN_RGT_REQ=0
    BSC_WNDHGT=0

    BSC_COLS=$(tput cols)
    case $3 in
        "" )
            # No width given
            ;;
        *% )
            w=${3/'%'}
            BSC_COLS=$((w*BSC_COLS/100))
            ;;
        * )
            BSC_COLS=$3
            ;;
    esac

    if [ "$BSC_COLS" -lt 3 ]; then
        echo "Column width of window \"$title\" is too narrow to render (sz=$BSC_COLS)." >&2
        exit 1;
    fi

    BSC_COLWIDTH=$BSC_COLS
    [ "$BSC_COLWIDTH" -gt "$BSC_COLWIDTH_MAX" ] && BSC_COLWIDTH_MAX=$BSC_COLWIDTH

    # Create an empty line for this window
    BSC_BLANKLINE=$(head -c "$BSC_COLWIDTH" /dev/zero | tr '\0' ' ')
    BSC_LINEBODY=${BSC_BLANKLINE:2}
    local content_len
    content_len=${#BSC_LINEBODY}
    BSC_LINEBODY=${BSC_LINEBODY// /$_HLINE}

    local len=${#title}

    if [ "$BSC_TITLECROP" -eq 1 ] && [ "$len" -gt "$content_len" ]; then
        title="${title:0:$content_len}"
        len=${#title}
    fi

    bsc_left=$(( (BSC_COLS - len)/2 - 1 ))

    # Init top left window corner
    tput cub "$(tput cols)"
    [ "$BSC_WLFT" -gt 0 ] && tput cuf "$BSC_WLFT"
    tput sc

    #draw upper line
    echo -ne "$_TL$BSC_LINEBODY$_TR"

    #next line, draw title
    bsc__nl
    append "$title" center "$color" "$bgcolor"

    #then draw bottom line for title
    addsep
}

reset_colors(){
    echo -ne "\033[00m"
}
setcolor(){
    local color
    color=$1
    case $color in
        grey|gray)
            echo -ne "\033[01;30m"
            ;;
        red)
            echo -ne "\033[01;31m"
            ;;
        green)
            echo -ne "\033[01;32m"
            ;;
        yellow)
            echo -ne "\033[01;33m"
            ;;
        blue)
            echo -ne "\033[01;34m"
            ;;
        magenta)
            echo -ne "\033[01;35m"
            ;;
        cyan)
            echo -ne "\033[01;36m"
            ;;
        white)
            echo -ne "\033[01;37m"
            ;;
        *) #default should be 39 maybe?
            echo -ne "\033[01;37m"
            ;;
    esac
}
setbgcolor(){
    local bgcolor
    bgcolor=$1
    case $bgcolor in
        grey|gray)
            echo -ne "\033[01;40m"
            ;;
        red)
            echo -ne "\033[01;41m"
            ;;
        green)
            echo -ne "\033[01;42m"
            ;;
        yellow)
            echo -ne "\033[01;43m"
            ;;
        blue)
            echo -ne "\033[01;44m"
            ;;
        magenta)
            echo -ne "\033[01;45m"
            ;;
        cyan)
            echo -ne "\033[01;46m"
            ;;
        white)
            echo -ne "\033[01;47m"
            ;;
        black)
            echo -ne "\033[01;49m"
            ;;
        *) #default should be 49
            echo -ne "\033[01;49m"
            ;;
    esac

}

#append a separator, new line
addsep (){
    clean_line
    echo -ne "$_SEPL$BSC_LINEBODY$_SEPR"
    bsc__nl
}

#clean the current line
clean_line(){
    #set default color
    reset_colors

    tput sc
    echo -ne "$BSC_BLANKLINE"
    #tput el
    tput rc
}

#add text on current window
append_file(){
    local filetoprint
    filetoprint=$1
    shift
    append_command "cat $filetoprint" "$@"
}

#tail text from file and add on current window
tail_file(){
    local filetoprint
    filetoprint=$1
    shift
    tail_opts=$1
    shift
    append_command "tail $tail_opts $filetoprint" "$@"
}

#
#   blinkenlights <text> <color> <color2> <incolor> <bgcolor> <light1> [light2...]
#
blinkenlights(){
    local color
    local color2
    local incolor
    local bgcolor
    local lights
    local col
    local text
    text=$1
    color=$2
    color2=$3
    incolor=$4
    bgcolor=$5

    declare -a params
    params=( "$@" )
    unset params[0]
    unset params[1]
    unset params[2]
    unset params[3]
    unset params[4]
    params=( "${params[@]}" )

    lights=""
    while [ -n "$params" ];do
        col=$incolor
        [ "${params[0]}" == "1" ] && col=$color
        [ "${params[0]}" == "2" ] && col=$color2
        lights="${lights} ${_DIAMOND} ${col} ${bgcolor}"
        unset params[0]
        params=( "${params[@]}" )
    done

    bsc__multiappend "left" "[" $incolor $bgcolor $lights "]${text}" $incolor $bgcolor
}

#
#   vumeter <text> <width> <value> <max> [color] [color2] [inactivecolor] [bgcolor]
#
vumeter(){
    local text=$1
    local value=$3
    local len=$2
    local max=$4
    local okcolor=$5
    local overcolor=$6
    local incolor=$7

    local done
    local todo
    local over
    local green
    local red
    local rest

    len=$(( len - 2 ))

    [ "$incolor" == "" ] && incolor="grey"
    [ "$okcolor" == "" ] && okcolor="green"
    [ "$overcolor" == "" ] && overcolor="red"


    done=$(( value * len / max  + 1 ))
    todo=$(( len - done - 1))

    [ "$(( len * 2 / 3 ))" -lt "$done" ] && {
        over=$(( done - ( len * 2 /3 )))
        done=$(( len * 2 / 3 ))
    }

    green=""
    red=""
    rest=""

    for i in `seq 1 $(($done))`;do
        green="${green}|"
    done

    for i in `seq 0 $(($over))`;do
        red="${red}|"
    done
    red=${red:1}
    
    for i in `seq 0 $(($todo))`;do
        rest="${rest}."
    done
    
    [ "$red" == ""  ] && bsc__multiappend "left" "[" $incolor "black" "${green}" $okcolor "black" "${rest}]${text}" $incolor "black"
    [ "$red" != ""  ] && bsc__multiappend "left" "[" $incolor "black" "${green}" $okcolor "black" "${red}" $overcolor "black" "${rest}]${text}" $incolor "black"
}
#
#
#
#   progressbar <length> <progress> <max> [color] [bgcolor]
#
progressbar(){
    local len=$1
    local progress=$2
    local max=$3
    local color=$4
    local bgcolor=$5

    [ "$color" == "" ] && color="green"
    [ "$bgcolor" == "" ] && bgcolor="black"

    case $len in
        *%)
            len=${len/'%'}
            len=$((len*BSC_COLS/100))
            len=$((len-4))
            ;;
        *)
            len=$((len-4))
            ;;
    esac

    if [ $len -lt 3 ];then
        len=3
    fi

    local done=$(( progress * len / max ))
    local todo=$(( len - done - 1 ))
    local modulo=$(( $(date +%s) % 4 ))

    local bar="[";
    for (( c=1; c<=done; c++ )); do
        bar="${bar}${_BLOCK}"
    done
    if [ "$done" -lt "$len" ]; then
        bar="${bar}${_SPINNER[modulo]}"
    fi
    for (( c=1; c<=todo; c++ )); do
        bar="${bar} "
    done
    bar="${bar}]"
    bsc__append "$bar" "left" "$color" "$bgcolor"
}

append(){
    while read -r line; do
        bsc__append "$line" "$2" "$3" "$4"
    done < <(echo -e "$1" | fold -w $((BSC_COLWIDTH-2)) -s)
}
#
#   append a single line of text consisting of multiple
#   segments
#   bsc__multiappend <centering> (<text> <color> <bgcolor>)+
#
bsc__multiappend(){
    local len
    local text
    declare -a params
    params=( "$@" )
    text=""
    unset params[0]
    params=( "${params[@]}" )
    while [ -n "$params" ];do
        text="${text}${params[0]}"
        unset params[0]
        unset params[1]
        unset params[2]
        params=( "${params[@]}" )
    done
    clean_line
    tput sc
    echo -ne $_VLINE
    local len=${#1}
    bsc_left=$(( (BSC_COLWIDTH - len)/2 - 1 ))

    params=( "$@" )
    [[ "${params[0]}" == "left" ]] && bsc_left=0
    unset params[0]
    params=( "${params[@]}" )
    [ $bsc_left -gt 0 ] && tput cuf $bsc_left
    while [ -n "${params}" ];do
        setcolor "${params[1]}"
        setbgcolor "${params[2]}"
        echo -ne "${params[0]}"
        reset_colors
        unset params[0]
        unset params[1]
        unset params[2]
        params=( "${params[@]}" )
    done
    tput rc
    tput cuf $((BSC_COLWIDTH-1))
    echo -ne $_VLINE
    bsc__nl
}
#
#   bsc__append <text> [centering] [color] [bgcolor]
#
bsc__append(){
    local text
    text=$1
    local centering
    centering=$2
    local color
    color=$3
    local bgcolor
    bgcolor=$4
    clean_line
    tput sc
    echo -ne $_VLINE
    local len=${#text}
    local cursor_right_shift
    case "$centering" in
        left)       cursor_right_shift=0 ;;
        right)      cursor_right_shift=$(( BSC_COLWIDTH - 2 - len )) ;;
        center | *) cursor_right_shift=$(( (BSC_COLWIDTH - len)/2 - 1 )) ;;
    esac
    [ "$cursor_right_shift" -gt 0 ] && tput cuf "$cursor_right_shift"
    [ "$VERBOSE" -eq 2 ] && echo "$bsc_left" >&2
    setcolor "$color"
    setbgcolor "$bgcolor"
    echo -ne "$text"
    reset_colors
    tput rc
    tput cuf $((BSC_COLWIDTH-1))
    echo -ne $_VLINE
    bsc__nl
}

#add separated values on current window
append_tabbed(){
    [[ $2 == "" ]] && echo "append_tabbed: Second argument needed" >&2 && exit 1
    [[ "$3" != "" ]] && delim=$3 || delim=":"
    clean_line

    echo -ne $_VLINE
    local len=${#1}
    cell_wdt=$((BSC_COLWIDTH/$2))

    setcolor $4
    setbgcolor $5
    tput sc

    local i
    for i in `seq 0 $(($2))`; do
        tput rc
        cell_offset=$((cell_wdt*i))
        [ $cell_offset -gt 0 ] && tput cuf $cell_offset
        echo -n "`echo -n $1 | cut -f$((i+1)) -d"$delim" | cut -c 1-$((cell_wdt-3))`"
    done

    tput rc
    reset_colors
    tput cuf $((BSC_COLWIDTH-2))
    echo -ne $_VLINE
    bsc__nl
}

#append a command output
append_command(){
    while read -r line; do
        bsc__append "$line" left $2 $3
    done < <( $1 2>&1 | fold -w $((BSC_COLWIDTH-2)) -s)
}

#close the window display
endwin(){
    # Plot bottom line
    echo -ne "$_BL$BSC_LINEBODY$_BR"
    bsc__nl

    BSC_COLHGT=$(( BSC_COLHGT + BSC_WNDHGT ))

    if [ $BSC_COLHGT -gt $BSC_COLBOT ]; then
        BSC_COLBOT=$BSC_COLHGT
    fi

    if [ $BSC_COLBOT -gt $BSC_COLHGT_MAX ]; then
        BSC_COLHGT_MAX=$BSC_COLBOT
    fi
    [ $VERBOSE -eq 2 ] && echo "End of window $title" >&2
}

function usage() {
    script_name=$(basename "$0")
    level=$1


    read -d '' <<-EOF
Usage: $script_name [options]
  -c,  --crop       Title is spread over multiple lines if necessary
                    Using -c, the title will be cropped to fit in 
                    window width
  -h,  --help       Displays this help message
  -hh, --more-help  Displays extended help message with more documentation
  -t,  --time [t]   Sleep time, in seconds, when no "update" function has
                    been defined, this option is used when calling the 
                    "update" function
  -s,  --scroll     Set presentation to scrolling mode.
  -q,  --quiet      There will be no warning messages at all
  -V,  --verbose    Append debug messages after the layout
  --version         Displays script version (${VERSION})

Note: this script is intended to be sourced by another script, not executed.

EOF

printf '%s' "$REPLY"

if [ "$level" == "2" ]; then
    read -r -d ''  <<-EOF
Displays windows in a layout using commands. User defines a "main" function, then calls this script main loop. The current help presents the options of the main loop function, presentation mode and layout usage.

Presentation mode:
==================
  The screen is either managed as a static dashboard (default) or scrolling mode. The latter enables seeing older displays by scrolling back in the terminal emulator window.
  In static mode, the window is cleared and the layout is reset to top left corner.
  In scrolling mode, the window is not cleared and the layout is just reset to the left border, leaving older display available for reading.
  Some windows, like progress bar, loose their interest in scrolling mode, but are compatible.
  In scrolling mode, new layout starts under the previous one. There is no screen clearing. In default mode (dashboard mode), the cursor is placed at the top left corner.

Layout usage:
=============
  Start window creation using "window" function. Width can be direct and percent of the full display area. User can enter more than 100%, there is no consistency check, result in unpredictable.
  End window creation using "endwin" function
  Windows can only be placed next to each other using "col_right" and/or "move_up" functions. This leads to 4 possible placement:
  - window under the previous one : start new window directly after endwin
  - Window on the right of the previous one : use col_right
  - Window on the right starting from first line : use col_right then move_up
  - Start from the bottom of the current one, first row : use move_up
  See examples, especially wintest.sh to see all possible usages.

EOF
printf '%s' "$REPLY" | fold -s -w "${COLUMNS:-80}"
fi
}

parse_args (){
    BSC_MODE=dashboard
    VERBOSE=1
    BSC_TITLECROP=0
    ENABLE_INPUT=0
    time=1
    while [[ $# -gt 0 ]]; do
        # shellcheck disable=SC2034
        case "$1" in
            --version)          echo "$VERSION"; exit 0 ;;
            -c  | --crop)       BSC_TITLECROP=1; shift 1 ;;
            -hh | --more-help)  usage 2; exit 0 ;;
            -h  | --help)       usage; exit 0 ;;
            -q  | --quiet)      VERBOSE=0; shift 1 ;;
            -s  | --scroll)     BSC_MODE=scroll; shift 1 ;;
            -t  | --time)       time=$2; shift 2 ;;
            -V  | --verbose)    VERBOSE=2; shift 1 ;;
            -i  | --enable-input) ENABLE_INPUT=1; shift 1 ;;
            --)                 return 0 ;;
            *)                  echo "Option $1 does not exist"; exit 1;;
        esac
    done
}

BSC_JOB=""


__get_input() {
    local accum
    accum=""
    local char
    OLD_IFS=$IFS
    IFS=""
    while :
    do
        if ! read -t 0
        then
            break
        fi
        read -n 1 char && accum+=$char
    done
    IFS=$OLD_IFS
    BSC_INPUT_BUFFER+=$accum
}

## The display function (called in main loop)
__display() {
    # if an update function has been defined, use it. Or just sleep
    if [ "$(type -t update)" == "function" ]; then
        update_fn="update"
    else
        update_fn="sleep"
    fi

    reset_layout
    echo -n "" > "$BSC_BUFFER"
    rm -f "$BSC_STDERR"

    if [ "$BSC_MODE" == dashboard ]; then
        tput clear >> "$BSC_BUFFER"
        tput cup 0 0 >> "$BSC_BUFFER"
    fi

    # hide cursor
    tput civis >> "$BSC_BUFFER" 2>"$BSC_STDERR"

    # call main function
    main >> "$BSC_BUFFER" 2>"$BSC_STDERR"

    # Go under the higest column, from under the last displayed window
    tput cud $(( BSC_COLHGT_MAX - BSC_COLBOT )) >> "$BSC_BUFFER"
    tput cub "$(tput cols)" >> "$BSC_BUFFER"

    sigint_check

    # Display the buffer
    cat "$BSC_BUFFER"

    [ "$ENABLE_INPUT" == 1 ] && __get_input

    [ "$VERBOSE" -gt 0 ] && [ -f "$BSC_STDERR" ] && cat "$BSC_STDERR" && rm "$BSC_STDERR"
    [ "$ENABLE_INPUT" == 1 ] && [ "$VERBOSE" -gt 0 ] && echo -n "input:$BSC_INPUT_BUFFER"

    # call update function
    # TODO: be able to get the pid of the update function to kill it on 
    #       WINCH signal
    #       note that the update function cannot get global variables 
    #       if we use "&", so "wait" command cannot be the solution
    if [ "$ENABLE_INPUT" == 1 ]; then
        unset RETURN_VALUE
        $update_fn "$time" "$BSC_INPUT_BUFFER"
        retval=$?
        [ -n "${RETURN_VALUE+x}" ] && BSC_INPUT_BUFFER=$RETURN_VALUE
    else
        $update_fn "$time"
        retval=$?
    fi
    if [ $retval -eq 255 ]; then
        clean_env
        exit "$retval"
    fi

    sigint_check
}

__force_refresh() {
    # we need to force a refresh of the screen
    # TODO: find a way to kill the "update" function here
    tput clear
}

#main loop called
main_loop (){
    parse_args "$@"

    bsc_term_init
    bsc_init_chars

    # Capture screen size change in dashboard mode to clean it
    if [ "$BSC_MODE" == dashboard ]; then
        trap "__force_refresh" WINCH
    fi
    
    while true; do
        __display
    done
}
# Calls to this function are placed so as to avoid stdout mangling
sigint_check (){
    if [ $BSC_SIGINT -eq 1 ]; then
        clean_env
        [ -f "$BSC_STDERR" ] && cat "$BSC_STDERR" && rm "$BSC_STDERR"
        # https://mywiki.wooledge.org/SignalTrap
        trap - INT
        kill -s INT "$$"
    fi
}

# case of a not sourced script
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_args "$@"
    usage
    exit 1
fi
