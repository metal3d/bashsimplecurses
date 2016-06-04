# Introduction #

Bash provides some command to make that kind of operations:

* tput command
* STD redirection
* escaped colors

Bash simple curses makes use of this commands to draw windows, change color, and so on.

## Lines ##

Lines and corners are display as "chars". You can try this:

```bash
echo -e "\033(0 l q k x m j \033(B"
```

You will see special chars that we use to create window borders.

## Placing cursor ##

Because we need to write lines and texts on screen, `tput` command is used. `tput` can move cursor everywhere you want on terminal.

## Colors ##

Bash can change the text color using escaped values. For example

```bash
echo -e "\033[32mText in red\033[0m"
```

This line displays text in red color.

## Buffer ##

Tput command is a bit low... Refreshing view is not pretty while the cursor is moving on screen. A "clipping" appears. That's why Bash simple curses needs a STDOUT buffer that is not display until we explicitally ask to flush display.

Bash has no STDOUT buffer...

So, to fix the buffering context, Bash simple curses redirects each "echo" command to a FIFO placed in /tmp/ or /dev/shm/ (depending on the OS).

This buffer is flushed when "refresh" (internal) command is called. This is executed automatically by bashsimplecurses.

## What's happend ? ##

Everything is done when you have call `main_loop` function. This makes:

* clean screen
* place cursor on top
* initiate buffer

When you create a "window", a title is set with color and size. Size is kept to set content with same width.

Everytime you call "window" or "append", a basic method is called to place text on center.
Then "endwin" close window.

`main_loop` sends outuput to the buffer file, when everything on "main" function is done, `main_loop` displays buffer, then clean it.
