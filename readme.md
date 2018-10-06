### introduction
[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=master)](https://travis-ci.org/cmhughes/latexindent.pl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=master&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent.pl)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest/?badge=latest)

`latexindent.pl` is a `perl` script to indent (add horizontal leading space to) 
code within environments, commands, after headings and within special code blocks.

It has the ability to align delimiters in environments and commands, and 
can modify line breaks.

### version 
 
    latexindent.pl, version 3.5.2, 2018-10-06

### author 
Chris Hughes (cmhughes)

### build status
I use both `travis-ci` (Linux) and `AppVeyor` (Windows) as continuous integration services to test `latexindent.pl` for a small selection of test cases for every commit (I use `git` to track changes in the many test cases listed in the `test-cases` directory); you can see which versions of `perl` are tested by `travis-ci` within `.travis.yml`. 

[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=master)](https://travis-ci.org/cmhughes/latexindent.pl)
[![Build status](https://ci.appveyor.com/api/projects/status/github/cmhughes/latexindent.pl?branch=master&svg=true)](https://ci.appveyor.com/project/cmhughes/latexindent-pl)

### documentation

For complete details, please see:

- pdf: http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf
- online (beta): http://latexindentpl.readthedocs.io/ (if you find discrepancies between the pdf and readthedocs, defer to the pdf)
[![Documentation Status](https://readthedocs.org/projects/latexindentpl/badge/?version=latest)](http://latexindentpl.readthedocs.io/en/latest/?badge=latest)

### Windows executable
`latexindent.exe` is available at `https://ctan.org/tex-archive/support/latexindent` 
and is created using 

      perl ppp.pl -u -o latexindent.exe latexindent.pl

using the `Par::Packer` perl module.

`ppp.pl` is located in the helper-scripts directory.

### usage

You'll need

        latexindent.pl
        LatexIndent/*.pm
        defaultSettings.yaml

in the same directory. Windows users might prefer to grab `latexindent.exe`

### testing

A nice way to test the script is to navigate to the test-cases 
directory, and then run the command (on Linux/Mac -- sorry, a Windows test-case version is not available):

        ./test-cases.sh

### *important*

This script may not work for your style of formatting; I highly 
recommend comparing the outputfile.tex to make sure that 
nothing has been changed (or removed) in a way that will damage
your file.

I recommend using each of the following:
* a visual check, at the very least, make sure that 
      each file has the same number of lines
* a check using `latexdiff inputfile.tex outputfile.tex`
* `git status` myfile.tex

### feature requests

I'm happy to review feature requests, but I make no promises as to if they 
will be implemented; if they can be implemented, I make no promises as to 
how long it will take to implement them, and in which order I do so -- some 
features are more difficult than others! Feel free to post on the issues 
page of this repository.

### development model

I follow the development model given here: http://nvie.com/posts/a-successful-git-branching-model/
which means that latexindent.pl always has (at least) two branches:
    
        master
        develop

The `master` branch always contains the released version and `develop` contains the 
development version. When developing a new feature or bug fix, I typically use:
    
        git checkout develop
        git checkout -b feature/name-of-feature

and then I merge it into the `develop` branch using

        git checkout develop
        git merge feature/name-of-feature --no-ff

### perl version

I develop latexindent.pl on Ubuntu Linux, using perlbrew; I currently develop on perl version v5.26.0

### related projects

You might like to checkout the following related projects on github.

[arara](https://github.com/cereda/arara): [![GitHub stars](https://img.shields.io/github/stars/cereda/arara.svg?style=flat-square)](https://github.com/cereda/arara/stargazers)

[atom-beautify](https://github.com/Glavin001/atom-beautify): [![GitHub stars](https://img.shields.io/github/stars/Glavin001/atom-beautify.svg?style=flat-square)](https://github.com/Glavin001/atom-beautify/stargazers)

### quotes

I find that the following quotes resonate with me with regards to my approach to `latexindent.pl`:

- *I want people to use Perl. I want to be a positive ingredient of the world and make my American history. So, whatever it takes to give away my software and get it used, that's great.* Larry Wall
- *A common, brute-force approach to parsing documents where newlines are not significant is to read ... the entire file as one string ... and then extract tokens one by one*, Christiansen & Torkington, Perl Cookbook, Section 6.16
- *Once you understand the power that regular expressions provide, the small amount of work spent learning them will feel trivial indeed* Friedl, Mastering Regular Expressions, end of Chapter 1.
- *a problem speaks to them, and they have to solve it...and it becomes a hobby. But they keep coming back to it every now and then. They keep tinkering. It will never be finished...that's the point of a hobby*, Westwood to Reacher in 'Make Me', Lee Child
- *Do the best you can until you know better. Then when you know better, do better.* Maya Angelou
