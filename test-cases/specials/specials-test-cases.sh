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
   [[ $silentMode == 0 ]] && set +x 
done
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
git status
