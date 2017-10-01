#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# two sentences
latexindent.pl -s two-sentences.tex -m -o=+mod0
latexindent.pl -s two-sentences.tex -m -o=+mod1 -l=manipulateSentences.yaml
# three sentences
latexindent.pl -s three-sentences-trailing-comments.tex -m -o=+mod1 -l=manipulateSentences.yaml
latexindent.pl -s three-sentences-trailing-comments.tex -m -o=+mod2 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0"
# six sentences
latexindent.pl -s six-sentences.tex -m -o=+mod1 -l=manipulateSentences.yaml
latexindent.pl -s six-sentences.tex -m -o=+mod2 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0"
latexindent.pl -s six-sentences.tex -m -o=+mod3 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:exclamationMark:0"
latexindent.pl -s six-sentences.tex -m -o=+mod4 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:fullStop:0"
latexindent.pl -s six-sentences.tex -m -o=+mod5 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:questionMark:0"
# six sentences, and blank lines
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod0 -l=manipulateSentences.yaml 
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0;condenseMultipleBlankLinesInto:0"
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod2 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine:0"
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod3 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;fullStop:0"
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod4 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;exclamationMark:0"
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod5 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;questionMark:0"
latexindent.pl -s six-sentences-mult-blank.tex -m -o=+mod6 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"
# other punctuation
latexindent.pl -s other-punctuation.tex -m -o=+mod0 -l=manipulateSentences.yaml 
latexindent.pl -s other-punctuation.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;"
latexindent.pl -s other-punctuation.tex -m -o=+mod2 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:"
latexindent.pl -s other-punctuation.tex -m -o=+mod3 -l=manipulateSentences.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:|"'
# sentences across blank lines, note the difference between the following two
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod0 -l=manipulateSentences.yaml 
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0"
# sentences across code blocks
latexindent.pl -s sentences-across-blocks.tex -m -o=+mod0 -l=manipulateSentences.yaml 
# tex book snippet
latexindent.pl -s texbook-snippet.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1"
latexindent.pl -s texbook-snippet.tex -m -o=+mod2 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\,|\:"

[[ $silentMode == 0 ]] && set -x 

[[ $noisyMode == 1 ]] && makenoise
git status
