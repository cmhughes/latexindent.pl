#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=0
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

latexindent.pl -w -s -t environments-simple.tex
latexindent.pl -w -s -t environments-simple-nested.tex
latexindent.pl -w -s -t environments-nested-nested.tex
latexindent.pl -w -s -t environments-one-line.tex
latexindent.pl -w -s -t environments-challenging.tex
latexindent.pl -w -s -t environments-verbatim-simple.tex
latexindent.pl -w -s -t environments-verbatim-harder.tex
latexindent.pl -w -s -t verbatim1.tex
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
# this next one tests undisclosed linebreaks!
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o environments-remove-line-breaks-trailing-comments-mod1.tex environments-remove-line-breaks-trailing-comments.tex
latexindent.pl  -s -m -l=env-mod-lines8.yaml -o=environments-remove-line-breaks-trailing-comments-mk1-mod1.tex environments-remove-line-breaks-trailing-comments-mk1.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod1.tex -m -tt -l=env-mod-lines9.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod2.tex -m -tt -l=env-mod-lines10.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod3.tex -m -tt -l=env-mod-lines11.yaml environments-modify-multiple-line-breaks.tex
# conflicting line breaks
latexindent.pl environments-line-break-conflict.tex -s -t -m -o environments-line-break-conflict-mod1.tex -l=env-conflicts-mod1.yaml
latexindent.pl environments-line-break-conflict.tex -s -t -m -o environments-line-break-conflict-mod4.tex -l=env-conflicts-mod4.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -t -m -o environments-line-break-conflict-nested-mod-2.tex -l=env-conflicts-mod2.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -t -m -o environments-line-break-conflict-nested-mod-3.tex -l=env-conflicts-mod3.yaml
# condense/protect line breaks
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod4.tex -m -tt -l=env-mod-lines12.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod5.tex -m -tt -l=env-mod-lines13.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod6.tex -m -tt -l=env-mod-lines14.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl environments-modify-multiple-line-breaks-verbatim.tex -s -t -m -o=environments-modify-multiple-line-breaks-verbatim-mod1.tex -l=env-mod-lines12.yaml 
# multi-switch == 2 (trailing comment stuff)
latexindent.pl -s -l=env-addPercentAfterBegin.yaml -m -tt environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-begin.tex
latexindent.pl -s -l=env-addPercentAfterBody.yaml -m -tt environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-Body.tex
latexindent.pl -s -l=env-addPercentAfterEnd.yaml -m -tt environments-simple-trailing-comments.tex -o=environments-simple-trailing-comments-percent-after-End.tex
# global noAdditionalIndent test
latexindent.pl -s -l=noAdditionalIndentGlobal.yaml environments-simple.tex -o=environments-simple-global.tex
latexindent.pl -s -l=noAdditionalIndentGlobal.yaml environments-ifelsefi.tex -o=environments-ifelsefi-global.tex
# global indentRules test
latexindent.pl -s -l=indentRulesGlobal.yaml environments-simple.tex -o=environments-simple-indent-rules-global.tex
latexindent.pl -tt -s -l=indentRulesGlobal.yaml environments-ifelsefi.tex -o=environments-ifelsefi-indent-rules-global.tex
# conflicting global noAdditionalIndent and indentRules 
latexindent.pl -s -l=indentRulesGlobal.yaml,noAdditionalIndentGlobal.yaml  environments-simple.tex -o=environments-simple-indent-rules-global-conflict.tex
# special characters
latexindent.pl -s environments-special-characters.tex -o environments-special-characters-default.tex
git status
