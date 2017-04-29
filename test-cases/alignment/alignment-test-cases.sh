#!/bin/bash
loopmax=4
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# table-based test cases
latexindent.pl -s table1.tex -o table1-default.tex
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    # basic tests
    latexindent.pl -s table1.tex -o table1-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table2.tex -o table2-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table3.tex -o table3-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table4.tex -o table4-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table5.tex -o table5-mod$i.tex -l=tabular$i.yaml
    # tests with \\ not aligned
    latexindent.pl -s table1.tex -o table1-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml
    # tests with \\ not aligned, and with spaces before \\
    latexindent.pl -s table1.tex -o table1-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml
    # alignment inside commented block
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-mod$i.tex -l tabular$i.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-no-Add-1-mod$i.tex -l tabular$i.yaml,noAddtabular1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-no-Add-2-mod$i.tex -l tabular$i.yaml,noAddtabular2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-no-Add-3-mod$i.tex -l tabular$i.yaml,noAddtabular3.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-indent-rules-1-mod$i.tex -l tabular$i.yaml,indentRules1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-indent-rules-2-mod$i.tex -l tabular$i.yaml,indentRules2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-indent-rules-3-mod$i.tex -l tabular$i.yaml,indentRules3.yaml
done
# legacy matrix test case
latexindent.pl -s matrix.tex -o matrix-default.tex
# legacy environment test case
latexindent.pl -s environments.tex -o environments-default.tex
latexindent.pl -s environments.tex -o environments-no-align-double-back-slash.tex -l=align-no-double-back-slash.yaml
latexindent.pl -s legacy-align.tex -o legacy-align-default.tex
# alignment inside a mandatory argument
latexindent.pl -s matrix1.tex -o matrix1-default.tex
latexindent.pl -s matrix1.tex -o matrix1-no-align.tex -l=noMatrixAlign.yaml
# nested
latexindent.pl nested-align1.tex -s -l=indentPreamble.yaml  -m -o nested-align1-mod0.tex
# using comments
latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o alignmentoutsideEnvironmentsCommands-default.tex
# end statement not on own line
latexindent.pl -s end-not-on-own-line.tex -o end-not-on-own-line-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o end-not-on-own-line1-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o end-not-on-own-line1-mod1.tex -m -l=env-mod-lines1.yaml
# pmatrix
latexindent.pl -s pmatrix.tex -outputfile=pmatrix-default.tex -l=noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o pmatrix-special-mod1.tex -m -l=../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o pmatrix-pmatrix-mod1.tex -m -l=pmatrix-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o pmatrix-pmatrix-special-mod1.tex -m -l=pmatrix-mod1.yaml,../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml
# special
latexindent.pl -s special1.tex -o special1-aligned.tex -l special-align.yaml
# uni code
for (( i=1 ; i <= 6 ; i++ )) 
do 
    latexindent.pl -s uni-code1.tex -o uni-code1-mod$i.tex -l=tabular$i.yaml
done
git status
