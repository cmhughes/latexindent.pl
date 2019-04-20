#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  verbatim-starred1 -l=verb-equation-star.yaml -o=+-mod1
latexindent.pl -s  verbatim-starred2 -l=no-indent-star.yaml -o=+-mod1

# m switch tests:
#   verbatim environment
for (( i=-1 ; i <= 3 ; i++ )) 
do
    latexindent.pl -s  -m verbatim1 -l=verb-env$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-env$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-env$i.yaml -o=+-mod$i
done
#   verbatim command
#   verbatim special
#   verbatim noindent block -- no need to test this one...?
git status
