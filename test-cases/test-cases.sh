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

silentMode=0
flagToPass=''
# check flags, and change defaults appropriately
while getopts "s" OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on..."
   flagToPass='-s'
   silentMode=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed

# environment objects
cd environments
[[ $silentMode == 1 ]] && echo "./environments/environments-test-cases.sh"
./environments-test-cases.sh $flagToPass
# ifelsefi objects
cd ../ifelsefi
[[ $silentMode == 1 ]] && echo "./ifelsefi/ifelsefi-test-cases.sh"
./ifelsefi-test-cases.sh $flagToPass
# optional arguments in environments
cd ../opt-args
[[ $silentMode == 1 ]] && echo "./opt-args/opt-args-test-cases.sh"
./opt-args-test-cases.sh $flagToPass
# mandatory arguments in environments
cd ../mand-args
[[ $silentMode == 1 ]] && echo "./mand-args/mand-args-test-cases.sh"
./mand-args-test-cases.sh $flagToPass
# mixture of optional and mandatory arguments
cd ../opt-and-mand-args/
[[ $silentMode == 1 ]] && echo "./opt-and-mand-args/opt-and-mand-args-test-cases.sh"
./opt-mand-args-test-cases.sh $flagToPass
# items
cd ../items/
[[ $silentMode == 1 ]] && echo "./items/items-test-cases.sh"
./items-test-cases.sh $flagToPass
# commands
cd ../commands/
[[ $silentMode == 1 ]] && echo "./commands/commands-test-cases.sh"
./commands-test-cases.sh $flagToPass
exit
