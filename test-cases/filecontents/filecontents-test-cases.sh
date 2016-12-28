#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# first test case
latexindent.pl -s filecontents1.tex -o filecontents1-default.tex
latexindent.pl -s filecontents1.tex -o filecontents1-indent-preamble.tex -l=indentPreambleYes.yaml
# second test case
latexindent.pl -s filecontents2.tex -o filecontents2-default.tex
latexindent.pl -s filecontents2.tex -o filecontents2-indent-preamble.tex -l=indentPreambleYes.yaml
# third test case
latexindent.pl -s filecontents3.tex -o filecontents3-default.tex 
latexindent.pl -s filecontents3.tex -o filecontents3-indent-preamble.tex -l=indentPreambleYes.yaml 
# fourth test case
latexindent.pl -s preamble1.tex -o preamble1-default.tex -g=one.log
latexindent.pl -s preamble1.tex -o preamble1-indent-preamble.tex -l=indentPreambleYes.yaml,preambleCommandsBeforeEnvironments.yaml -g=two.log -tt
# another
latexindent.pl -s theorem-small.tex -o theorem-small-default.tex -g=one.log
latexindent.pl -s theorem.tex -o theorem-default.tex -g=one.log
latexindent.pl -s theorem.tex -o theorem-indent-preamble.tex -l=indentPreambleYes.yaml,preambleCommandsBeforeEnvironments.yaml -g=two.log -tt
git status
