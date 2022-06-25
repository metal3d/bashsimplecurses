# Introduction #

Bash provides these features to make various operations:

* `tput` command
* STD* redirection
* color escape codes

Bash Simple Curses makes use of these commands to draw windows, change color, and so on.

## Lines ##

Lines and corners display as "chars". You can try this:

```bash
echo -e "\033(0 l q k x m j \033(B"
```

You will see special chars that we use to create window borders.

## Placing cursor ##

Because we need to write lines and words on screen, `tput` is used. `tput` can move the cursor anywhere you'd like on the terminal.

## Colors ##

Bash can change the text color using escape codes. For example

```bash
echo -e "\033[32mText in red\033[0m"
```

This line displays red text.

## Buffer ##

`tput` has a few problems. Refreshing view isn't pretty while the cursor is moving on screen; a "clipping" appears. That's why Bash Simple Curses needs a STDOUT buffer that won't display until we explicitly ask it to flush the display.

Bash has no STDOUT buffer...

So, to fix the buffering context, Bash Simple Curses redirects each `echo` command to a FIFO placed in /tmp or /dev/shm (depending on the OS).

This buffer is flushed when "refresh" (internal) command is called. This is executed automatically by Bash Simple Curses.

## What's happened? ##

Everything is done when you call the `main_loop` function. This does the following:

* clean screen
* place cursor on top
* initiate buffer

When you create a "window", a title is set with a color and size. The size is kept to set content with same width.

Everytime you call `window` or `append`, a basic method is called to place text on center.
After that, `endwin` closes the window.

`main_loop` sends output to the buffer file. When everything in the `main` function is done, `main_loop` displays the buffer, then cleans it.
