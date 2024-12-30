#!/bin/bash
loopmax=48
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s special1.tex -o special1-default.tex
# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   # add line breaks
   latexindent.pl -s special1.tex -o special1-mod$i.tex -m -l=special-mod$i.yaml
   latexindent.pl -s special1-remove-line-breaks.tex -o special1-remove-line-breaks-mod$i.tex -m -l=special-mod$i.yaml
   latexindent.pl -s special1-remove-line-breaks.tex -o special1-remove-line-breaks-unprotect-mod$i.tex -m -l=special-mod$i.yaml,../commands/unprotect-blank-lines.yaml
   [[ $silentMode == 0 ]] && set +x 
done

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s special2.tex -o special2-mod1.tex -m -l=special-mod1.yaml 
latexindent.pl -s special3.tex -o special3-mod1.tex -m -l=special-mod1.yaml
latexindent.pl -s special2.tex -o special2-mod17.tex -m -l=special-mod17.yaml
latexindent.pl -s special3.tex -o special3-mod17.tex -m -l=special-mod17.yaml

# noAdditionalIndent
latexindent.pl -s special3.tex -o special3-noAddIndent-global-mod17.tex -m -l=no-add-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-mod17.tex -m -l=no-add-displayMath.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-body-mod17.tex -m -l=no-add-displayMath-body.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-noAddIndent-displayMath-body-no-mod17.tex -m -l=no-add-displayMath-body-no.yaml,special-mod17.yaml

# indentRules
latexindent.pl -s special3.tex -o special3-indent-rules-global-mod17.tex -m -l=indent-rules-global.yaml,special-mod17.yaml
latexindent.pl -s special3.tex -o special3-indent-rules-displayMath-mod17.tex -m -l=indent-rule-displayMath.yaml,special-mod17.yaml -g=one.log

# no-inline-math (lookForThis: 0)
latexindent.pl -s special3.tex -o special3-no-inline-math-mod17.tex -m -l=no-inline-math.yaml,special-mod17.yaml -g=one.log

# issues from github
latexindent.pl -s Focus.tex -o Focus-default.tex
latexindent.pl -s heptadecagon1.tex -o heptadecagon1-default.tex
latexindent.pl -s heptadecagon2.tex -o heptadecagon2-default.tex
latexindent.pl -s heptadecagon3.tex -o heptadecagon3-mod1.tex -m -l=special-mod1.yaml,env-mod1.yaml
latexindent.pl -s heptadecagon3.tex -o heptadecagon3-mod17.tex -m -l=special-mod17.yaml,env-mod1.yaml

# nested special
latexindent.pl -s special-nested-simple.tex -o special-nested-simple-default.tex
latexindent.pl -s special-nested.tex -o special-nested-default.tex
latexindent.pl -s special-nested.tex -o special-nested-mod1.tex -m -l special-mod1.yaml
latexindent.pl -s nested-specials.tex -o=+-default

# mixed test case
latexindent.pl -s tabdo.sty -o tabdo-default.sty

# new specials test-cases
latexindent.pl -s nestedalignment.tex -o nestedalignment-NEW.tex -local new-specials.yaml
latexindent.pl -s nestedalignment.tex -o nestedalignment-NEW1.tex -local new-specials1.yaml

# specialBeforeCommand
latexindent.pl -s specialLeftBracket.tex -o=+-commands-first -l=specialsLeftRight.yaml
latexindent.pl -s specialLeftBracket.tex -o=+-commands-first-no-paren -l=specialsLeftRight.yaml,commands-no-parenthesis.yaml
latexindent.pl -s specialLeftBracket.tex -o=+-specials-first -l=specialsLeftRight.yaml,specialBeforeCommand.yaml 

# specialMiddle (see: https://github.com/cmhughes/latexindent.pl/issues/100)
latexindent.pl -s algpseudocode.tex -o=+-mod1 -l=koppor
latexindent.pl -s algpseudocode-mk1.tex -o=+-mod1 -l=koppor
latexindent.pl -s algpseudocode-mk2.tex -o=+-mod0 -l=koppor
latexindent.pl -s algpseudocode-mk2.tex -o=+-mod-array -l=koppor2
latexindent.pl -s algpseudocode.tex -o=+-mod3 -l=koppor3
latexindent.pl -s algpseudocode.tex -o=+-mod4 -l=koppor4

# specialMiddle polyswitch
[[ $loopmin -gt 10 ]] && loopmin=1
[[ $loopmax -gt 10 ]] && loopmax=10
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo "$i of $loopmax"
   latexindent.pl -m -s algpseudocode-mk2 -l=koppor,special-middle$i.yaml -t -o=+-mod$i
done
latexindent.pl -s algpseudocode-mk3.tex -o=+-mod1 -l=koppor,koppor1

# special verbatim (see https://github.com/cmhughes/latexindent.pl/issues/124)
latexindent.pl -s special4.tex -o=+-mod1 -l=special-verb1.yaml
latexindent.pl -s special4.tex -o=+-mod2 -l=special-verb2.yaml
latexindent.pl -s special4.tex -o=+-mod3 -l=special-verb1.yaml,special-verb2.yaml

latexindent.pl -s issue-448 -l issue-448a -o=+-mod1
latexindent.pl -s issue-448 -l issue-448b -o=+-mod2

latexindent.pl -s -l issue-477.yaml issue-477.tex -g one.log -o=+-mod1
latexindent.pl -s -l issue-477.yaml issue-477.tex -g two.log -o=+-mod2

latexindent.pl -s -l issue-480.yaml issue-480.tex -o=+-mod1

latexindent.pl -s -l issue-511.yaml issue-511.tex -o=+-mod1
latexindent.pl -s -l issue-511a.yaml issue-511.tex -o=+-mod2

latexindent.pl -s -l issue-554.yaml issue-554.tex -o=+-mod1

latexindent.pl -s -m -l issue-567.yaml issue-567.tex -o=+-mod1

latexindent.pl -s -r -m -l issue-567a.yaml issue-567a.tex -o=+-mod1

latexindent.pl -s -l issue-572.yaml -m -r issue-572.tex -o=+-mod1
[[ $noisyMode == 1 ]] && paplay /usr/share/sounds/freedesktop/stereo/complete.oga
[[ $gitStatus == 1 ]] && git status
