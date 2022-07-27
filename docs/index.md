# The simple way #

Bash Simple Curses gives you some basic functions to quickly create windows on your terminal.

An example is given: bashbar. Bashbar is a monitoring bar that you can integrate into tiling window managers.

The (unfinished) goal of Bash Simple Curses is to create very complete windows. It is only made to create colored windows and display information into.

# Why ? #

Bash is very complete and has a great ecosystem; there are commands to do whatever you want. With `curses` you can create a little bar to display information each second, you can change an output command to display a report, etc.

So, we need an easy and useful library to quickly create this kind of views inside of Bash. This is why Bash Simple Curses exists.

# Example: the bashbar #

Bashbar is the given example that shows system information. You only have to resize your terminal window and place it on the left or on the right. This screenshot is made on Xmonad:

This is how it's implemented:

```bash
#!/bin/bash

. `dirname $0`/simple_curses.sh

main (){
    window "`hostname`" "red"
    append "`date`"
    addsep
    append_tabbed "Up since|`uptime | cut -f1 -d"," | sed 's/^ *//' | cut -f3- -d" "`" 2 "|"
    append_tabbed "Users:`uptime | cut -f2 -d"," | sed 's/^ *//'| cut -f1 -d" "`" 2
    append_tabbed "`awk '{print "Load average:" $1 " " $2 " " $3}' < /proc/loadavg`" 2
    endwin 
    
    window "Memory usage" "red"
    append_tabbed `cat /proc/meminfo | awk '/MemTotal/ {print "Total:" $2/1024}'` 2
    append_tabbed `cat /proc/meminfo | awk '/MemFree/ {print "Used:" $2/1024}'` 2
    endwin

    window "Processus taking memory and CPU" "green"
    for i in `seq 2 6`; do
        append_tabbed "`ps ax -o pid,rss,pcpu,ucmd --sort=-cpu,-rss | sed -n "$i,$i p" | awk '{printf "%s: %smo:  %s%%" , $4, $2/1024, $3 }'`" 3
    done
    endwin

    window "Last kernel messages" "blue"
    dmesg | tail -n 10 > /tmp/deskbar.dmesg
    while read line; do
        append_tabbed "$line" 1 "~"
    done < /tmp/deskbar.dmesg
    rm -f /tmp/deskbar.dmesg
    endwin

    window "Inet interfaces" "grey"
    _ifaces=$(for inet in `ifconfig | cut -f1 -d " " | sed -n "/./ p"`; do ifconfig $inet | awk 'BEGIN{printf "%s", "'"$inet"'"} /adr:/ {printf ":%s\n", $2}'|sed 's/adr://'; done)
    for ifac in $_ifaces; do
        append_tabbed  "$ifac" 2
    done
    endwin
}
main_loop 1
```

# Another Example #

This capture shows you that you can do whatever you want with Bash Simple Curses:

Code is:

```bash
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
```

# Other cool ideas #

With `img2txt` from the libcaca library, you can do something like this:

Cool, isn't it?
