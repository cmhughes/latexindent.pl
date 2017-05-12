#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# simplest preamble
latexindent.pl -s simplest.tex -o simplest-out.tex
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
# noAdditionalIndent, indentRules (global)
latexindent.pl -s filecontents1.tex -o filecontents1-noAdditionalIndent.tex -l=noAdditionalIndentGlobal.yaml,indentPreambleYes.yaml
latexindent.pl -s filecontents1.tex -o filecontents1-indentRulesGlobal.tex -l=indentRulesGlobal.yaml,indentPreambleYes.yaml
# filecontents within document body
latexindent.pl -s filecontents4.tex -o filecontents4-default.tex -g=one.log
latexindent.pl -s filecontents4.tex -o filecontents4-indent-preamble.tex -l=indentPreambleYes.yaml -g two.log
latexindent.pl -s filecontents5.tex -o filecontents5-default.tex -g=one.log
latexindent.pl -s filecontents5.tex -o filecontents5-indent-preamble.tex -l=indentPreambleYes.yaml -g two.log
# filecontents with noindent block in preamble
latexindent.pl -s filecontents6.tex -o filecontents6-default.tex -g=one.log
latexindent.pl -s filecontents6.tex -o filecontents6-indent-preamble.tex -l=indentPreambleYes.yaml -g two.log
# headings-preamble-verbatim.tex
latexindent.pl -s headings-preamble-verbatim.tex -o headings-preamble-verbatim-default.tex
latexindent.pl -s headings-preamble-verbatim.tex -o headings-preamble-verbatim-indent-preamble.tex -l=indentPreambleYes.yaml
latexindent.pl -s headings-preamble-verbatim.tex -o headings-preamble-verbatim-indent-preamble-with-headings.tex -l=indentPreambleYes.yaml,../headings/levels1.yaml
git status
