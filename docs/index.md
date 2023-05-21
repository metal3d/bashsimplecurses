# Bash Simple Curses - aka BSC

Bash Simple Curses is a simple bash library to create windows and dashboards. It doesn't require any dependencies. The library provides several functions to call to help you to create interfaces.

BSC is not intended to create interactive forms. Even you can make manage some interactions, you'd rather use `whiptail` or `dialog` wich are adapted on form creation.

BSC is a presentation library. You can use it to present monitoring, job results, etc.

## How to use?

Place the library (`simple_curses.sh` file) inside your project or somewhere else. Then `source` the script as usual:

```bash
source path/to/simple_curses.sh
```

Then:

- create a `main` function where you define the windows
- end by a call to `main_loop`

```bash
#!/bin/bash
source ../simple_curses.sh

main(){
    # create a window
    window "Example" "blue" "50%"
        append "Hello world"
        addsep
        append "The date command"
        append_command "date"
    endwin

    # move on the next column
    col_right

    # and create another window
    window "Example 2" "red" "50%"
        append "Hello world"
        addsep
        append "The date command"
        append_command "date"
    endwin
}
main_loop
```

![Simple example](images/bsc-example.png)


BSC proposes several others functions like `addsep`, `append_tabbed`, `append_file`...

Go to the command reference to lean more.
