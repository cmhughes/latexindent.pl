#!/bin/bash
#
loopmax=16
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# optional arguments in environments
latexindent.pl environments-first-opt-args -m -s -o=+-mod0 -l=opt-args-remove-all,../environments/env-all-on
latexindent.pl environments-first-opt-args-remove-linebreaks1 -m  -s -o=+-mod0 -l=opt-args-remove-all,../environments/env-all-on
latexindent.pl environments-simple-opt-args -m -s -o=+-out -l=opt-args-remove-all,../environments/env-all-on

set +x
# loop through -opt-args-mod<i>, from i=1...16
[[ $silentMode == 0 ]] && set +x
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
 [[ $showCounter == 1 ]] && echo $i of $loopmax
 [[ $silentMode == 0 ]] && set -x
 # one optional arg
 latexindent.pl environments-first-opt-args -m -s -o=+-mod$i -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i 
 latexindent.pl environments-first-opt-args -m -s -o=+-mod-supp$i -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,opt-args-supp 
 latexindent.pl environments-first-opt-args-remove-linebreaks1 -m -s -o=+-mod$i -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i 
 latexindent.pl environments-first-opt-args-remove-linebreaks1 -m -s -o=+-mod-supp$i -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,opt-args-supp
 latexindent.pl environments-first-opt-args-remove-linebreaks2 -m -s -o=+-mod-supp$i -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,unprotect-blank-lines
 # two optional args
 latexindent.pl environments-second-opt-args -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i -s -o=+-mod$i 
 latexindent.pl environments-second-opt-args-remove-linebreaks1 -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i -s -o=+-mod$i 
 latexindent.pl environments-second-opt-args-remove-linebreaks1 -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,unprotect-blank-lines -s -o=+-mod-unprotect$i 
 latexindent.pl environments-second-opt-args-remove-linebreaks1 -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,unprotect-blank-lines,condense-blank-lines,../ifelsefi/removeTWS-before -s -o=+-mod-unprotect-condense$i 
 # three, ah ah ah
 latexindent.pl environments-third-opt-args-remove-linebreaks1-trailing-comments -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i -s -o=+-mod$i
 latexindent.pl environments-third-opt-args -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod$i,addPercentAfterBegin -s -o=+-mod$i -g=other.log
 set +x
done

# multi switches set to 2
latexindent.pl environments-third-opt-args-remove-linebreaks1-trailing-comments -m -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod1,addPercentAfterBegin -s -o=+-mod1-addPercentAfterBegin
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,opt-args-mod1,addPercentBeforeBegin -m -s -o=+-percent-before-begin
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercentAfterEnd -m -s -o=+-percent-after-end
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercentAfterBody -m -s -o=+-percent-after-body
latexindent.pl -s -m -w environments-first-opt-args-mod-supp1 -l=opt-args-remove-all,../environments/env-all-on,addPercentAfterBody -o=+-mod1 
latexindent.pl -s environments-first-opt-args-more-comments -m -l=opt-args-remove-all,../environments/env-all-on,addPercentAfterBegin  -o=+-addPercentAfterBegin
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercentAll -m -s -o=+-percent-after-all

# noAdditionalIndent experiments   
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent -m -s -o=+-noAddtionalIndentScalar
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-mod1 -m -s -o=+-noAddtionalIndentHash-mod1
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-mod2 -m -s -o=+-noAddtionalIndentHash-mod2
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-mod3 -m -s -o=+-noAddtionalIndentHash-mod3
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-mod4 -m -s -o=+-noAddtionalIndentHash-mod4

# indent rules
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-indent-rules1 -m -s -o=environments-third-opt-args-indent-rules1
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-indent-rules2 -m -s -o=environments-third-opt-args-indent-rules2
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-indent-rules3 -m -s -o=environments-third-opt-args-indent-rules3
latexindent.pl environments-third-opt-args -l=opt-args-remove-all,../environments/env-all-on,addPercent-noAdditionalIndent-opt-args-indent-rules4 -m -s -o=environments-third-opt-args-indent-rules4

# multiple lines in optional arguments
latexindent.pl environments-third-opt-args-multiple-lines -w -s

# noAdditionalIndent
latexindent.pl environments-third-opt-args-mod1 -l=opt-args-remove-all,../environments/env-all-on,noAdditionalIndentGlobal -s -o=environments-third-opt-args-mod1-global -tt

# indentRules
latexindent.pl environments-third-opt-args-mod1 -l=opt-args-remove-all,../environments/env-all-on,indentRulesGlobal -s -o=environments-third-opt-args-mod1-indent-rules-global -tt

# forrest syntax bug, see https://github.com/cmhughes/latexindent.pl/issues/107
latexindent.pl -s forrest -o=+-mod1 -y="defaultIndent:' '"

exit 
# issue 445
latexindent.pl -s -l issue-445  -m issue-445 -o=+-mod1
latexindent.pl -s -l issue-445a -m issue-445 -o=+-mod2
latexindent.pl -s -l issue-445b -m issue-445 -o=+-mod3
latexindent.pl -s -l issue-445c -m issue-445 -o=+-mod4

latexindent.pl -s -l issue-445  -m issue-445a -o=+-mod1
latexindent.pl -s -l issue-445a -m issue-445a -o=+-mod2
latexindent.pl -s -l issue-445b -m issue-445a -o=+-mod3
latexindent.pl -s -l issue-445c -m issue-445a -o=+-mod4

[[ $silentMode == 0 ]] && set -x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
exit
