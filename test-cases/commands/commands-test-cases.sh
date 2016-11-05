#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed

silentMode=0
loopmax=16
# check flags, and change defaults appropriately
while getopts 'sl:' OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on...next thing you'll see is git status."
   silentMode=1
   ;;
  l)
    loopmax=$OPTARG
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

echo "loopmax is $loopmax"

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
latexindent.pl -s -w commands-six-nested-mk1.tex
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
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=1 ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
   # add line breaks
   latexindent.pl commands-one-line.tex -m  -tt -s -o=commands-one-line-mod$i.tex -l=mand-args-mod$i.yaml 
   latexindent.pl commands-one-line.tex -m  -tt -s -o=commands-one-line-noAdditionalIndentGlobal-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml 
   # remove line breaks
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-mod$i.tex -l=mand-args-mod$i.yaml
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-unprotect-mod$i.tex -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml 
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-unprotect-no-condense-mod$i.tex -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml 
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-noAdditionalGlobal-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml,unprotect-blank-lines.yaml 
   [[ $silentMode == 0 ]] && set +x 
done
git status
