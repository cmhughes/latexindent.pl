#!/bin/bash
loopmax=6
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
latexindent.pl -s six-sentences.tex -m -o=+mod4 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:betterFullStop:0"
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
latexindent.pl -s other-punctuation.tex -m -o=+mod1 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;"
latexindent.pl -s other-punctuation.tex -m -o=+mod2 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:"
latexindent.pl -s other-punctuation.tex -m -o=+mod3 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:|"'
# sentences across blank lines, note the difference between the following two
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod0 -l=manipulateSentences.yaml 
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0"
# sentences across code blocks
latexindent.pl -s sentences-across-blocks.tex -m -o=+mod0 -l=manipulateSentences.yaml 
# tex book snippet
latexindent.pl -s texbook-snippet.tex -m -o=+mod1 -l=manipulateSentences.yaml
latexindent.pl -s texbook-snippet.tex -m -o=+mod2 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\,|\:"
latexindent.pl -s texbook-snippet.tex -m -o=+mod3 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:commentOnPreviousLine:0"
# verbatim block
latexindent.pl -s verbatim-test.tex -m -o=+mod0 -l=manipulateSentences.yaml 
# more code blocks
latexindent.pl -s more-code-blocks.tex -m -o=+mod0 -l=manipulateSentences.yaml,itemize.yaml
latexindent.pl -s more-code-blocks.tex -m -o=+mod1 -l=manipulateSentences.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'
latexindent.pl -s more-code-blocks.tex -m -o=+mod2 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml,item.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'
# webwork guide
latexindent.pl -s webwork-guide -m -o=+mod0 -l=manipulateSentences.yaml,basic-full-stop.yaml
latexindent.pl -s webwork-guide -m -o=+mod1 -l=manipulateSentences.yaml,alt-full-stop
latexindent.pl -s webwork-guide -m -o=+mod2 -l=manipulateSentences.yaml,alt-full-stop,itemize
# trailing comments
latexindent.pl -s trailing-comments -m -o=+mod0 -l=manipulateSentences.yaml
latexindent.pl -s trailing-comments -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"
# sentences beginning with 'other'
latexindent.pl -s other-begins -m -o=+mod0 -l=manipulateSentences.yaml
latexindent.pl -s other-begins -m -o=+mod1 -l=manipulateSentences.yaml,other-begins.yaml
# from the feature request (https://github.com/cmhughes/latexindent.pl/issues/81)
latexindent.pl -s -m mlep -o=+-mod0 -l=manipulateSentences.yaml 
latexindent.pl -s -m mlep -o=+-mod1 -l=manipulateSentences.yaml,basic-full-stop.yaml -y="specialBeginEnd:inlineMath:lookForThis:0" 
latexindent.pl -s -m mlep2 -o=+-mod0 -l=manipulateSentences.yaml,itemize.yaml
latexindent.pl -s -m mlep2 -o=+-mod1 -l=manipulateSentences.yaml,itemize.yaml,mlep2.yaml 
latexindent.pl -s -m mlep2 -o=+-mod2 -l=manipulateSentences.yaml,itemize.yaml -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"
# pcc program review test cases (https://github.com/PCCMathSAC/PCCMathProgramReview2014)
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    [[ $silentMode == 0 ]] && set -x 
    latexindent.pl -s pcc-program-review$i.tex -m -o=+-mod1 -l=manipulateSentences.yaml,basic-full-stop.yaml
    latexindent.pl -s pcc-program-review$i.tex -m -o=+-mod2 -l=manipulateSentences.yaml,item,pcc-program-review
    [[ $silentMode == 0 ]] && set +x 
done

# text wrap and indent sentences, https://github.com/cmhughes/latexindent.pl/issues/111
latexindent.pl -s dbmrq.tex -m -l=dbmrq1.yaml -o=+-mod1
latexindent.pl -s dbmrq.tex -m -l=dbmrq2.yaml -o=+-mod2
latexindent.pl -s dbmrq.tex -m -l=dbmrq3.yaml -o=+-mod3
latexindent.pl -s dbmrq.tex -m -l=dbmrq1.yaml,dbmrq4.yaml -o=+-mod4
latexindent.pl -s dbmrq2.tex -m -l=dbmrq1.yaml -o=+-mod1
latexindent.pl -s dbmrq3.tex -m -l=dbmrq1.yaml -o=+-mod1
latexindent.pl -s dbmrq3.tex -m -l=dbmrq5.yaml -o=+-mod5

# sentences as objects was required from https://github.com/cmhughes/latexindent.pl/issues/131
latexindent.pl -s kiryph.tex -m -l=kiryph1.yaml -o=+-mod1
latexindent.pl -s kiryph1.tex -m -l=kiryph2.yaml -o=+-mod2
[[ $silentMode == 0 ]] && set -x 

[[ $noisyMode == 1 ]] && makenoise
git status
