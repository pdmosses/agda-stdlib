# Agda-StdLib Pages

!!! info
    This ***prototype*** website lists the Agda Standard Library.[^updates]

[^updates]:
    The `master` version of this website might not include recent updates to
    the `master` branch of the [agda-stdlib repository].

Please report any [issues] with the website, including all relevant details. [Discussions]
including queries, comments, and suggestions for improvement, are also welcome.

The rest of this page is an update of the original [agda-stdlib issue].

## Background

The official [agda-stdlib website] provides hyperlinked highlighted listings of all the library
source files (and the accompanying `README` files). Each occurrence of a name in the web pages is
linked to its declaration.

A CI workflow action generates the website remotely, and deploys it to GitHub Pages whenever
changes are pushed to the `master` and `experimental` branches of the [agda-stdlib repository].

The official website is a valuable resource for browsing the library in ordinary web browsers
(online or locally) without needing to download or install anything.
Browsing the library online directly in GitHub is not so easy, due to the lack of hyperlinks
from names to declarations.

However, the official website currently has some significant deficiencies:

1.  **Search:**
    Global textual search in the library is not supported.

2.  **Module navigation:**
    The only support for navigating the module hierarchy is a huge flat list of module names.
    The deeply-nested hierarchy of modules makes it difficult to get an overview of the
    topmost levels.

3.  **Current module:**
    Although hovering over a name shows the name of the module where the name is declared,
    the module name is not usually visible (except in the browser address bar) after clicking
    on the name and jumping to the declaration.

4.  **Scroll to top:**
    It can be tedious to scroll manmually to the top of a page (especially when browsing on a
    mobile device).

5.  **Dark mode:**
    The pages are displayed with white background: switching the system appearance to dark
    does not affect the page rendering, and there is no toggle to switch to a dark background.
    The highlighting palette used is also unsuitable for dark backgrounds.

6.  **Version switching:**
    The web pages do not display a menu for switching between different versions of the library.

## Prototype website

This prototype website aims to address the above deficiencies:

1.  **Search:**
    All pages provide access to global textual search. On larger displays, the search field
    is shown directly in the panel above the page content; on smaller displays, the field
    appears after clicking on an icon.

2.  **Module navigation:**
    When browsing the library on larger displays, a navigation panel is shown on the left,
    displaying the top level of the library directory hierarchy; on smaller displays, the panel
    appears after clicking on an icon. Clicking on a directory name (or a `>` icon) in the
    navigation panel expands the name to display its next level; if the name is also a module name,
    the page shows the code of that module.

3.  **Current module:**
    The name of the module currently being browsed is highlighted in the navigation menu. Moreover,
    the navigation path to the current module is displayed at the top of the page.

4.  **Scroll to top:**
    If you start scrolling towards the top, a `Back to top`  button appears at the top of the
    displayed code.

5.  **Dark mode:**
    All pages provide a toggle to switch the current preference between light, dark, and
    automatic mode. The highlighting palette for dark mode differs from that used for light mode.

6.  **Version switching:**
    All pages provide a version selector at the top.

The prototype lists all Agda source files from the `master` branch and from some previous releases 
of the Agda standard library.

Each version of the website was generated and deployed manually, using the [agda-pages repository]
as a submodule, and files copied from the [agda-stdlib-pages repository].

## Contact

Peter Mosses

[p.d.mosses@tudelft.nl]

[pdmosses.github.io]

[p.d.mosses@tudelft.nl]:        mailto:p.d.mosses@tudelft.nl
[pdmosses.github.io]:           https://pdmosses.github.io

[agda-stdlib fork]:             https://github.com/pdmosses/agda-stdlib/
[issues]:                       https://github.com/pdmosses/agda-stdlib/issues
[discussions]:                  https://github.com/pdmosses/agda-stdlib/discussions
[agda-stdlib-pages repository]: https://github.com/pdmosses/agda-stdlib-pages/
[agda-pages repository]:        https://github.com/pdmosses/agda-pages/

[agda-stdlib issue]:            https://github.com/agda/agda-stdlib/issues/2893
[agda-stdlib repository]:       https://github.com/agda/agda-stdlib/
[agda-stdlib website]:          https://agda.github.io/agda-stdlib/
