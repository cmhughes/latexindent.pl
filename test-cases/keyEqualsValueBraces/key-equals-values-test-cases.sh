#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s -w keyEqualsValueFirst.tex 
latexindent.pl -s -w braceTestsmall.tex
git status