#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

{ time latexindent.pl -s  sampleBEFORE-smaller.tex; } 2>sampleBEFORE-smaller.data
{ time latexindent.pl -s  sampleBEFORE.tex; } 2>sampleBEFORE.data
latexindent.pl -s sampleBEFORE.tex -o sampleBEFORE-default.tex -l indentHeadings.yaml

# big file at https://tex.stackexchange.com/questions/742079/format-document-with-latex-workshop-seems-not-to-work-for-large-tex-file?noredirect=1#comment1852196_742079
[[ $gitStatus == 1 ]] && git status
