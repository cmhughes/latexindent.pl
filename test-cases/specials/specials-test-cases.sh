#!/bin/bash
loopmax=32
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s special1.tex -o special1-default.tex
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # add line breaks
   latexindent.pl -s special1.tex -o special1-mod$i.tex -m -l=special-mod$i.yaml
   latexindent.pl -s special1-remove-line-breaks.tex -o special1-remove-line-breaks-mod$i.tex -m -l=special-mod$i.yaml
   latexindent.pl -s special1-remove-line-breaks.tex -o special1-remove-line-breaks-unprotect-mod$i.tex -m -l=special-mod$i.yaml,../commands/unprotect-blank-lines.yaml
   [[ $silentMode == 0 ]] && set +x 
done

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s special2.tex -o special2-mod1.tex -m -l=special-mod1.yaml 
latexindent.pl -s special3.tex -o special3-mod1.tex -m -l=special-mod1.yaml
latexindent.pl -s special2.tex -o special2-mod17.tex -m -l=special-mod17.yaml
latexindent.pl -s special3.tex -o special3-mod17.tex -m -l=special-mod17.yaml
# noAdditionalIndent
latexindent.pl -s special3.tex -o special3-noAddIndent-global-mod17.tex -m -l=no-add-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-mod17.tex -m -l=no-add-displayMath.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-body-mod17.tex -m -l=no-add-displayMath-body.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-body-no-mod17.tex -m -l=no-add-displayMath-body-no.yaml,special-mod17.yaml
# indentRules
latexindent.pl -s special3.tex -o special3-indent-rules-global-mod17.tex -m -l=indent-rules-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-indent-rules-displayMath-mod17.tex -m -l=indent-rule-displayMath.yaml,special-mod17.yaml -g=one.log
# no-inline-math (lookForThis: 0)
latexindent.pl -s special3.tex -o special3-no-inline-math-mod17.tex -m -l=no-inline-math.yaml,special-mod17.yaml -g=one.log
# issues from github
latexindent.pl -s Focus.tex -o Focus-default.tex
latexindent.pl -s heptadecagon1.tex -o heptadecagon1-default.tex
latexindent.pl -s heptadecagon2.tex -o heptadecagon2-default.tex
latexindent.pl -s heptadecagon3.tex -o heptadecagon3-mod1.tex -m -l=special-mod1.yaml,env-mod1.yaml
latexindent.pl -s heptadecagon3.tex -o heptadecagon3-mod17.tex -m -l=special-mod17.yaml,env-mod1.yaml
# nested special
latexindent.pl -s special-nested-simple.tex -o special-nested-simple-default.tex
latexindent.pl -s special-nested.tex -o special-nested-default.tex
latexindent.pl -s special-nested.tex -o special-nested-mod1.tex -m -l special-mod1.yaml
# mixed test case
latexindent.pl -s tabdo.sty -o tabdo-default.sty
# new specials test-cases
latexindent.pl -s nestedalignment.tex -o nestedalignment-NEW.tex -local new-specials.yaml
latexindent.pl -s nestedalignment.tex -o nestedalignment-NEW1.tex -local new-specials1.yaml
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
git status
