#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# table-based test cases
latexindent.pl -s table1.tex -o table1-default.tex
for (( i=1 ; i <= 4 ; i++ )) 
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
done
# legacy matrix test case
latexindent.pl -s matrix.tex -o matrix-default.tex
# legacy environment test case
latexindent.pl -s environments.tex -o environments-default.tex
latexindent.pl -s environments.tex -o environments-no-align-double-back-slash.tex -l=align-no-double-back-slash.yaml
# alignment inside a mandatory argument
latexindent.pl -s matrix1.tex -o matrix1-default.tex
latexindent.pl -s matrix1.tex -o matrix1-no-align.tex -l=noMatrixAlign.yaml
git status
