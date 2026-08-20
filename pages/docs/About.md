# About Agda Standard Library Pages

This website illustrates and tests use of **[Agda-Pages]** to
**generate websites** with **module navigation** between
**highlighted, hyperlinked listings** of Agda code.

## Website

The **[README]** section was generated from plain Agda files in the
[doc directory].

The **[Library]** section was generated from plain Agda files created by
[GenerateEverything.hs], which import modules from the [src directory].
The Library home page is also the website home page.

When deployed, the website displays a **version selector** on all pages.
Currently, only the `master` version has been deployed; it was generated from
a [fork] of the [Agda StdLib repository] after the release of version 2.4.

!!! warning

    The Agda code in the `master` version of the standard library may have
    been updated since the `master` version of the present website was
    generated. For the definitive listings of the `master` branch, see the
    official [Agda StdLib website].

See the **[Agda-Pages About]** page for an overview of the features
of the generated website, and for links to further examples.

## Generation

The **[Agda-Pages User Guide]** explains how to generate a website listing
Agda code in any GitHub repository.

See the **[Agda-Pages README]** for how to install Agda-Pages,
and for a list of its main software dependencies.

The following files were added to the fork of the standard library repository
to support website generation using Agda-Pages:

```
.
├─  ...
└─  pages/
    ├─  agda-pages/
    │   └─ ...
    ├─  docs/
    │   ├─ About.md
    │   └─ .nav.yml
    ├─  Makefile
    └─  properdocs.yml
```

The [pages directory] includes all the required files:

-   `agda-pages` was added as a Git submodule referring to the
    [Agda-Pages repository].
-   [docs/About.md] is the source file for the present webpage.
-   [docs/.nav.yml] configures the main navigation of the website.
-   [Makefile] configures the location of the Agda source files and
    a non-generated Markdown file.
-   [properdocs.yml] configures the name and location of the website and the
    repository.

Running the following shell commands in the [pages directory] generated the
present website:

```shell
make index
make check
make web
make serve
```

While serving the website, running the [linkcheck] application reports:

```sh
agda-stdlib: .../linkcheck/linkcheck -e :8020 --skip-file ../agda-pages/skip.txt

Perfect. Checked 1935439 links, 1209 destination URLs (1 ignored).
```

The generated website was initially deployed at <https://pdmosses.github.io/agda-stdlib/pages/> by:

```shell
make start-versioning
make deploy VERSION=master
make default VERSION=master
```

An update can be deployed at the same URL by:

```shell
make deploy VERSION=master
```

[Library]:               index.md
[README]:                README/index.md

[Agda-Pages]:            https://pdmosses.github.io/agda-pages/
[Agda-Pages About]:      https://pdmosses.github.io/agda-pages/About/
[Agda-Pages User Guide]: https://pdmosses.github.io/agda-pages/User-Guide/
[Agda-Pages repository]: https://github.com/pdmosses/agda-pages/
[Agda-Pages README]:     https://github.com/pdmosses/agda-pages/blob/main/README.md
[linkcheck]:             https://github.com/filiph/linkcheck/

[fork]:                  https://github.com/pdmosses/agda-stdlib/
[add-pages branch]:      https://github.com/pdmosses/agda-stdlib/tree/add-pages
[doc directory]:         https://github.com/pdmosses/agda-stdlib/tree/add-pages/doc
[src directory]:         https://github.com/pdmosses/agda-stdlib/tree/add-pages/src
[pages directory]:       https://github.com/pdmosses/agda-stdlib/tree/add-pages/pages
[docs/.nav.yml]:         https://github.com/pdmosses/agda-stdlib/blob/add-pages/pages/docs/.nav.yml
[docs/About.md]:         https://github.com/pdmosses/agda-stdlib/blob/add-pages/pages/docs/About.md
[Makefile]:              https://github.com/pdmosses/agda-stdlib/blob/add-pages/pages/Makefile
[properdocs.yml]:        https://github.com/pdmosses/agda-stdlib/blob/add-pages/pages/properdocs.yml
[GenerateEverything.hs]: https://github.com/pdmosses/agda-stdlib/blob/add-pages/GenerateEverything.hs

[Agda StdLib repository]: https://github.com/agda/agda-stdlib/
[Agda StdLib website]:    https://agda.github.io/agda-stdlib/master/
