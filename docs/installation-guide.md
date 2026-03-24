# Additional installation instructions

The repository contains the following additional directory and files:

- `docs`: directory for generating a website
    - `docs/javascripts`: directory for added Javascript files
    - `docs/stylesheets`: directory for added CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/index.md`: the home page of the generated website
    - `docs/installation-guide.md`: this page
- `Makefile`: automation of website generation
- `mkdocs.yml`: configuration file for the generated website

The repository does not contain any generated files.

The `Makefile` generates files in the docs directory:

- `docs/*.html`: HTML files
- `docs/*/**/index.md`: Markdown files

Moreover, building and deploying the generated website creates the directories
`site` and `temp`.

When they are not needed for browsing or deploying the website, the generated
files can be removed by `make -f Makefile clean-all`.

The following files need to be generated or updated before checking the
library code and generating a website:

- `Everything.agda`
- `EverythingSafe.agda`
- `index.agda`

To do that, run the following commands:

```sh
cp .github/tooling/index.* .
cabal run GenerateEverything
./index.sh
```

To avoid committing generated files to the current branch, the following lines
have been added to `.gitignore`:

```
/docs/*.css
/docs/*.html
/docs/*.js
/docs/*/**/index.md
/index.agda
/index.sh
/site/
```

## Additional software dependencies

- [Awesome-nav] (3.3.0)
- [GNU Make] (3.81)
- [Material for MkDocs] (9.7.6)
- [mike] (2.0.0)
- [MkDocs] (1.6.1)
- [pip] (26.0.1)
- [Python 3] (3.14.0)
- [sd] (1.0.0)

## Platform dependencies

The website generation has been developed and tested on MacBook laptops
with Apple M1 and M3 chips running macOS Tahoe (26.3) with CLI Tools.

[Awesome-nav]: https://lukasgeiter.github.io/mkdocs-awesome-nav/
[GNU Make]: https://www.gnu.org/software/make/manual/make.html
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[mike]: https://github.com/jimporter/mike/
[MkDocs]: https://www.mkdocs.org/getting-started/
[pip]: https://pip.pypa.io/stable/
[Python 3]: https://www.python.org/downloads/
[sd]: https://github.com/chmln/sd/