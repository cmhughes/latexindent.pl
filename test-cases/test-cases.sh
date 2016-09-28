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

# environment objects
cd environments
./environments-test-cases.sh
# ifelsefi objects
cd ../ifelsefi
./ifelsefi-test-cases.sh
# optional arguments in environments
cd ../opt-args
./opt-args-test-cases.sh
# mandatory arguments in environments
cd ../mand-args
./mand-args-test-cases.sh
# mixture of optional and mandatory arguments
cd ../opt-and-mand-args/
./opt-mand-args-test-cases.sh
# items
cd ../items/
./items-test-cases.sh
git status
exit
