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
latexindent.pl  tabular-karl -l=+../alignment/multiColumnGrouping.yaml -s -o=tabular-karl1.tex 
latexindent.pl  tabular-karl -l="   +../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl2.tex 
latexindent.pl  tabular-karl -l="   +   ../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl3.tex 
latexindent.pl  tabular-karl -l=../alignment/multiColumnGrouping.yaml+ -s -o=tabular-karl4.tex 
latexindent.pl  tabular-karl -l="../alignment/multiColumnGrouping.yaml    +" -s -o=tabular-karl5.tex -g=one.log
# no yaml extension
latexindent.pl  tabular-karl -l=+../alignment/multiColumnGrouping -s -o=tabular-karl6.tex 
# no extension for output file
latexindent.pl -s cmh.tex -o one -g=one.log
latexindent.pl -s cmh -o two -g=two.log
latexindent.pl -s cmh -o three. -g=three.log
latexindent.pl -s cmh.bib -o one -g=four.log
latexindent.pl -s cmh.bib -o two. -g=five.log
# the output file can be called with a + sign, e.g
#       latexindent.pl cmh.tex -o=+one.tex
#       latexindent.pl cmh.tex -o=+one
# both of which are equivalent to
#       latexindent.pl cmh.tex -o=cmhone.tex
latexindent.pl -s cmh.tex -o +one -g=six.log
latexindent.pl -s cmh.tex -o +two.tex -g=seven.log
# test the ++ routine:
#       latexindent.pl myfile.tex -o=++
# says that latexindent should output to myfile0.tex; if myfile0.tex exists, it should use myfile1.tex, and so on.
#       latexindent.pl myfile.tex -o=output++
# says that latexindent should output to output0.tex; if output0.tex exists, it should use output1.tex, and so on.
#       latexindent.pl myfile.tex -o=+output++
# says that latexindent should myfileoutput to myfileoutput0.tex; if myfileoutput0.tex exists, it should use myfileoutput1.tex, and so on.
latexindent.pl cmh.tex -o=++ -s
latexindent.pl cmh.tex -o=output++ -s
latexindent.pl cmh.tex -o +output++ -s
latexindent.pl cmh.tex -o +myfile++.tex -s
latexindent.pl cmh.tex -o myfile++.tex -s
# update for https://github.com/cmhughes/latexindent.pl/issues/154
# latexindent can now be called to act on any file, regardless of it is 
# part of fileExtensionPreference
latexindent.pl -w cmh.txt -s
latexindent.pl -w cmh.jab -s
git status
[[ $noisyMode == 1 ]] && makenoise
