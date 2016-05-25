#!/bin/bash
# A little script to help me run through test cases

#find . -type f \( -name "*.tex" -or -name "*.cls" -or -name "*.sty" -or -name "*.bib" \) | while read file; do echo $file; latexindent.pl -w -s -l "$file";done
#
#echo latexindent.pl -w -t -l=table5.yaml -s table5
#latexindent.pl -w -t -l=table5.yaml -s table5
#
#echo latexindent.pl  -w -l=items3.yaml -s --ttrace items3
#latexindent.pl  -w -l=items3.yaml -s --ttrace items3
#
#echo latexindent.pl  -w -l=items4.yaml -s --ttrace items4
#latexindent.pl  -w -l=items4.yaml -s --ttrace items4

latexindent.pl -w -s environments-simple.tex
latexindent.pl -w -s environments-simple-nested.tex
latexindent.pl -w -s environments-nested-nested.tex
latexindent.pl -w -s environments-one-line.tex
latexindent.pl -w -s environments-challenging.tex
latexindent.pl -w -s environments-verbatim-simple.tex
latexindent.pl -w -s environments-verbatim-harder.tex
latexindent.pl -w -s environments-noindent-block.tex
latexindent.pl -w -s no-environments.tex
latexindent.pl -w -s environments-repeated.tex
latexindent.pl -w -s environments-trailing-comments.tex
git status
exit
