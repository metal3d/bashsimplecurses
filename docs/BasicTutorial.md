# Basic Introduction #

Bash simple curses is a very simple bash library to create "bash windows" and append texts into. 
You only have to know some functions and what to show.

Let's take a look on this little tutorial

# Importing bash functions #

Create a directory where we will work. For example

```bash
mkdir -p ~/tutorial/bashcurses
```

Get bashsimplecurses sources from github.

```bash
cd ~/tutorial/bashcurses
git clone git@github.com:metal3d/bashsimplecurses.git
```

Now, create a tutorial.sh script and edit it, you can use vim, gedit, nano...:

```bash
touch tutorial.sh
#vim tutorial.sh
#or nano tutorial.sh
```

It's ok, then you can add this:

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
#then ask the standard loop
main_loop
```

Save your work. Now, you only have to set this script "executable"

```bash
chmod +x ~/tutorial/bashcurses/tutorial.sh
```

Now, you can try:
```
~/tutorial/bashcurses/tutorial.sh
```

And a window appeaars ! To close your script, you only have to kill or press CTRL+C

![http://www.metal3d.org/captures/bashsimplecurses/tuto1.png](http://www.metal3d.org/captures/bashsimplecurses/tuto1.png)

## Title Colors ##

You can specify colors for titles. For example, change line on tutorial like this:

```
...
   window "Title of my window" "red"
```

Restart your script, and the title is red.

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

This will set the width to 36 caracters (cols).

You may use percent:

```
window "Title of my window" "red" "50%"
```

and the window takes 50% of the terminal width

## Functions reference ##

This is the list of commands you can use:

  * **`window "TITLE" "COLOR" WIDTH`** = create a window with title, color and width
  * **`append "TEXT"`** = append text to the window, be carefull "\n" are not interpreted, you have to append line by line
  * **`append_tabbed "TEXT" COLS SEP`** = As "append" function but TEXT will be displayed as table. You need to give number of cols you will display. SEP is ":" by default
  * **`append_file`** display a file text on window, text is wrapped to fit window
  * **`append_command`** Execute command and display result on window
  * **`addsep`** = Append a separator
  * **`main_loop SEC`** = run loop every SEC second, default is 1 second

That's all folks !
