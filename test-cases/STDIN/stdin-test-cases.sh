#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
cat myfile.tex | latexindent.pl -s -o=myfile-default 
git status
