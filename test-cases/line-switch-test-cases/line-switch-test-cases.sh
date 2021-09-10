#!/bin/bash
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# single line ranges
latexindent.pl --lines 3-5 -s environments-simple-nested.tex -o=+-mod1
latexindent.pl --lines 8-10 -s environments-simple-nested.tex -o=+-mod2

# line ranges specified in wrong order
latexindent.pl --lines 10-8 -s environments-simple-nested.tex -o=+-mod3

# multiple line ranges
latexindent.pl --lines 3-5,8-10 -s environments-simple-nested.tex -o=+-mod4

# multiple line range that actually is just one
latexindent.pl --lines 3-5,6-10 -s environments-simple-nested.tex -o=+-mod5

# overlapping line range
latexindent.pl --lines 3-5,4-10 -s environments-simple-nested.tex -o=+-mod6
latexindent.pl --lines 3-5,4-10 -s environments-simple-nested.tex -o=+-mod6A
latexindent.pl --lines 3-7,4-6  -s environments-simple-nested.tex -o=+-mod6B
latexindent.pl --lines 3-7,4-7  -s environments-simple-nested.tex -o=+-mod6C
latexindent.pl --lines 5-6,4-10 -s environments-simple-nested.tex -o=+-mod6D
latexindent.pl --lines 5-6,4-10,7-8 -s environments-simple-nested.tex -o=+-mod6E
latexindent.pl --lines 3-7,7-8 -s environments-simple-nested.tex -o=+-mod6F

# line range when <maxline> is greater than the number of lines in the file
latexindent.pl --lines 3-15 -s environments-simple-nested.tex -o=+-mod7

# invalid line range, which will be ignored
latexindent.pl --lines 3x-7 -s environments-simple-nested.tex -o=+-mod8

# ranges specified in funky order
latexindent.pl --lines 8-10,3-5 -s environments-simple-nested.tex -o=+-mod9
latexindent.pl --lines 8-10,3-5,1-2 -s environments-simple-nested.tex -o=+-mod10

# single line specification
latexindent.pl --lines 8 -s environments-simple-nested.tex -o=+-mod11
latexindent.pl --lines 8,4 -s environments-simple-nested.tex -o=+-mod12

# single line file
latexindent.pl --lines 8,4 -s single-line.tex -o=+-mod1

# modifylinebreaks testing
latexindent.pl --lines 6-11 -s -m environments-simple-nested.tex -l env-mod-lines1.yaml -o=+-mod13
latexindent.pl --lines 6 -s -m environments-to-multiple.tex -l env-mod-lines2.yaml -o=+-mod2

# replacement switch testing
latexindent.pl --lines 3 -s -r environments-simple-nested.tex -l replace1.yaml -o=+-mod14

# not mode ....
latexindent.pl --lines !8-10,!3-5 -s environments-simple-nested.tex -o=+-mod15

# nearly all the lines
latexindent.pl --lines 2-12 environments-simple-nested.tex -s -o=+-mod16

# blank lines
latexindent.pl --lines 1 blank-lines.tex -s -o=+-mod1
latexindent.pl --lines 4 blank-lines.tex -s -o=+-mod4
latexindent.pl --lines 6 blank-lines.tex -s -o=+-mod6
latexindent.pl --lines 8 blank-lines.tex -s -o=+-mod8
git status
