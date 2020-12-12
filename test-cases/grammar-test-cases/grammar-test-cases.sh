#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s command1.tex -o=+-default.tex
latexindent.pl -s command2.tex -o=+-default.tex
latexindent.pl -s command3.tex -o=+-default.tex
latexindent.pl -s command4.tex -o=+-default.tex
latexindent.pl -s command5.tex -o=+-default.tex
latexindent.pl -s command6.tex -o=+-default.tex

latexindent.pl -s special1.tex -o=+-default.tex

latexindent.pl -s key-equals-value-braces1.tex -o=+-default.tex
latexindent.pl -s key-equals-value-braces2.tex -o=+-default.tex
latexindent.pl -s key-equals-value-braces3.tex -o=+-default.tex

for (( i=1 ; i <= 8 ; i++ )) do 
    latexindent.pl -s environment$i.tex -o=+-default.tex
done

latexindent.pl -s named-grouping-braces-brackets1.tex -o=+-default.tex
latexindent.pl -s named-grouping-braces-brackets2.tex -o=+-default.tex
latexindent.pl -s named-grouping-braces-brackets3.tex -o=+-default.tex

latexindent.pl -s ifelsefi1.tex -o=+-default.tex

[[ $silentMode == 0 ]] && set -x 

[[ $noisyMode == 1 ]] && makenoise
git status