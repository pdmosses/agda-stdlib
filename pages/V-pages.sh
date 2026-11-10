# CAVEAT: NOT YET TESTED!

# Usage: sh pages/V-pages.sh

# Script to generate and deploy a website for a single version of agda-stdlib

# Assumptions:
# - Executables of all the dependencies of Agda-Pages
# - A clone/fork of the agda-stdlib repository
# - The versioned pages website has been initialised using `make start-versioning`
# - Called in the root directory of a published branch V-pages
#   where the pages directory was copied from pdmosses/agda-stdlib-pages/pages

# Check that the pages directory exists:
if [ ! -d "pages" ]; then
  echo "Directory `pages` not found"
  echo "Execution abandoned"
  exit 1
fi

# Check that the current branch name is `V-pages` and set V:
BRANCH=$(git branch --show-current)
V=${BRANCH%-pages}

if [ "$V" == "${BRANCH}" ]; then
  echo "Current branch `${BRANCH}` not named `*-pages`"
  echo "Execution abandoned"
  exit 1
fi

# Add agda-pages to pages as a submodule:
git submodule add --force https://github.com/pdmosses/agda-pages/ pages/agda-pages
echo "\tbranch = main" >> .gitmodules
git add .
git commit -a -m 'Add pages'
git push

# Execute make commands from the pages directory:
cd pages
make properdocs # instead of make check
make copy-html  # instead of make gen-html
make gen-pages  # instead of make web

make deploy VERSION=$V -n # Remove "-n" after testing
echo "Generated website not yet deployed"

# Version V should appear at https://OWNER.github.io/agda-stdlib/pages/V/
# If it hasn't appeared after a few minutes, check the deployment job
# at https://github.com/OWNER/agda-stdlib/tree/gh-pages
