# 
# Makefile for creating distribution of vim config files.
#
# Type 'make dist' for create tar-gziped and zip archiv. 
#
# Developed by Lubomir Host 'rajo' <rajo AT platon.sk>
# Copyright (c) 2001 - 2003 Platon SDG
# Licensed under terms of GNU General Public License.
# All rights reserved.
#

# $Platon: vimconfig/Makefile,v 1.33 2003-11-03 08:20:20 rajo Exp $

PACKAGE = vimconfig
VERSION = 1.8
PACKAGE_TEMPLATE_PLUGIN = templatefile
VERSION_TEMPLATE_PLUGIN = $(VERSION)

# DISTFILES_TEMPLATE_PLUGIN {{{
DISTFILES_TEMPLATE_PLUGIN = vim    \
							vim/plugin \
							vim/plugin/templatefile.vim \
							vim/templates/         \
							vim/templates/skel.c   \
							vim/templates/skel.h   \
							vim/templates/skel.sh  \
							vim/templates/skel.tex \
							vim/templates/Makefile

# DISTFILES_TEMPLATE_PLUGIN }}}

# DISTFILES {{{
DISTFILES = README \
			Makefile vimrc gvimrc vim \
			contrib \
			contrib/update-vim-sources \
			vim/strace.vim \
			vim/csyntax.vim \
			vim/latextags \
			vim/vimlatex \
			vim/compiler \
			vim/compiler/tex.vim \
			vim/diary \
			vim/doc \
			vim/doc/FEATURES.txt \
			vim/doc/tags \
			vim/ftplugin \
			vim/ftplugin/cvs.vim \
			vim/ftplugin/html.vim \
			vim/ftplugin/mail.vim \
			vim/ftplugin/miktexmenus.vim \
			vim/ftplugin/perl.vim \
			vim/ftplugin/sgml.vim \
			vim/ftplugin/tex.vim \
			vim/ftplugin/txt.vim \
			vim/ftplugin/vim.vim \
			vim/indent/ \
			vim/indent/php.vim \
			vim/indent/tex.vim \
			vim/local \
			vim/local/README \
			vim/modules/ \
			vim/modules/diacritics.vim \
			vim/plugin \
			vim/plugin/CmdlineCompl.vim \
			vim/plugin/calendar.vim \
			vim/plugin/imaps.vim \
			vim/plugin/increment.vim \
			vim/plugin/matchit.vim \
			vim/plugin/syntaxFolds.vim \
			vim/syntax/ \
			vim/syntax/FEATURES.vim \
			$(DISTFILES_TEMPLATE_PLUGIN)

# DISTFILES }}}

TAR      = tar
ZIP      = zip
LN_S     = ln -s

ZIP_ENV  = -r9
GZIP_ENV = --best


srcdir                  = .
distdir                 = $(PACKAGE)-$(VERSION)
distdir_template_plugin = $(PACKAGE_TEMPLATE_PLUGIN)-$(VERSION_TEMPLATE_PLUGIN)
top_distdir             = $(distdir)
top_builddir            = .

#########
# Targets

all: tags dist dist-template-plugin
	md5sum *$(VERSION).tar.gz *$(VERSION).zip > $(distdir).md5sums \
	&& cat $(distdir).md5sums

tags: ./vim/doc

./vim/doc/tags: ./vim/doc/FEATURES.txt
	vim -u NONE -U NONE -c ":helptags ./vim/doc" -c ":q" > /dev/null

# Clean {{{
clean: clean-dist clean-dist-template-plugin clean-tags
	-rm -f $(distdir).md5sums

clean-tags:
	rm -f vim/doc/tags

clean-dist: clean-dist-template-plugin
	-rm -rf $(distdir)
	-rm -f $(distdir).tar.gz $(distdir).zip

clean-dist-template-plugin:
	-rm -rf $(distdir_template_plugin)
	-rm -f $(distdir_template_plugin).tar.gz $(distdir_template_plugin).zip

# }}}

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
	@here=`cd $(top_builddir) && pwd`; \
	top_distdir_template_plugin=`cd $(distdir_template_plugin) && pwd`; \
	distdir_template_plugin=`cd $(distdir_template_plugin) && pwd`;
	@FILES=`echo "$(DISTFILES_TEMPLATE_PLUGIN)" | awk 'BEGIN{RS=" "}{print}' | sort -u`; \
	for file in $$FILES; do \
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

# Distribution {{{
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
	      || cp -p $$d/$$file $(distdir)/$$file ; \
	  fi; \
	done
# }}}

# Install {{{
install:
	@here="`pwd`"; \
	backup="bak.`date '+%y%m%d'`"; \
	if [ -d "$$HOME/.vim" -o -L "$$HOME/.vim" ]; then \
		if [ -d "$$HOME/.vim\-$$backup" -o -L "$$HOME/.vim\-$$backup" ]; then \
			echo "Moving           $$HOME/.vim	--->   $$HOME/.vim-`date \"+%y%m%d-%X\"`"; \
			mv "$$HOME/.vim" "$$HOME/.vim-`date '+%y%m%d-%X'`" ; \
			echo "Creating symlink $$HOME/.vim	--->   $$here/vim"; \
			$(LN_S) "$$here/vim" "$$HOME/.vim"; \
		else \
			echo "Moving           $$HOME/.vim	--->   $$HOME/.vim-$$backup"; \
			mv "$$HOME/.vim" "$$HOME/.vim-$$backup"; \
			echo "Creating symlink $$HOME/.vim	--->   $$here/vim"; \
			$(LN_S) "$$here/vim" "$$HOME/.vim"; \
		fi \
	else \
		echo "Creating symlink $$HOME/.vim	--->   $$here/vim"; \
		$(LN_S) "$$here/vim" "$$HOME/.vim"; \
	fi; \
	for file in vimrc gvimrc; do \
		if [ -f "$$HOME/.$$file" -o -L "$$HOME/.$$file" ]; then \
			if [ -f "$$HOME/.$$file\-$$backup" -o -L "$$HOME/.$$file\-$$backup" ]; then \
				echo "Moving           $$HOME/.$$file	--->   $$HOME/.$$file-`date \"+%y%m%d-%X\"`"; \
				mv "$$HOME/.$$file" "$$HOME/.$$file-`date '+%y%m%d-%X'`" ; \
				echo "Creating symlink $$HOME/.$$file	--->   $$here/$$file"; \
				$(LN_S) "$$here/$$file" "$$HOME/.$$file"; \
			else \
				echo "Moving           $$HOME/.$$file	--->   $$HOME/.$$file-$$backup"; \
				mv "$$HOME/.$$file" "$$HOME/.$$file-$$backup;" \
				echo "Creating symlink $$HOME/.$$file	--->   $$here/$$file"; \
				$(LN_S) "$$here/$$file" "$$HOME/.$$file"; \
			fi \
		else \
			echo "Creating symlink $$HOME/.$$file	--->   $$here/$$file"; \
			$(LN_S) "$$here/$$file" "$$HOME/.$$file"; \
		fi; \
	done

# }}}

uninstall:
	@echo "Please remove instalation files manualy:"; \
	 echo "	$$HOME/.vim"; \
	 echo "	$$HOME/.vimrc"; \
	 echo "	$$HOME/.gvimrc";

update:
	@echo "If your version of vimconfig is checked out from"; \
	 echo "CVS Repository, 'make update' works. If you have only"; \
	 echo "tarball, 'make update' failed. You can update manualy"; \
	 echo "running"; \
	 echo ""; \
	 echo "    cvs -d :pserver:anonymous@kepler.fmph.uniba.sk:/home/cvs login"; \
	 echo "    cvs -d :pserver:anonymous@kepler.fmph.uniba.sk:/home/cvs co vimconfig"; \
	 echo "";
# next command may failed, if user doesn't have CVS version of vimconfig
	-cvs update;

.PHONY: clean all

# Modeline {{{
# vim:set ts=4:
# vim600:fdm=marker fdl=0 fdc=3 vb t_vb=:
# }}}

