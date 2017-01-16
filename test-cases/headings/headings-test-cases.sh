#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# first test case
latexindent.pl -s headings-first.tex -o headings-first-default.tex -l resetChapter.yaml
latexindent.pl -s headings-first.tex -o headings-first1.tex -l=indentRules1.yaml,levels1.yaml
latexindent.pl -s headings-first.tex -o headings-first2.tex -l=levels2.yaml,resetChapter.yaml
# second test case
latexindent.pl -s headings-second.tex -o headings-second-default.tex -local resetChapter.yaml
latexindent.pl -s headings-second.tex -o headings-second1.tex -l=indentRules1.yaml,levels1.yaml
latexindent.pl -s headings-second.tex -o headings-second2.tex -l=levels2.yaml,resetChapter.yaml -tt
latexindent.pl -s headings-second.tex -o headings-second2-indentRules.tex -l=indentRules1.yaml,levels2.yaml -tt
# large (legacy) test case
latexindent.pl -s testHeadings.tex -o testHeadings-default.tex
latexindent.pl -s testHeadings.tex -o testHeadings1.tex -l=levels1.yaml
latexindent.pl -s testHeadings.tex -o testHeadings2.tex -l=levels2.yaml 
latexindent.pl -s testHeadings.tex -o testHeadings3.tex -l=levels3.yaml
latexindent.pl -s testHeadings.tex -o testHeadings4.tex -l=levels4.yaml
# custom headings
latexindent.pl -s customHeadings.tex -o customHeadings1.tex -l custom1.yaml 
latexindent.pl -s customHeadings.tex -o customHeadings2.tex -l custom2.yaml 
latexindent.pl -s customHeadings.tex -o customHeadings3.tex -l custom3.yaml 

# modifyLineBreaks experiments
# levels1.yaml
latexindent.pl -s headings-single-line.tex -o headings-single-line-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml -m
latexindent.pl -s headings-single-line-simple.tex -o headings-single-line-simple-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml -m
latexindent.pl -s headings-single-line.tex -o headings-single-line-comment-mod1.tex  -l=levels1.yaml,headingStartOwnLineComment.yaml -m
latexindent.pl -s headings-blank-line.tex -o headings-blank-line-default.tex -l resetChapter.yaml
latexindent.pl -s headings-blank-line.tex -o headings-blank-line-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml,resetChapter.yaml -m
latexindent.pl -s headings-blank-line.tex -o headings-remove-blank-line-mod1.tex  -l=levels1.yaml,headingNotStartOwnLine.yaml,resetChapter.yaml -m
# levels2.yaml
latexindent.pl -s headings-single-line.tex -o headings-single-line-mod2.tex  -l=levels2.yaml,headingStartOnOwnLine.yaml -m -g=one.log
latexindent.pl -s headings-single-line.tex -o headings-single-line-comment-mod2.tex  -l=levels2.yaml,headingStartOwnLineComment.yaml -m
# single line, with many titles
latexindent.pl -s headings-single-line-many.tex -o headings-single-line-many-mod1.tex -l=levels1.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml -m
latexindent.pl -s headings-single-line-many.tex -o headings-single-line-many-mod2.tex -l=levels2.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml  -m
latexindent.pl -s headings-single-line-many.tex -o headings-single-line-many-mod3.tex -l=levels3.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml  -m
# headings with stars at different levels
latexindent.pl -s headings-names-with-stars.tex -o headings-names-with-stars-mod5.tex -l=levels5.yaml,resetChapter.yaml
latexindent.pl -s headings-names-with-stars.tex -o headings-names-with-stars-mod6.tex -l=levels6.yaml,resetChapter.yaml
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
git status
