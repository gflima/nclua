# maint.mk -- Maintainer's makefile.
# Copyright (C) 2013-2014 PUC-Rio/Laboratorio TeleMidia
#
# This file is part of NCLua.
#
# NCLua is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# NCLua is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License
# along with NCLua.  If not, see <http://www.gnu.org/licenses/>.

all: bootstrap
.PHONY: all

OPTIONS ?= --enable-ansi --enable-debug --enable-gcc-warnings
EXTRA ?=
.PHONY: bootstrap
bootstrap:
	./bootstrap
	./configure CFLAGS="" $(OPTIONS) $(EXTRA)

.PHONY: debuild
debuild:
	@$(MAKE) dist
	@set -e;\
	version=`perl -wlne '/^VERSION\s*=\s*(.*)$$/ and print $$1;' Makefile`;\
	package=nclua-$$version;\
	rm -rf ./debuild && mkdir -p ./debuild;\
	mv $$package.tar.xz ./debuild/nclua_$$version.orig.tar.xz;\
	(cd ./debuild && tar -xf nclua_$$version.orig.tar.xz);\
	cp -r ./contrib/debian ./debuild/nclua-$$version;\
	(cd ./debuild/nclua-$$version && debuild -us -uc);\
	rm -rf ./debuild/nclua-$$version


gnulib_remote = http://git.savannah.gnu.org/cgit/gnulib.git/plain
misc_remote = https://github.com/gflima/misc/raw/master
.PHONY: fetch-remote
fetch-remote:
	@fetch () { wget -O "$$2/`basename $$1`" "$$1"; };\
	fetch $(gnulib_remote)/build-aux/git-log-fix ./build-aux;\
	fetch $(gnulib_remote)/build-aux/git-version-gen ./build-aux;\
	fetch $(gnulib_remote)/build-aux/gitlog-to-changelog ./build-aux;\
	fetch $(gnulib_remote)/build-aux/useless-if-before-free ./build-aux;\
	fetch $(gnulib_remote)/m4/manywarnings.m4 ./build-aux;\
	fetch $(gnulib_remote)/m4/perl.m4 ./build-aux;\
	fetch $(gnulib_remote)/m4/valgrind-tests.m4 ./build-aux;\
	fetch $(gnulib_remote)/m4/visibility.m4 ./build-aux;\
	fetch $(gnulib_remote)/m4/warnings.m4 ./build-aux;\
	fetch $(misc_remote)/bootstrap .;\
	fetch $(misc_remote)/luax-macros.h ./lib;\
	fetch $(misc_remote)/macros.h ./lib;\
	fetch $(misc_remote)/syntax-check ./build-aux;\
	chmod +x ./bootstrap ./build-aux/syntax-check;\
	true

vc_list     = git ls-files
VC_LIST_ALL = `$(vc_list) | perl -wnle '-T and print;'`
VC_LIST_AC  = `$(vc_list) '*.ac'`
VC_LIST_AM  = `$(vc_list) '*.am' 'build-aux/Makefile.am.*'`
VC_LIST_C   = `$(vc_list) '*.[ch]'`
VC_LIST_LUA = `$(vc_list) '*.lua'`
VC_LIST_MK  = `$(vc_list) '*.mk'`
VC_LIST_SH  = `$(vc_list) '*.sh'`

perl_after_indent_type_list :=\
  GAsyncResult GObject GdkEventKey GdkFrameClock GtkWidget\
  cairo_rectangle_int_t cairo_surface_t cairo_t canvas_t lua_State\
  ncluaw_event_t ncluaw_t socket_callback_data_t socket_t

perl_after_indent :=\
  s:{\s+([\w\"]):{$$1:g;\
  s:([\w\"\-])\s+}:$$1}:g;\
  $$t=join "|", qw($(perl_after_indent_type_list));\
  s:($$t)(\s\*+)\s+(\w):$$1$$2$$3:g;

perl_after_indent_join_empty_lines=\
  my @files = @ARGV;\
  $$^I = "~";\
  for my $$file (@files) {\
    local $$/;\
    @ARGV = $$file;\
    while (<>) {\
      s/\n\n\n+/\n\n/gs;\
      print;\
    }\
  }

.PHONY: indent
indent:
	@indent -gnu -nut -lps -par -cp0 -il-1 $(VC_LIST_C)
	@indent -gnu -nut -lps -par -cp0 -il-1 $(VC_LIST_C)
	@perl -i'~' -wple '$(perl_after_indent)' $(VC_LIST_C)
	@perl -we '$(perl_after_indent_join_empty_lines)'\
	  $(VC_LIST_C) $(VC_LIST_LUA)

perl_list_c_names :=\
  (/^()()(\w+)\s*\(/ or /^(static\s+)?(const\s+)?\w+\s+\**(\w+)\s+=/)\
  and print "$$ARGV:$$.:$$3";\
  eof and close ARGV;

perl_list_lua_names :=\
  (/^(local\s+)?function\s*([\w\.]+?)\s*\(/ or /^(local\s+)?(\w+)\s*=/)\
  and print "$$ARGV:$$.:$$2";\
  eof and close ARGV;

perl_list_mk_names :=\
  (/^([\w\-]+?):/ or /^(\w+\s*)=/)\
  and print "$$ARGV:$$.:$$1";\
  eof and close ARGV;

.PHONY: list-c-names list-lua-names list-mk-names
list-c-names:
	@perl -wnle '$(perl_list_c_names)' $(VC_LIST_C)
list-lua-names:
	@perl -wnle '$(perl_list_lua_names)' $(VC_LIST_LUA)
list-mk-names:
	@perl -wnle '$(perl_list_mk_names)' $(VC_LIST_MK)

.PHONY: maintainer-clean-diff
maintainer-clean-diff:
	@test `git ls-files --other | wc -l` -ne 0 &&\
	  { echo "error: untracked files not removed by maintainer-clean";\
	    git ls-files --other; exit 1;  } || :

syntax_check_rules =\
  sc-avoid-if-before-free\
  sc-base\
  sc-copyright\
  sc-make-indent\
  $(NULL)

syntax-check: $(syntax_check_rules)
.PHONY: $(syntax_check_rules) syntax-check

sc-avoid-if-before-free:
	@./build-aux/useless-if-before-free\
	  --name=cairo_destroy\
	  --name=cairo_region_destroy\
	  --name=cairo_surface_destroy\
	  --name=pango_font_description_free\
	  $(VC_LIST_C) && exit 1 || :;

sc-base:
	@./build-aux/syntax-check\
	  $(VC_LIST_C) $(VC_LIST_LUA) $(VC_LIST_PL) $(VC_LIST_SH)

perl_sc_copright_exclude :=\
  s:\blib/(macros|luax-macros)\.h\b::g;

sc-copyright:
	@./build-aux/syntax-check-copyright -b='/*' -e='*/'\
	  $$(echo $(VC_LIST_C) | perl -wple '$(perl_sc_copright_exclude)')
	@./build-aux/syntax-check-copyright -b='--[[' -e=']]--'\
	  $(VC_LIST_LUA)
	@./build-aux/syntax-check-copyright -b='#' $(VC_LIST_AC)\
	  $(VC_LIST_AM) $(VC_LIST_MK) $(VC_LIST_SH)

perl_sc_make_indent :=\
  /^\t?\ \S/ and print "$$ARGV:$$.:\n-->$$_\n";\
  eof and close ARGV;

sc-make-indent:
	@perl -wnle '$(perl_sc_make_indent)' $(VC_LIST_AM) $(VC_LIST_MK)

COPYRIGHT_YEAR := 2014
COPYRIGHT_HOLDER := PUC-Rio/Laboratorio TeleMidia
perl_update_copyright :=\
  s:(\W*Copyright\s\(C\)\s\d+)-?\d*(\s\Q$(COPYRIGHT_HOLDER)\E\b)\
   :$$1-$(COPYRIGHT_YEAR)$$2:x;

.PHONY: update-copyright
update-copyright:
	@perl -i'~' -wple '$(perl_update_copyright)' $(VC_LIST_ALL)
