# Functions reference

For each of the following function, the order of the arguments is important.

## `window` + `endwind`

**Arguments:**

- title: string
- fgcolor: string (optional)
- width: int or string (optional)
- bgcolor: string (optional)

Create a window with title, color and width. You **must** end the window by `endwin`
E.g.

```bash
# create a 20% width window
window "An example" "red" "20%"
# the content...
endwin
```

## `append`

**Arguments:**

- text (sting)

Append text to the window. Be careful, newline characters (`\n`) are not interpreted, you'll have to append line by line.

```bash
main() {
    window "Example"
    append "Hello World :)"
    append "This is a test"
    endwin
}
```

```
┌───────────────────────────────────────────────────────────────────────────┐
│                                  Example                                  │
├───────────────────────────────────────────────────────────────────────────┤
│                              Hello World :)                               │
│                              This is a test                               │
└───────────────────────────────────────────────────────────────────────────┘
```


## `append_tabbed`

**Arguments:**

- text: string
- cols: int
- sep: char (optional, default ":")

This is similar to the `append` function, but `text` is displayed as a table. 

You'll need to give the number of colons to display.


```bash
append_tabbed "Content 1:Content 2:Other content" 3
# equivalent to
append_tabbed "Content 1:Content 2:Other content" 3 ":"
```

```bash
#!/bin/bash
source ../simple_curses.sh

main() {
    window "Example of tabbed values"
        append_tabbed "Content 1:Content 2:Other content" 3
        append_tabbed "Other line:Content 3:Other content 4" 3
    endwin
}
main_loop
```

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         Example of tabbed values                          │
├───────────────────────────────────────────────────────────────────────────┤
│Content 1                Content 2                Other content            │
│Other line               Content 3                Other content 4          │
└───────────────────────────────────────────────────────────────────────────┘
```


Note that the `cols` argument will define the number of columns to display. If the number of elements is greater, so a new line is displayed.


## `append_file`

**Arguments:**

- filename: string

Display text from a file on a window. Text is wrapped to fit window.


## `append_command`

**Arguments:**

- command: string

Execute a command and display the result.

## `addsep`

Append an horizontal separator.

## `tail_file`

**Arguments:**

- filename: string

`tail` text from a file or pipe to a window. Text is wrapped to fit window.

> This function accepts any tail options after the filename

# Special functions

## `main_loop`

Execute the `main` and `update` functions each second.

Options:

- `-t N` change the default update time to N seconds (accepts int and float)
- `-c` force to crop the title to fit the window width
- `-s` set presentation to scrolling mode
- `-q` prevent the warning/error display
- `-V` appends debug messages


## `update`

You may redefine the `update` function. This function is called after each `main_loop` iteration. The default is the "sleep" command.

