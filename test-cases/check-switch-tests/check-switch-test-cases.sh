#!/bin/bash
loopmax=3
verbatimTest=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

for file in *.tex
do
   latexindent.pl --check -s $file && echo "latexindent.pl check passed for $file (file unchanged by latexindent.pl)"
done
git status
