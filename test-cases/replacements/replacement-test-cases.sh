#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# string test cases
# string test cases
# string test cases
latexindent.pl -s -r test1.tex -l=replace1.yaml -o=+-mod1
latexindent.pl -s -r test1.tex -l=replace2.yaml -o=+-mod2
latexindent.pl -s -rr test1.tex -l=replace1.yaml -o=+-rr-mod1
latexindent.pl -s -onlyreplacement test1.tex -l=replace1.yaml -o=+-rr-mod1
latexindent.pl -s -r test1.tex -l=replace3.yaml -o=+-mod3

latexindent.pl -s -r test2.tex -l=replace4.yaml -o=+-mod4
latexindent.pl -s -r -m test2.tex -l=replace5.yaml -o=+-mod5

# referencee: https://stackoverflow.com/questions/3790454/in-yaml-how-do-i-break-a-string-over-multiple-lines
latexindent.pl -s -r test3.tex -l=replace6.yaml -o=+-mod6

# regex substitution test cases
# regex substitution test cases
# regex substitution test cases
latexindent.pl -s -r test4.tex -l=replace7.yaml -o=+-mod7

# modifiers: https://perldoc.perl.org/perlre.html#Modifiers
latexindent.pl -s -r test4.tex -l=replace8.yaml -o=+-mod8
latexindent.pl -s -r test4.tex -l=replace9.yaml -o=+-mod9
latexindent.pl -s -r test3.tex -l=replace10.yaml -o=+-mod10

# replace $$...$$ with \begin{equation}...\end{equation}, https://tex.stackexchange.com/questions/242150/good-looking-latex-code
latexindent.pl -s -r test5.tex -l=replace11.yaml -o=+-mod11
latexindent.pl -s -r test5.tex -l=replace11.yaml -o=+-m-mod11 -m -y="modifyLineBreaks:environments:BeginStartsOnOwnLine:1;BodyStartsOnOwnLine:2;EndStartsOnOwnLine:2"

# multiple spaces with single spaces: https://tex.stackexchange.com/questions/490086/bring-several-lines-together-to-fill-blank-spaces-in-texmaker
latexindent.pl -s -r test6.tex -l=replace12.yaml -o=+-mod12

# an auto-index...? https://tex.stackexchange.com/questions/494776/how-do-i-create-an-index-in-latex-using-a-custom-wordfile
latexindent.pl -s -r test7.tex -l=replace13.yaml -o=+-mod13
latexindent.pl -s -r test7.tex -l=replace14.yaml -o=+-mod14

# replacing short commands with long commands, https://tex.stackexchange.com/questions/496660/replace-all-shorthands-defined-by-newcommand-with-full-commands
latexindent.pl -s -r test8.tex -l=replace15.yaml -o=+-mod15

# replacing equation \eqref{eq:aa} with \hyperref{equation \ref*{eq:aa}}
latexindent.pl -s -r test9.tex -l=replace16.yaml -o=+-mod16
latexindent.pl -s -replacement test9.tex -l=replace17.yaml -o=+-mod17

# verbatim test cases
latexindent.pl -s -r test10.tex -l=replace14.yaml -o=+-mod14
latexindent.pl -s -rr test10.tex -l=replace14.yaml -o=+-rr-mod14
latexindent.pl -s -rv test10.tex -l=replace14.yaml -o=+-rv-mod14

latexindent.pl -s -r test12.tex -l=replace19.yaml,../specials/special-verb1.yaml -o=+-mod19
latexindent.pl -s -rv test12.tex -l=replace19.yaml,../specials/special-verb1.yaml -o=+-rv-mod19

# strip preamble
latexindent.pl -s -r test11.tex -l=replace18.yaml -o=+-mod18

git status
[[ $noisyMode == 1 ]] && makenoise
