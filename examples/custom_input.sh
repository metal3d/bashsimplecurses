#!/usr/bin/env bash
#
#   ./custom_input.sh
#
#   Reverses the given input word.
#   A word is terminated with space.
#
SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
pushd "$SCRIPT_DIR" || exit
. ../simple_curses.sh
WORD=""
main() {
    window "ReverseInput" "white" "20%"
        append "$WORD" "left"
    endwin
}

update() {
    local input_str=$2
    local input=($2)
    if [ -n "${input[0]}" ] && [ "${input_str: -1}" == " " ]
    then
        WORD=$(rev <<<"${input[0]}")
        RETURN_VALUE=${input[*]:1}
    fi
    return 0
}

main_loop "$@" --enable-input
popd || exit
