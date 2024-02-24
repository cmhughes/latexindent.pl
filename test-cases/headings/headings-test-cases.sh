#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# first test case
latexindent.pl -s headings-first.tex -o +-default.tex -l resetChapter.yaml
latexindent.pl -s headings-first.tex -o +1.tex -l=indentRules1.yaml,levels1.yaml
latexindent.pl -s headings-first.tex -o +2.tex -l=levels2.yaml,resetChapter.yaml
# second test case
latexindent.pl -s headings-second.tex -o +-default.tex -local resetChapter.yaml
latexindent.pl -s headings-second.tex -o +1.tex -l=indentRules1.yaml,levels1.yaml
latexindent.pl -s headings-second.tex -o +2.tex -l=levels2.yaml,resetChapter.yaml -tt
latexindent.pl -s headings-second.tex -o +2-indentRules.tex -l=indentRules1.yaml,levels2.yaml -tt
# large (legacy) test case
latexindent.pl -s testHeadings.tex -o +-default.tex
latexindent.pl -s testHeadings.tex -o +1.tex -l=levels1.yaml
latexindent.pl -s testHeadings.tex -o +2.tex -l=levels2.yaml 
latexindent.pl -s testHeadings.tex -o +3.tex -l=levels3.yaml
latexindent.pl -s testHeadings.tex -o +4.tex -l=levels4.yaml
# custom headings
latexindent.pl -s customHeadings.tex -o +1.tex -l custom1.yaml 
latexindent.pl -s customHeadings.tex -o +2.tex -l custom2.yaml 
latexindent.pl -s customHeadings.tex -o +3.tex -l custom3.yaml 

# modifyLineBreaks experiments
# levels1.yaml
latexindent.pl -s headings-single-line.tex -o +-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml -m
latexindent.pl -s headings-single-line-simple.tex -o +-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml -m
latexindent.pl -s headings-single-line.tex -o +-comment-mod1.tex  -l=levels1.yaml,headingStartOwnLineComment.yaml -m
latexindent.pl -s headings-blank-line.tex -o +-default.tex -l resetChapter.yaml
latexindent.pl -s headings-blank-line.tex -o +-mod1.tex  -l=levels1.yaml,headingStartOnOwnLine.yaml,resetChapter.yaml -m
latexindent.pl -s headings-blank-line.tex -o headings-remove-blank-line-mod1.tex -l=levels1.yaml,headingNotStartOwnLine.yaml,resetChapter.yaml -m
# levels2.yaml
latexindent.pl -s headings-single-line.tex -o +-mod2.tex  -l=levels2.yaml,headingStartOnOwnLine.yaml -m -g=one.log
latexindent.pl -s headings-single-line.tex -o +-comment-mod2.tex  -l=levels2.yaml,headingStartOwnLineComment.yaml -m
# single line, with many titles
latexindent.pl -s headings-single-line-many.tex -o +-mod1.tex -l=levels1.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml -m
latexindent.pl -s headings-single-line-many.tex -o +-mod2.tex -l=levels2.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml  -m
latexindent.pl -s headings-single-line-many.tex -o +-mod3.tex -l=levels3.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml  -m
# headings with stars at different levels
latexindent.pl -s headings-names-with-stars.tex -o +-mod5.tex -l=levels5.yaml,resetChapter.yaml
latexindent.pl -s headings-names-with-stars.tex -o +-mod6.tex -l=levels6.yaml,resetChapter.yaml
# poly-switch = 3 (blank line mode)
latexindent.pl -s headings-single-line-many.tex -o +-mod7.tex -l=levels3.yaml,headingStartOnOwnLine.yaml,../specials/special-mod1.yaml,chapterBlankLines.yaml -m
latexindent.pl -s headings-single-line-many.tex -o +-mod8.tex -l=levels3.yaml,headingStartOnOwnLine.yaml,../specials/special-mod33.yaml,headingsBlankLines.yaml -m
latexindent.pl -s headings-single-line-many.tex -o +-mod9.tex -l=aronovgj.yaml -m
latexindent.pl -s headings-blank-line.tex -o +-mod2.tex -l=levels3.yaml,headingStartOnOwnLine.yaml,../specials/special-mod33.yaml,headingsBlankLines.yaml -m
# testing the -y switch
latexindent.pl -s headings1.tex -o=+-mod1 -y=' indentAfterHeadings:paragraph:indentAfterThisHeading:1;level:1 '

latexindent.pl -s -l issue-519.yaml issue-519.tex -o=+-mod1

[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
[[ $gitStatus == 1 ]] && git status
