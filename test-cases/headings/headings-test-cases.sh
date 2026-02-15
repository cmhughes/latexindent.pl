#!/bin/bash
. ../common.sh

openingtasks

# first test case
latexindent.pl -s headings-first -o +-default -l resetChapter
latexindent.pl -s headings-first -o +1 -l=indentRules1,levels1
latexindent.pl -s headings-first -o +2 -l=levels2,resetChapter

# second test case
latexindent.pl -s headings-second -o +-default -local resetChapter
latexindent.pl -s headings-second -o +1 -l=indentRules1,levels1
latexindent.pl -s headings-second -o +2 -l=levels2,resetChapter -t
latexindent.pl -s headings-second -o +2-indentRules -l=indentRules1,levels2 -tt

# large (legacy) test case
latexindent.pl -s testHeadings -o +-default
latexindent.pl -s testHeadings -o +1 -l=levels1
latexindent.pl -s testHeadings -o +2 -l=levels2
latexindent.pl -s testHeadings -o +3 -l=levels3
latexindent.pl -s testHeadings -o +4 -l=levels4

# custom headings
latexindent.pl -s customHeadings -o +1 -l custom1 
latexindent.pl -s customHeadings -o +2 -l custom2 
latexindent.pl -s customHeadings -o +3 -l custom3 

# modifyLineBreaks experiments
# levels1
latexindent.pl -s headings-single-line -o +-mod1  -l=levels1,headingStartOnOwnLine -m
latexindent.pl -s headings-single-line-simple -o +-mod1  -l=levels1,headingStartOnOwnLine -m
latexindent.pl -s headings-single-line -o +-comment-mod1  -l=levels1,headingStartOwnLineComment -m
latexindent.pl -s headings-blank-line -o +-default -l resetChapter
latexindent.pl -s headings-blank-line -o +-mod1  -l=levels1,headingStartOnOwnLine,resetChapter -m
latexindent.pl -s headings-blank-line -o headings-remove-blank-line-mod1 -l=levels1,headingNotStartOwnLine,resetChapter -m

# levels2
latexindent.pl -s headings-single-line -o +-mod2  -l=levels2,headingStartOnOwnLine -m -g=one.log
latexindent.pl -s headings-single-line -o +-comment-mod2  -l=levels2,headingStartOwnLineComment -m

# single line, with many titles
latexindent.pl -s headings-single-line-many -o +-mod1 -l=levels1,headingStartOnOwnLine,../specials/special-mod1 -m
latexindent.pl -s headings-single-line-many -o +-mod2 -l=levels2,headingStartOnOwnLine,../specials/special-mod1  -m
latexindent.pl -s headings-single-line-many -o +-mod3 -l=levels3,headingStartOnOwnLine,../specials/special-mod1  -m

# headings with stars at different levels
latexindent.pl -s headings-names-with-stars -o +-mod5 -l=levels5,resetChapter
latexindent.pl -s headings-names-with-stars -o +-mod6 -l=levels6,resetChapter

# poly-switch = 3 (blank line mode)
latexindent.pl -s headings-single-line-many -o +-mod7 -l=levels3,headingStartOnOwnLine,../specials/special-mod1,chapterBlankLines -m
latexindent.pl -s headings-single-line-many -o +-mod8 -l=levels3,headingStartOnOwnLine,../specials/special-mod33,headingsBlankLines -m
latexindent.pl -s headings-single-line-many -o +-mod9 -l=aronovgj -m
latexindent.pl -s headings-blank-line -o +-mod2 -l=levels3,headingStartOnOwnLine,../specials/special-mod33,headingsBlankLines -m

# testing the -y switch
latexindent.pl -s headings1 -o=+-mod1 -y=' indentAfterHeadings:paragraph:indentAfterThisHeading:1;level:1 '
latexindent.pl -s -l issue-519 issue-519 -o=+-mod1
latexindent.pl -s issue-448 -l issue-448a -o=+-mod1

# preamble has heading commands
latexindent.pl -s -t -l sec-in-preamble1.yaml sec-in-preamble.tex -o=+-mod1
egrep -i 'found:' indent.log > headings-info1.txt 

latexindent.pl -s sample-large -o=+-mod1 -l indentHeadings

set +x 
wrapuptasks
