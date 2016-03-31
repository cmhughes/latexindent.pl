#!/bin/bash
# A little script to help me run through test cases

find . -type f \( -name "*.tex" -or -name "*.cls" -or -name "*.sty" -or -name "*.bib" \) | while read file; do echo $file; latexindent.pl -w -s -l "$file";done

echo latexindent.pl -w -t -l=table5.yaml -s table5
latexindent.pl -w -t -l=table5.yaml -s table5

echo latexindent.pl  -w -l=items3.yaml -s --ttrace items3
latexindent.pl  -w -l=items3.yaml -s --ttrace items3

echo latexindent.pl  -w -l=items4.yaml -s --ttrace items4
latexindent.pl  -w -l=items4.yaml -s --ttrace items4
exit
