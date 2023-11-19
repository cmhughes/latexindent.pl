#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
cat myfile.tex | latexindent.pl -s -o=myfile-default 
cat myfile.tex | latexindent.pl -s -o=myfile-default -l=dontMeasure.yaml -

# issue 493
cat issue-493.tex| latexindent.pl -s -m -l latexindent.yaml -o=issue-493-mod1 -
latexindent.pl -s -l -m -o=+-mod2 issue-493.tex 
cat issue-493.tex| latexindent.pl -s -m -l issue-493a.yaml -o=issue-493-mod3 -

[[ $gitStatus == 1 ]] && git status
