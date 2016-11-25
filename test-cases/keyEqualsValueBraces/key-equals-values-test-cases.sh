#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  -tt keyEqualsValueFirst.tex -o=keyEqualsValueFirst-default.tex
latexindent.pl -s  braceTestsmall.tex -o=braceTestsmall-default.tex 
latexindent.pl -s  braceTest.tex -o=braceTest-default.tex 
# noAdditional indent for the key, globally
latexindent.pl -s  -tt keyEqualsValueFirst.tex -l=noAdditionalKey.yaml -o=keyEqualsValueFirst-noAdditional-key-global.tex
latexindent.pl -s  -tt braceTestsmall.tex -l=noAdditionalKey.yaml -o=braceTestsmall-noAdditional-key-global.tex
latexindent.pl -s  -tt braceTest.tex -l=noAdditionalKey.yaml -o=braceTest-noAdditional-key-global.tex
# noAdditional indent for mandatory arguments
latexindent.pl -s  -tt keyEqualsValueFirst.tex -l=noAdditionalIndent-pdfstartview.yaml -o=keyEqualsValueFirst-noAdditional-pdfstartview.tex
latexindent.pl -s  -tt braceTestsmall.tex -l=noAdditionalIndent-pdfstartview.yaml -o=braceTestsmall-noAdditional-pdfstartview.tex
latexindent.pl -s  -tt braceTest.tex -l=noAdditionalIndent-pdfstartview.yaml -o=braceTest-noAdditional-pdfstartview.tex
latexindent.pl -s  -tt braceTest.tex -l=noAdditionalIndent-pdfstartview.yaml,noAdditionalKey.yaml -o=braceTest-noAdditional-pdfstartview-and-global.tex
# key = brace within a command
latexindent.pl -s -tt -w pgfkeys-first.tex
git status
