#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
set -x 

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

latexindent.pl -w -s -t environments-simple.tex
latexindent.pl -w -s -t environments-simple-nested.tex
latexindent.pl -w -s -t environments-nested-nested.tex
latexindent.pl -w -s -t environments-one-line.tex
latexindent.pl -w -s -t environments-challenging.tex
latexindent.pl -w -s -t environments-verbatim-simple.tex
latexindent.pl -w -s -t environments-verbatim-harder.tex
latexindent.pl -w -s -t environments-noindent-block.tex
latexindent.pl -w -s -t no-environments.tex
latexindent.pl -w -s -t environments-repeated.tex
latexindent.pl -w -s -t environments-trailing-comments.tex
latexindent.pl -w -s -t -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l=env-chall.yaml -s -t -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l env-chall.yaml -s -t -o environments-challenging-output.tex environments-challenging.tex
# go from one line to multi-line environments
latexindent.pl -s -l=env-mod-lines1.yaml -t -m -o=environments-one-line-mod-lines1.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines2.yaml -t -m -o=environments-one-line-mod-lines2.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines3.yaml -t -m -o=environments-one-line-mod-lines3.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines4.yaml -t -m -o=environments-one-line-mod-lines4.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines5.yaml -t -m -o=environments-one-line-mod-lines5.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines5.yaml -t -m -o=environments-one-line-simple-mod1.tex environments-one-line-simple.tex
latexindent.pl -s -w -o environments-nested-fourth-mod1.tex -m environments-nested-fourth.tex
# change log file name
latexindent.pl -s -l=testlogfile.yaml environments-nested-fourth.tex
# go from multiline to non-multi line
latexindent.pl  -s -m -tt -l=env-mod-lines6.yaml -o env-remove-line-breaks-mod1.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o env-remove-line-breaks-mod2.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o env-remove-line-breaks-mk1-mod1.tex environments-remove-line-breaks-mk1.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o environments-remove-line-breaks-trailing-comments-mod1.tex environments-remove-line-breaks-trailing-comments.tex
git status
exit
