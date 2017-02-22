#!/bin/bash
loopmax=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s unnamed.tex -o unnamed-default.tex
git status
[[ $noisyMode == 1 ]] && makenoise
