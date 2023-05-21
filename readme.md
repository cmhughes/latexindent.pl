# latexindent.pl
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=main&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent.pl)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest/)

<img src="documentation/logo.png" alt="latexindent logo" width="25%;"/>

`latexindent.pl` is a `perl` script to *beautify/tidy/format/indent* (add horizontal leading space to)
code within environments, commands, after headings and within special code blocks.

It has the ability to [align delimiters](https://latexindentpl.readthedocs.io/en/latest/sec-default-user-local.html#aligning-at-delimiters)
in environments and commands, and can [modify line breaks](https://latexindentpl.readthedocs.io/en/latest/sec-the-m-switch.html) 
including [text wrapping](https://latexindentpl.readthedocs.io/en/latest/sec-the-m-switch.html#text-wrapping) and 
[one-sentence-per-line](https://latexindentpl.readthedocs.io/en/latest/sec-the-m-switch.html#onesentenceperline-modifying-line-breaks-for-sentences). 

It can also perform string-based and regex-based 
[substitutions/replacements](https://latexindentpl.readthedocs.io/en/latest/sec-replacements.html). The script is customisable through its YAML interface. 

It has support for [Conda](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#using-conda), [docker](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#using-docker)
and [pre-commit](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#pre-commit).

## version

    latexindent.pl, version 3.21.1, 2023-05-20

## author
Chris Hughes (cmhughes)

## example

Before:
``` tex
\begin{one}
latexindent.pl adds leading
space to code blocks.
\begin{two}
It aims to beautify .tex, .sty
and .cls files. It is customisable
via its YAML interface.
\end{two}
\end{one}
```
After running
```
latexindent.pl myfile.tex
```
then you receive:
``` tex
\begin{one}
	latexindent.pl adds leading
	space to code blocks.
	\begin{two}
		It aims to beautify .tex, .sty
		and .cls files. It is customisable
		via its YAML interface.
	\end{two}
\end{one}
```
tl;dr, a [quick start](https://latexindentpl.readthedocs.io/en/latest/sec-introduction.html#quick-start) 
section is available for those short of time.

There are *many* more features available, detailed in full within the [documentation](http://latexindentpl.readthedocs.io/).

## documentation

For complete details, please see:

- pdf: [http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf](http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf)
- online: [http://latexindentpl.readthedocs.io/](http://latexindentpl.readthedocs.io/) (if you find discrepancies between the pdf and readthedocs, defer to the pdf)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest)

## getting started

<details>
<summary>perl users</summary>

You'll need
```
latexindent.pl
LatexIndent/*.pm
defaultSettings.yaml
```
in the same directory.

You'll need a few readily-available perl modules. Full details are given within the Appendix
of the [documentation](https://latexindentpl.readthedocs.io/en/latest/);
you might also like to see [.appveyor.yml](.appveyor.yml) for Strawberry perl users.
</details>
<details>
<summary>Windows users without perl</summary>
Windows users who do not have a perl installation might prefer to get

    latexindent.exe

`latexindent.exe` is a standalone executable file which does not require a `perl` installation.
It is available at [releases](https://github.com/cmhughes/latexindent.pl/releases) page of this repository
and also from [https://ctan.org/tex-archive/support/latexindent](https://ctan.org/tex-archive/support/latexindent).
</details>
<details>
<summary>Linux users</summary>

Please see the [Linux section of the appendix](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#linux) 
</details>
<details>
<summary>Ubuntu Linux users without perl</summary>
Ubuntu Linux users who do not have a perl installation might try the standalone executable

    latexindent-linux

which should be saved as simply `latexindent`. It is available at [releases](https://github.com/cmhughes/latexindent.pl/releases) page of this repository
and also from [https://ctan.org/tex-archive/support/latexindent](https://ctan.org/tex-archive/support/latexindent).
</details>
<details>
<summary>Mac users</summary>

Please see the [Mac section of the appendix](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#mac)
</details>
<details>
<summary>Mac users without perl</summary>
Mac users who do not have a perl installation might try the standalone executable

    latexindent-macos

which should be saved as simply `latexindent`. It is available at [releases](https://github.com/cmhughes/latexindent.pl/releases) page of this repository
and also from [https://ctan.org/tex-archive/support/latexindent](https://ctan.org/tex-archive/support/latexindent).
</details>
<details>
<summary>conda users</summary>
If you use conda you'll only need

    conda install latexindent.pl -c conda-forge

this will install the executable and all its dependencies (including perl) in the activate environment.
You don't even have to worry about `defaultSettings.yaml` as it is included too.

Full details at [using conda](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#using-conda). 

**Important**: the executable name is `latexindent.pl` (not `latexindent`). 

> [![Conda Version](https://img.shields.io/conda/vn/conda-forge/latexindent.pl.svg)](https://anaconda.org/conda-forge/latexindent.pl)
</details>
<details>
<summary>docker users</summary>
If you use latexindent via docker you'll only need

    docker pull ghcr.io/cmhughes/latexindent.pl
    docker run -v /path/to/local/myfile.tex:/myfile.tex --rm -it ghcr.io/cmhughes/latexindent.pl -s -w myfile.tex

Full details at [using docker](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#using-docker).
</details>

## pre-commit

You can use `latexindent` with the [pre-commit
framework](https://pre-commit.com) by adding this to your
`.pre-commit-config.yaml`:

      - repo: https://github.com/cmhughes/latexindent.pl.git
        rev: V3.21.1
        hooks:
          - id: latexindent

Full details at [pre-commit users](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#pre-commit), 
including a [worked example](https://latexindentpl.readthedocs.io/en/latest/sec-appendices.html#pre-commit-example-using-l-m-switches)
demonstrating how you can add a `.latexindent.yaml` to the root of the git repo to customize the behavior.

## testing

A nice way to test the script is to navigate to the test-cases
directory, and then run the command (on Linux/Mac -- sorry, a Windows test-case version is not available):

    ./test-cases.sh

## *important*

This script may not work for your style of formatting; I highly
recommend that when you first use the script you use the `-o` switch
to output to a separate file; something like
```
latexindent.pl myfile.tex -o myfile-output.tex
```
and then check `myfile-output.tex` carefully to make sure that
nothing has been changed (or removed) in a way that will damage
your file.

I recommend using each of the following:
* a visual check, at the very least;
* a check using `latexdiff myfile.tex myfile-output.tex`.

I recommend using a version control system to track your files, especially if you intend 
to use `latexindent.pl` to modify files.

## feature requests

I'm happy to review feature requests, but I make no promises as to if they
will be implemented; if they can be implemented, I make no promises as to
how long it will take to implement them, and in which order I do so -- some
features are more difficult than others! Feel free to post on the issues
page of this repository, but please *do use the given issue template*!

## development model

I follow the development model given here: http://nvie.com/posts/a-successful-git-branching-model/
which means that latexindent.pl always has (at least) two branches:

    main
    develop

The `main` branch always contains the released version and `develop` contains the
development version. When developing a new feature or bug fix, I typically use:

    git checkout develop
    git checkout -b feature/name-of-feature

and then I merge it into the `develop` branch using

    git checkout develop
    git merge feature/name-of-feature --no-ff

I align with many of the approaches and details at [Dramatically increase your productivity with Atomic Git Commits](https://suchdevblog.com/lessons/AtomicGitCommits.html).

## perl version

I develop latexindent.pl on Ubuntu Linux, using [perlbrew](https://perlbrew.pl/); I currently develop on perl version v5.36.0

## GitHub Actions
The standalone executables `latexindent.exe`, `latexindent-linux`, `latexindent-macos` are created and released by [GitHub Actions](https://github.com/features/actions); the
file that controls this is available within the [github/workflows](https://github.com/cmhughes/latexindent.pl/tree/main/.github/workflows) 
directory of this repository, and you can track the actions on the [actions page](https://github.com/cmhughes/latexindent.pl/actions/) of this repository.

> ![Batch latexindent.pl check](https://github.com/cmhughes/latexindent.pl/actions/workflows/batch-check.yaml/badge.svg)
![Publish latexindent.exe](https://github.com/cmhughes/latexindent.pl/actions/workflows/build-documentation-and-executables.yaml/badge.svg)
![Publish docker image](https://github.com/cmhughes/latexindent.pl/actions/workflows/release-docker-ghcr.yml/badge.svg)

## build status
I use [GitHub actions](https://github.com/cmhughes/latexindent.pl/tree/main/.github/workflows) and `AppVeyor` (Windows) as continuous integration services to test `latexindent.pl`. 
I use `git` to track changes in the many test cases listed in the `test-cases` directory. 

[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=main&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent-pl)


## related projects

You might like to checkout the following related projects on github.

[arara](https://github.com/cereda/arara): [![GitHub stars](https://img.shields.io/github/stars/cereda/arara.svg?style=flat-square)](https://github.com/cereda/arara/stargazers)

[atom-beautify](https://github.com/Glavin001/atom-beautify): [![GitHub stars](https://img.shields.io/github/stars/Glavin001/atom-beautify.svg?style=flat-square)](https://github.com/Glavin001/atom-beautify/stargazers)

[LaTeX-Workshop](https://github.com/James-Yu/LaTeX-Workshop): [![GitHub stars](https://img.shields.io/github/stars/James-Yu/LaTeX-Workshop.svg?style=flat-square)](https://github.com/James-Yu/LaTeX-Workshop/stargazers)

[Neelfrost/dotfiles](https://github.com/Neelfrost/dotfiles): [![GitHub stars](https://img.shields.io/github/stars/Neelfrost/dotfiles.svg?style=flat-square)](https://github.com/Neelfrost/dotfiles/stargazers)

[latex-formatter](https://github.com/nfode/latex-formatter): [![GitHub stars](https://img.shields.io/github/stars/nfode/latex-formatter.svg?style=flat-square)](https://github.com/nfode/latex-formatter)

## thank you
Thank you to the [contributors](https://github.com/cmhughes/latexindent.pl/graphs/contributors) to the project!

## quotes

I find that the following quotes resonate with me with regards to my approach to `latexindent.pl`:

- *I want people to use Perl. I want to be a positive ingredient of the world and make my American history. So, whatever it takes to give away my software and get it used, that's great.* Larry Wall
- *A common, brute-force approach to parsing documents where newlines are not significant is to read ... the entire file as one string ... and then extract tokens one by one*, Christiansen & Torkington, Perl Cookbook, Section 6.16
- *Once you understand the power that regular expressions provide, the small amount of work spent learning them will feel trivial indeed* Friedl, Mastering Regular Expressions, end of Chapter 1.
- *a problem speaks to them, and they have to solve it...and it becomes a hobby. But they keep coming back to it every now and then. They keep tinkering. It will never be finished...that's the point of a hobby*, Westwood to Reacher in 'Make Me', Lee Child
- *Perl’s primary strength is in text processing. Be it a regex-based approach or otherwise, Perl is excellent for logfile analysis, text manipulation, in-place editing of files, and scouring structured text files for specific field values*,
  Girish Venkatachalam [Why Perl is still relevant in 2022](https://stackoverflow.blog/2022/07/06/why-perl-is-still-relevant-in-2022/)
- *Do the best you can until you know better. Then when you know better, do better.* Maya Angelou

## changelog
[changelog.md](documentation/changelog.md) provides details of the history of the project.
