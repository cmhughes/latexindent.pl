# latexindent.pl
[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=main)](https://travis-ci.org/cmhughes/latexindent.pl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=main&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent.pl)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest/)

<img src="documentation/logo.png" alt="latexindent logo" width="25%;"/>

`latexindent.pl` is a `perl` script to indent (add horizontal leading space to)
code within environments, commands, after headings and within special code blocks.

It has the ability to align delimiters in environments and commands, and
can modify line breaks.

## version

    latexindent.pl, version 3.13.3, 2021-12-13

## author
Chris Hughes (cmhughes)

## example
A simple example follows; there are *many* more features available, detailed in full within the [documentation](http://latexindentpl.readthedocs.io/).

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
After:
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

## documentation

For complete details, please see:

- pdf: [http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf](http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf)
- online: [http://latexindentpl.readthedocs.io/](http://latexindentpl.readthedocs.io/) (if you find discrepancies between the pdf and readthedocs, defer to the pdf)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest)

## build status
I use both `travis-ci` (Linux) and `AppVeyor` (Windows) as continuous integration services to test `latexindent.pl` for a small selection of test cases for every commit (I use `git` to track changes in the many test cases listed in the `test-cases` directory); you can see which versions of `perl` are tested by `travis-ci` within `.travis.yml`.
Additionally, [GitHub actions](https://github.com/cmhughes/latexindent.pl/tree/main/.github/workflows) performs checks on a selection
of test cases on every commit.

[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=main)](https://travis-ci.org/cmhughes/latexindent.pl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=main&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent-pl)

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
you might also like to see [.travis.yml](.travis.yml) for Linux/MacOS users,
and [.appveyor.yml](.appveyor.yml) for Strawberry perl users.
</details>
<details>
<summary>Windows users without perl</summary>
Windows users who do not have a perl installation might prefer to get

    latexindent.exe
    defaultSettings.yaml

`latexindent.exe` is a standalone executable file which does not require a `perl` installation.
It is available at [releases](https://github.com/cmhughes/latexindent.pl/releases) page of this repository
and also from [https://ctan.org/tex-archive/support/latexindent](https://ctan.org/tex-archive/support/latexindent).
</details>
<details>
<summary>conda users</summary>
If you use conda you'll only need
```
conda install latexindent.pl -c conda-forge
```
this will install the executable and all its dependencies (including perl) in the activate environment.
You don't even have to worry about `defaultSettings.yaml` as it included too.

> [![Conda Version](https://img.shields.io/conda/vn/conda-forge/latexindent.pl.svg)](https://anaconda.org/conda-forge/latexindent.pl)
</details>

## GitHub Actions
`latexindent.exe` is created and released by [GitHub Actions](https://github.com/features/actions); the
file that controls this is available within the [github/workflows](https://github.com/cmhughes/latexindent.pl/tree/main/.github/workflows) 
directory of this repository, and you can track the actions on the [actions page](https://github.com/cmhughes/latexindent.pl/actions/) of this reposito
ry.

> ![Batch latexindent.pl check](https://github.com/cmhughes/latexindent.pl/actions/workflows/batch-check.yaml/badge.svg)
![Publish latexindent.exe](https://github.com/cmhughes/latexindent.pl/actions/workflows/build-documentation-and-windows-exe.yaml/badge.svg)

## testing

A nice way to test the script is to navigate to the test-cases
directory, and then run the command (on Linux/Mac -- sorry, a Windows test-case version is not available):

    ./test-cases.sh

## *important*

This script may not work for your style of formatting; I highly
recommend comparing the outputfile.tex to make sure that
nothing has been changed (or removed) in a way that will damage
your file.

I recommend using each of the following:
* a visual check, at the very least, make sure that
      each file has the same number of lines
* a check using `latexdiff inputfile.tex outputfile.tex`
* `git status myfile.tex`

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

## perl version

I develop latexindent.pl on Ubuntu Linux, using [perlbrew](https://perlbrew.pl/); I currently develop on perl version v5.32.1

## related projects

You might like to checkout the following related projects on github.

[arara](https://github.com/cereda/arara): [![GitHub stars](https://img.shields.io/github/stars/cereda/arara.svg?style=flat-square)](https://github.com/cereda/arara/stargazers)

[atom-beautify](https://github.com/Glavin001/atom-beautify): [![GitHub stars](https://img.shields.io/github/stars/Glavin001/atom-beautify.svg?style=flat-square)](https://github.com/Glavin001/atom-beautify/stargazers)

[LaTeX-Workshop](https://github.com/James-Yu/LaTeX-Workshop): [![GitHub stars](https://img.shields.io/github/stars/James-Yu/LaTeX-Workshop.svg?style=flat-square)](https://github.com/James-Yu/LaTeX-Workshop/stargazers)

[Neelfrost/dotfiles](https://github.com/Neelfrost/dotfiles): [![GitHub stars](https://img.shields.io/github/stars/Neelfrost/dotfiles.svg?style=flat-square)](https://github.com/Neelfrost/dotfiles/stargazers)

## thank you
Thank you to the [contributors](https://github.com/cmhughes/latexindent.pl/graphs/contributors) to the project!

## quotes

I find that the following quotes resonate with me with regards to my approach to `latexindent.pl`:

- *I want people to use Perl. I want to be a positive ingredient of the world and make my American history. So, whatever it takes to give away my software and get it used, that's great.* Larry Wall
- *A common, brute-force approach to parsing documents where newlines are not significant is to read ... the entire file as one string ... and then extract tokens one by one*, Christiansen & Torkington, Perl Cookbook, Section 6.16
- *Once you understand the power that regular expressions provide, the small amount of work spent learning them will feel trivial indeed* Friedl, Mastering Regular Expressions, end of Chapter 1.
- *a problem speaks to them, and they have to solve it...and it becomes a hobby. But they keep coming back to it every now and then. They keep tinkering. It will never be finished...that's the point of a hobby*, Westwood to Reacher in 'Make Me', Lee Child
- *Do the best you can until you know better. Then when you know better, do better.* Maya Angelou

## changelog
[changelog.md](documentation/changelog.md) provides details of the history of the project.

