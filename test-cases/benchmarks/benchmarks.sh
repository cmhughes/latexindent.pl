#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

time latexindent.pl -s  sampleBEFORE-smaller.tex
time latexindent.pl -s sampleBEFORE.tex -l indentHeadings.yaml
latexindent.pl -s sampleBEFORE.tex -o sampleBEFORE-default.tex -l indentHeadings.yaml
git status
