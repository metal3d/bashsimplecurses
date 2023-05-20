# Bash Simple Curses

[![Documentation Status](https://readthedocs.org/projects/bashsimplecurses/badge/?version=latest)](https://readthedocs.org/projects/bashsimplecurses/?badge=latest)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses?ref=badge_shield)
                

Bash Simple Curses gives you some basic functions to quickly create windows on your terminal.

An example is given: bashbar. Bashbar is a monitoring bar that you can integrate into tiling window managers.

The (unfinished) goal of Bash Simple Curses is to create windows. It is only done to create colored windows and display information into.

To use this library, you have to import "simple_curses.sh" into your bash script, like so:

```bash

#!/bin/bash

#import library, please check path
#source /usr/lib/simple_curses.sh
source /usr/local/lib/simple_curses.sh

# You must create a "main" function:
main () {
    # Your code here, here we add some windows and text
    window "title" "color"
    append "Text..."
    endwin
}

# Then, execute the loop every second ( -t 1 => 1s)
main_loop -t 1
```

That's all.

Visit the repository's documentation to learn about functions: 
https://github.com/metal3d/bashsimplecurses



## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses?ref=badge_large)
