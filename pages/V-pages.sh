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
  printf "\n%s\n\n" "Generating and deploying website for version $V"
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

printf "\n%s\n\n" "Adding pages/properdocs.yml for version $V"
make properdocs

printf "\n%s\n\n" "Copying HTML files to pages/html"
make copy-html

printf "\n%s\n\n" "Generating Markdown files in pages/docs"
make gen-pages

printf "\n%s\n\n" "Deploying version $V to https://${OWNER}.github.io/agda-stdlib/pages/$V/"
make deploy VERSION=$V

printf "\n%s\n%s\n\n" \
  "If it hasn't appeared on GitHub after a few minutes, check the deployment job status at" \
  "https://github.com/${OWNER}/agda-stdlib/tree/gh-pages"
