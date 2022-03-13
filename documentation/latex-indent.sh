#!/bin/bash
loopmax=1
. ../test-cases/common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

latexindent.pl -l=+mainfile.yaml -w -rv -m -s  latexindent.tex

find . -maxdepth 1 -name "s*.tex" -exec latexindent.pl -l -w -rv -m -s {} \;
find . -maxdepth 1 -name "*.bib" -exec latexindent.pl -l bibsettings.yaml -w -rv -m -s {} \;
[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status
