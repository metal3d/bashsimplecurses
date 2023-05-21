SHELL=bash
PREFIX ?= /usr/local
LIBDIR ?= $(DESTDIR)$(PREFIX)/lib

CUR_SHA=$(shell git log -n1 --pretty='%h')
CUR_BRANCH=$(shell git branch --show-current)
VERSION=$(shell git describe --exact-match --tags $(CUR_SHA) 2>/dev/null || echo $(CUR_BRANCH)-$(CUR_SHA))

.PHONY: help install uninstall dist
.SILENT: help dist

help:
	echo "Usage: make [install|uninstall] [PREFIX=path]"
	echo
	echo "Run 'make test'. If everything is OK, run 'make install'."
	echo "You can set PREFIX (default. /usr/local) to a valid directory."
	echo
	echo "You can uninstall Bash Simple Curses by running 'make uninstall' (giving the same PREFIX)."
	echo "You may need to run 'sudo make uninstall' if you don't have write permissions on PREFIX."

install:
	@echo "Installing $(LIBDIR)/simple_curses.sh ..."
	@mkdir -p $(LIBDIR)
	install -Dm644 simple_curses.sh $(LIBDIR)/simple_curses.sh
	@echo "done"


uninstall:
	@echo "Removing..."
	rm -rf $(LIBDIR)/simple_curses.sh
	@echo "done"

.ONESHELL:
dist:
	echo "Creating ./dist/bashsimplecurses-$(VERSION).tar.gz ..."
	mkdir -p dist
	rm -rf ./dist/bashsimplecurses-$(VERSION) ./dist/bashsimplecurses-$(VERSION).tar.gz
	mkdir ./dist/bashsimplecurses-$(VERSION)
	cp README.md README
	echo $(VERSION) > ./dist/bashsimplecurses-$(VERSION)/VERSION
	cp LICENSE README AUTHORS INSTALL simple_curses.sh Makefile ./dist/bashsimplecurses-$(VERSION)
	sed -i 's/VERSION="dev"/VERSION="$(VERSION)"/g' ./dist/bashsimplecurses-$(VERSION)/simple_curses.sh
	tar cvfz bashsimplecurses-$(VERSION).tar.gz ./dist/bashsimplecurses-$(VERSION) >/dev/null
	mv bashsimplecurses-$(VERSION).tar.gz ./dist
	rm -rf ./dist/bashsimplecurses-$(VERSION)
	echo "Done at ./dist/bashsimplecurses-$(VERSION).tar.gz"
	rm -f README

clean:
	rm -rf ./dist
