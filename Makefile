# Makefile for creating distribution of vim configfiles.
# Type 'make dist' for create tar-gziped archiv. 

#
# (c) rajo <host8@kepler.fmph.uniba.sk
#

# $ID: $

PACKAGE = vimconfig
VERSION = 1.0

DISTFILES = Makefile .vimrc .vim .vim/strace.vim

#TAR = gtar
TAR = tar
ZIP = zip
ZIP_ENV = -r9
GZIP_ENV = --best


srcdir = .
distdir = $(PACKAGE)-$(VERSION)
top_distdir = $(distdir)
top_builddir = .

dist: distdir
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir).zip $(distdir)
	-rm -rf $(distdir)

dist-all: distdir
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir).zip $(distdir)
	-rm -rf $(distdir)

distdir: $(DISTFILES)
	-rm -rf $(distdir)
	mkdir $(distdir)
	here=`cd $(top_builddir) && pwd`; \
	top_distdir=`cd $(distdir) && pwd`; \
	distdir=`cd $(distdir) && pwd`;
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    mkdir $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done


