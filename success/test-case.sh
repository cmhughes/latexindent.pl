#!/bin/bash
# A little script to help me run through test cases

find . -type f \( -name "*.tex" -or -name "*.cls" -or -name "*.sty" -or -name "*.bib" \) | while read file; do echo $file; latexindent.pl -w -s -l "$file";done

echo latexindent.pl -w -t -l=table5.yaml -s table5.tex
latexindent.pl -w -t -l=table5.yaml -s table5.tex

exit
