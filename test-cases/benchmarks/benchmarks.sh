#!/bin/bash
loopmax=0
. ../common.sh

openingtasks

{ time latexindent.pl -s -l sample  sampleBEFORE-smaller; } 2>sampleBEFORE-smaller.data
{ time latexindent.pl -s -l sample  sampleBEFORE; } 2>sampleBEFORE.data

# big file at https://tex.stackexchange.com/questions/742079/format-document-with-latex-workshop-seems-not-to-work-for-large-tex-file?noredirect=1#comment1852196_742079
{ time latexindent.pl -s -l paperSS122018arxivv2 -o=+-mod1; } 2>paperSS122018arxivv2.data

# big test file, should be less than 4 seconds
#
#       time latexindent.pl -s commands-simple-big.tex -o=+-mod1 -y="defaultIndent: '  '"
#
# perl -d:NYTProf  ../../latexindent.pl -s commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '"
# nytprofhtml --open
{ time latexindent.pl -s commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing.data
{ time latexindent.pl -s -m commands-simple-big.tex -o=+-out1 -l arg-minimal-between -y="defaultIndent: '  '" ; } 2> commands-simple-big-timing-m-switch.data

set +x 
wrapuptasks
