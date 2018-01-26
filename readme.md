### introduction
[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=master)](https://travis-ci.org/cmhughes/latexindent.pl)

`latexindent.pl` is a `perl` script to indent (add horizontal leading space to) 
code within environments, commands, after headings and within special code blocks.

It has the ability to align delimiters in environments and commands, and 
can modify line breaks.

    latexindent.pl, version 3.4.1, 2018-01-18

### author 
Chris Hughes (cmhughes)

### build status
I use `travis-ci` as a continuous integration service to test `latexindent.pl` for a small selection of test cases for every commit (I use `git` to track changes in the many test cases listed in the `test-cases` directory); you can see which versions of `perl` are tested by `travis-ci` within `.travis.yml`. 

[![Build Status](https://travis-ci.org/cmhughes/latexindent.pl.svg?branch=master)](https://travis-ci.org/cmhughes/latexindent.pl)

### documentation

For complete details, please see http://mirrors.ctan.org/support/latexindent/documentation/latexindent.pdf

### Windows executable
`latexindent.exe` is created using 

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
how long it will take to implement -- feel free to post on the issues 
page of this repository.

### development model

I follow the development model given here: http://nvie.com/posts/a-successful-git-branching-model/
which means that latexindent.pl always has two branches:
    
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
