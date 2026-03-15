#!/bin/bash
loopmax=0
. ../common.sh

openingtasks

# simplest preamble
latexindent.pl -s simplest -o simplest-out
# first test case
latexindent.pl -s filecontents1 -o=+-default
latexindent.pl -s filecontents1 -o=+-indent-preamble -l=indentPreambleYes
# second test case
latexindent.pl -s filecontents2 -o filecontents2-default
latexindent.pl -s filecontents2 -o filecontents2-indent-preamble -l=indentPreambleYes
# third test case
latexindent.pl -s filecontents3 -o=+-default -y="noAdditionalIndentGlobal:namedGroupingBracesBrackets:1"
latexindent.pl -s filecontents3 -o=+-indent-preamble -l=indentPreambleYes -y="noAdditionalIndentGlobal:namedGroupingBracesBrackets:1"
# fourth test case
latexindent.pl -s preamble1 -o preamble1-default -g=one.log
latexindent.pl -s preamble1 -o preamble1-indent-preamble -l=indentPreambleYes,preambleCommandsBeforeEnvironments
# another
latexindent.pl -s theorem-small -o=+-mod1 -l specialLR
latexindent.pl -s theorem -o=+-default -l specialLR
latexindent.pl -s theorem -o=+-indent-preamble -l=indentPreambleYes,preambleCommandsBeforeEnvironments,specialLR
# noAdditionalIndent, indentRules (global)
latexindent.pl -s filecontents1 -o=+-noAdditionalIndent -l=noAdditionalIndentGlobal,indentPreambleYes
latexindent.pl -s filecontents1 -o=+-indentRulesGlobal -l=indentRulesGlobal,indentPreambleYes
# filecontents within document body
latexindent.pl -s filecontents4 -o=+-default
latexindent.pl -s filecontents4 -o=+-indent-preamble -l=indentPreambleYes
latexindent.pl -s filecontents5 -o=+-default
latexindent.pl -s filecontents5 -o=+-indent-preamble -l=indentPreambleYes
# filecontents with noindent block in preamble
latexindent.pl -s filecontents6 -o=+-default
latexindent.pl -s filecontents6 -o=+-indent-preamble -l=indentPreambleYes
# headings-preamble-verbatim
latexindent.pl -s headings-preamble-verbatim -o=+-default
latexindent.pl -s headings-preamble-verbatim -o=+-indent-preamble -l=indentPreambleYes
latexindent.pl -s headings-preamble-verbatim -o=+-indent-preamble-with-headings -l=indentPreambleYes,levels1

set +x 
wrapuptasks
