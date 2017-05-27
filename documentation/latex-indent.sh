#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=1
. ../test-cases/common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

find . -maxdepth 1 -name "*.tex" -exec latexindent.pl -l -w -m -s {} \;
find . -maxdepth 1 -name "*.bib" -exec latexindent.pl -l -w -m -s {} \;
git status
