#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s -r test1.tex -l=replace1.yaml -o=+-mod1
latexindent.pl -s -r test1.tex -l=replace2.yaml -o=+-mod2
latexindent.pl -s -rr test1.tex -l=replace1.yaml -o=+-mod3
git status
[[ $noisyMode == 1 ]] && makenoise
