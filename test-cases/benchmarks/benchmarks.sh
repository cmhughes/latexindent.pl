#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

{ time latexindent.pl -s  sampleBEFORE-smaller.tex; } 2>sampleBEFORE-smaller.data
{ time latexindent.pl -s  sampleBEFORE.tex; } 2>sampleBEFORE.data
latexindent.pl -s sampleBEFORE.tex -o sampleBEFORE-default.tex -l indentHeadings.yaml
git status
