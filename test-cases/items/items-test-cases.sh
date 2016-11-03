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

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 
loopmax=7
#[[ $# -eq 1 ]] &&  loopmax=$1  # mand-args-test-cases.sh <maxloop>
#echo "mand-args-test-cases.sh will run with loopmax = $loopmax"

# making strings of tabs and spaces gives different results; 
# this first came to light when studying items1.tex -- the following test cases helped to 
# resolve the issue
latexindent.pl -s -t spaces-and-tabs.tex -l=tabs-follow-tabs.yaml -o=spaces-and-tabs-tft.tex
latexindent.pl -s -t spaces-and-tabs.tex -l=spaces-follow-tabs.yaml -o=spaces-and-tabs-sft.tex
latexindent.pl -s -t spaces-and-tabs.tex -l=tabs-follow-spaces -o=spaces-and-tabs-tfs.tex
# first lot of items
latexindent.pl -s -w items1.tex
# nested itemize/enumerate environments -- these ones needed ancestors, the understanding/development of which took about a week!
latexindent.pl -s -w items1.5.tex
latexindent.pl -s -w items2.tex
latexindent.pl -s -w items2.5.tex
latexindent.pl -s -w items3.tex
latexindent.pl -s -w items4.tex -g=items4-check.log
latexindent.pl -s -w items5.tex
# noAdditionalIndent
latexindent.pl -s -l=noAdditionalIndentItemize.yaml items1.tex -o=items1-noAdditionalIndentItemize.tex
latexindent.pl -s -l=noAdditionalIndentItems.yaml items1.tex -o=items1-noAdditionalIndentItems.tex
latexindent.pl -s -g=other.log -l=noAdditionalIndent-myenv.yaml items3.tex -o=items3-noAdditionalIndent-myenv.tex
# indentRules
latexindent.pl -s -l=indentRulesItemize.yaml items1.tex -o=items1-indentRulesItemize.tex
latexindent.pl -s -l=indentRulesItems.yaml items1.tex -o=items1-indentRulesItems.tex
# test different item names
latexindent.pl -s -l=myitem.yaml -w items1-myitem.tex
latexindent.pl -s -l=part.yaml -w items1-part.tex
# modify linebreaks starts here
latexindent.pl -s -m items1.tex -o=items1-mod0.tex
latexindent.pl -tt -s -m items1-blanklines.tex -o=items1-blanklines-mod0.tex 
latexindent.pl -s -m items2.tex -o=items2-mod0.tex
[[ $silentMode == 0 ]] && set +x 
for (( i=1 ; i <= $loopmax ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set -x 
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items1.tex -o=items1-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items2.tex -o=items2-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items3.tex -o=items3-mod$i.tex
    # blank line tests
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items1-blanklines.tex -o=items1-blanklines-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml,unPreserveBlankLines.yaml items1-blanklines.tex -o=items1-blanklines-unPreserveBlankLines-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml,BodyStartsOnOwnLine.yaml items1.tex -o=items1-BodyStartsOnOwnLine-mod$i.tex
    # starts on one line, adds linebreaks accordingly
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items5.tex -o=items5-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items6.tex -o=items6-mod$i.tex
    latexindent.pl -s -tt -m -l=items-mod$i.yaml items7.tex -o=items7-mod$i.tex -g=other.log
    [[ $silentMode == 0 ]] && set +x 
done
[[ $silentMode == 0 ]] && set -x 
# ifelsefi within an item
latexindent.pl -s items8.tex -o=items8-mod0.tex
latexindent.pl -s items9.tex -o=items9-mod0.tex
latexindent.pl -s items10.tex -w
latexindent.pl -s items10.tex -o=items10-myenv-noAdditionalIndent.tex -l=myenv.yaml
latexindent.pl -s items10.tex -o=items10-items-noAdditionalIndent.tex -l=noAdditionalIndentItems.yaml
latexindent.pl -s items11.tex -w
latexindent.pl -s items12.tex -o=items12-mod0.tex
latexindent.pl -s items12.tex -m -l=env-mod-lines1.yaml -o=items12-mod1.tex
# noAdditionalIndent
latexindent.pl -s -tt items12.tex -o=items12-Global.tex -l=noAdditionalIndentGlobal.yaml
git status
