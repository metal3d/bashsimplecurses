LIBDIR=/usr/local/lib

all: test
	@echo "If no error, you can now run make install"

help:
	@echo ""
	@echo "Usage: make [test|install|uninstall] [LIBDIR=path]"
	@echo ""
	@echo "Try make test. If everything is ok, you can run make install as root"
	@echo "You can set LIBDIR to a valid directory. Default is $(LIBDIR)"
	@echo ""
	@echo "You can remove installation using make uninstall as root"
	@echo ""

install:
	@echo "Install..."
	install -m655 simple_curses.sh $(LIBDIR)/simple_curses.sh
	@echo "done"

uninstall:
	@echo "Removing library"
	rm -rf $(LIBDIR)/simple_curses.sh
	@echo "done"

test:
	@echo "Check if img2txt is installed"
	which idddmg2txt > /dev/null && echo -e "\033[32mOk\033[0m - you can use img2txt command to display images on window" || echo -e "\033[33mWarning\033[0m - You should install caca-utils or img2txt command"
	echo $(PREFIX)
