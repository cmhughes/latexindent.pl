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
latexindent.pl -s -w commands-four-nested-mk1.tex
latexindent.pl -s -w commands-five-nested.tex
latexindent.pl -s -w commands-five-nested-mk1.tex
latexindent.pl -s -w commands-six-nested.tex
# noAdditionalIndent
latexindent.pl -s commands-six-nested.tex -l=noAdditionalIndent1.yaml -o=commands-six-nested-NAD1.tex
latexindent.pl -s commands-six-nested.tex -l=noAdditionalIndent2.yaml -o=commands-six-nested-NAD2.tex
latexindent.pl -s commands-six-nested.tex -l=noAdditionalIndent3.yaml -o=commands-six-nested-NAD3.tex
latexindent.pl -s commands-six-nested.tex -l=noAdditionalIndent1.yaml,noAdditionalIndent2.yaml -o=commands-six-nested-NAD4.tex
latexindent.pl -s commands-six-nested.tex -o=commands-six-nested-global.tex -l=noAdditionalIndentGlobal.yaml
latexindent.pl -tt -s commands-simple-more-text.tex -o=commands-simple-more-text-not-global.tex
latexindent.pl -tt -s commands-simple-more-text.tex -o=commands-simple-more-text-global.tex -l=noAdditionalIndentGlobal.yaml
# indentRules
latexindent.pl -tt -s commands-simple-more-text.tex -o=commands-simple-more-text-indent-rules-global.tex -l=indentRulesGlobal.yaml
git status
