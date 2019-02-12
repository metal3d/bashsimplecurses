# Bash Simple Curses

[![Documentation Status](https://readthedocs.org/projects/bashsimplecurses/badge/?version=latest)](https://readthedocs.org/projects/bashsimplecurses/?badge=latest)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses?ref=badge_shield)
                

"Bash simple curses" give you some basic functions to quickly create some windows on you terminal as Xterm, aterm, urxvt...

An example is given: bashbar. Bashbar is a monitoring bar that you can integrate in tiling desktop (Xmonad, WMii...)

The goal of Bash Simple Curses is not done (not yet) to create very complete windows. It is only done to create some colored windows and display informations into.

To use library, you have to import library "simple_curses.sh" into you bash script:

```bash

#!/bin/bash

#import library, please check path
#source /usr/lib/simple_curses.sh
source /usr/local/lib/simple_curses.sh

#Then, you must create a "main" function:
main (){
    #your code here, you can add some windows, text...
    window "title" "color"
    append "Text..."
    endwin
}

#then, you can execute loop:
main_loop 1
```

That's all... 

Go into the project to have documentation about functions: 
https://github.com/metal3d/bashsimplecurses



## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmetal3d%2Fbashsimplecurses?ref=badge_large)