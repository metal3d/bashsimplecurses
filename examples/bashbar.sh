#!/bin/bash

. `dirname $0`/../simple_curses.sh

main (){
    #basic information, hostname, date, ...
    window "`hostname`" "red"
    append "`date`"
    addsep
    append_tabbed "Up since|`uptime | cut -f1 -d"," | sed 's/^ *//' | cut -f3- -d" "`" 2 "|"
    append_tabbed "Users:`uptime | cut -f2 -d"," | sed 's/^ *//'| cut -f1 -d" "`" 2
    append_tabbed "`awk '{print "Load average:" $1 " " $2 " " $3}' < /proc/loadavg`" 2
    endwin

    #memory usage
    window "Memory usage" "red"
    append_tabbed `cat /proc/meminfo | awk '/MemTotal/ {print "Total:" $2/1024}'` 2
    append_tabbed `cat /proc/meminfo | awk '/MemFree/ {print "Free:" $2/1024}'` 2
    endwin

    #5 most used processes ordered by cpu and memory usage
    window "Processes taking memory and CPU" "green"
    for i in `seq 2 6`; do
        append_tabbed "`ps ax -o pid,rss,pcpu,ucmd --sort=-cpu,-rss | sed -n "$i,$i p" | awk '{printf "%s: %smo:  %s%%" , $4, $2/1024, $3 }'`" 3
    done
    endwin

    #get dmesg, log it then send to deskbar
    window "Last kernel messages" "blue"
    dmesg | tail -n 10 > /dev/shm/deskbar.dmesg
    append_file /dev/shm/deskbar.dmesg
    rm -f /dev/shm/deskbar.dmesg
    endwin

    #a special manipulation to get net interfaces and IP
    window "Inet interfaces" "grey"
    _ifaces=$(for inet in `ifconfig | cut -f1 -d " " | sed -n "/./ p"`; do ifconfig $inet | awk 'BEGIN{printf "%s", "'"$inet"'"} /adr:/ {printf ":%s\n", $2}'|sed 's/adr://'; done)
    for ifac in $_ifaces; do
        append_tabbed  "$ifac" 2
    done
    endwin
}
main_loop 0.5
