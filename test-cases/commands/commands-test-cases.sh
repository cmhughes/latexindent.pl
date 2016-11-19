#!/bin/bash
#
# sample usage:
#   non-silent
#       commands-test-cases.sh
#   silent mode
#       commands-test-cases.sh -s
#   silent mode, loopmax 5
#       commands-test-cases.sh -s -l 5
#   silent mode, loopmin is 13, loopmax is 13
#       commands-test-cases.sh -s -o 13
# 
# i=22 && vim -p commands-one-line.tex commands-one-line-mod$i.tex && vim -p commands-one-line.tex commands-one-line-noAdditionalIndentGlobal-mod$i.tex && vim -p commands-one-line-nested-simple.tex commands-one-line-nested-simple-mod$i.tex && vim -p commands-one-line-nested.tex commands-one-line-nested-mod$i.tex && vim -p commands-one-line-nested.tex commands-one-line-nested-noAdditionalIndentGlobal-mod$i.tex && vim -p commands-remove-line-breaks.tex commands-remove-line-breaks-mod$i.tex && vim -p commands-remove-line-breaks.tex commands-remove-line-breaks-unprotect-mod$i.tex && vim -p commands-remove-line-breaks.tex commands-remove-line-breaks-unprotect-no-condense-mod$i.tex && vim -p commands-remove-line-breaks.tex commands-remove-line-breaks-noAdditionalGlobal-changeCommandBody-mod$i.tex && vim -p commands-remove-line-breaks.tex commands-remove-line-breaks-noAdditionalGlobal-mod$i.tex
loopmax=32
. ../common.sh

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
latexindent.pl -s -w trailingComments.tex
latexindent.pl -s -w bracketTest.tex
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
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
   # add line breaks
   latexindent.pl commands-one-line.tex -m  -tt -s -o=commands-one-line-mod$i.tex -l=mand-args-mod$i.yaml 
   latexindent.pl commands-one-line.tex -m  -tt -s -o=commands-one-line-noAdditionalIndentGlobal-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml 
   latexindent.pl commands-one-line-nested-simple.tex -m  -tt -s -o=commands-one-line-nested-simple-mod$i.tex -l=mand-args-mod$i.yaml -g=one.log
   latexindent.pl commands-one-line-nested.tex -m  -tt -s -o=commands-one-line-nested-mod$i.tex -l=mand-args-mod$i.yaml -g=one.log
   latexindent.pl commands-one-line-nested.tex -m  -tt -s -o=commands-one-line-nested-noAdditionalIndentGlobal-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml -g=two.log 
   # remove line breaks
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-mod$i.tex -l=mand-args-mod$i.yaml
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-unprotect-mod$i.tex -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noChangeCommandBody.yaml
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-unprotect-no-condense-mod$i.tex -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml,noChangeCommandBody.yaml
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-noAdditionalGlobal-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml,unprotect-blank-lines.yaml,noChangeCommandBody.yaml 
   # note the ChangeCommandBody.yaml in the following, which changes the behaviour of linebreaks at the end of a command
   latexindent.pl commands-remove-line-breaks.tex -s -m -tt -o=commands-remove-line-breaks-noAdditionalGlobal-changeCommandBody-mod$i.tex -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml,unprotect-blank-lines.yaml,ChangeCommandBody.yaml 
   # multiple commands
   latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-mod$i.tex -l=mand-args-mod$i.yaml -g=one.log
   latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-textbf-mod$i.tex -l=mand-args-mod$i.yaml,textbf.yaml -g=two.log
   latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-textbf-noAdditionalIndentGlobal-mod$i.tex -l=mand-args-mod$i.yaml,textbf.yaml,noAdditionalIndentGlobal.yaml -g=three.log
   latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-textbf-mand-args-noAdditionalIndentGlobal-mod$i.tex -l=mand-args-mod$i.yaml,textbf-mand-args.yaml,noAdditionalIndentGlobal.yaml -g=four.log
   [[ $silentMode == 0 ]] && set +x 
done
# testing the linebreak immediately before, e.g, \mycommand
latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-command-mod1.tex -l=command-begin-mod1.yaml
latexindent.pl commands-nested-multiple.tex -m  -tt -s -o=commands-nested-multiple-command-mod2.tex -l=command-begin-mod2.yaml
latexindent.pl commands-nested-multiple-remove-line-breaks.tex -m -tt -s -o=commands-nested-multiple-remove-line-breaks-command-mod3.tex -l=command-begin-mod3.yaml
latexindent.pl commands-nested-multiple-remove-line-breaks.tex -m -tt -s -o=commands-nested-multiple-remove-line-breaks-command-unprotect-mod3.tex -l=command-begin-mod3.yaml,unprotect-blank-lines.yaml
# special characters test case
latexindent.pl commands-four-special-characters.tex -o=commands-four-special-characters-default.tex -s
# multiple brace test
latexindent.pl -s -w multipleBraces.tex
latexindent.pl -s -m multipleBraces.tex -l=mand-args-mod1.yaml -o multipleBraces-mod1.tex
latexindent.pl -s -m multipleBraces.tex -l=mand-args-mod1.yaml,xapptocmd-none.yaml -o multipleBraces-xapptocmd-none-mod1.tex
latexindent.pl -s -m multipleBraces.tex -l=mand-args-mod1.yaml,xapptocmd-none.yaml,pagestyle.yaml -o multipleBraces-xapptocmd-none-pagestyle-comments-mod1.tex
git status
