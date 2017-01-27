#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# tikz tag
latexindent.pl -s 74878.tex -o 74878-default.tex
latexindent.pl -s -l indentPreamble.yaml 350144.tex -o 350144-default.tex
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot.yaml 350144.tex -o 350144-default-ngp.tex 
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot-headings.yaml 350144.tex -o 350144-default-ngp-headings.tex -g=ngp.log -tt
latexindent.pl -s 5461.tex -o 5461-default.tex
# latex3 tag
latexindent.pl -s 253693 -o 253693-default.tex
git status
