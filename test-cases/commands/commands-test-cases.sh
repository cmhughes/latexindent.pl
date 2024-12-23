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
# for i in {1..32}; do latexindent.pl -m -l=opt-args-mod$i.yaml,figValign-yaml.yaml figureValign.tex -o=figureValign-opt-mod$i.tex -s && vim -p figureValign.tex figureValign-opt-mod$i.tex;done
loopmax=32
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s -w commands-simple.tex 
latexindent.pl -s -w commands-simple1.tex 
latexindent.pl -s -w commands-nested.tex 
latexindent.pl -s -w commands-nested-opt-nested.tex 
latexindent.pl -s -w commands-nested-harder.tex 
latexindent.pl -s -w commands-nested-harder1.tex 
latexindent.pl -s -w commands-four-nested.tex 

latexindent.pl -s commands-simple.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-simple1.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-nested.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-nested-opt-nested.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-nested-harder.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-nested-harder1.tex -o=+-mod1 -y="defaultIndent:'  '" 
latexindent.pl -s commands-four-nested.tex -o=+-mod1 -y="defaultIndent:'  '" 

# big test file, should be less than 4 seconds
#
#       time latexindent.pl -s commands-simple-big.tex -o=+-mod1 -y="defaultIndent: '  '"
#
{ time latexindent.pl -s commands-simple-big.tex -o=+-mod1 -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing.txt
{ time latexindent.pl -s commands-simple-big.tex -mod1 -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing-m-switch.txt

latexindent.pl -s -w commands-four-nested-mk1.tex

latexindent.pl -s -w commands-five-nested.tex 
latexindent.pl -s commands-five-nested.tex -o=+-mod1 -y="defaultIndent:'  '" 

latexindent.pl -s -w commands-five-nested-mk1.tex 
latexindent.pl -s commands-five-nested-mk1.tex -o=+-mod1 -y="defaultIndent:'  '" 

latexindent.pl -s -w commands-six-nested.tex 
latexindent.pl -s -w commands-six-nested-mk1.tex 
latexindent.pl -s -w trailingComments.tex
latexindent.pl -s -w bracketTest.tex

# noAdditionalIndent
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent1.yaml -o=commands-six-nested-NAD1.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent2.yaml -o=commands-six-nested-NAD2.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent3.yaml -o=commands-six-nested-NAD3.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent1.yaml,noAdditionalIndent2.yaml -o=commands-six-nested-NAD4.tex
latexindent.pl -s commands-six-nested.tex -o=commands-six-nested-global.tex -l=noAdditionalIndentGlobal.yaml
latexindent.pl -s commands-simple-more-text.tex -o=commands-simple-more-text-not-global.tex
latexindent.pl -s commands-simple-more-text.tex -o=commands-simple-more-text-global.tex -l=noAdditionalIndentGlobal.yaml

# indentRules
latexindent.pl -s commands-simple-more-text.tex -o=commands-simple-more-text-indent-rules-global.tex -l=../opt-args/opt-args-remove-all.yaml,indentRulesGlobal.yaml

latexindent.pl just-one-command.tex -m  -s -o=+-mod1 -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod1

# modifyLineBreaks experiments
[[ $loopmin -gt 32 ]] && loopmin=32
[[ $loopmax -gt 32 ]] && loopmax=32
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   
   # add line breaks
   latexindent.pl just-one-command  -m -s -o=+-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i 
   latexindent.pl commands-one-line -m -s -o=+-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i 
   latexindent.pl commands-one-line -m -s -o=+-noAdditionalIndentGlobal-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal 
   latexindent.pl commands-one-line-nested-simple -m -s -o=+-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-one-line-nested -m -s -o=+-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-one-line-nested -m -s -o=+-noAdditionalIndentGlobal-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal
   
   # remove line breaks
   latexindent.pl commands-remove-line-breaks -s -m -o=+-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i
done
[[ $silentMode == 0 ]] && set -x 

exit

   latexindent.pl commands-remove-line-breaks -s -m -o=+-unprotect-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod$i,unprotect-blank-lines,noChangeCommandBody
   latexindent.pl commands-remove-line-breaks.tex -s -m -o=commands-remove-line-breaks-unprotect-no-condense-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml,noChangeCommandBody.yaml
   latexindent.pl commands-remove-line-breaks.tex -s -m -o=commands-remove-line-breaks-noAdditionalGlobal-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml,unprotect-blank-lines.yaml,noChangeCommandBody.yaml 

   # note the ChangeCommandBody.yaml in the following, which changes the behaviour of linebreaks at the end of a command
   latexindent.pl commands-remove-line-breaks.tex -s -m -o=commands-remove-line-breaks-noAdditionalGlobal-changeCommandBody-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml,unprotect-blank-lines.yaml,ChangeCommandBody.yaml 
   # multiple commands
   latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml
   latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-textbf-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,textbf.yaml
   latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-textbf-noAdditionalIndentGlobal-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,textbf.yaml,noAdditionalIndentGlobal.yaml
   latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-textbf-mand-args-noAdditionalIndentGlobal-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod$i.yaml,textbf-mand-args.yaml,noAdditionalIndentGlobal.yaml
   # multiple commands and environments
   latexindent.pl figureValign.tex -m -s -o=figureValign-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,mand-args-mod$i.yaml,figValign-yaml.yaml,../filecontents/indentPreambleYes.yaml
   latexindent.pl figureValign.tex -m -s -o=figureValign-opt-mod$i.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,opt-args-mod$i.yaml,figValign-yaml.yaml,makebox.yaml,../filecontents/indentPreambleYes.yaml 
   [[ $silentMode == 0 ]] && set +x 

# testing the linebreak immediately before, e.g, \mycommand
latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-command-mod1.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,command-begin-mod1.yaml
latexindent.pl commands-nested-multiple.tex -m  -s -o=commands-nested-multiple-command-mod2.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,command-begin-mod2.yaml
latexindent.pl commands-nested-multiple-remove-line-breaks.tex -m -s -o=commands-nested-multiple-remove-line-breaks-command-mod3.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,command-begin-mod3.yaml
latexindent.pl commands-nested-multiple-remove-line-breaks.tex -m -s -o=commands-nested-multiple-remove-line-breaks-command-unprotect-mod3.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,command-begin-mod3.yaml,unprotect-blank-lines.yaml
# special characters test case
latexindent.pl commands-four-special-characters.tex -o=+-default.tex -s -l=fine-tuning-args1
# multiple brace test
latexindent.pl -s -w multipleBraces.tex
latexindent.pl -s -m multipleBraces.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod1.yaml -o multipleBraces-mod1.tex
latexindent.pl -s -m multipleBraces.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod1.yaml,xapptocmd-none.yaml -o multipleBraces-xapptocmd-none-mod1.tex
latexindent.pl -s -m multipleBraces.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod1.yaml,xapptocmd-none.yaml,pagestyle.yaml -o multipleBraces-xapptocmd-none-pagestyle-comments-mod1.tex
# (empty) environment nested in a command
latexindent.pl -s -w command-nest-env.tex
# multiple trailing comment
latexindent.pl just-one-command-multiple-trailing-comments.tex -m  -s -o=just-one-command-multiple-trailing-comments-mod17.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod17.yaml 
# test that commands with trailing comments do not remove line breaks
latexindent.pl -m commands-remove-line-breaks-tc.tex -s -o=commands-remove-line-breaks-tc-mod5.tex -l=command-name-not-finishes-with-line-break.yaml,../opt-args/opt-args-remove-all.yaml,mand-args-mod5.yaml
# command with numeric arguments
latexindent.pl -s command-with-numeric-args -o=command-with-numeric-args-default.tex
# small test case for intricate ancestors
latexindent.pl -s testcls-small.cls -o=testcls-small-default.cls
latexindent.pl -s -w testcls.cls
latexindent.pl -s -w ifelsefiONE.tex
# legacy test case, lots of commands, comments, line breaks
latexindent.pl -s  bigTest.tex -o  bigTest-default.tex
# from the documentation
latexindent.pl -s stars-from-documentation -o stars-from-documentation-default.tex
# sub and super scripts
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-default.tex
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-mod5.tex -m -l=../specials/special-mod5.yaml
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-mod55.tex -m -l=../mand-args/mand-args-mod5.yaml,../specials/special-mod5.yaml
# round brackets ( )
latexindent.pl -s brackets1.tex -o brackets1-default.tex
latexindent.pl -s pstricks1.tex -o pstricks1-default.tex -l=../texexchange/indentPreamble.yaml
# github issue
latexindent.pl -s github-issue-35.tex -o github-issue-35-default.tex
latexindent.pl -s github-issue-35.tex -o=+-no-at.tex -l no-at-between-args.yaml
latexindent.pl -s github-issue-35.tex -o=+-no-at1.tex -l no-at-between-args1.yaml
latexindent.pl -s github-issue-35.tex -o=+-no-at2.tex -l no-at-between-args2.yaml
latexindent.pl -s github-issue-35.tex -o=+-no-at3.tex -l no-at-between-args3.yaml
latexindent.pl -s numbers-between-args.tex -o=+-mod1 -l numbers-allowed.yaml
latexindent.pl -s foreach.tex -o=+-mod1 -l foreach.yaml
# poly-switch = 3 (add line break experiements)
[[ $loopmin -lt 33 ]] && loopmin=33 && loopmax=33 
[[ $loopmax -gt 48 ]] && loopmax=48 
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # multiple commands
   latexindent.pl commands-nested-multiple.tex -m  -s -o=+-mod$i.tex -l=../opt-args/opt-args-mod$i.yaml,mand-args-mod$i.yaml
   latexindent.pl commands-nested-multiple.tex -m  -s -o=+-un-protect-mod$i.tex -l=../opt-args/opt-args-mod$i.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml
   # remove line breaks/exisiting blank lines
   latexindent.pl commands-remove-line-breaks.tex -s -m -o=+-mod$i.tex -l=../opt-args/opt-args-mod$i.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml,command-name-not-finishes-with-line-break.yaml
   [[ $silentMode == 0 ]] && set +x 
done
[[ $silentMode == 0 ]] && set -x 
# ifnextchar issue
latexindent.pl -s ifnextchar.tex -o=+-default.tex -l=com-name-special.yaml
latexindent.pl -s ifnextchar.tex -o=+-mod1.tex -l=com-name-special1.yaml
latexindent.pl -s ifnextchar.tex -o=+-mod2.tex -l=com-name-special2.yaml
# issue 123: https://github.com/cmhughes/latexindent.pl/issues/123
latexindent.pl -s issue-123.tex -o=+-default.tex

# issue 239: https://github.com/cmhughes/latexindent.pl/issues/239
latexindent.pl -s issue-239.tex -o=+-default.tex

# issue 379
latexindent.pl -s issue-379.tex -o=+-default.tex
latexindent.pl -s issue-379.tex -l issue-379.yaml -o=+-mod1.tex

# multiple environments and commands with optional/mandatory arguments
latexindent.pl -w figureValign.tex -s

[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
[[ $gitStatus == 1 ]] && git status
