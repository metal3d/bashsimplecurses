#!/bin/bash

source ./simple_curses.sh
selected="1"
main(){
	local foo1
	local foo2
	window "test" "red" "33%" "blue"
	foo1="black"
	foo2="black"
	[ "$selected" == "1" ] && foo1="grey"
	[ "$selected" == "2" ] && foo2="grey"
	append "footext1" "blue" $foo1
	append "footext2" "cyan" $foo2
	endwin
}
update(){
	local ret
	local success
	#read -n 1 -s -t 1 ret
	read -n 1 -s ret
	success=$?
	echo $ret
	echo $success
	[ "$success" == "0" ] && selected=$ret
}
main_loop update
