# Usage: sh pages/REF-pages.sh

# Script to generate and deploy a website for a single version of agda-stdlib

# Assumptions:
# - Executables of all the dependencies of Agda-Pages are in PATH
# - The current project is a clone/fork of the agda/agda-stdlib repository
# - Called in the root directory of a tracked branch REF-pages
#   where the pages directory was copied from pdmosses/agda-stdlib-pages/pages
# - The versioned pages website has been initialised using `make start-versioning`

# Check that the pages directory exists:
if [ ! -d "pages" ]
then
  echo "Directory `pages` not found"
  echo "Execution abandoned"
  exit 1
fi

# Check that the current branch name is `REF-pages` and set REF:
BRANCH=$(git branch --show-current)
REF=${BRANCH%-pages}

if [ "${REF}" == "${BRANCH}" ]
then
  echo "Current branch (${BRANCH}) not named '*-pages'"
  echo "Execution abandoned"
  exit 1
else
  printf "\n%s\n" "Generating and deploying website for version ${REF}"
fi

# Set the OWNER of the clone/fork:
ORIGIN=$(git remote get-url origin)
REPO=${ORIGIN#https:\/\/github.com\/}
OWNER=${REPO%%\/*}

printf "\n%s\n\n" "Adding agda-pages submodule to pages"

git submodule add --force https://github.com/pdmosses/agda-pages/ pages/agda-pages
if ! grep -q '^\tbranch = main$' .gitmodules
then
  echo "\tbranch = main" >> .gitmodules
fi
git add .
git commit -a -m 'Add pages'
git push

cd pages

printf "\n%s\n" "Adding pages/properdocs.yml for version ${REF}"
make properdocs

printf "\n%s\n\n" "Copying HTML files to pages/html"
make copy-html

printf "\n%s\n\n" "Generating Markdown files in pages/docs"
make gen-pages

printf "\n%s\n\n" "Deploying version ${REF} to https://${OWNER}.github.io/agda-stdlib/pages/${REF}/"
make deploy VERSION=${REF}

printf "\n%s\n%s\n\n" \
  "If it hasn't appeared on GitHub after a few minutes, check the deployment job status at" \
  "https://github.com/${OWNER}/agda-stdlib/tree/gh-pages"

# Terminal log for generating v2.0-pages:

# agda-stdlib: git checkout -b v2.0-pages v2.0 --recurse-submodules
#
# Switched to a new branch 'v2.0-pages'

# agda-stdlib: git push -u origin v2.0-pages
#
# Total 0 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
# remote: 
# remote: Create a pull request for 'v2.0-pages' on GitHub by visiting:
# remote:      https://github.com/pdmosses/agda-stdlib/pull/new/v2.0-pages
# remote: 
# To https://github.com/pdmosses/agda-stdlib.git
#  * [new branch]          v2.0-pages -> v2.0-pages
# branch 'v2.0-pages' set up to track 'origin/v2.0-pages'.

# agda-stdlib: cp -r ../agda-stdlib-pages/pages .        

# agda-stdlib: time sh pages/REF-pages.sh
#
# Generating and deploying website for version v2.0

# Adding agda-pages submodule to pages

# Reactivating local git directory for submodule 'pages/agda-pages'
# [v2.0-pages 34d54a663] Add pages
#  6 files changed, 289 insertions(+)
#  create mode 100644 .gitmodules
#  create mode 100644 pages/Makefile
#  create mode 100644 pages/REF-pages.sh
#  create mode 160000 pages/agda-pages
#  create mode 100644 pages/docs/.nav.yml
#  create mode 100644 pages/docs/About.md
# Enumerating objects: 10, done.
# Counting objects: 100% (10/10), done.
# Delta compression using up to 10 threads
# Compressing objects: 100% (9/9), done.
# Writing objects: 100% (9/9), 4.50 KiB | 4.50 MiB/s, done.
# Total 9 (delta 1), reused 4 (delta 0), pack-reused 0 (from 0)
# remote: Resolving deltas: 100% (1/1), completed with 1 local object.
# To https://github.com/pdmosses/agda-stdlib.git
#    2b8fff10f..34d54a663  v2.0-pages -> v2.0-pages

# Adding pages/properdocs.yml for version v2.0

# Copying HTML files to pages/html

# Cloning into 'temp'...
# remote: Enumerating objects: 14799, done.
# remote: Counting objects: 100% (14799/14799), done.
# remote: Compressing objects: 100% (1751/1751), done.
# remote: Total 14799 (delta 13782), reused 13959 (delta 13046), pack-reused 0 (from 0)
# Receiving objects: 100% (14799/14799), 72.20 MiB | 27.44 MiB/s, done.
# Resolving deltas: 100% (13782/13782), done.
# Updating files: 100% (19589/19589), done.
# Generated HTML files in html

# Generating Markdown files in pages/docs

# Generated Markdown files in docs and other required files

# Deploying version v2.0 to https://pdmosses.github.io/agda-stdlib/pages/v2.0/

# INFO    -  Cleaning site directory
# INFO    -  Building documentation to directory: /Users/pdm/Projects/Agda/agda-stdlib/pages/site
# INFO    -  Documentation built in 91.82 seconds
# Deployed generated website as version v2.0

# If it hasn't appeared on GitHub after a few minutes, check the deployment job status at
# https://github.com/pdmosses/agda-stdlib/tree/gh-pages

# sh pages/REF-pages.sh  162.39s user 35.12s system 111% cpu 2:56.53 total
