#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# blank line poly-switch, https://github.com/cmhughes/latexindent.pl/issues/146

# BodyStartsOnOwnLine
latexindent.pl -s -m  ../environments/environments-nested-fourth.tex -y="modifyLineBreaks:environments:BodyStartsOnOwnLine:4" -o=+-bl-mod1
latexindent.pl -s -m  ../specials/special1.tex -y="modifyLineBreaks:specialBeginEnd:SpecialBodyStartsOnOwnLine:4" -o=+-bl-mod1
latexindent.pl -s -m  ifelsefi-simple-nested.tex -y="modifyLineBreaks:ifElseFi:BodyStartsOnOwnLine:4" -o=+-bl-mod1

# EndStartsOnOwnLine
latexindent.pl -s -m  ../environments/environments-simple.tex -y="modifyLineBreaks:environments:EndStartsOnOwnLine:4" -o=+-bl-mod1
latexindent.pl -s -m  ../specials/special1.tex -y="modifyLineBreaks:specialBeginEnd:SpecialEndStartsOnOwnLine:4" -o=+-bl-end-mod1
latexindent.pl -s -m  ifelsefi-simple-nested.tex -y="modifyLineBreaks:ifElseFi:FiStartsOnOwnLine:4" -o=+-bl-fi-mod1

# EndFinishesWithLineBreak
latexindent.pl -s -m  ../environments/environments-simple.tex -y="modifyLineBreaks:environments:EndFinishesWithLineBreak:4" -o=+-bl-fin-mod1
latexindent.pl -s -m  ../specials/special1.tex -y="modifyLineBreaks:specialBeginEnd:SpecialEndFinishesWithLineBreak:4" -o=+-bl-fin-mod1
latexindent.pl -s -m  ifelsefi-simple-nested.tex -y="modifyLineBreaks:ifElseFi:FiFinishesWithLineBreak:4" -o=+-bl-fi-fin-mod1

# BeginStartsOnOwnLine
latexindent.pl -s -m  ../environments/environments-simple.tex -y="modifyLineBreaks:environments:BeginStartsOnOwnLine:4" -o=+-bl-beg-mod1
latexindent.pl -s -m  section1.tex -y="modifyLineBreaks:mandatoryArguments:RCuBFinishesWithLineBreak:4" -o=+-bl-beg-mod1
latexindent.pl -s -m  section1.tex -y="modifyLineBreaks:commands:CommandStartsOnOwnLine:4" -o=+-bl-beg-head-mod1
latexindent.pl -s -m  defn1.tex -y="modifyLineBreaks:environments:defn:EndFinishesWithLineBreak:4" -o=+-bl-beg-mod1

# arguments
latexindent.pl -s -m mycommand.tex -y="modifyLineBreaks:mandatoryArguments:LCuBStartsOnOwnLine:4" -o=+-mod4-LCuB
latexindent.pl -s -m mycommand.tex -y="modifyLineBreaks:mandatoryArguments:RCuBStartsOnOwnLine:4" -o=+-mod4-RCuB
latexindent.pl -s -m mycommand.tex -y="modifyLineBreaks:optionalArguments:LSqBStartsOnOwnLine:4" -o=+-mod4-LSqB
latexindent.pl -s -m mycommand.tex -y="modifyLineBreaks:optionalArguments:RSqBStartsOnOwnLine:4" -o=+-mod4-RSqB

latexindent.pl -s -m mycommand1.tex -y="modifyLineBreaks:mandatoryArguments:LCuBStartsOnOwnLine:4" -o=+-mod4-LCuB
latexindent.pl -s -m mycommand1.tex -y="modifyLineBreaks:mandatoryArguments:RCuBStartsOnOwnLine:4" -o=+-mod4-RCuB
latexindent.pl -s -m mycommand1.tex -y="modifyLineBreaks:optionalArguments:LSqBStartsOnOwnLine:4" -o=+-mod4-LSqB
latexindent.pl -s -m mycommand1.tex -y="modifyLineBreaks:optionalArguments:RSqBStartsOnOwnLine:4" -o=+-mod4-RSqB

# https://github.com/cmhughes/latexindent.pl/issues/160
latexindent.pl -s -m xaltsc.tex -l=xaltsc.yaml -o=+-mod1
latexindent.pl -s -m -r xaltsc.tex -l=xaltsc2.yaml -o=+-mod2

[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
