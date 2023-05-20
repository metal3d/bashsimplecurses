SHELL=bash
PREFIX ?= /usr/local
LIBDIR ?= $(DESTDIR)$(PREFIX)/lib

CUR_SHA=$(shell git log -n1 --pretty='%h')
CUR_BRANCH=$(shell git branch --show-current)
VERSION=$(shell git describe --exact-match --tags $(CUR_SHA) 2>/dev/null || echo $(CUR_BRANCH)-$(CUR_SHA))

.PHONY: help test install uninstall dist

all: test
	@echo "If no error was displayed, you can run 'make install'"

help:
	@echo ""
	@echo "Usage: make [test|install|uninstall] [LIBDIR=path]"
	@echo ""
	@echo "Run 'make test'. If everything is OK, run 'make install' as root."
	@echo "You can set LIBDIR to a valid directory. Default is $(LIBDIR)"
	@echo ""
	@echo "You can uninstall Bash Simple Curses by running 'make uninstall' as root."
	@echo ""

install:
	@echo "Installing..."
	@mkdir -p $(LIBDIR)
	install -m655 simple_curses.sh $(LIBDIR)/simple_curses.sh
	@echo "done"

uninstall:
	@echo "Removing..."
	rm -rf $(LIBDIR)/simple_curses.sh
	@echo "done"

test:
	@echo "Checking if img2txt is installed"
	@which img2txt > /dev/null && echo -e "\033[32mOk\033[0m - you can use img2txt command to display images on window" || echo -e "\033[33mWarning\033[0m - You should install caca-utils or img2txt command"

dist:
	@mkdir -p dist
	@rm -rf ./dist/bashsimplecurses-$(VERSION) ./dist/bashsimplecurses-$(VERSION).tar.gz
	@mkdir ./dist/bashsimplecurses-$(VERSION)
	@cp README.md README
	@echo $(VERSION) > ./dist/bashsimplecurses-$(VERSION)/VERSION
	@cp LICENSE README AUTHORS INSTALL simple_curses.sh Makefile ./dist/bashsimplecurses-$(VERSION)
	@sed -i 's/VERSION="dev"/VERSION="$(VERSION)"/g' ./dist/bashsimplecurses-$(VERSION)/simple_curses.sh
	@tar cvfz bashsimplecurses-$(VERSION).tar.gz ./dist/bashsimplecurses-$(VERSION) >/dev/null
	@cp bashsimplecurses-$(VERSION).tar.gz ./dist
	@rm -rf ./dist/bashsimplecurses-$(VERSION)
	@echo "./dist/bashsimplecurses-$(VERSION).tar.gz done"
	@rm -f README
