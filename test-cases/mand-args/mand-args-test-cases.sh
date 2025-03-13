#!/bin/bash
loopmax=16
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# mandatory arguments in environments
latexindent.pl environments-first-mand-args -m -s -w

# loop through mand-args-mod<i>.yaml, from i=1...16
set +x
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
 [[ $showCounter == 1 ]] && echo $i of $loopmax
 [[ $silentMode == 0 ]] && set -x 
 # one mand arg
 latexindent.pl environments-first-mand-args -m -s -o=+-mod$i -l=../environments/env-all-on,mand-args-mod$i 
 latexindent.pl environments-first-mand-args -m -s -o=+-mod-supp$i -l=../environments/env-all-on,mand-args-mod$i,mand-args-supp 
 latexindent.pl environments-first-mand-args-remove-linebreaks1 -m -s -o=+-mod$i -l=../environments/env-all-on,mand-args-mod$i 
 latexindent.pl environments-first-mand-args-remove-linebreaks1 -m -s -o=+-mod-supp$i -l=../environments/env-all-on,mand-args-mod$i,mand-args-supp
 latexindent.pl environments-first-mand-args-remove-linebreaks2 -m -s -o=+-mod-supp$i -l=../environments/env-all-on,mand-args-mod$i,unprotect-blank-lines
 # two mand args
 latexindent.pl environments-second-mand-args -m -l=../environments/env-all-on,mand-args-mod$i -s -o=+-mod$i 
 latexindent.pl environments-second-mand-args-remove-linebreaks1 -m -l=../environments/env-all-on,mand-args-mod$i -s -o=+-mod$i 
 latexindent.pl environments-second-mand-args-remove-linebreaks1 -m -l=../environments/env-all-on,mand-args-mod$i,unprotect-blank-lines -s -o=+-mod-unprotect$i 
 latexindent.pl environments-second-mand-args-remove-linebreaks1 -m -l=../environments/env-all-on,mand-args-mod$i,unprotect-blank-lines,condense-blank-lines,../ifelsefi/removeTWS-before -s -o=+-mod-unprotect-condense$i 
 # three, ah ah ah
 latexindent.pl environments-third-mand-args-remove-linebreaks1-trailing-comments -m -l=../environments/env-all-on,mand-args-mod$i -s -o=+-mod$i
 latexindent.pl environments-third-mand-args -m -l=../environments/env-all-on,mand-args-mod$i,addPercentAfterBegin -s -o=+-mod$i -g=other.log
 set +x
done

# multi switches set to 2
[[ $silentMode == 0 ]] && set -x 
latexindent.pl environments-third-mand-args-remove-linebreaks1-trailing-comments -m -l=../environments/env-all-on,mand-args-mod1,addPercentAfterBegin -s -o=environments-third-mand-args-remove-linebreaks1-trailing-comments-mod1-addPercentAfterBegin
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,mand-args-mod1,addPercentBeforeBegin -m -s -o=+-percent-before-begin
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercentAfterEnd -m -s -o=environments-third-mand-args-percent-after-end
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercentAfterBody -m -s -o=environments-third-mand-args-percent-after-body
latexindent.pl -s -m -w environments-first-mand-args-mod-supp1 -l=../environments/env-all-on,addPercentAfterBody -o=environments-first-mand-args-mod-supp1-mod1 
latexindent.pl -s environments-first-mand-args-more-comments -m -l=../opt-args/opt-args-remove-all,../environments/env-all-on,addPercentAfterBegin  -o=environments-first-mand-args-more-comments-addPercentAfterBegin
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercentAll -m -s -o=environments-third-mand-args-percent-after-all
# noAdditionalIndent experiments   
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent -m -s -o=environments-third-mand-args-noAddtionalIndentScalar
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-mod1 -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod1
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-mod2 -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod2
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-mod3 -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod3
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-mod4 -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod4
# indent rules
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-indent-rules1 -m -s -o=environments-third-mand-args-indent-rules1
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-indent-rules2 -m -s -o=environments-third-mand-args-indent-rules2
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-indent-rules3 -m -s -o=environments-third-mand-args-indent-rules3
latexindent.pl environments-third-mand-args -l=../environments/env-all-on,addPercent-noAdditionalIndent-mand-args-indent-rules4 -m -s -o=environments-third-mand-args-indent-rules4
# noAdditionalIndent
latexindent.pl environments-third-mand-args-mod1 -l=../environments/env-all-on,noAdditionalIndentGlobal -s -o=environments-third-mand-args-mod1-global -tt
# indentRules
latexindent.pl environments-third-mand-args-mod1 -l=../environments/env-all-on,indentRulesGlobal -s -o=environments-third-mand-args-mod1-indent-rules-global -tt
set +x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
