#!/bin/bash
loopmax=32
. ../common.sh

openingtasks

latexindent.pl -s -l online.yaml contributors -o=+-default
latexindent.pl -m -s -t contributors-remove-line-breaks -o contributors-vo-nameStartsOnOwnLine -l=NameStartsOnOwnLineYes,online
latexindent.pl -m -s contributors-remove-line-breaks -o contributors-vo-nameStartsOnOwnLine-no -l=NameStartsOnOwnLineNo,../commands/unprotect-blank-lines,online
latexindent.pl -m -s contributors-remove-line-breaks -o=+-vo-name-finishes-lb-mod1 -l=mand-args-Vo-mod1,../commands/unprotect-blank-lines,NameFinishesWithLineBreakYes,online 
latexindent.pl -m -s contributors-remove-line-breaks -o=+-vo-name-finishes-lb-mod2 -l=mand-args-Vo-mod2,../commands/unprotect-blank-lines,NameFinishesWithLineBreakNo,online
latexindent.pl -m -s contributors-remove-line-breaks -o=+-vo-name-finishes-lb-mod3 -l=mand-args-Vo-mod1,../commands/unprotect-blank-lines,NameFinishesWithLineBreakNo,online
latexindent.pl -m -s contributors-remove-line-breaks -o=+-vo-name-finishes-lb-mod4 -l=mand-args-Vo-mod2,../commands/unprotect-blank-lines,NameFinishesWithLineBreakYes,online 

# modifyLineBreaks experiments
set +x 
 for (( i=$loopmin ; i <= $loopmax ; i++ )) 
 do 
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    [[ $silentMode == 0 ]] && set -x 
    # just linebreak modification
    latexindent.pl -m -s contributors -o=+-vo-mod$i -l=mand-args-Vo-mod$i,online
    latexindent.pl -t -m -s contributors-remove-line-breaks -o=+-vo-mod$i -l=mand-args-Vo-mod$i,../commands/unprotect-blank-lines,online
    set +x 
 done

latexindent.pl -m -s contributors-remove-line-breaks -o=+-vo-mod5-no-remove -l=mand-args-Vo-mod5,../commands/unprotect-blank-lines,online  -y="removeTrailingWhitespace:beforeProcessing: 0"

# special characters
latexindent.pl -s special-characters -m -l=mand-args-mod1,../filecontents/indentPreambleYes -o=+-mod1 
latexindent.pl -s special-characters-minimal -o=+-default
latexindent.pl -s special-characters-minimal-blank-lines -o=+-default -g=one.log

# m switch active
latexindent.pl -t -s -m special-characters-minimal-blank-lines -o=+-m-switch -l=noCondenseBlankLines
egrep 'found:' indent.log > special-characters-minimal-blank-lines-m-swith.txt
latexindent.pl -s -m special-characters-minimal-blank-lines -o=+-m-switch-condense

# legacy test case
latexindent.pl -s tikz3 -o=+-default
latexindent.pl -s tikz4 -o=+-default -l ../texexchange/indentPreamble
latexindent.pl -s tikz4 -o=+-no-add-global -l ../texexchange/indentPreamble,noAddGlobNamed

# issue 241: https://github.com/cmhughes/latexindent.pl/issues/241
latexindent.pl -s -l issue241 issue241 -o +-mod1
latexindent.pl -s -l issue241a issue241 -o +-mod2

latexindent.pl -s issue-501 -o +-mod1

latexindent.pl -s -l issue-501 issue-501 -o +-mod2
latexindent.pl -s -m -y "modifyLineBreaks:textWrapOptions:columns:25,modifyLineBreaks:textWrapOptions:blocksBeginWith:other:(?:\\\\),noAdditionalIndentGlobal:namedGroupingBracesBrackets:1" issue-501a -o=+-mod2

latexindent.pl -s -l issue-544 issue-544 -o=+-mod1
latexindent.pl -s -l issue-565 issue-565 -o=+-mod1

set +x 
wrapuptasks
