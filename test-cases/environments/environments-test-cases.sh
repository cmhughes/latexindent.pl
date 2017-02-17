#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=32
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

latexindent.pl -w -s environments-simple.tex
latexindent.pl -w -s environments-simple-nested.tex
latexindent.pl -w -s environments-nested-nested.tex
latexindent.pl -w -s environments-one-line.tex
latexindent.pl -w -s environments-challenging.tex
latexindent.pl -w -s environments-verbatim-simple.tex
latexindent.pl -w -s environments-verbatim-harder.tex
latexindent.pl -w -s verbatim1.tex
latexindent.pl -w -s environments-noindent-block.tex
latexindent.pl -w -s environments-noindent-block-mk1.tex
latexindent.pl -w -s noIndent-maetra.tex
latexindent.pl -w -s no-environments.tex
latexindent.pl -w -s environments-repeated.tex
latexindent.pl -w -s environments-trailing-comments.tex
latexindent.pl -w -s -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l=env-all-on.yaml,env-chall.yaml -s -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l env-all-on.yaml,env-chall.yaml -s -o environments-challenging-output.tex environments-challenging.tex
# go from one line to multi-line environments
latexindent.pl -s -l=env-all-on.yaml,env-mod-lines1.yaml -m -o=environments-one-line-mod-lines1.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines2.yaml -m -o=environments-one-line-mod-lines2.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines3.yaml -m -o=environments-one-line-mod-lines3.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines4.yaml -m -o=environments-one-line-mod-lines4.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines5.yaml -m -o=environments-one-line-mod-lines5.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines5.yaml -m -o=environments-one-line-simple-mod1.tex environments-one-line-simple.tex
latexindent.pl -s -l env-all-on.yaml -w -o environments-nested-fourth-mod1.tex -m environments-nested-fourth.tex
# change log file name
latexindent.pl -s -l=env-all-on.yaml,testlogfile.yaml environments-nested-fourth.tex
# go from multiline to non-multi line
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines6.yaml -o env-remove-line-breaks-mod1.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o env-remove-line-breaks-mod2.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o env-remove-line-breaks-mk1-mod1.tex environments-remove-line-breaks-mk1.tex
# this next one tests undisclosed linebreaks!
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o environments-remove-line-breaks-trailing-comments-mod1.tex environments-remove-line-breaks-trailing-comments.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines8.yaml -o=environments-remove-line-breaks-trailing-comments-mk1-mod1.tex environments-remove-line-breaks-trailing-comments-mk1.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod1.tex -m -l=env-all-on.yaml,env-mod-lines9.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod2.tex -m -l=env-all-on.yaml,env-mod-lines10.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod3.tex -m -l=env-all-on.yaml,env-mod-lines11.yaml environments-modify-multiple-line-breaks.tex
# conflicting line breaks
latexindent.pl environments-line-break-conflict.tex -s -m -o environments-line-break-conflict-mod1.tex -l=env-all-on.yaml,env-conflicts-mod1.yaml
latexindent.pl environments-line-break-conflict.tex -s -m -o environments-line-break-conflict-mod4.tex -l=env-all-on.yaml,env-conflicts-mod4.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -m -o environments-line-break-conflict-nested-mod-2.tex -l=env-all-on.yaml,env-conflicts-mod2.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -m -o environments-line-break-conflict-nested-mod-3.tex -l=env-all-on.yaml,env-conflicts-mod3.yaml
# condense/protect line breaks
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod4.tex -m -l=env-all-on.yaml,env-mod-lines12.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod5.tex -m -l=env-all-on.yaml,env-mod-lines13.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod6.tex -m -l=env-all-on.yaml,env-mod-lines14.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl environments-modify-multiple-line-breaks-verbatim.tex -s -m -o=environments-modify-multiple-line-breaks-verbatim-mod1.tex -l=env-all-on.yaml,env-mod-lines12.yaml 
# multi-switch == 2 (trailing comment stuff)
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterBegin.yaml -m environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-begin.tex
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterBody.yaml -m environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-Body.tex
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterEnd.yaml -m environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-End.tex
# global noAdditionalIndent test
latexindent.pl -s -l=env-all-on.yaml,noAdditionalIndentGlobal.yaml environments-simple.tex -o=environments-simple-global.tex
latexindent.pl -s -l=env-all-on.yaml,noAdditionalIndentGlobal.yaml environments-ifelsefi.tex -o=environments-ifelsefi-global.tex
# global indentRules test
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml environments-simple.tex -o=environments-simple-indent-rules-global.tex
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml environments-ifelsefi.tex -o=environments-ifelsefi-indent-rules-global.tex
# conflicting global noAdditionalIndent and indentRules 
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml,noAdditionalIndentGlobal.yaml  environments-simple.tex -o=environments-simple-indent-rules-global-conflict.tex
# special characters
latexindent.pl -s environments-special-characters.tex -o environments-special-characters-default.tex
# loop! this file was the first test-case file I created, and I hadn't yet explored looping. better late than never
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   latexindent.pl -s env-single-line.tex -o env-single-line-mod$i.tex -m -l=env-mod$i.yaml
   [[ $silentMode == 0 ]] && set +x 
done

[[ $silentMode == 0 ]] && set -x 


[[ $noisyMode == 1 ]] && makenoise
git status
