#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -w -s  myfile.tex
# shouldn't work, as .cmh is not in fileExtensionPreference
latexindent.pl -w -s  myfile.cmh
# *should* work as .cmh is in fileExtensionPreference in fileExtension1.yaml
latexindent.pl -w -s  myfile.cmh -l=fileExtension1.yaml
# should work, as it will pick up myfile.tex
latexindent.pl -w -s  myfile -g=myfile.log
# should pick up myfile.sty first
latexindent.pl -w -s  myfile -l=style-file-first.yaml -g=myfile-sty.log
# won't work, as it will look for another.tex, another.cls, another.bib, another.sty
latexindent.pl -w -s  another -g=one.log
git status
