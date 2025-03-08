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
# perl -d:NYTProf  ../../latexindent.pl -s commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '"
# nytprofhtml --open

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

latexindent.pl -s command-at-end-of-file.tex -o=+-mod1
latexindent.pl -s -m command-at-end-of-file.tex -o=+-mod2

# big test file, should be less than 4 seconds
#
#       time latexindent.pl -s commands-simple-big.tex -o=+-mod1 -y="defaultIndent: '  '"
#
{ time latexindent.pl -s commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing.txt
{ time latexindent.pl -s -m commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing-m-switch.txt

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
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent1.yaml -o=+-NAD1.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent2.yaml -o=+-NAD2.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent3.yaml -o=+-NAD3.tex
latexindent.pl -s commands-six-nested.tex -l=../opt-args/opt-args-remove-all.yaml,noAdditionalIndent1.yaml,noAdditionalIndent2.yaml -o=+-NAD4.tex
latexindent.pl -s commands-six-nested.tex -o=+-global.tex -l=noAdditionalIndentGlobal.yaml
latexindent.pl -s commands-simple-more-text.tex -o=+-not-global.tex
latexindent.pl -s commands-simple-more-text.tex -o=+-global.tex -l=noAdditionalIndentGlobal.yaml

# indentRules
latexindent.pl -s commands-simple-more-text.tex -o=+-indent-rules-global.tex -l=../opt-args/opt-args-remove-all.yaml,indentRulesGlobal.yaml

latexindent.pl just-one-command.tex -m  -s -o=+-mod1 -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,mand-args-mod1

set +x

# modifyLineBreaks experiments
[[ $loopmin -gt 32 ]] && loopmin=32
[[ $loopmax -gt 32 ]] && loopmax=32
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   
   # add line breaks
   latexindent.pl just-one-command  -m -s -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i 
   latexindent.pl commands-one-line -m -s -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i 
   latexindent.pl commands-one-line -m -s -o=+-noAdditionalIndentGlobal-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal 
   latexindent.pl commands-one-line-nested-simple -m -s -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-one-line-nested -m -s -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-one-line-nested -m -s -o=+-noAdditionalIndentGlobal-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal
   
   # remove line breaks
   latexindent.pl commands-remove-line-breaks -s -m -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-remove-line-breaks -s -m -o=+-unprotect-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,unprotect-blank-lines,noChangeCommandBody
   latexindent.pl commands-remove-line-breaks -s -m -o=+-unprotect-no-condense-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,unprotect-blank-lines,noCondenseMultipleLines,noChangeCommandBody
   latexindent.pl commands-remove-line-breaks -s -m -o=+-noAdditionalGlobal-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal,unprotect-blank-lines,noChangeCommandBody 
   latexindent.pl commands-remove-line-breaks -s -m -o=+-noAdditionalGlobal-changeCommandBody-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,noAdditionalIndentGlobal,unprotect-blank-lines,ChangeCommandBody 

   # multiple commands
   latexindent.pl commands-nested-multiple -m -s -o=+-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i
   latexindent.pl commands-nested-multiple -m -s -o=+-textbf-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,textbf
   latexindent.pl commands-nested-multiple -m -s -o=+-textbf-noAdditionalIndentGlobal-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,textbf,noAdditionalIndentGlobal
   latexindent.pl commands-nested-multiple -m -s -o=+-textbf-mand-args-noAdditionalIndentGlobal-mod$i -l=../opt-args/opt-args-remove-all,mand-args-mod$i,textbf-mand-args,noAdditionalIndentGlobal

   # multiple commands and environments
   latexindent.pl figureValign -m -s -o=figureValign-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,../environments/env-all-on,mand-args-mod$i,figValign-yaml,../filecontents/indentPreambleYes,SAS
   latexindent.pl figureValign -m -s -o=+-opt-mod$i -l=command-name-not-finishes-with-line-break,../opt-args/opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,figValign-yaml,makebox,../filecontents/indentPreambleYes,SAS 

   set +x
done
[[ $silentMode == 0 ]] && set -x 

# testing the linebreak immediately before, e.g, \mycommand
latexindent.pl commands-nested-multiple -m -s -o=+-command-mod1 -l=../opt-args/opt-args-remove-all,command-begin-mod1
latexindent.pl commands-nested-multiple -m -s -o=+-command-mod2 -l=../opt-args/opt-args-remove-all,command-begin-mod2
latexindent.pl commands-nested-multiple-remove-line-breaks -m -s -o=+-command-mod3 -l=../opt-args/opt-args-remove-all,command-begin-mod3
latexindent.pl commands-nested-multiple-remove-line-breaks -m -s -o=+-command-unprotect-mod3 -l=../opt-args/opt-args-remove-all,command-begin-mod3,unprotect-blank-lines

# special characters test case
latexindent.pl -s commands-four-special-characters -o=+-default

# multiple brace test
latexindent.pl -s -w multipleBraces.tex
latexindent.pl -s -m multipleBraces -o=+-mod1 -l=../opt-args/opt-args-remove-all,mand-args-mod1 
latexindent.pl -s -m multipleBraces -o=+-xapptocmd-none-mod1 -l=../opt-args/opt-args-remove-all,mand-args-mod1,xapptocmd-none
latexindent.pl -s -m multipleBraces -o=+-xapptocmd-none-pagestyle-comments-mod1 -l=../opt-args/opt-args-remove-all,mand-args-mod1,xapptocmd-none,pagestyle

# multiple trailing comment
latexindent.pl just-one-command-multiple-trailing-comments -m -s -o=+-mod17 -l=../opt-args/opt-args-remove-all,mand-args-mod17 

# trailing comments do not remove line breaks
latexindent.pl -m commands-remove-line-breaks-tc -s -o=+-mod5 -l=../opt-args/opt-args-remove-all,mand-args-mod5

# command with numeric arguments
latexindent.pl -s command-with-numeric-args -o=+-default

# issue 239: https://github.com/cmhughes/latexindent.pl/issues/239
latexindent.pl -s issue-239.tex -o=+-default.tex

# (empty) environment nested in a command
latexindent.pl -s -w command-nest-env

latexindent.pl -s numbers-between-args -o=+-mod0 -l numbers-allowed
latexindent.pl -s numbers-between-args -o=+-mod1 -m -l numbers-allowed,mand-args-mod1,../opt-args/opt-args-mod1

# round brackets ( )
latexindent.pl -s brackets1 -o=+-default
latexindent.pl -s foreach -o=+-mod1 -l foreach

# poly-switch = 3 (add line break experiements)
set +x
[[ $userSpecifiedLoopMin == 0 ]] && loopmin=33 
[[ $userSpecifiedLoopMin == 0 ]] && loopmax=48 

[[ $userSpecifiedLoopMin == 1 ]] && [[ $loopmin -lt 33 ]] && loopmin=33 && loopmax=33 
[[ $userSpecifiedLoopMin == 1 ]] && [[ $loopmax -gt 48 ]] && loopmin=48 && loopmax=48 
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # multiple commands
   latexindent.pl commands-nested-multiple -m  -s -o=+-mod$i -l=../opt-args/opt-args-mod$i,mand-args-mod$i
   latexindent.pl commands-nested-multiple -m  -s -o=+-un-protect-mod$i -l=../opt-args/opt-args-mod$i,mand-args-mod$i,unprotect-blank-lines

   # remove line breaks/exisiting blank lines
   latexindent.pl commands-remove-line-breaks -s -m -o=+-mod$i -l=../opt-args/opt-args-mod$i,mand-args-mod$i,unprotect-blank-lines

   set +x
done

[[ $silentMode == 0 ]] && set -x 

# issue 123: https://github.com/cmhughes/latexindent.pl/issues/123
latexindent.pl -s issue-123.tex -o=+-default.tex

# ifnextchar issue
latexindent.pl -s ifnextchar -o=+-default
latexindent.pl -s ifnextchar -o=+-mod1 -l=com-name-special1.yaml

# issue 379
latexindent.pl -s issue-379.tex -o=+-default.tex

latexindent.pl -s -t issue-379.tex -l issue-379.yaml -o=+-mod1.tex
egrep 'found:' indent.log > issue-379-mod1.txt

latexindent.pl -s commands-keys -l commands-keys -o=+-mod1

# from the documentation
latexindent.pl -s stars-from-documentation -o stars-from-documentation-default.tex

# small test case for environments
latexindent.pl -s -t testcls-small.cls -o=+-default.cls
egrep 'found:' indent.log > testcls.txt

# small test case for ifElseFi
latexindent.pl -s -w -t ifelsefiONE.tex
egrep 'found:' indent.log > ifelsefiONE.txt

latexindent.pl -s -w testcls.cls

latexindent.pl -s unnamed-small -o=+-mod1

# legacy test case, lots of commands, comments, line breaks
latexindent.pl -s  bigTest.tex -o=+-default.tex

# github issue
latexindent.pl -t -s github-issue-35 -o=+-default
egrep 'found:' indent.log > github-issue-35-default.txt
latexindent.pl -t -s github-issue-35 -o=+-no-at -l no-at-between-args.yaml
egrep 'found:' indent.log > github-issue-35-no-at.txt
latexindent.pl -s github-issue-35 -o=+-no-at1 -l no-at-between-args1.yaml
latexindent.pl -s github-issue-35 -o=+-no-at2 -l no-at-between-args2.yaml
latexindent.pl -t -s github-issue-35 -o=+-no-at3 -l no-at-between-args3.yaml
egrep 'found:' indent.log > github-issue-35-no-at3.txt

# multiple environments and commands with optional/mandatory arguments
latexindent.pl -w figureValign.tex -s

latexindent.pl -s pstricks1 -o=+-default -l=../texexchange/indentPreamble
exit

# <!---- RETURN TO SPECIALS
# <!---- RETURN TO SPECIALS
# <!---- RETURN TO SPECIALS

# sub and super scripts
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-default.tex
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-mod5.tex -m -l=../specials/special-mod5.yaml
latexindent.pl -s sub-super-scripts.tex -outputfile=sub-super-scripts-mod55.tex -m -l=../mand-args/mand-args-mod5.yaml,../specials/special-mod5.yaml

# named grouping bracket test case
latexindent.pl commands-four-special-characters -o=+-mod1 -s -l=fine-tuning-args1

[[ $silentMode == 0 ]] && set -x 
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
[[ $gitStatus == 1 ]] && git status
