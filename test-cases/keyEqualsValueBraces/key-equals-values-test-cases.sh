#!/bin/bash
loopmax=32
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
latexindent.pl -s -tt -w pgfkeys-nested.tex
# multiple nesting with modifyLineBreaks
latexindent.pl -s -tt pgfkeys-multiple-nested.tex -m -l=../commands/mand-args-mod1.yaml -o=pgfkeys-multiple-nested-mod1.tex
latexindent.pl -s -tt pgfkeys-multiple-nested.tex -m -l=../commands/mand-args-mod1.yaml,noAdditionalIndentGlobal.yaml  -o=pgfkeys-multiple-nested-global-mod1.tex
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # just linebreak modification
   latexindent.pl -s -tt pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml -o=pgfkeys-nested-mod$i.tex
   # linebreak modification, together with noAdditionalIndent globally for key={value} set to 1
   latexindent.pl -s -tt pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml -o=pgfkeys-nested-noAdditional-Global-mod$i.tex
   # linebreak modification, together with noAdditionalIndent set for 'another/. style'
   latexindent.pl -s -tt pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml,noAdditionalIndent-start.yaml -o=pgfkeys-nested-noAdditional-start-mod$i.tex
   # remove line breaks
   latexindent.pl -s -tt pgfkeys-remove-line-breaks-first.tex -m -l=mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-first-mod$i.tex -g=one.log
   latexindent.pl -s -tt pgfkeys-remove-line-breaks-first.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,equalsKeyOff.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-equalsKeyOff-mod$i.tex -g=two.log
   latexindent.pl -s -tt pgfkeys-remove-line-breaks-first.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-mod$i.tex -g=three.log
   latexindent.pl -s -tt pgfkeys-remove-line-breaks-first.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-nocondense-mod$i.tex -g=four.log
   # remove line breaks, with trailing comments
   latexindent.pl pgfkeys-remove-line-breaks-first-tc.tex -s -tt -m -l=unprotect-blank-lines.yaml,mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-first-tc-mod$i.tex
   ##latexindent.pl -s -tt pgfkeys-remove-line-breaks.tex -m -l=mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-mod$i.tex -g=one.log
   ##latexindent.pl -s -tt pgfkeys-remove-line-breaks.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml -o=pgfkeys-remove-line-breaks-unprotect-mod$i.tex -g=two.log
   ##latexindent.pl -s -tt pgfkeys-remove-line-breaks.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml -o=pgfkeys-remove-line-breaks-unprotect-nocondense-mod$i.tex -g=three.log
   [[ $silentMode == 0 ]] && set +x 
done
###### NEED TO TEST key STARTS ON OWN LINE!!!
###### NEED TO TEST key STARTS ON OWN LINE!!!
###### NEED TO TEST key STARTS ON OWN LINE!!!

###### NEED TO TEST EQUALS STARTS ON OWN LINE!!!
###### NEED TO TEST EQUALS STARTS ON OWN LINE!!!
###### NEED TO TEST EQUALS STARTS ON OWN LINE!!!
git status
