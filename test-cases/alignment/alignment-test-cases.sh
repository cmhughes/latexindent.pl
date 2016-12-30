#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# table-based test cases
latexindent.pl -s table1.tex -o table1-default.tex
for (( i=1 ; i <= 4 ; i++ )) 
do 
    latexindent.pl -s table1.tex -o table1-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table2.tex -o table2-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table3.tex -o table3-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table4.tex -o table4-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table5.tex -o table5-mod$i.tex -l=tabular$i.yaml
done
# legacy matrix test case
latexindent.pl -s matrix.tex -o matrix-default.tex
# legacy environment test case
latexindent.pl -s environments.tex -o environments-default.tex
git status
