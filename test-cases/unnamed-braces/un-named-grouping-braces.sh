#!/bin/bash
loopmax=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s unnamed.tex -o unnamed-default.tex
latexindent.pl -s issue-265.tex -o +-mod1 -l issue-265.yaml
latexindent.pl -s issue-265-second.tex -o +-mod1 -l issue-265.yaml
latexindent.pl -s -l issue-568.yaml issue-568.tex -o=+-mod1

[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
