# Makefile for generating websites from Agda sources

# Peter Mosses (@pdmosses)
# November 2025

##############################################################################
# MAIN TARGETS

# MAKE CLEAN WEBSITE:
# make -f Makefile clean-all
# make -f Makefile web

# SHOW EXPLANATIONS OF THE MAIN TARGETS:
# make -f Makefile help

# CHECK THE AGDA CODE:
# make -f Makefile check

# BROWSE AND DEPLOY A WEBSITE:
# make -f Makefile serve
# make -f Makefile deploy

# DEPLOY A VERSION OF A GENERATED WEBSITE:
# make -f Makefile initial VERSION=...
# make -f Makefile default VERSION=...
# make -f Makefile extra   VERSION=...
# make -f Makefile delete  VERSION=...
# make -f Makefile serve-all

# REMOVE ALL GENERATED FILES:
# make -f Makefile clean-all

# SHOW VARIABLE VALUES:
# make -f Makefile debug
# (An example of the output is listed at the end of this file)

# TIMED EXAMPLES:

# agda-stdlib: time make -f Makefile check
# Checking Agda sources finished
# make -f Makefile check  37.74s user 4.92s system 96% cpu 44.116 total

# agda-stdlib: time make -f Makefile clean-all
# make -f Makefile clean-all  21.69s user 4.07s system 98% cpu 26.102 total

# agda-stdlib: time make -f Makefile web      
# Web pages finished
# make -f Makefile web  87.09s user 34.84s system 103% cpu 1:57.83 total

# agda-stdlib: time make -f Makefile serve
# INFO    -  Building documentation...
# INFO    -  Cleaning site directory
# INFO    -  Documentation built in 71.61 seconds
# INFO    -  [12:58:59] Serving on http://127.0.0.1:8000/agda-stdlib/


##############################################################################
# COMMAND LINE ARGUMENTS
#
# Name    Purpose
# -----------------------------
# DIR     Agda import include-path
# ROOT    Agda root module source file
#
# VERSION for versioned website deployment
#
# HTML    generated directory for HTML files
# MD      generated directory for Markdown files
# TEMP    generated directory for temporary files

# ARGUMENT DEFAULT VALUES

DIR     := doc
ROOT    := doc/README.agda
# TODO: update to doc/index.agda

# DIR needs to be a prefix of ROOT; the other arguments are independent.
# Generation of multi-ROOT websites requires multiple calls of make.

HTML    := docs/html
MD      := docs/md
TEMP    := /tmp/html

# All files in the docs directory are rendered in the generated website.
# Top-level navigation links are specified in docs/.nav.yml; the lower
# navigation levels reflect the directory hierarchy of the source files.

# Force sequential execution of phony prerequisites, to avoid use of
# recipes with recursive calls of $(MAKE):

.NOTPARALLEL:

##############################################################################
# CONTENTS
#
# VARIABLES
# HELPFUL TARGETS
# CHECK THE AGDA CODE
# GENERATE WEBPAGES
# BROWSE AND DEPLOY THE GENERATED WEBSITE
# DEPLOY, DELETE, AND BROWSE WEBSITE VERSIONS
# REMOVE GENERATED FILES
# HELPFUL TEXTS

##############################################################################
# VARIABLES

# Characters:

EMPTY :=

SPACE := $(EMPTY) $(EMPTY)

# Shell commands:

SHELL=/bin/sh

PROJECT := $(shell pwd)

AGDA-Q := agda --include-path=$(DIR) --trace-imports=0
AGDA-V := agda --include-path=$(DIR) --trace-imports=3

##############################################################################
# HELPFUL TARGETS

# `make` without a target is equivalent to `make help`. It lists the main
# targets and their purposes:

.PHONY: help
export HELP
help:
	@echo "$$HELP"

# `make debug` shows the values of most of the variables assigned in this file:

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

# The illustrative values below are from generating the Agda-Material website.

##############################################################################
# CHECK THE AGDA CODE

# `make check` loads ROOT, reporting any errors:

.PHONY: check
check:
	@ { $(AGDA-Q) $(ROOT) 2>&1 > /dev/null && \
	    echo "Checking Agda sources finished"; } || \
	  { $(AGDA-V) $(ROOT) 2>&1 | sed -e 's#$(PROJECT)/##'; }
	
##############################################################################
# GENERATE WEBPAGES

# ROOT module path relative to DIR:
NAME-PATH := $(patsubst $(DIR)/%,%,$(basename $(ROOT)))

# ROOT module name:
NAME := $(subst /,.,$(NAME-PATH))

# Target files for HTML generation:
HTML-FILES := $(sort \
	$(HTML)/$(NAME).html \
	$(patsubst $(TEMP)/%,$(HTML)/%,$(shell \
		rm -rf $(TEMP); \
		$(AGDA-Q) --html --html-dir=$(TEMP) $(ROOT) > /dev/null; \
		if [ -d $(TEMP) ]; then \
		  ls $(TEMP)/*.html; \
		else \
		  mkdir $(TEMP); \
		  echo $(TEMP)/ERROR.html; \
		fi)))

# Paths of modules imported (perhaps indirectly) by ROOT:
IMPORT-PATHS := $(subst .,/,$(subst $(HTML)/,,$(basename $(HTML-FILES))))

# Names of imported modules located in DIR:
LOCAL-IMPORT-FILES := $(foreach n,$(IMPORT-PATHS),$(filter $n.%,$(sort $(subst $(DIR)/,,$(shell \
		find $(DIR) -name '*.agda' -or -name '*.lagda')))))

# Target files for Markdown generation:
MD-FILES := $(sort $(addprefix $(MD)/,$(addsuffix /index.md,$(IMPORT-PATHS))))

# `make web` generates the HTML and Markdown sources for all web pages.
# Note: Generating a website for the Agda standard library takes a few minutes.

.PHONY: web
web: html md
	@echo "Web pages finished"

# Generate HTML web pages:

# If agda could print a list of *all* the source files imported by ROOT,
# the html target could be skipped when *none* of them have changed.
# Restricting html generation to just the changed files seems more difficult.

.PHONY: html
html:
	@$(AGDA-Q) --html --html-dir=$(HTML) $(ROOT)

# Alternative rule – potentially quicker:

# html:
# 	@mkdir -p $(HTML) && cp $(TEMP)/* $(HTML)

# Generate Markdown sources for web pages:

# `agda --html --html-highlight=code ROOT.lagda` produces highlighted HTML
# from plain `agda` and literate `lagda` source files. The file extension is
# `tex` for HTML produced from `lagda` files; it is `html` for `agda` files,
# but the files needs to be wrapped in `<pre class="Agda">...</pre>` tags.

# The links in the HTML files assume they are all in the same directory, and
# that all files have extension `.html`. Adjusting them to hierarchical links
# with directory URLs involves replacing the dots in the basenames of the files
# by slashes, prefixing the href by the path to the top of the hierarchy, and
# appending a slash to the file path. All URLs that start with A-Z or a-z are
# assumed to be links to modules, and adjusted in the same way (also in the
# prose parts of the HTML produced from `lagda` files).

# The links generated by Agda always start with the file name. This could be
# omitted for local links where the target is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

.PHONY: md
md: $(MD-FILES)

# Create HTML files and ROOT directory in $(MD):
$(MD)/$(NAME-PATH):
	@$(AGDA-Q) --html --html-highlight=code --html-dir=$(MD) $(ROOT)
	@mkdir -p $(MD)/$(NAME-PATH)

# Use an order-only prerequisite:
$(MD-FILES): $(MD)/%/index.md: $(prefix $(DIR),$(LOCAL-IMPORT-FILES)) \
				| $(MD)/$(NAME-PATH)
	@mkdir -p $(@D)
# Wrap *.html files in <pre> tags, and rename *.html and *.tex files to *.md:
	@if [ -f $(MD)/$(subst /,.,$*).html ]; then \
	    mv -f $(MD)/$(subst /,.,$*).html $@; \
	    sd '\A' '<pre class="Agda">' $@; sd '\z' '</pre>' $@; \
	else \
	    mv -f $(MD)/$(subst /,.,$*).tex $@; \
	fi
# Remove LaTeX page breaks:
	@sd '\n\\(clearpage|newpage)\n' '' $@
# Prepend front matter:
	@sd -- '\A' \
		'---\ntitle: $(*F)\nhide: toc\n---\n\n# $(subst /,.,$*)\n\n' $@
# Use directory URLs:
	@sd '(href="[A-Za-z][^"]*)\.html' '$$1/' $@
# Replace `.`-separated filenames in URLs by `/`-separated paths:
	@while grep -q 'href="[A-Z][^".]*\.' $@; do \
	    sd '(href="[A-Za-z][^".]*)\.' '$$1/' $@; \
	done
# Prefix paths by the relative path to the top level:
	@sd 'href="([A-Za-z])' \
	'href="$(subst $(SPACE),$(EMPTY),$(foreach d,$(subst /, ,$*),../))$$1' \
	$@
	
##############################################################################
# BROWSE AND DEPLOY THE GENERATED WEBSITE

# `make serve` provides a local preview of an unversioned website:

.PHONY: serve
serve:
	@mkdocs serve

# `make deploy` publishes an unversioned website on GitHub Pages:

.PHONY: deploy
deploy:
ifndef VERSION
	@mkdocs gh-deploy --force --ignore-version
else
	@echo "Error: VERSION value set"
	@echo "Use one of the following commands to deploy version v:"
	@echo "  make initial VERSION=v"
	@echo "  make default VERSION=v"
	@echo "  make extra   VERSION=v"
endif

# (The `ignore-version` option is added due to an potential conflict
# between mkdocs and mike version numbers.)

##############################################################################
# DEPLOY, DELETE, AND BROWSE WEBSITE VERSIONS

VERSION =

# The make commands for deploying or deleting a version require VERSION to be
# defined by either passing it as an argument or assigning it as a default.

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.

# N.B. To deploy website versions, uncomment the following lines in mkdocs.yml:
# extra:
#   version:
#     provider: mike

# Agda-Material supports a simplified form of version deployment:
# - make initial VERSION=...
# - make default VERSION=...
# - make extra VERSION=...
# - make delete  VERSION=...
# - make serve-all
# For additional generality, use the `mike` commands documented at
# https://github.com/jimporter/mike.

# `make initial VERSION=...` deletes any previously deployed website (versioned
# or not), publishes the current generated website as the specified version,
# and makes it the default version.

.PHONY: initial
initial:
ifdef VERSION
	@mike delete --all --allow-empty
	@mike deploy $(VERSION) default
	@mike set-default default --push
	@echo "Deployed $(VERSION) as the only version"
else 
	@echo "Error: missing VERSION"
endif

# `make default VERSION=...` publishes or updates the specified version of the
# generated website and ensures that it is the default version:

.PHONY: default
default:
ifdef VERSION
	@mike deploy $(VERSION) default --update-aliases --push
	@echo "Deployed $(VERSION) as the default version"
else
	@echo "Error: missing VERSION"
endif

# `make extra VERSION=...` publishes or updates an extra version of the
# generated website, without updating the default version:

.PHONY: extra
extra:
ifdef VERSION
	@mike deploy $(VERSION) --push
	@echo "Deployed $(VERSION) as an extra version"
else
	@echo "Error: missing VERSION"
endif

# `make delete VERSION=...` removes a published version of a website.
# If this is the default version, this can break existing links to the website!
# To avoid that, first use `make default` to change the default to a
# different version. Note that `make initial` deletes all published versions,
# but then publishes the specified version as the default.

.PHONY: delete
delete:
ifdef VERSION
	@mike delete $(VERSION) --allow-empty --push
	@echo "Deleted $(VERSION)"
else
	@echo "Error: missing VERSION"
endif

# `make serve-versions` provides a local preview of a versioned website.

.PHONY: serve-all
serve-all:
	@mike serve

##############################################################################
# REMOVE GENERATED FILES

# `make clean-all` removes all generated files.

.PHONY: clean-all
clean-all: clean-html clean-md

# `make clean-html` removes the entire HTML directory.

.PHONY: clean-html
clean-html:
	@rm -rf $(HTML)

# `make clean-md` removes the entire MD directory.

.PHONY: clean-md
clean-md:
	@rm -rf $(MD)

##############################################################################
# HELPFUL TEXTS

define HELP

make (or make help)
  Display this list of make targets
make check
  Check loading the Agda source files for $(ROOT)

make web
  Generate web pages for $(ROOT)
make clean-all
  Remove *all* generated files !!!
make serve
  Browse a generated website locally
make deploy
  Deploy an (unversioned) website on GitHub Pages 

Note: Generated files should *not* be committed to the remote repository.

VERSIONING OF GENERATED WEBSITES

make initial VERSION=v
  Deploy version v as the only version on GitHub Pages
make default VERSION=v
  Deploy version v as the default version
make extra VERSION=v
  Deploy version v
make delete VERSION=v
  Remove deployed version v from GitHub Pages
make serve-all
  Browse a generated website and its deployed versions locally

Note: Deployment does *not* push local commits to the remote repository.

endef

# Note: all make commands load $(ROOT) to initialize HTML-FILES

define DEBUG

DIR:          $(DIR)
ROOT:         $(ROOT)
PROJECT:      $(PROJECT)
NAME-PATH:    $(NAME-PATH)
NAME:         $(NAME)

HTML-FILES   (1-9): $(wordlist 1, 9, $(HTML-FILES))

IMPORT-PATHS (1-9): $(wordlist 1, 9, $(IMPORT-PATHS))

LOCAL-IMPORT-FILES (1-9): $(wordlist 1, 9, $(LOCAL-IMPORT-FILES))

MD-FILES     (1-9): $(wordlist 1, 9, $(MD-FILES))

endef

# agda-stdlib: make -f Makefile debug      

# DIR:          doc
# ROOT:         doc/README.agda
# PROJECT:      /Users/pdm/Projects/Agda/agda-stdlib
# NAME-PATH:    README
# NAME:         README

# HTML-FILES   (1-9): docs/html/Agda.Builtin.Bool.html docs/html/Agda.Builtin.Char.Properties.html docs/html/Agda.Builtin.Char.html docs/html/Agda.Builtin.Coinduction.html docs/html/Agda.Builtin.Equality.Erase.html docs/html/Agda.Builtin.Equality.html docs/html/Agda.Builtin.Float.Properties.html docs/html/Agda.Builtin.Float.html docs/html/Agda.Builtin.FromNat.html

# IMPORT-PATHS (1-9): Agda/Builtin/Bool Agda/Builtin/Char/Properties Agda/Builtin/Char Agda/Builtin/Coinduction Agda/Builtin/Equality/Erase Agda/Builtin/Equality Agda/Builtin/Float/Properties Agda/Builtin/Float Agda/Builtin/FromNat

# LOCAL-IMPORT-FILES (1-9): Everything.agda EverythingSafe.agda                                                                          README/Axiom.agda README/Case.agda README/Data/Container/FreeMonad.agda README/Data/Container/Indexed/MultiSortedAlgebraExample.agda README/Data/Container/Indexed/VectorExample.agda README/Data/Default.agda README/Data/Fin/Substitution/UntypedLambda.agda

# MD-FILES     (1-9): docs/md/Agda/Builtin/Bool/index.md docs/md/Agda/Builtin/Char/Properties/index.md docs/md/Agda/Builtin/Char/index.md docs/md/Agda/Builtin/Coinduction/index.md docs/md/Agda/Builtin/Equality/Erase/index.md docs/md/Agda/Builtin/Equality/index.md docs/md/Agda/Builtin/Float/Properties/index.md docs/md/Agda/Builtin/Float/index.md docs/md/Agda/Builtin/FromNat/index.
