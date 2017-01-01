#!/bin/bash
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s -w token-checks1 -g=one.log
latexindent.pl -s -w token-checks2 -g=two.log
latexindent.pl -s -w token-checks3 -g=three.log
latexindent.pl -s -w token-checks4 -g=four.log
git status
