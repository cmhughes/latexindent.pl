#!/bin/bash
loopmax=32
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  keyEqualsValueFirst.tex -o=keyEqualsValueFirst-default.tex
latexindent.pl -s  braceTestsmall.tex -o=braceTestsmall-default.tex 
latexindent.pl -s  braceTest.tex -o=braceTest-default.tex 
# noAdditional indent for the key, globally
latexindent.pl -s  keyEqualsValueFirst.tex -l=noAdditionalKey.yaml -o=keyEqualsValueFirst-noAdditional-key-global.tex
latexindent.pl -s  braceTestsmall.tex -l=noAdditionalKey.yaml -o=braceTestsmall-noAdditional-key-global.tex
latexindent.pl -s  braceTest.tex -l=noAdditionalKey.yaml -o=braceTest-noAdditional-key-global.tex
# noAdditional indent for mandatory arguments
latexindent.pl -s  keyEqualsValueFirst.tex -l=noAdditionalIndent-pdfstartview.yaml -o=keyEqualsValueFirst-noAdditional-pdfstartview.tex
latexindent.pl -s  braceTestsmall.tex -l=noAdditionalIndent-pdfstartview.yaml -o=braceTestsmall-noAdditional-pdfstartview.tex
latexindent.pl -s  braceTest.tex -l=noAdditionalIndent-pdfstartview.yaml -o=braceTest-noAdditional-pdfstartview.tex
latexindent.pl -s  braceTest.tex -l=noAdditionalIndent-pdfstartview.yaml,noAdditionalKey.yaml -o=braceTest-noAdditional-pdfstartview-and-global.tex
# key = brace within a command
latexindent.pl -s -w pgfkeys-first.tex
latexindent.pl -s -w pgfkeys-nested.tex
# multiple nesting with modifyLineBreaks
latexindent.pl -s pgfkeys-multiple-nested.tex -m -l=../commands/mand-args-mod1.yaml -o=pgfkeys-multiple-nested-mod1.tex
latexindent.pl -s pgfkeys-multiple-nested.tex -m -l=../commands/mand-args-mod1.yaml,noAdditionalIndentGlobal.yaml  -o=pgfkeys-multiple-nested-global-mod1.tex
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # just linebreak modification
   latexindent.pl -s pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml -o=pgfkeys-nested-mod$i.tex
   # linebreak modification, together with noAdditionalIndent globally for key={value} set to 1
   latexindent.pl -s pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml,noAdditionalIndentGlobal.yaml -o=pgfkeys-nested-noAdditional-Global-mod$i.tex
   # linebreak modification, together with noAdditionalIndent set for 'another/. style'
   latexindent.pl -s pgfkeys-nested.tex -m -l=mand-args-mod$i.yaml,noAdditionalIndent-start.yaml -o=pgfkeys-nested-noAdditional-start-mod$i.tex
   # remove line breaks
   latexindent.pl -s pgfkeys-remove-line-breaks-first.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-first-mod$i.tex -g=one.log
   latexindent.pl -s pgfkeys-remove-line-breaks-first.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml,equalsKeyOff.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-equalsKeyOff-mod$i.tex -g=two.log
   latexindent.pl -s pgfkeys-remove-line-breaks-first.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-mod$i.tex -g=three.log
   latexindent.pl -s pgfkeys-remove-line-breaks-first.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml -o=pgfkeys-remove-line-breaks-first-unprotect-nocondense-mod$i.tex -g=four.log
   # bibliography check
   latexindent.pl -s contributors.bib -m -l=equals-not-finishes-with-line-break.yaml,mand-args-keywords$i.yaml -o=contributors-mod$i.bib
   # remove line breaks, with trailing comments
   latexindent.pl pgfkeys-remove-line-breaks-first-tc.tex -s -m -l=equals-not-finishes-with-line-break.yaml,unprotect-blank-lines.yaml,mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-first-tc-mod$i.tex
   latexindent.pl -s pgfkeys-remove-line-breaks.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml -o=pgfkeys-remove-line-breaks-mod$i.tex -g=one.log
   latexindent.pl -s pgfkeys-remove-line-breaks.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml -o=pgfkeys-remove-line-breaks-unprotect-mod$i.tex -g=two.log
   latexindent.pl -s pgfkeys-remove-line-breaks.tex -m -l=equals-not-finishes-with-line-break.yaml,mand-args-mod$i.yaml,unprotect-blank-lines.yaml,noCondenseMultipleLines.yaml -o=pgfkeys-remove-line-breaks-unprotect-nocondense-mod$i.tex -g=three.log
   [[ $silentMode == 0 ]] && set +x 
done
# KeyStartsOnOwnLine
latexindent.pl -s pgfkeys-multiple-keys -l=equals-not-finishes-with-line-break.yaml,keyStartsOnOwnLine.yaml -m -o=pgfkeys-multiple-keys-remove.tex
latexindent.pl -s pgfkeys-multiple-keys -l=equals-not-finishes-with-line-break.yaml,keyStartsOnOwnLine.yaml,unprotect-blank-lines.yaml -m -o=pgfkeys-multiple-keys-unprotect-remove.tex
latexindent.pl -s pgfkeys-multiple-keys-single-line.tex -l=equals-not-finishes-with-line-break.yaml,keyStartsOnOwnLineYes.yaml -m -o=pgfkeys-multiple-keys-single-line-to-multiple.tex
latexindent.pl -s pgfkeys-multiple-keys-single-line.tex -l=equals-not-finishes-with-line-break.yaml,keyStartsOnOwnLineWithComment.yaml -m -o=pgfkeys-multiple-keys-single-line-to-multiple-comment.tex
# EqualsStartsOnOwnLine.yaml
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break.yaml,EqualsStartsOnOwnLine.yaml -o=pgfkeys-add-equals-first.tex
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break.yaml,EqualsStartsOnOwnLine-comment.yaml -o=pgfkeys-add-equals-comments.tex
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break.yaml,EqualsStartsOnOwnLine-comment.yaml,mand-args-mod17.yaml -o=pgfkeys-add-equals-comments-everywhere.tex
latexindent.pl -s pgfkeys-equals-remove-line-breaks -m -l=equals-not-finishes-with-line-break.yaml,EqualsStartsOnOwnLine-remove.yaml -o=pgfkeys-equals-remove-line-breaks-mod0.tex
latexindent.pl -s pgfkeys-equals-remove-line-breaks -m -l=equals-not-finishes-with-line-break.yaml,EqualsStartsOnOwnLine-remove.yaml,unprotect-blank-lines.yaml  -o=pgfkeys-equals-remove-line-breaks-unprotect-mod0.tex
# outn.cls
latexindent.pl -s outn-tiny.cls -o=outn-tiny-default.cls
latexindent.pl -s outn-small.cls -o=outn-small-default.cls
latexindent.pl -s outn.cls -o=outn-default.cls -l=notabular.yaml,resetItem.yaml -g=cmh.log
# optional argument to an environment with keys, and commands
latexindent.pl -s environment-opt-arg-with-commands1 -o=environment-opt-arg-with-commands1-default.tex
# mixed object example
latexindent.pl -s mixed-ifelsefi-commands-keys-braces1-default-small.tex -o mixed-ifelsefi-commands-keys-braces1-default-small-out.tex
latexindent.pl -s environment-opt-arg-with-commands1-default-small.tex -o environment-opt-arg-with-commands1-default-small-out.tex
latexindent.pl -s mixed-ifelsefi-commands-keys-braces1 -o=mixed-ifelsefi-commands-keys-braces1-default.tex -l=../filecontents/indentPreambleYes.yaml
latexindent.pl -s glossary1.tex -o glossary1-default.tex
latexindent.pl -s pgfplotstable1.tex -o pgfplotstable1-default.tex -l=../filecontents/indentPreambleYes.yaml
latexindent.pl -s tikz2.tex -o tikz2-default.tex
# hea files
latexindent.pl -s heabib.bib -o heabib-default.bib
latexindent.pl -s hea-senior-fellowship-application.tex -o hea-senior-fellowship-application-default.tex -l=../filecontents/indentPreambleYes.yaml
# double back slash dodge, motivated by texexchange/29293-christian-feuersanger.tex
latexindent.pl -s dodge-double-back-slash.tex -o dodge-double-back-slash-default.tex
git status
[[ $noisyMode == 1 ]] && makenoise
