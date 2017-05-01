#!/bin/bash
loopmax=5
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# proof of concept
latexindent.pl -s long-lines1.tex -o long-lines1-default.tex
latexindent.pl -s long-lines2.tex -o long-lines2-default.tex

# the issue that motivated this pursuit  https://github.com/cmhughes/latexindent.pl/issues/33
latexindent.pl -s jowens-short.tex -o jowens-short-mod-4.tex -l=text-wrap-4.yaml -m
latexindent.pl -s jowens-long.tex -o jowens-long-mod-4.tex -l=text-wrap-4.yaml -m

# long lines test cases
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
    # basic tests
    latexindent.pl -s long-lines1.tex -o long-lines1-mod-$i.tex -l=text-wrap-$i.yaml -m
    latexindent.pl -s long-lines2.tex -o long-lines2-mod-$i.tex -l=text-wrap-$i.yaml -m
    latexindent.pl -s long-lines3.tex -o long-lines3-mod-$i.tex -l=text-wrap-$i.yaml -m 
   [[ $silentMode == 0 ]] && set +x 
done

# verbatim
latexindent.pl -s -m verbatim-long-lines.tex -o verbatim-long-lines-mod1.tex -l=text-wrap-1.yaml
git status
[[ $noisyMode == 1 ]] && makenoise
