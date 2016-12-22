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
latexindent.pl -tt -s special2.tex -o special2-mod1.tex -m -l=special-mod1.yaml 
latexindent.pl -tt -s special3.tex -o special3-mod1.tex -m -l=special-mod1.yaml
latexindent.pl -tt -s special2.tex -o special2-mod17.tex -m -l=special-mod17.yaml
latexindent.pl -tt -s special3.tex -o special3-mod17.tex -m -l=special-mod17.yaml
# noAdditionalIndent
latexindent.pl -s special3.tex -t -o special3-noAddIndent-global-mod17.tex -m -l=no-add-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -t -o special3-noAddIndent-displayMath-mod17.tex -m -l=no-add-displayMath.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -t -o special3-noAddIndent-displayMath-body-mod17.tex -m -l=no-add-displayMath-body.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -t -o special3-noAddIndent-displayMath-body-no-mod17.tex -m -l=no-add-displayMath-body-no.yaml,special-mod17.yaml
# indentRules
latexindent.pl -s special3.tex -tt -o special3-indent-rules-global-mod17.tex -m -l=indent-rules-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -tt -o special3-indent-rules-displayMath-mod17.tex -m -l=indent-rule-displayMath.yaml,special-mod17.yaml -g=one.log
latexindent.pl -s special3.tex -tt -o special3-no-inline-math-mod17.tex -m -l=no-inline-math.yaml,special-mod17.yaml -g=one.log

# issues from github
latexindent.pl -s Focus.tex -o Focus-default.tex
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
git status
