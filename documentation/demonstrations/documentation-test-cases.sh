#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=0
. ../../test-cases/common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# demonstration
latexindent.pl -s filecontents1.tex -o filecontents1-default.tex
latexindent.pl -s tikzset.tex -o tikzset-default.tex
latexindent.pl -s pstricks.tex --outputfile pstricks-default.tex
latexindent.pl -s pstricks.tex --outputfile pstricks-default.tex -logfile cmh.log

# alignment
latexindent.pl -s tabular1.tex --outputfile tabular1-default.tex -logfile cmh.log
latexindent.pl -s -l tabular.yaml tabular1.tex --outputfile tabular1-advanced.tex 
latexindent.pl -s -l tabular1.yaml tabular1.tex --outputfile tabular1-advanced-3spaces.tex 
latexindent.pl -s matrix1.tex -o matrix1-default.tex
# items
latexindent.pl -s items1.tex -o items1-default.tex
# special
latexindent.pl -s special1.tex -o special1-default.tex
# headings
latexindent.pl -s headings1.tex -o headings1-mod1.tex -l=headings1.yaml
latexindent.pl -s headings1.tex -o headings1-mod2.tex -l=headings2.yaml
# previously important example
latexindent.pl -s previously-important-example.tex -o previously-important-example-default.tex
# noAdditionalIndent, environment
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body1.tex -l myenv-noAdd1.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body2.tex -l myenv-noAdd2.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body3.tex -l myenv-noAdd3.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body4.tex -l myenv-noAdd4.yaml
[[ $noisyMode == 1 ]] && makenoise
git status
