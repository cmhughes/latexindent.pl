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
latexindent.pl -s other-punctuation.tex -m -o=+mod3 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:|\"'

# sentences across blank lines, note the difference between the following two
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod0 -l=manipulateSentences.yaml,issue-419b.yaml 
latexindent.pl -s sentences-across-blank-lines.tex -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:preserveBlankLines:0"

# sentences across code blocks
latexindent.pl -s sentences-across-blocks.tex -m -o=+mod0 -l=manipulateSentences.yaml,issue-419b.yaml 

# tex book snippet
latexindent.pl -s texbook-snippet.tex -m -o=+mod1 -l=manipulateSentences.yaml
latexindent.pl -s texbook-snippet.tex -m -o=+mod2 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\,|\:"
latexindent.pl -s texbook-snippet.tex -m -o=+mod3 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:commentOnPreviousLine:0"

# verbatim block
latexindent.pl -s verbatim-test.tex -m -o=+mod0 -l=manipulateSentences.yaml 

# more code blocks
latexindent.pl -s more-code-blocks.tex -m -o=+mod0 -l=manipulateSentences.yaml,itemize.yaml,issue-419b.yaml
latexindent.pl -s more-code-blocks.tex -m -o=+mod1 -l=manipulateSentences.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'
latexindent.pl -s more-code-blocks.tex -m -o=+mod2 -l=manipulateSentences.yaml,sentences-start-with-lower-case.yaml,item.yaml -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'

# webwork guide
latexindent.pl -s webwork-guide -m -o=+mod0 -l=manipulateSentences.yaml,basic-full-stop.yaml,keepMultipleSpaces.yaml,issue-419b
latexindent.pl -s webwork-guide -m -o=+mod1 -l=manipulateSentences.yaml,alt-full-stop,keepMultipleSpaces.yaml,issue-419b
latexindent.pl -s webwork-guide -m -o=+mod2 -l=manipulateSentences.yaml,alt-full-stop,itemize,keepMultipleSpaces.yaml,issue-419b

# trailing comments
latexindent.pl -s trailing-comments -m -o=+mod0 -l=manipulateSentences.yaml
latexindent.pl -s trailing-comments -m -o=+mod1 -l=manipulateSentences.yaml -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"

# sentences beginning with 'other'
latexindent.pl -s other-begins -m -o=+mod0 -l=manipulateSentences.yaml
latexindent.pl -s other-begins -m -o=+mod1 -l=manipulateSentences.yaml,other-begins.yaml

# from the feature request (https://github.com/cmhughes/latexindent.pl/issues/81)
latexindent.pl -s -m mlep -o=+-mod0 -l=manipulateSentences.yaml 
latexindent.pl -s -m mlep -o=+-mod1 -l=manipulateSentences.yaml,basic-full-stop.yaml -y="specialBeginEnd:inlineMath:lookForThis:0" 
latexindent.pl -s -m mlep2 -o=+-mod0 -l=manipulateSentences.yaml,itemize.yaml,issue-419b.yaml
latexindent.pl -s -m mlep2 -o=+-mod1 -l=manipulateSentences.yaml,itemize.yaml,mlep2.yaml 
latexindent.pl -s -m mlep2 -o=+-mod2 -l=manipulateSentences.yaml,itemize.yaml -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"

# pcc program review test cases (https://github.com/PCCMathSAC/PCCMathProgramReview2014)
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    [[ $silentMode == 0 ]] && set -x 
    latexindent.pl -s pcc-program-review$i.tex -m -o=+-mod1 -l=manipulateSentences.yaml,basic-full-stop.yaml,keepMultipleSpaces.yaml,issue-419b
    latexindent.pl -s pcc-program-review$i.tex -m -o=+-mod2 -l=manipulateSentences.yaml,item,pcc-program-review,keepMultipleSpaces.yaml,issue-419b
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
latexindent.pl -s kiryph.tex -m -l=kiryph1.yaml,issue-419b -o=+-mod1
latexindent.pl -s kiryph1.tex -m -l=kiryph2.yaml -o=+-mod2
[[ $silentMode == 0 ]] && set -x 

# tilde after full stop, see https://github.com/cmhughes/latexindent.pl/issues/153
latexindent.pl -s -m dot-followed-by-tilde.tex -o=+-mod1 -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences:1'

# https://github.com/cmhughes/latexindent.pl/issues/167
latexindent.pl -s -m konfekt.tex -o=+-mod0 -l=konfekt0.yaml
latexindent.pl -s -m konfekt.tex -o=+-mod1 -l=konfekt1.yaml
latexindent.pl -s -m konfekt.tex -o=+-mod2 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1;sentencesEndWith:other:\;;sentencesBeginWith:other:[[:lower:]]"

# https://github.com/cmhughes/latexindent.pl/issues/188; in particular, see the WARNING message within indent.log from the following
latexindent.pl -s -m sentence-wrap-no-columns-specified.tex -l=sentence-wrap-no-columns-specified.yaml -o=+-mod1

# https://github.com/cmhughes/latexindent.pl/issues/217
latexindent.pl -s -m psttf.tex -l psttf1.yaml -o=+-mod1
latexindent.pl -s -m psttf.tex -l psttf2.yaml -o=+-mod2

# https://github.com/cmhughes/latexindent.pl/issues/243
latexindent.pl -s -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1,modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1,fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' issue-243.tex -o=+-mod1

# issue 321
latexindent.pl -s issue-321.tex -m -o=+mod0 -l=manipulateSentences.yaml 

# issue 355
latexindent.pl -s -m -l issue-355.yaml issue-355.tex -o=+-mod1
latexindent.pl -s -m -l issue-355a.yaml issue-355.tex -o=+-mod2

# issue 376
latexindent.pl -s -m -l issue-376-orig.yaml,issue-419b issue-376.tex -o=+-mod0 -r
latexindent.pl -s -m -l issue-376.yaml,issue-419b issue-376.tex -o=+-mod1
latexindent.pl -s -m -l issue-376a.yaml issue-376.tex -o=+-mod2
latexindent.pl -s -m -l issue-376b.yaml issue-376.tex -o=+-mod3

# issue 377
latexindent.pl -s -m -l issue-377a.yaml issue-377.tex -o=+-mod1

# issue 392
latexindent.pl -s -m -l issue-392.yaml issue-392.tex -o=+-mod1

latexindent.pl multiple-sentences9.tex -o=+-mod1.tex -l=sentence-wrap4 -m -s -o=+-mod1
latexindent.pl multiple-sentences9.tex -o=+-mod1.tex -l=sentence-wrap5 -m -s -o=+-mod2

# issue 417
latexindent.pl -s -m -l issue-417.yaml issue-417.tex -o=+-mod1
latexindent.pl -s -m -l issue-417a.yaml issue-417.tex -o=+-mod2

# pull 447
latexindent.pl -s issue-447 -m -o=+-mod1 -l=manipulateSentences.yaml

# issue 419, sentencesDoNOTcontain
latexindent.pl -s issue-419a -m -o=+-mod1 -l=issue-419a.yaml
latexindent.pl -s issue-419a -m -o=+-mod2 -l=manipulateSentences.yaml
latexindent.pl -s issue-419a -m -o=+-mod3 -l=issue-419b.yaml
latexindent.pl -s issue-419a -m -o=+-mod4 -l=issue-419c.yaml
latexindent.pl -s issue-419a -m -o=+-mod5 -l=issue-419d.yaml
latexindent.pl -s issue-419a -m -o=+-mod6 -l=issue-419e.yaml

latexindent.pl -s issue-419b -m -o=+-mod1 -l=manipulateSentences.yaml
latexindent.pl -s issue-419b -m -o=+-mod2 -l=manipulateSentences.yaml,issue-419c.yaml

latexindent.pl -s issue-419c -m -o=+-mod6 -l=issue-419e.yaml
latexindent.pl -s issue-419c -m -o=+-mod7 -l=issue-419f.yaml

latexindent.pl -s issue-463 -m -o=+-mod1 -l=manipulateSentences.yaml
latexindent.pl -s issue-463 -m -o=+-mod2 -l=issue-419b.yaml

latexindent.pl -s issue-514 -m -o=+-mod1 -l=issue-514.yaml

[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status

exit 0
