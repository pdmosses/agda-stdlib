# https://github.com/pdmosses/agda-pages/agda-pages.mk

# Set non-default argument values before including this file in Makefile:
#
# AGDA-PAGES := ...  # relative path to AGDA-PAGES submodule/directory
# SOURCES    := ...  # Agda import include-path(s), separated by spaces
# MODULES    := ...  # Agda root module name(s), separated by spaces
# PROTECT    := ...  # protected Markdown files, separated by spaces
# ...                # see below for further optional argument values
# include $(AGDA-PAGES)/agda-pages.mk

##############################################################################
# HELP

# `make` or `make help` displays brief explanations of the non-versioning targets.

.PHONY: help
export HELP
help:
	@echo "$$HELP"

define HELP

make check
  Load $(ROOT-FILES)
make web
  Generate web pages listing the Agda files
make serve
  Browse the generated web pages using a local server
make deploy
  Deploy the unversioned website on GitHub Pages 
make clean
  Remove configuration-dependent generated files
make clean-all
  Remove all generated files
make help-versioning
  Display commands for managing versioned websites

endef

# `make help-versioning` displays brief explanations of the versioning targets.

.PHONY: help-versioning
export HELP_VERSIONING
help-versioning:
	@echo "$${HELP_VERSIONING}"

define HELP_VERSIONING

make start-versioning
  Clear any deployed unversioned website
make deploy VERSION=...
  Deploy version ... of the generated website on GitHub Pages
make default VERSION=...
  Set version ... as the default
make delete VERSION=...
  Remove deployed version ... from GitHub Pages
make list-versions
  Display a list of all deployed versions

endef

# N.B. Before using `make start-versioning`, add the following lines
# in mkdocs.yml:
#
# extra:
#   version:
#     provider: mike
#
# The `mike` commands documented at https://github.com/jimporter/mike/ provide
# more general version management possibilities than this makefile. See also:
# https://blog.lx862.com/blog/2025-06-10-versioning-with-material-mkdocs/

##############################################################################
# ARGUMENT DEFAULT VALUES

# Non-generated webpage source files, separated by spaces (no default):
# PROTECT := 

# Relative path to the agda-pages directory:
AGDA-PAGES ?= agda-pages

# Agda import include-path(s), separated by spaces:
SOURCES    ?= ../agda

# Agda root module name(s), separated by spaces:
MODULES    ?= index

# To link directory names to index pages:
INDEXES    ?= true

# To serve the website at localhost:$(SERVER):
SERVER     ?= 8000

# For sd v1.0.0:
SD         ?= sd
# For sd v1.1.0 (breaking change):
# SD       ?= sd -A`

# VERSION is an optional argument of some versioning commands (no default).

# All files in the docs directory are rendered in the generated website
# (except for docs/.* files and files explicitly excluded in mkdocs.yml).

# Specify top-level navigation links in docs/.nav.yml. The hierarchy in
# navigation sections specified by paths `.../*` is automatically generated
# from the directory structure of the Agda source modules.

# When serving or deploying the generated website, any broken navigation links
# in docs/.nav.yml are reported, along with any pages that are not accessible
# from the generated navigation panels.

##############################################################################
# CONTENTS
#
# VARIABLES
# CHECK THE AGDA SOURCE MODULES
# GENERATE A WEBSITE
# BROWSE A WEBSITE
# DEPLOY AN UNVERSIONED WEBSITE
# REMOVE ALL GENERATED FILES
# MANAGE VERSION DEPLOYMENT
# HELP
# DEBUG

##############################################################################
# VARIABLES

# Shell commands:

SHELL := /bin/sh

# Note: In shell commands, `$(...)` refers to a Makefile variable definition,
# and `$${...}` refers to a shell variable definition. Make removes newlines
# in shell scripts, so end-of-line shell comments `# ...` cannot be used;
# comments are written instead as dummy assignments of the form `_='# ...';`.

# Determine the root module path(s) and file(s):

ROOT-PATHS := $(subst .,/, $(MODULES))

ROOT-FILES := $(strip \
	$(filter %.agda %.lagda %.lagda.tex %.lagda.md, \
	  $(foreach dir, $(SOURCES), \
	    $(wildcard \
	      $(addsuffix .*, $(addprefix $(dir)/, $(ROOT-PATHS)))))))

# Agda requires each include-path to be a separate option:

AGDA := agda $(addprefix --include-path=, $(SOURCES))

# AGDA-QUIET does not print any messages about loading imported modules:
# AGDA-VERBOSE reports loading imported modules, and the location of errors:

AGDA-QUIET   := $(AGDA) --trace-imports=0
AGDA-VERBOSE := $(AGDA) --trace-imports=3

# Suppress mkdocs warning about breaking changes in v2:

MKDOCS := NO_MKDOCS_2_WARNING=1 mkdocs

##############################################################################
# CHECK THE AGDA SOURCE MODULES

# `make check` first tries to load all the ROOT-FILES quietly. When a root file
# has been loaded without errors, it reports that it has been checked; if an
# error occured, it reloads that file verbosely, displaying the error and its
# location (eliding the CURDIR part of the path) then exits.

.PHONY: check
check: 
	@if [ -z "$(ROOT-FILES)" ]; then \
	    echo "Error: No files defining modules $(MODULES) found in:"; \
	    echo "  $(CURDIR)/$(SOURCES)"; \
	    echo "Checking abandoned"; \
	    exit 1; \
	fi
	@for file in $(ROOT-FILES); do \
	  { $(AGDA-QUIET) $${file} 2>&1 > /dev/null && \
	    echo "Checked $${file}"; } || \
	  { $(AGDA-VERBOSE) $${file} 2>&1 | sed -e 's#$(CURDIR)/##'; \
	    echo "Checking abandoned"; \
	    exit 1; } \
	  done
	
##############################################################################
# GENERATE A WEBSITE

# `make web` generates Markdown pages in docs from the Agda ROOT-FILES.

# `agda --html --html-highlight=code FILE` generates files with highlighted
# HTML from plain and literate Agda source files. The generated file extension
# depends on the source file extension:
#   - .html for .agda files,
#   - .tex  for .lagda and .lagda.tex files, and
#   - .md   for .lagda.md files.
# Web pages are not produced from other kinds of literate Agda files.

# Some slight differences between the .tex and .md files: in the .md files,
#   - <pre> tags are followed by newlines;
#   - newlines following </pre> tags are discarded; and
#   - empty code blocks are discarded.

# The files generated by Agda are transformed to Markdown pages as follows:
#   - .html: wrap the whole file in <pre class="Agda">...</pre> tags.
#   - .tex:  move the pre tags from code blocks to wrap the whole file.
#   - .md:   leave the pre tags around code blocks unchanged.
#   - .*:    wrap code blocks in <code class="Agda">...</code> tags.

# The files are generated in a fresh temp directory. To produce the intended
# navigation, the file generated for module M1. ... .Mn in temp needs to be
# renamed to MD/M1/.../Mn/index.md or MD/M1/.../Mn.md, depending on whether
# the navigation.sections feature is enabled, resp. disabled, in mkdocs.yml.

# Assumption: For all M, module M and module M.index do not both exist
# (because the generated pages would have the same URL: .../M/).

# The links in the HTML files generated by agda --html assume they are all in
# the same directory, and that all files have extension html.
# Adjusting the links to hierarchical links with directory URLs involves:
#   - replacing the dots in the basenames of the files by slashes,
#   - prefixing the href URL by the path to the top of the hierarchy,
#   - appending a slash to the file path, and
#   - removing /index.md from URLs.
# N.B. All URLs that do not include a colon are assumed to be links to modules,
# and get replaced by directory URLs (also in literate agda prose blocks).

# After adjusting the links, each file is moved to the appropriate subdirectory
# of docs, and its name and extension updated.

# Finally, the javascripts and stylesheets directories are copied to docs,
# together with a .gitignore file including generated files.

# The links generated by Agda always start with the file name. This could be
# removed for local links where the target is in the same file. Similarly, the
# links to modules in the same directory could be optimized.

.PHONY: web
web: clean

	@if [ -z "$(ROOT-FILES)" ]; then \
	    echo "Error: Files defining modules $(MODULES) not found in"; \
	    echo "$(CURDIR)/$(SOURCES)"; \
	    echo "Website generation abandoned"; \
	    exit 1; \
	fi

# Assumption: Loading the ROOT-FILES does not report errors.

	@for file in $(ROOT-FILES); do \
	    $(AGDA-QUIET) --html --html-highlight=code --highlight-occurrences \
	        --html-dir=temp $${file}; \
	done
	@rm -f temp/*.css temp/*.js
	@mkdir -p docs

	@filelist=$$(ls -1 temp/*); \
	for file in $${filelist}; do \
	    \
	    _='# Get the path of the file relative to temp:'; \
	    path=$${file#temp/}; \
	    _='# Get the module name by dropping the path extension:'; \
	    module=$${path%.*}; \
	    _='# Get the module title by dropping all prefixes:'; \
	    title=$${module##*.}; \
	    \
	    _='# Adjust the pre and code tags:'; \
	    case $${file} in \
	    *.html) \
		_='# Wrap the file in pre and code tags:'; \
		$(SD) '\A' '<pre class="Agda"><code class="Agda">' $${file}; \
		$(SD) '\z' '</code></pre>' $${file}; \
		;; \
	    *.tex) \
		_='# Replace pre tags by code tags, adjusting layout:'; \
		$(SD) '^[ \t]*<pre class="Agda">\n([ \t]*)</pre>\n' '<code class="Agda">$$1</code>' $${file}; \
		$(SD) '^[ \t]*<pre class="Agda">\n' '<code class="Agda">' $${file}; \
		$(SD) '\n[ \t]*</pre>\n' '\n</code>' $${file}; \
		$(SD) '\n[ \t]*</pre>$$' '\n</code>' $${file}; \
		_='# Wrap the file in pre tags:'; \
		$(SD) '\A' '<pre class="Agda">' $${file}; \
		$(SD) '\z' '</pre>' $${file}; \
		;; \
	    *.md) \
		_='# Replace pre tags by code tags:'; \
		$(SD) '(<pre class="Agda">)' '$$1<code class="Agda">' $${file}; \
		$(SD) '(</pre>)' '</code>$$1\n' $${file}; \
		_='# Ensure the page has a top-level heading:'; \
		if ! grep -q '^# ' $${file}; then \
		    $(SD) '\A' "# $${title}\n\n" $${file}; \
		fi; \
		;; \
	    *) \
		echo "Module $${module} has an unsupported type of literate Agda."; \
		echo "No web page has been generated from it,"; \
		echo "and all references to the module are broken links."; \
		exit; \
		;; \
	    esac; \
	    \
	    _='# Prepend front matter:'; \
	    if [ "$${file##*.}" == "md" ]; then \
		$(SD) -- '\A' "---\ntitle: $${title}\n---\n\n" $${file}; \
		_='# Combine with original front matter:'; \
		$(SD) -- '^---\n---\n' "" $${file}; \
	    else \
		$(SD) -- '\A' "---\ntitle: $${title}\nhide: toc\n---\n\n" $${file}; \
	    fi; \
	    \
	    _='# Replace local urls to html files in hrefs by directory urls:'; \
	    $(SD) '(href="[^:"]+)\.html' '$$1/' $${file}; \
	    _='# Replace flat local urls in hrefs by hierarchical urls:'; \
	    while grep -q 'href="[^:".][^:".]*\.' $${file}; do \
		$(SD) '(href="[^:".][^:".]*)\.' '$$1/' $${file}; \
	    done; \
	    _='# Replace `...index/` by `...` in local urls:'; \
	    $(SD) '(href="[^:"]*)index/' '$$1' $${file}; \
	    \
	    _='# Get modulepath by replacing `.`s with `/`s in module:'; \
	    modulepath=$${module//\./\/}; \
	    \
	    if [ "$${module}" == "index" ]; then \
		mdpage=index.md; \
		relurl=""; \
	    elif $(INDEXES) && [ "$${title}" != "index" ] && \
		 (echo "$${filelist}" | grep -q "temp/$${module}\.[^.]*\.[^.]*"); \
	    then \
		_='# Non-leaf modules become index pages:'; \
		mdpage=$${modulepath}/index.md; \
		relurl=$${modulepath}/; \
	    else \
		mdpage=$${modulepath}.md; \
		_='# Remove a trailing /index:'; \
		relurl=$${modulepath%\/index}/; \
	    fi; \
	    \
	    _='# Get the relative path to the top level of docs:'; \
	    path2docs=$$(echo $${relurl} | $(SD) '[^/]*/' '../'); \
	    _='# Prefix local urls by the relative path:'; \
	    $(SD) "href=\"([^:\"]*)\"" "href=\"$${path2docs}\$$1\"" $${file}; \
	    \
	    _='# Ensure the directory for mdpage exists:'; \
	    mkdir -p $$(dirname docs/$${mdpage});  \
	    _='# Move the file from TEMP to docs:'; \
	    mv -f $${file} docs/$${mdpage}; \
	    \
	done

	@rmdir temp

# Copy required files from AGDA-PAGES to required locations:

	@mkdir -p overrides/partials docs/javascripts docs/stylesheets
	@cp $(AGDA-PAGES)/overrides/partials/path.html overrides/partials
	@cp $(AGDA-PAGES)/javascripts/*.js docs/javascripts
	@touch docs/javascripts/custom.js
	@cp $(AGDA-PAGES)/stylesheets/*.css docs/stylesheets
	@touch docs/stylesheets/custom.css

# Generate .gitignore to avoid tracking generated files:

	@printf "%s\n" \
	    '/.gitignore' \
	    '/site/' \
	    '/temp/' \
	    '/overrides/partials/path.html' \
	    '/docs/javascripts/*.js' \
	    '!/docs/javascripts/custom.js' \
	    '/docs/stylesheets/*.css' \
	    '!/docs/stylesheets/custom.css' \
	    '/docs/**/*.md' \
	    > .gitignore
	@for file in $(PROTECT); do \
	    printf "!/%s\n" $${file} >> .gitignore; \
	done

	@echo "Generated webpages in docs"

##############################################################################
# BROWSE A GENERATED WEBSITE

# `make serve` provides a local preview of a generated website (ignoring any
# deployed versions).

.PHONY: serve
serve:
	@if [ ! -f "docs/index.md" ] && [ ! -f "docs/README.md" ]; then \
	    echo "Error: Home page source file not found in"; \
	    echo "$(CURDIR)/docs"; \
	    echo "Serving abandoned"; \
	    exit 1; \
	fi
	@$(MKDOCS) serve --livereload --dev-addr localhost:$(SERVER)

##############################################################################
# DEPLOY AN UNVERSIONED WEBSITE

# `make deploy` publishes a website on GitHub Pages *without* versioning.
# If the website is already deployed as versioned, it first needs to be
# *completely* cleared using `mike delete --all --push`.

.PHONY: deploy

ifndef VERSION
deploy:
	@if ! type -P mike || [ -z "$$(mike list)" ]; then \
	    $(MKDOCS) gh-deploy --force --ignore-version; \
	else \
	    echo "Error: unversioned deployment blocked."; \
	    echo "To deploy an update to version ..., use 'make deploy VERSION=...'."; \
	    echo "To clear ALL deployed versions, use 'mike delete --all --push'."; \
	fi
endif

# `make deploy VERSION=...` is defined differently (see below).

# Note: `mkdocs gh-deploy --ignore-version` allows the version of `mkdocs`
# to differ from the previous deployment. It is unrelated to website versions.

##############################################################################
# REMOVE GENERATED FILES

# EXCEPT-PROTECTED := $(addprefix ' ! -path ', $(PROTECT))
# then remove separating spaces – implemented by:

EXCEPT-PROTECTED := $(subst md ',md',$(foreach p,$(PROTECT),' ! -path '$(strip $p)))

# `make clean` removes unprotected configuration-dependent generated files.

.PHONY: clean
clean:
ifndef PROTECT
	@echo "Error: PROTECT not set in Makefile"
	@exit 1
else
	@find docs -name '*.md$(EXCEPT-PROTECTED)' -delete
	@rm -rf temp .gitignore
	@find . -type d -empty -delete
endif

# `make clean-all` removes all unprotected generated files.

.PHONY: clean-all
clean-all: clean
	@find docs -path 'docs/javascripts/*.js' \
	         ! -path 'docs/javascripts/custom.js' -delete
	@find docs -path 'docs/stylesheets/*.css' \
	         ! -path 'docs/stylesheets/custom.css' -delete
	@rm -f overrides/partials/path.html
	@rm -rf temp site .gitignore
	@find . -type d -empty -delete

##############################################################################
# MANAGE VERSION DEPLOYMENT

# N.B. The following commands use `mike` to push commits to the `gh-pages`
# branch, This starts a GitHub Action to deploy the updated website. If a
# new command is run before the action from the previous command has finished,
# the action may be aborted, causing a failed run. To avoid such issues,
# run a series of `mike` commands directly, including the `--push` option only
# in the last command.

##############################################################################
# START VERSIONING

# `make start-versioning` clears a deployed *unversioned* site, in preparation
# for versioned deployment.
#
# To completely clear a *versioned* site, use `mike delete --all --push`.

# N.B. Before running `make start-versioning`, check that `mike` is installed,
# and uncomment the following lines in mkdocs.yml:
#
# extra:
#   version:
#     provider: mike

.PHONY: start-versioning
start-versioning:
ifndef VERSION
	@if [ -z "$$(mike list)" ]; then \
	    mike delete --all --allow-empty --push; \
	    echo "Cleared any deployed unversioned website"; \
	else \
	    echo "Error: blocked by currently deployed version(s)"; \
	    echo "To clear ALL deployed versions, use 'mike delete --all --push'"; \
	fi
else
	@echo "Error: superfluous VERSION argument; start-versioning abandoned"
endif

##############################################################################
# DEPLOY A VERSION

# `make deploy VERSION=v` publishes version v of the website:

ifdef VERSION
deploy:
	@mike deploy $(VERSION) --push
	@echo "Deployed generated website as version $(VERSION)"
endif

# It is recommended to omit patch numbers in semantic versioning.
# Version identifiers that "look like" versions (e.g. 1.2.3, 1.0b1, v1.0)
# are treated as ordinary versions, whereas other identifiers, like devel,
# are treated as development versions, and placed above ordinary versions.

##############################################################################
# SET A DEPLOYED VERSION AS DEFAULT

# `make default VERSION=...` sets a previously deployed version as the default,
# *without* deploying the current generated website. It also creates or updates
# the alias `default` to point to the default version.

.PHONY: default
default:
ifdef VERSION
	@mike alias $(VERSION) default --update-aliases
	@mike set-default $(VERSION) --allow-empty --push
	@echo "The default version is now $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

##############################################################################
# DELETE A DEPLOYED VERSION

# `make delete VERSION=...` removes a deployed version of a website.

# If VERSION is set as the default version, this can break existing links to
# the website! To avoid that, first use `make default VERSION=...` to change
# the default to a different version.

.PHONY: delete
delete:
ifdef VERSION
	@mike delete $(VERSION) --allow-empty --push
	@echo "Deleted deployed version $(VERSION)"
else
	@echo "Error: missing VERSION=..."
endif

##############################################################################
# LIST VERSIONS

# `make list-versions` lists the current deployed versions.

.PHONY: list-versions
list-versions:
	@mike list

##############################################################################
# DEBUG

# `make debug` shows the values of some of the variables assigned in this file:

.PHONY: debug
export DEBUG
debug:
	@echo "$$DEBUG"

define DEBUG

CURDIR:     $(CURDIR)
AGDA-PAGES: $(AGDA-PAGES)
SOURCES:    $(SOURCES)
MODULES:    $(MODULES)
PROTECT:    $(PROTECT)
INDEXES:    $(INDEXES)
VERSION:    $(VERSION)

ROOT-FILES:
  $(strip $(ROOT-FILES))

endef
