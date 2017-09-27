#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s two-sentences.tex -m -o=+mod0
latexindent.pl -s two-sentences.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s three-sentences-trailing-comments.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s six-sentences.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s texbook-snippet.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
git status
