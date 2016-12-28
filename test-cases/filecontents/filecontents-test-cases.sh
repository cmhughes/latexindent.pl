#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# first test case
latexindent.pl -s filecontents1.tex -o filecontents1-default.tex
latexindent.pl -s filecontents1.tex -o filecontents1-indent-preamble.tex -l=indentPreambleYes.yaml
git status
