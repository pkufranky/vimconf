
# XXX XXX XXX  THIS IS A NEW FILE XXX XXX XXX

# Makefile for creating distribution of test package
# Type 'make dist' for create tar-gziped archiv. 

#
# Author: Lubomir Host 'rajo' <rajo AT host.sk>
#

# $Id$

PACKAGE = test
VERSION = 1.0

# Directories {{{

srcdir       = .
top_srcdir   = .
distdir      = $(PACKAGE)-$(VERSION)
top_distdir  = $(distdir)
top_builddir = .

# }}} Directories

# Targets {{{

PROGRAM   = test

SOURCES   = $(srcdir)/test.c

OBJECTS   = $(top_builddir)/test.o

DEP_FILES = $(top_builddir)/.deps/test.P

DISTFILES = Makefile \
			test.c

CONFIG_HEADER   = $(top_builddir)/config.h

# }}} Targets

# Programs {{{

TAR      = tar
ZIP      = zip
ZIP_ENV  = -r9
GZIP_ENV = --best

CC       =
CPP      =
CXX      =
#DEBUG_FLAGS = -g -ggdb -DDEBUG
CFLAGS   = -O2 -Wall -Wshadow -pedantic $(DEBUG_FLAGS)
CPPFLAGS =
LDFLAGS  =
DEFS     =
INCLUDES = -I$(srcdir) -I$(top_builddir)
LIBS     =


COMPILE  = $(CC) $(DEFS) $(INCLUDES) $(CPPFLAGS) $(CFLAGS)
CCLD     = $(CC)
LINK     = $(CCLD) $(CFLAGS) $(LDFLAGS) -o $@

# }}} Programs

all: $(PROGRAM)
	
$(PROGRAM): $(OBJECTS)
	$(LINK) $(OBJECTS) $(LIBS)

DEPS_MAGIC := $(shell mkdir .deps > /dev/null 2>&1 || :)
#-include $(DEP_FILES)

.s.o:
	$(COMPILE) -c $<

%.o: %.c $(CONFIG_HEADER)
	@echo '$(COMPILE) -c $<'; \
	$(COMPILE) -Wp,-MD,.deps/$(*F).pp -o $@ -c $<
	@-cp .deps/$(*F).pp .deps/$(*F).P; \
	tr ' ' '\012' < .deps/$(*F).pp \
	  | sed -e 's/^\\$$//' -e '/^$$/ d' -e '/:$$/ d' -e 's/$$/ :/' \
	    >> .deps/$(*F).P; \
	rm .deps/$(*F).pp

clean:
	-rm -f *.o core

.PHONY:	sources
sources:
	@echo $(SOURCES:%=cfg/%)

# Distribution targets {{{
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
	@here=`cd $(top_builddir) && pwd`; \
	top_distdir=`cd $(distdir) && pwd`; \
	distdir=`cd $(distdir) && pwd`;
	@FILES=`echo "$(DISTFILES)" | awk 'BEGIN{RS=" "}{print}' | sort -u`; \
	for file in $$FILES; do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    mkdir $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done

# }}}

# vim600: fdm=marker fdc=3

