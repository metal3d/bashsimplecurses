# Tricks and tips

## One shot display

Sometimes you want to only display the windows as a "one shot command". The tip is to override the `update` function to exit the script.

```bash
main() {
    # create the windows here...
}

update() {
    # immediately exit the script
    exit 0
}

main_loop
```

## Make it a bit interactive

The `update()` function override is especially useful to add interactivity. Use `read` command to intercept keyboard for example.

```bash
message=""

main(){
    window "Example"
    append "This is a simple example of the simple curses library, type a text or use arrows to see the result"
    append "$message"
    endwin
}

readKey(){
    # get pressed key for one second, 
    # - if the key is a letter, return it
    # - if the key is other than a letter, return the escape sequence
    read -rsN1 -t 1 ret && read -t 0.0001 -rsd $'\0' d
    echo -n "$ret$d"
}

update() {
   key=$(readKey)
   case "$key" in
    [a-zA-Z0-9\s\n\d\t\b]) message="$message$key" ;; #append the key to the message
    $'\e[A') message="You pressed up" ;;
    $'\e[B') message="You pressed down" ;;
    $'\e[C') message="You pressed right" ;;
    $'\e[D') message="You pressed left" ;;
    *) message="";;
   esac
}

main_loop
```

