#!/bin/bash
loopmax=48
. ../common.sh

openingtasks

latexindent.pl -s  keyEqualsValueFirst -o=+-default
latexindent.pl -s  braceTestsmall -o=+-default 
latexindent.pl -s  braceTest -o=+-default 

# noAdditional indent for the key, globally
latexindent.pl -s  keyEqualsValueFirst -l=noAdditionalKey -o=+-noAdditional-key-global
latexindent.pl -s  braceTestsmall -l=noAdditionalKey -o=+-noAdditional-key-global
latexindent.pl -s  braceTest -l=noAdditionalKey -o=+-noAdditional-key-global

# noAdditional indent for mandatory arguments
latexindent.pl -s  keyEqualsValueFirst -l=noAdditionalIndent-pdfstartview -o=+-noAdditional-pdfstartview
latexindent.pl -s  braceTestsmall -l=noAdditionalIndent-pdfstartview -o=+-noAdditional-pdfstartview
latexindent.pl -s  braceTest -l=noAdditionalIndent-pdfstartview -o=+-noAdditional-pdfstartview
latexindent.pl -s  braceTest -l=noAdditionalIndent-pdfstartview,noAdditionalKey -o=+-noAdditional-pdfstartview-and-global

# key = brace within a command
latexindent.pl -s -w pgfkeys-first
latexindent.pl -s -w pgfkeys-nested

# multiple nesting with modifyLineBreaks
latexindent.pl -s pgfkeys-multiple-nested -m -l=../commands/mand-args-mod1 -o=+-mod1
latexindent.pl -s pgfkeys-multiple-nested -m -l=../commands/mand-args-mod1,noAdditionalIndentGlobal -o=+-global-mod1

set +x
# modifyLineBreaks experiments
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
 [[ $showCounter == 1 ]] && echo $i of $loopmax
 [[ $silentMode == 0 ]] && set -x 
 keepappendinglogfile

 # just linebreak modification
 latexindent.pl -s pgfkeys-nested -m -l=mand-args-mod$i -o=+-mod$i

 # linebreak modification, together with noAdditionalIndent globally for key={value} set to 1
 latexindent.pl -s pgfkeys-nested -m -l=mand-args-mod$i,noAdditionalIndentGlobal -o=+-noAdditional-Global-mod$i

 # linebreak modification, together with noAdditionalIndent set for 'another/. style'
 latexindent.pl -s pgfkeys-nested -m -l=mand-args-mod$i,noAdditionalIndent-start -o=+-noAdditional-start-mod$i

 # remove line breaks
 latexindent.pl -s pgfkeys-remove-line-breaks-first -m -l=equals-not-finishes-with-line-break,mand-args-mod$i -o=+-mod$i
 latexindent.pl -s pgfkeys-remove-line-breaks-first -m -l=equals-not-finishes-with-line-break,mand-args-mod$i,unprotect-blank-lines,equalsKeyOff -o=+-unprotect-equalsKeyOff-mod$i 
 latexindent.pl -s pgfkeys-remove-line-breaks-first -m -l=equals-not-finishes-with-line-break,mand-args-mod$i,unprotect-blank-lines -o=+-unprotect-mod$i 
 latexindent.pl -s pgfkeys-remove-line-breaks-first -m -l=equals-not-finishes-with-line-break,mand-args-mod$i,unprotect-blank-lines,noCondenseMultipleLines -o=+-unprotect-nocondense-mod$i 

 # bibliography check
 set +x
 [[ $i -lt 33 ]] && latexindent.pl -s contributors.bib -m -l=equals-not-finishes-with-line-break,online,mand-args-keywords$i -o=+-mod$i.bib

 [[ $silentMode == 0 ]] && set -x 
 keepappendinglogfile
 # remove line breaks, with trailing comments
 latexindent.pl pgfkeys-remove-line-breaks-first-tc -s -m -l=equals-not-finishes-with-line-break,unprotect-blank-lines,mand-args-mod$i -o=+-mod$i
 latexindent.pl -s pgfkeys-remove-line-breaks -m -l=equals-not-finishes-with-line-break,mand-args-mod$i -o=+-mod$i
 latexindent.pl -s pgfkeys-remove-line-breaks -m -l=equals-not-finishes-with-line-break,mand-args-mod$i,unprotect-blank-lines -o=+-unprotect-mod$i
 latexindent.pl -s pgfkeys-remove-line-breaks -m -l=equals-not-finishes-with-line-break,mand-args-mod$i,unprotect-blank-lines,noCondenseMultipleLines -o=+-unprotect-nocondense-mod$i
 set +x 
done

[[ $silentMode == 0 ]] && set -x 
keepappendinglogfile

# KeyStartsOnOwnLine
latexindent.pl -s pgfkeys-multiple-keys -l=equals-not-finishes-with-line-break,keyStartsOnOwnLine -m -o=+-remove
latexindent.pl -s pgfkeys-multiple-keys -l=equals-not-finishes-with-line-break,keyStartsOnOwnLine,unprotect-blank-lines -m -o=+-unprotect-remove
latexindent.pl -s pgfkeys-multiple-keys-single-line -l=equals-not-finishes-with-line-break,keyStartsOnOwnLineYes -m -o=+-to-multiple
latexindent.pl -s pgfkeys-multiple-keys-single-line -l=equals-not-finishes-with-line-break,keyStartsOnOwnLineWithComment -m -o=+-to-multiple-comment

# EqualsStartsOnOwnLine
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break,EqualsStartsOnOwnLine -o=+-first
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break,EqualsStartsOnOwnLine-comment -o=+-comments
latexindent.pl -s pgfkeys-add-equals -m -l=equals-not-finishes-with-line-break,EqualsStartsOnOwnLine-comment,mand-args-mod17 -o=+-comments-everywhere
latexindent.pl -s pgfkeys-equals-remove-line-breaks -m -l=equals-not-finishes-with-line-break,EqualsStartsOnOwnLine-remove -o=+-mod0
latexindent.pl -s pgfkeys-equals-remove-line-breaks -m -l=equals-not-finishes-with-line-break,EqualsStartsOnOwnLine-remove,unprotect-blank-lines -o=+-unprotect-mod0

# outn.cls
latexindent.pl -s outn-tiny.cls -o=+-default.cls
latexindent.pl -s outn-small.cls -o=+-default.cls

# optional argument to an environment with keys, and commands
latexindent.pl -s environment-opt-arg-with-commands1 -o=+-default

# mixed object example
latexindent.pl -s mixed-ifelsefi-commands-keys-braces1-default-small -o=+-out
latexindent.pl -s environment-opt-arg-with-commands1-default-small -o=+-out
latexindent.pl -s mixed-ifelsefi-commands-keys-braces1 -o=+-default -l=../filecontents/indentPreambleYes
latexindent.pl -s glossary1 -o=+-default
latexindent.pl -s pgfplotstable1 -o=+-default -l=../filecontents/indentPreambleYes
latexindent.pl -s tikz2 -o=+-default -l tikz2

# hea files
latexindent.pl -s heabib.bib -o=+-default.bib -l heabib
latexindent.pl -s hea-senior-fellowship-application -o=+-default -l=../filecontents/indentPreambleYes
latexindent.pl -s hea-senior-fellowship-application -o=+-max-indentation -l=../filecontents/indentPreambleYes,../environments/max-indentation1
latexindent.pl -s hea-senior-fellowship-application -o=+-max-indentation5 -l=../filecontents/indentPreambleYes,../environments/max-indentation5

# double back slash dodge, motivated by texexchange/29293-christian-feuersanger
latexindent.pl -s dodge-double-back-slash -o dodge-double-back-slash-default

latexindent.pl -s issue-378 -o=+-mod1 -l issue-378

set +x 
wrapuptasks
