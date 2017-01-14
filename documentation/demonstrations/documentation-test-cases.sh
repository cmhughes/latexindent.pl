#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=0
. ../common.sh

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
[[ $noisyMode == 1 ]] && makenoise
git status
