#!/bin/bash

source ./simple_curses.sh
selected="1"
main(){
	local foo1
	local foo2
	window "test" "red" "33%" "blue"
	foo1="black"
	foo2="black"
	case $selected in 
		1)
			foo1="grey"
		;;
		2)
			foo2="grey"
		;;
		*A)
			foo1="grey"
		;;
		*B)
			foo2="grey"
		;;
	esac
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
	[ "$ret" == "^" ] && echo "fub" && read -n 3 -s -t 0 ret
#	echo $ret
#	echo $success
	[ "$success" == "0" ] && selected=$ret
#	exit 1
}
main_loop update
