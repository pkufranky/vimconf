# Makefile for creating distribution of vim configfiles.
# Type 'make dist' for create tar-gziped and zip archiv. 

#
# (c) rajo <host8@kepler.fmph.uniba.sk
#

# $Id: Makefile,v 1.7 2002/02/17 03:27:41 host8 Exp $

PACKAGE = vimconfig
VERSION = 1.4
PACKAGE_TEMPLATE_PLUGIN = templatefile
VERSION_TEMPLATE_PLUGIN = 1.4

DISTFILES_TEMPLATE_PLUGIN = vim \
						vim/plugin \
						vim/plugin/templatefile.vim \
						vim/templates \
						vim/templates/ \
						vim/templates/skel.c \
						vim/templates/skel.h \
						vim/templates/skel.sh \
						vim/templates/Makefile

DISTFILES = Makefile vimrc vim \
			vim/strace.vim \
			vim/csyntax.vim \
			vim/ftplugin \
			vim/ftplugin/mail.vim \
			vim/ftplugin/perl.vim \
			vim/ftplugin/tex.vim \
			vim/plugin/ \
			vim/plugin/CmdlineCompl.vim \
			vim/plugin/calendar.vim \
			vim/plugin/matchit.vim $(DISTFILES_TEMPLATE_PLUGIN)


#TAR = gtar
TAR = tar
ZIP = zip
ZIP_ENV = -r9
GZIP_ENV = --best


srcdir = .
distdir = $(PACKAGE)-$(VERSION)
distdir_template_plugin = $(PACKAGE_TEMPLATE_PLUGIN)-$(VERSION_TEMPLATE_PLUGIN)
top_distdir = $(distdir)
top_builddir = .

#########
# Targets

all: dist dist-template-plugin

clean: clean-dist clean-dist-template-plugin

clean-dist:
	-rm -rf $(distdir)
	-rm -f $(distdir).tar.gz $(distdir).zip

clean-dist-template-plugin:
	-rm -rf $(distdir_template_plugin)
	-rm -f $(distdir_template_plugin).tar.gz $(distdir_template_plugin).zip

# Distribution of template plugin {{{
dist-template-plugin: distdir_template_plugin
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir_template_plugin).tar.gz $(distdir_template_plugin)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir_template_plugin).zip $(distdir_template_plugin)
	-rm -rf $(distdir_template_plugin)

dist-template-plugin-all: distdir_template_plugin
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir_template_plugin).tar.gz $(distdir_template_plugin)
	ZIP=$(ZIP_ENV) $(ZIP) $(distdir_template_plugin).zip $(distdir_template_plugin)
	-rm -rf $(distdir_template_plugin)

distdir_template_plugin: $(DISTFILES_TEMPLATE_PLUGIN)
	-rm -rf $(distdir_template_plugin)
	mkdir $(distdir_template_plugin)
	here=`cd $(top_builddir) && pwd`; \
	top_distdir_template_plugin=`cd $(distdir_template_plugin) && pwd`; \
	distdir_template_plugin=`cd $(distdir_template_plugin) && pwd`;
	@for file in $(DISTFILES_TEMPLATE_PLUGIN); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    mkdir $(distdir_template_plugin)/$$file; \
	  else \
	    test -f $(distdir_template_plugin)/$$file \
	    || ln $$d/$$file $(distdir_template_plugin)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir_template_plugin)/$$file || :; \
	  fi; \
	done
# }}} Distribution of template plugin

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


# Modeline {{{
# vim:set ts=4:
# vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
# }}}
