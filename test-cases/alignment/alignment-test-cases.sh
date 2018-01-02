#!/bin/bash
loopmax=4
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# table-based test cases
latexindent.pl -s table1.tex -o table1-default.tex
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    # basic tests
    latexindent.pl -s table1.tex -o=+-mod$i.tex -l=tabular$i.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table3.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table4.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table5.tex -o=+-mod$i.tex -l=tabular$i.yaml
    # tests with \\ not aligned
    latexindent.pl -s table1.tex -o table1-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml
    # tests with \\ not aligned, and with spaces before \\
    latexindent.pl -s table1.tex -o table1-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml
    # alignment inside commented block
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-mod$i.tex -l tabular$i.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-1-mod$i.tex -l tabular$i.yaml,noAddtabular1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-2-mod$i.tex -l tabular$i.yaml,noAddtabular2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-3-mod$i.tex -l tabular$i.yaml,noAddtabular3.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-1-mod$i.tex -l tabular$i.yaml,indentRules1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-2-mod$i.tex -l tabular$i.yaml,indentRules2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-3-mod$i.tex -l tabular$i.yaml,indentRules3.yaml
done
latexindent.pl -s table1.tex -o=+-mod3.tex -l=tabular3.yaml
# legacy matrix test case
latexindent.pl -s matrix.tex -o=+-default.tex
# legacy environment test case
latexindent.pl -s environments.tex -o=+-default.tex
latexindent.pl -s environments.tex -o=+-no-align-double-back-slash.tex -l=align-no-double-back-slash.yaml
latexindent.pl -s legacy-align.tex -o=+-default.tex
# alignment inside a mandatory argument
latexindent.pl -s matrix1.tex -o=+-default.tex
latexindent.pl -s matrix1.tex -o=+-no-align.tex -l=noMatrixAlign.yaml
# nested
latexindent.pl nested-align1.tex -s -l=indentPreamble.yaml  -m -o=+-mod0.tex
# using comments
latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-default.tex
# end statement not on own line
latexindent.pl -s end-not-on-own-line.tex -o=+-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o=+-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o=+-mod1.tex -m -l=env-mod-lines1.yaml
# pmatrix
latexindent.pl -s pmatrix.tex -outputfile=pmatrix-default.tex -l=noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-special-mod1.tex -m -l=../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-pmatrix-mod1.tex -m -l=pmatrix-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-pmatrix-special-mod1.tex -m -l=pmatrix-mod1.yaml,../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml
# special
latexindent.pl -s special1.tex -o=+-aligned.tex -l special-align.yaml
# uni code
for (( i=1 ; i <= 6 ; i++ )) 
do 
    latexindent.pl -s uni-code1.tex -o=+-mod$i.tex -l=tabular$i.yaml
done
# multiColumnGrouping
latexindent.pl -s tabular-karl.tex -o=+-default.tex
latexindent.pl -s tabular-karl.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s tabular-karl.tex -o=+-out1.tex -l multiColumnGrouping1.yaml
latexindent.pl -s tabular-karl.tex -o=+-out2.tex -l multiColumnGrouping2.yaml
latexindent.pl -s tabular-karl.tex -o=+-out3.tex -l multiColumnGrouping3.yaml
latexindent.pl -s tabular-karl.tex -o=+-out5.tex -l multiColumnGrouping.yaml,tabular5.yaml
latexindent.pl -s tabular-karl.tex -o=+-out6.tex -l multiColumnGrouping.yaml,tabular6.yaml
latexindent.pl -s multicol.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s unicode-multicol.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s table3.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s multicol-no-ampersands -o=+-default.tex
latexindent.pl -s multicol-no-ampersands.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s multicol-no-ampersands.tex -o=+-out5.tex -l multiColumnGrouping.yaml,tabular5.yaml
latexindent.pl -s multicol-no-ampersands.tex -o=+-out6.tex -l multiColumnGrouping.yaml,tabular6.yaml
latexindent.pl -s longcells.tex -o=+-default.tex
latexindent.pl -s longcells.tex -o=+-multicol.tex -l multiColumnGrouping.yaml
# spaces before and after ampersands
latexindent.pl -s table5.tex -o=+-mod7 -l=tabular7
latexindent.pl -s table5.tex -o=+-mod8 -l=tabular8
latexindent.pl -s table5.tex -o=+-mod9 -l=tabular9
latexindent.pl -s table5.tex -o=+-mod10 -l=tabular10
latexindent.pl -s tabular-karl.tex -o=+-out9.tex -l multiColumnGrouping.yaml,tabular9.yaml
latexindent.pl -s tabular-karl.tex -o=+-out10.tex -l multiColumnGrouping.yaml,tabular10.yaml
latexindent.pl -s matrix1.tex -o=+-mod1 -l=matrix1
latexindent.pl -s matrix1.tex -o=+-mod2 -l=matrix2
# left/right justification
latexindent.pl -s table5.tex -o=+-mod11 -l=tabular11
latexindent.pl -s table5.tex -o=+-mod12 -l=tabular11,tabular7,tabular8
latexindent.pl -s table5.tex -o=+-mod13 -l=tabular11,tabular9
latexindent.pl -s tabular-karl.tex -o=+-out11.tex -l multiColumnGrouping.yaml,tabular11.yaml

[[ $silentMode == 0 ]] && set -x 
git status
[[ $noisyMode == 1 ]] && makenoise
