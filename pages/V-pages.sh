# Usage: sh pages/V-pages.sh

# Script to generate and deploy a website for a single version of agda-stdlib

# Assumptions:
# - Executables of all the dependencies of Agda-Pages are in PATH
# - The current project is a clone/fork of the agda/agda-stdlib repository
# - Called in the root directory of a tracked branch V-pages
#   where the pages directory was copied from pdmosses/agda-stdlib-pages/pages
# - The versioned pages website has been initialised using `make start-versioning`

# Check that the pages directory exists:
if [ ! -d "pages" ]
then
  echo "Directory `pages` not found"
  echo "Execution abandoned"
  exit 1
fi

# Check that the current branch name is `V-pages` and set V:
BRANCH=$(git branch --show-current)
V=${BRANCH%-pages}

if [ "$V" == "${BRANCH}" ]
then
  echo "Current branch (${BRANCH}) not named '*-pages'"
  echo "Execution abandoned"
  exit 1
else
  printf "%s" "\nGenerating and deploying website for version $V\n\n"
fi

# Set the OWNER of the clone/fork:
ORIGIN=$(git remote get-url origin)
REPO=${ORIGIN#https:\/\/github.com\/}
OWNER=${REPO%%\/*}

printf "%s" "\nAdding agda-pages submodule to pages\n\n"

git submodule add --force https://github.com/pdmosses/agda-pages/ pages/agda-pages
if ! grep -q '^\tbranch = main$' .gitmodules
then
  echo "\tbranch = main" >> .gitmodules
fi
git add .
git commit -a -m 'Add pages'
git push

cd pages

printf "%s" "\nAdding pages/properdocs.yml for version $V\n\n"
make properdocs

printf "%s" "\nCopying HTML files to pages/html\n\n"
make copy-html

printf "%s" "\nGenerating Markdown files in pages/docs\n\n"
make gen-pages

printf "%s" "\nDeploying version $V to https://${OWNER}.github.io/agda-stdlib/pages/$V/\n\n"
make deploy VERSION=$V

printf "%s" \
  "\nIf it hasn't appeared on GitHub after a few minutes, check the deployment job status at\n" \
  "https://github.com/${OWNER}/agda-stdlib/tree/gh-pages\n\n"
