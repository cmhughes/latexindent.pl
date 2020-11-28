#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s command1.tex -o=+-default.tex
latexindent.pl -s command2.tex -o=+-default.tex
latexindent.pl -s environment1.tex -o=+-default.tex
latexindent.pl -s environment2.tex -o=+-default.tex

[[ $silentMode == 0 ]] && set -x 

[[ $noisyMode == 1 ]] && makenoise
git status
