#!/bin/bash
. ../test-cases/common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -l=+mainfile.yaml -w -rv -m -s  latexindent.tex
latexindent.pl -w -rv -m -g tex-files.log -l -s s*.tex
latexindent.pl -w -rv -m -g bib-files.log -l bibsettings.yaml -s *.bib

set +x
[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status

exit 0
