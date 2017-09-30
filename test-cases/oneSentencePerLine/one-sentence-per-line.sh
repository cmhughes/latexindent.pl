#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# two sentences
latexindent.pl -s two-sentences.tex -m -o=+mod0
latexindent.pl -s two-sentences.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
# three sentences
latexindent.pl -s three-sentences-trailing-comments.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s three-sentences-trailing-comments.tex -m -o=+mod2 -y="modifyLineBreaks:preserveBlankLines:0,modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
# six sentences
latexindent.pl -s six-sentences.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s six-sentences.tex -m -o=+mod2 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1,modifyLineBreaks:preserveBlankLines:0"
# six sentences, and blank lines
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod1 -y="modifyLineBreaks:preserveBlankLines:0;condenseMultipleBlankLinesInto:0,modifyLineBreaks:oneSentencePerLine:manipulateSentences:1,"
latexindent.pl -s texbook-snippet.tex -m -o=+mod1 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
git status
