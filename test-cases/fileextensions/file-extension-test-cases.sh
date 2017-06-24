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
# the -l switch can accept a + symbol:
latexindent.pl  tabular-karl -tt -l=+../alignment/multiColumnGrouping.yaml -s -o=tabular-karl1.tex 
latexindent.pl  tabular-karl -tt -l="   +../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl2.tex 
latexindent.pl  tabular-karl -tt -l="   +   ../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl3.tex 
latexindent.pl  tabular-karl -tt -l=../alignment/multiColumnGrouping.yaml+ -s -o=tabular-karl4.tex 
latexindent.pl  tabular-karl -tt -l="../alignment/multiColumnGrouping.yaml    +" -s -o=tabular-karl5.tex -g=one.log
# no yaml extension
latexindent.pl  tabular-karl -tt -l=+../alignment/multiColumnGrouping -s -o=tabular-karl6.tex 
# no extension for output file
latexindent.pl -s cmh.tex -tt -o one -g=one.log
latexindent.pl -s cmh -tt -o two -g=two.log
latexindent.pl -s cmh -tt -o three. -g=three.log
latexindent.pl -s cmh.bib -tt -o one -g=four.log
latexindent.pl -s cmh.bib -tt -o two. -g=five.log
git status
[[ $noisyMode == 1 ]] && makenoise
