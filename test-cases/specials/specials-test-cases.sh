#!/bin/bash
loopmax=48
. ../common.sh

openingtasks

latexindent.pl -s -m -l ../environments/env-mod1,../commands/unprotect-blank-lines -o=+-mod1 env1
latexindent.pl -s -m -l ../environments/env-mod1,../commands/unprotect-blank-lines -o=+-mod1 env2
latexindent.pl -s special1 -o special1-default
latexindent.pl -s -m -o=+-mod1 -l ../mand-args/mand-args-mod1,../commands/unprotect-blank-lines commands1
latexindent.pl -s -m -o=+-mod1 -l special-mod1,../commands/unprotect-blank-lines spec1

set +x
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   set +x
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   keepappendinglogfile

   # add line breaks
   latexindent.pl -s special1 -o=+-mod$i -m -l=special-mod$i
   latexindent.pl -s special1-remove-line-breaks -o=+-mod$i -m -l=special-mod$i
   latexindent.pl -s special1-remove-line-breaks -o=+-unprotect-mod$i -m -l=special-mod$i,../commands/unprotect-blank-lines
   set +x
done
keepappendinglogfile

latexindent.pl -s special2 -o=+-mod1 -m -l=special-mod1 
latexindent.pl -s special3 -o=+-mod1 -m -l=special-mod1
latexindent.pl -s special2 -o=+-mod17 -m -l=special-mod17
latexindent.pl -s special3 -o=+-mod17 -m -l=special-mod17

# noAdditionalIndent
latexindent.pl -s special3 -o=+-noAddIndent-global-mod17 -m -l=no-add-global,special-mod17
latexindent.pl -s special3 -o=+-noAddIndent-displayMath-mod17 -m -l=no-add-displayMath,special-mod17
latexindent.pl -s special3 -o=+-noAddIndent-displayMath-body-mod17 -m -l=no-add-displayMath-body,special-mod17
latexindent.pl -s special3 -o=+-noAddIndent-displayMath-body-no-mod17 -m -l=no-add-displayMath-body-no,special-mod17

# indentRules
latexindent.pl -s special3 -o=+-indent-rules-global-mod17 -m -l=indent-rules-global,special-mod17
latexindent.pl -s special3 -o=+-indent-rules-displayMath-mod17 -m -l=indent-rule-displayMath,special-mod17 -g=one.log

# no-inline-math (lookForThis: 0)
latexindent.pl -s special3 -o=+-no-inline-math-mod17 -m -l=no-inline-math,special-mod17

# issues from github
latexindent.pl -s Focus -o Focus-default
latexindent.pl -s heptadecagon1 -o=+-default
latexindent.pl -s heptadecagon2 -o=+-default
latexindent.pl -s heptadecagon3 -o=+-mod1 -m -l=special-mod1,env-mod1
latexindent.pl -s heptadecagon3 -o=+-mod17 -m -l=special-mod17,env-mod1

# nested special
latexindent.pl -s special-nested-simple -l dm-nested -o=+-default
latexindent.pl -s special-nested -o=+-default
latexindent.pl -s special-nested -o=+-mod1 -m -l special-mod1,dm-nested
latexindent.pl -s nested-specials -l dm-nested -o=+-default

# specialBeforeCommand
latexindent.pl -s specialLeftBracket -o=+-commands-first -l=specialsLeftRight
latexindent.pl -s specialLeftBracket -o=+-commands-first-no-paren -l=specialsLeftRight
latexindent.pl -s specialLeftBracket -o=+-specials-first -l=specialsLeftRight,specialBeforeCommand 

# specialMiddle (see: https://github.com/cmhughes/latexindent.pl/issues/100)
latexindent.pl -s algpseudocode -o=+-mod1 -l=koppor
latexindent.pl -s algpseudocode-mk1 -o=+-mod1 -l=koppor
latexindent.pl -s algpseudocode-mk2 -o=+-mod0 -l=koppor
latexindent.pl -s algpseudocode-mk2 -o=+-mod-array -l=koppor2
latexindent.pl -s algpseudocode -o=+-mod3 -l=koppor3
latexindent.pl -s algpseudocode -o=+-mod4 -l=koppor4

# specialMiddle polyswitch
[[ $loopmin -gt 10 ]] && loopmin=1
[[ $loopmax -gt 10 ]] && loopmax=10
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo "$i of $loopmax"
   keepappendinglogfile
   latexindent.pl -m -s algpseudocode-mk2 -l=koppor,special-middle$i -t -o=+-mod$i
done
keepappendinglogfile

latexindent.pl -s algpseudocode-mk3 -o=+-mod1 -l=koppor,koppor1

# special verbatim (see https://github.com/cmhughes/latexindent.pl/issues/124)
latexindent.pl -s special4 -o=+-mod1 -l=special-verb1
latexindent.pl -s special4 -o=+-mod2 -l=special-verb2
latexindent.pl -s special4 -o=+-mod3 -l=special-verb1,special-verb2

latexindent.pl -s issue-448 -l issue-448b -o=+-mod2
latexindent.pl -s -l issue-511 issue-511 -o=+-mod1
latexindent.pl -s -l issue-511a issue-511 -o=+-mod2
latexindent.pl -s -l issue-554 issue-554 -o=+-mod1
latexindent.pl -s -l issue-572 -m -r issue-572 -o=+-mod1
latexindent.pl -s -l issue-477 issue-477 -o=+-mod1
latexindent.pl -s -l issue-480 issue-480 -o=+-mod1

set +x 
wrapuptasks
