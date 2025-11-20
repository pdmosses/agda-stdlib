# Additional installation instructions

The repository contains the following additional directory and files:

- `docs`: directory for generating a website
    - `docs/javascripts`: directory for added Javascript files
    - `docs/stylesheets`: directory for added CSS files
    - `docs/.nav.yml`: configuration file for navigation panels
    - `docs/index.md`: Markdown source for the home page of the generated website
- `Makefile`: automation of website and PDF generation
- `mkdocs.yml`: configuration file for the generated website
- `installation-guide.md`: Markdown source for this page

The location of the directory `docs` can be configured by setting `docs_dir`
in `mkdocs.yml`.

The repository does not contain any generated files. The `Makefile` creates
files in the following directories:

- `docs/html`: HTML files
- `docs/md`: Markdown files

The `.gitignore` file contains the following additional lines:

```
docs/md
site
```

The default directories for Agda source code and generated files can be changed
by editing `Makefile`. 

## Additional software dependencies

- [GNU Make] (3.81)
- [sd] (1.0.0)
- [Python 3] (3.14.0)
- [Pip] (25.2)
- [MkDocs] (1.6.1)
- [Material for MkDocs] (9.6.19)
- [Awesome-nav] (3.2.0)
- [mike] (2.0.0)

## Platform dependencies

The website generation has been developed and tested on MacBook laptops
with Apple M1 and M3 chips running macOS Sequoia (15.5) with CLI Tools.

!!! warning

    All `make -f Makefile` commands start by running
    `agda  --include-path=doc --trace-imports=0 --html --html-dir=/tmp/html doc/README.agda`.
    Loading a fresh copy of all the imported modules may take several minutes,
    and `make` proceeds with executing the command only after that.

[GNU Make]: https://www.gnu.org/software/make/manual/make.html
[sd]: https://github.com/chmln/sd/
[Python 3]: https://www.python.org/downloads/
[Pip]: https://pypi.org/project/pip/
[MkDocs]: https://www.mkdocs.org/getting-started/
[Material for MkDocs]: https://squidfunk.github.io/mkdocs-material/getting-started/
[Awesome-nav]: https://lukasgeiter.github.io/mkdocs-awesome-nav/
[mike]: https://github.com/jimporter/mike/