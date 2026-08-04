SOURCES := ../. ../doc ../src
PROTECT := docs/About.md
SERVER  := 8020

include agda-pages/agda-pages.mk

# Website generation:
#
# cd pages
# make index
# make check
# make web
# make serve
# make deploy VERSION=...

# Optionally:
# make clean-index

# `make index` generates Agda files in the repository root:
#  - Everything.agda
#  - EverythingSafe.agda
#  - index.agda

.PHONY: index
index:
	@cd ..; \
	cp .github/tooling/* .; \
	cabal run GenerateEverything; \
	./index.sh; \
	echo "Generated Agda files in root directory"

# `make clean-index` removes the copied tooling files
# and the files created by GenerateEverything:

.PHONY: clean-index
clean-index:
	@cd ..; \
	rm -f $$(cd .github/tooling && ls *); \
	rm -f Everything.agda EverythingSafe.agda
