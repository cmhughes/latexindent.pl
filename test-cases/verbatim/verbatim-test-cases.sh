#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  verbatim-starred1 -l=verb-equation-star.yaml -o=+-mod1
latexindent.pl -s  verbatim-starred2 -l=no-indent-star.yaml -o=+-mod1
git status
