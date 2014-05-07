
CFLAGS = -g #-Wall -pedantic -std=c99

top_srcdir = ..
DOXYGEN = touch 
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
INSTALL_DIR = /sw/lors/doc/lors

all: html_doc/index.html

html_doc/index.html:
	$(DOXYGEN) doxygen.cfg

install:
	$(mkinstalldirs)  $(INSTALL_DIR)
	if test -f html_doc/index.html; then \
	   /usr/bin/install -c -m 644  html_doc/*.html style_dox.css  $(INSTALL_DIR); \
	fi

distclean: clean
clean:
	@rm -rf man/*

