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
git status
[[ $noisyMode == 1 ]] && makenoise
