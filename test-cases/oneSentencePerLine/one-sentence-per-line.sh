#!/bin/bash
loopmax=6
. ../common.sh

openingtasks

# two sentences
latexindent.pl -s two-sentences -m -o=+mod0
latexindent.pl -s two-sentences -m -o=+mod1 -l=manipulateSentences

# three sentences
latexindent.pl -s three-sentences-trailing-comments -m -o=+mod1 -l=manipulateSentences
latexindent.pl -s three-sentences-trailing-comments -m -o=+mod2 -l=manipulateSentences -y="modifyLineBreaks:preserveBlankLines:0"

# six sentences
latexindent.pl -s six-sentences -m -o=+mod1 -l=manipulateSentences
latexindent.pl -s six-sentences -m -o=+mod2 -l=manipulateSentences -y="modifyLineBreaks:preserveBlankLines:0"
latexindent.pl -s six-sentences -m -o=+mod3 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:exclamationMark:0"
latexindent.pl -s six-sentences -m -o=+mod4 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:betterFullStop:0"
latexindent.pl -s six-sentences -m -o=+mod5 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:questionMark:0"

# six sentences, and blank lines
latexindent.pl -s six-sentences-mult-blank -m -o=+mod0 -l=manipulateSentences 
latexindent.pl -s six-sentences-mult-blank -m -o=+mod1 -l=manipulateSentences -y="modifyLineBreaks:preserveBlankLines:0;condenseMultipleBlankLinesInto:0"
latexindent.pl -s six-sentences-mult-blank -m -o=+mod2 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine:0"
latexindent.pl -s six-sentences-mult-blank -m -o=+mod3 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;fullStop:0"
latexindent.pl -s six-sentences-mult-blank -m -o=+mod4 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;exclamationMark:0"
latexindent.pl -s six-sentences-mult-blank -m -o=+mod5 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:blankLine: 0;questionMark:0"
latexindent.pl -s six-sentences-mult-blank -m -o=+mod6 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"

# other punctuation
latexindent.pl -s other-punctuation -m -o=+mod0 -l=manipulateSentences 
latexindent.pl -s other-punctuation -m -o=+mod1 -l=manipulateSentences,sentences-start-with-lower-case -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;"
latexindent.pl -s other-punctuation -m -o=+mod2 -l=manipulateSentences,sentences-start-with-lower-case -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:"
latexindent.pl -s other-punctuation -m -o=+mod3 -l=manipulateSentences,sentences-start-with-lower-case -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\:|\"'

# sentences across blank lines, note the difference between the following two
latexindent.pl -s sentences-across-blank-lines -m -o=+mod0 -l=manipulateSentences,issue-419b 
latexindent.pl -s sentences-across-blank-lines -m -o=+mod1 -l=manipulateSentences -y="modifyLineBreaks:preserveBlankLines:0"

# sentences across code blocks
latexindent.pl -s sentences-across-blocks -m -o=+mod0 -l=manipulateSentences,issue-419b 

# tex book snippet
latexindent.pl -s texbook-snippet -m -o=+mod1 -l=manipulateSentences
latexindent.pl -s texbook-snippet -m -o=+mod2 -l=manipulateSentences,sentences-start-with-lower-case -y="modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\;|\,|\:"
latexindent.pl -s texbook-snippet -m -o=+mod3 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:sentencesFollow:commentOnPreviousLine:0"

# verbatim block
latexindent.pl -s verbatim-test -m -o=+mod0 -l=manipulateSentences 

# more code blocks
latexindent.pl -s more-code-blocks -m -o=+mod0 -l=manipulateSentences,itemize,issue-419b
latexindent.pl -s more-code-blocks -m -o=+mod1 -l=manipulateSentences -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'
latexindent.pl -s more-code-blocks -m -o=+mod2 -l=manipulateSentences,sentences-start-with-lower-case,item -y='modifyLineBreaks:oneSentencePerLine:sentencesEndWith:other:\:'

# webwork guide
latexindent.pl -s webwork-guide -m -o=+mod0 -l=manipulateSentences,basic-full-stop,keepMultipleSpaces,issue-419b
latexindent.pl -s webwork-guide -m -o=+mod1 -l=manipulateSentences,alt-full-stop,keepMultipleSpaces,issue-419b
latexindent.pl -s webwork-guide -m -o=+mod2 -l=manipulateSentences,alt-full-stop,itemize,keepMultipleSpaces,issue-419b

# trailing comments
latexindent.pl -s trailing-comments -m -o=+mod0 -l=manipulateSentences
latexindent.pl -s trailing-comments -m -o=+mod1 -l=manipulateSentences -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"

# sentences beginning with 'other'
latexindent.pl -s other-begins -m -o=+mod0 -l=manipulateSentences
latexindent.pl -s other-begins -m -o=+mod1 -l=manipulateSentences,other-begins

# from the feature request (https://github.com/cmhughes/latexindent.pl/issues/81)
latexindent.pl -s -m mlep -o=+-mod0 -l=manipulateSentences 
latexindent.pl -s -m mlep -o=+-mod1 -l=manipulateSentences,basic-full-stop,inlineMath
latexindent.pl -s -m mlep2 -o=+-mod0 -l=manipulateSentences,itemize,issue-419b
latexindent.pl -s -m mlep2 -o=+-mod1 -l=manipulateSentences,itemize,mlep2 
latexindent.pl -s -m mlep2 -o=+-mod2 -l=manipulateSentences,itemize -y="modifyLineBreaks:oneSentencePerLine:removeSentenceLineBreaks:0"

# pcc program review test cases (https://github.com/PCCMathSAC/PCCMathProgramReview2014)
set +x
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
    keepappendinglogfile
    latexindent.pl -s pcc-program-review$i -m -o=+-mod1 -l=manipulateSentences,basic-full-stop,keepMultipleSpaces,issue-419b,pcc-review
    latexindent.pl -s pcc-program-review$i -m -o=+-mod2 -l=manipulateSentences,item,pcc-program-review,keepMultipleSpaces,issue-419b,pcc-review
    set +x
done
keepappendinglogfile

# text wrap and indent sentences, https://github.com/cmhughes/latexindent.pl/issues/111
latexindent.pl -s dbmrq -m -l=dbmrq1 -o=+-mod1
latexindent.pl -s dbmrq -m -l=dbmrq2 -o=+-mod2
latexindent.pl -s dbmrq -m -l=dbmrq3 -o=+-mod3
latexindent.pl -s dbmrq -m -l=dbmrq1,dbmrq4 -o=+-mod4
latexindent.pl -s dbmrq2 -m -l=dbmrq1 -o=+-mod1
latexindent.pl -s dbmrq3 -m -l=dbmrq1 -o=+-mod1
latexindent.pl -s dbmrq3 -m -l=dbmrq5 -o=+-mod5

# sentences as objects was required from https://github.com/cmhughes/latexindent.pl/issues/131
latexindent.pl -s kiryph -m -l=kiryph1,issue-419b -o=+-mod1
latexindent.pl -s kiryph1 -m -l=kiryph2 -o=+-mod2

# tilde after full stop, see https://github.com/cmhughes/latexindent.pl/issues/153
latexindent.pl -s -m dot-followed-by-tilde -o=+-mod1 -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences:1'

# https://github.com/cmhughes/latexindent.pl/issues/167
latexindent.pl -s -m konfekt -o=+-mod0 -l=konfekt0
latexindent.pl -s -m konfekt -o=+-mod1 -l=konfekt1
latexindent.pl -s -m konfekt -o=+-mod2 -y="modifyLineBreaks:oneSentencePerLine:manipulateSentences:1;sentencesEndWith:other:\;;sentencesBeginWith:other:[[:lower:]]"

# https://github.com/cmhughes/latexindent.pl/issues/188; in particular, see the WARNING message within indent.log from the following
latexindent.pl -s -m sentence-wrap-no-columns-specified -l=sentence-wrap-no-columns-specified -o=+-mod1

# https://github.com/cmhughes/latexindent.pl/issues/217
latexindent.pl -s -m psttf -l psttf1 -o=+-mod1
latexindent.pl -s -m psttf -l psttf2 -o=+-mod2

# https://github.com/cmhughes/latexindent.pl/issues/243
latexindent.pl -s -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1,modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1,fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' issue-243 -o=+-mod1

# issue 321
latexindent.pl -s issue-321 -m -o=+mod0 -l=manipulateSentences 

# issue 355
latexindent.pl -s -m -l issue-355 issue-355 -o=+-mod1
latexindent.pl -s -m -l issue-355a issue-355 -o=+-mod2

# issue 376
latexindent.pl -s -m -l issue-376-orig,issue-419b issue-376 -o=+-mod0 -r
latexindent.pl -s -m -l issue-376,issue-419b issue-376 -o=+-mod1
latexindent.pl -s -m -l issue-376a issue-376 -o=+-mod2
latexindent.pl -s -m -l issue-376b issue-376 -o=+-mod3

# issue 377
latexindent.pl -s -m -l issue-377a issue-377 -o=+-mod1

# issue 392
latexindent.pl -s -m -l issue-392 issue-392 -o=+-mod1

latexindent.pl multiple-sentences9 -o=+-mod1 -l=sentence-wrap4 -m -s -o=+-mod1
latexindent.pl multiple-sentences9 -o=+-mod1 -l=sentence-wrap5 -m -s -o=+-mod2

# issue 417
latexindent.pl -s -m -l issue-417 issue-417 -o=+-mod1
latexindent.pl -s -m -l issue-417a issue-417 -o=+-mod2

# pull 447
latexindent.pl -s issue-447 -m -o=+-mod1 -l=manipulateSentences

# issue 419, sentencesDoNOTcontain
latexindent.pl -s issue-419a -m -o=+-mod1 -l=issue-419a
latexindent.pl -s issue-419a -m -o=+-mod2 -l=manipulateSentences
latexindent.pl -s issue-419a -m -o=+-mod3 -l=issue-419b
latexindent.pl -s issue-419a -m -o=+-mod4 -l=issue-419c
latexindent.pl -s issue-419a -m -o=+-mod5 -l=issue-419d
latexindent.pl -s issue-419a -m -o=+-mod6 -l=issue-419e

latexindent.pl -s issue-419b -m -o=+-mod1 -l=manipulateSentences
latexindent.pl -s issue-419b -m -o=+-mod2 -l=manipulateSentences,issue-419c

latexindent.pl -s issue-419c -m -o=+-mod6 -l=issue-419e
latexindent.pl -s issue-419c -m -o=+-mod7 -l=issue-419f

latexindent.pl -s issue-463 -m -o=+-mod1 -l=manipulateSentences
latexindent.pl -s issue-463 -m -o=+-mod2 -l=issue-419b

latexindent.pl -s issue-514 -m -o=+-mod1 -l=issue-514

latexindent.pl -s issue-527 -m -o=+-mod1 -l=issue-527

latexindent.pl -s -l issue-557 -m issue-557 -o=+-mod1

latexindent.pl -s -l issue-575 -m issue-575 -o=+-mod1

latexindent.pl -s -m -l issue-567 issue-567 -o=+-mod1
latexindent.pl -s -r -m -l issue-567a issue-567a -o=+-mod1

set +x 
wrapuptasks
