# Basic Introduction #

Bash Simple Curses is a very simple Bash library to create "bash windows" and append texts into.
You only have to know some functions and what to show.

Let's take a look at this little tutorial.

# Importing bash functions #

Create a directory where we will work. For example:

```bash
mkdir -p ~/tutorial/bashcurses
```

Clone the Bash Simple Curses GitHub repository.

```bash
cd ~/tutorial/bashcurses
git clone git@github.com:metal3d/bashsimplecurses.git
```

Now, create a tutorial.sh script and edit it with your favourite editor:

```bash
touch tutorial.sh
#vim tutorial.sh
#nano tutorial.sh
editor tutorial.sh
```

Now, add this:

```bash
#!/bin/bash

#import bashsimplecurses
source $(dirname $0)/bashsimplecurses/simple_curses.sh

#create the main function
main(){
   window "Title of my window"
   append "It's the content of my window"
   endwin
}
#then call the standard loop
main_loop
```

Save your work. Now, you have to make the script executable:

```bash
chmod +x ~/tutorial/bashcurses/tutorial.sh
```

Now, you can try:
```
~/tutorial/bashcurses/tutorial.sh
```

And a window appeaars! To close your script, you only have to kill the process, or press CTRL+C.

![http://www.metal3d.org/captures/bashsimplecurses/tuto1.png](http://www.metal3d.org/captures/bashsimplecurses/tuto1.png)

## Title Colors ##

You can specify colors for titles. For example, change line on tutorial like this:

```
...
   window "Title of my window" "red"
```

Now restart your script, and the title is red.

![http://www.metal3d.org/captures/bashsimplecurses/tuto2.png](http://www.metal3d.org/captures/bashsimplecurses/tuto2.png)

Provided colors are:

* grey or gray
* red
* yellow
* green
* blue
* magenta
* cyan


## Sizes ##

By default, windows take 100% of terminal width. You can specify number of cols to use:

```
...
   window "Title of my window" "red" 36
```

This will set the width of the window to 36 characters.

You can also use a percentage:

```
window "Title of my window" "red" "50%"
```

and now, the window takes up 50% of the terminal width.

## Functions reference ##

This is a list of commands you can use:

  * **`window "TITLE" "COLOR" WIDTH`**: Create a window with title, color and width.
  * **`append "TEXT"`**: Append text to the window. Be careful, newline characters (`\n`) are not interpreted, you'll have to append line by line.
  * **`append_tabbed "TEXT" COLS SEP`**: This is similar to the `append` function, but `TEXT` will be displayed as a table. You'll need to give the number of characters you will display. SEP is ":" by default.
  * **`append_file`**: Display text from a file on a window. Text is wrapped to fit window.
  * **`tail_file "TAIL_OPTS"`**: `tail` text from a file or pipe to a window. Text is wrapped to fit window.
  * **`append_command`**: Execute a command and display the result on a window.
  * **`addsep`**: Append a separator.
  * **`main_loop SEC`**: Run a loop every SEC second, the default is 1 second.

That's all folks!
