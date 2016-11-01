#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed

silentMode=0
# check flags, and change defaults appropriately
while getopts 's' OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on...next thing you'll see is git status."
   silentMode=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s -w commands-simple.tex
latexindent.pl -s -w commands-nested.tex
latexindent.pl -s -w commands-nested-opt-nested.tex
latexindent.pl -s -w commands-nested-harder.tex
latexindent.pl -s -w commands-four-nested.tex
git status
