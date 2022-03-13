#!/bin/bash
loopmax=3
verbatimTest=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

for file in *.tex
do
   latexindent.pl --check -s -w $file && echo "latexindent.pl check passed for $file (file unchanged by latexindent.pl)"
done
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
