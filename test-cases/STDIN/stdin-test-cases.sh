#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
cat myfile.tex | latexindent.pl -s -o=myfile-default 
cat myfile.tex | latexindent.pl -s -o=myfile-default -l=dontMeasure.yaml -
[[ $gitStatus == 1 ]] && git status
