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


