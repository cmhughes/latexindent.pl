#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
#
# hugely useful, for example:
#       vim opt-args-test-cases.sh && ./opt-args-test-cases.sh && vim -p env-second-opt-args env-second-opt-args-mod2
. ../common.sh

set +x
[[ $silentMode == 0 ]] && set -x 
# add linebreaks
latexindent.pl -m -s env-opt-mand-args1 -o=+-default -l=../opt-args/opt-args-remove-all,../environments/env-all-on
latexindent.pl -m -s env-opt-mand-args1 -o=+-addPercent-all -l=../opt-args/opt-args-remove-all,../environments/env-all-on,addPercentAll-mand,addPercentAll-opts
# remove linebreaks
latexindent.pl -m -s env-opt-mand-args1-remove-linebreaks1 -o=+-mod1 -l=../opt-args/opt-args-remove-all,../environments/env-all-on,opt-args-mod5,mand-args-mod5
latexindent.pl -m -s env-opt-mand-args1-remove-linebreaks1 -o=+-mod2 -l=../opt-args/opt-args-remove-all,../environments/env-all-on,opt-args-mod5,mand-args-mod5,unprotect-blank-lines
# noAdditionalIndent
latexindent.pl -s env-opt-mand-args1-addPercent-all -l=../opt-args/opt-args-remove-all,../environments/env-all-on,noAdditionalIndentGlobal -o=+-Global
# indentRules
latexindent.pl -s env-opt-mand-args1-addPercent-all -l=../opt-args/opt-args-remove-all,../environments/env-all-on,indentRulesGlobal -o=+-indent-rules-Global
latexindent.pl -s -t env-opt-mand-args1-addPercent-all -l=../opt-args/opt-args-remove-all,../environments/env-all-on,indentRulesGlobal,indentRulesGlobalEnv -o=+-indent-rules-all-Global
# comma poly-switch, https://github.com/cmhughes/latexindent.pl/issues/106
set +x
for (( i=-1 ; i <= 3 ; i++ )) 
do 
 [[ $showCounter == 1 ]] && echo $i of 3
 [[ $silentMode == 0 ]] && set -x 
 # CommaStartsOnOwnLine, opt args
 latexindent.pl -s -m mycommand -o=+-opt-mod$i -y="modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i"
 # CommaStartsOnOwnLine, mand args
 latexindent.pl -s -m mycommand -o=+-mand-mod$i -y="modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i"
 # CommaFinishesWithLineBreak, opt args
 latexindent.pl -s -m mycommand -o=+-opt-finish-mod$i -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i"
 # CommaFinishesWithLineBreak, mand args
 latexindent.pl -s -m mycommand -o=+-mand-finish-mod$i -y="modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i"
 # CommaStartsOnOwnLine, opt and args
 latexindent.pl -s -m mycommand -o=+-opt-mand-mod$i -y="modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i,modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i"
 # CommaFinishesWithLineBreak, opt and mand args
 latexindent.pl -s -m mycommand -o=+-opt-mand-finish-mod$i -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i"
 latexindent.pl -s -t -m mycommand2 -o=+-opt-mand-finish-mod$i -l=remove-blank-lines -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i,modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i"
 # per-name testing
 latexindent.pl -s -m mycommand1 -o=+-opt-mod$i -y="modifyLineBreaks:optionalArguments:cmh:CommaStartsOnOwnLine:$i"
 latexindent.pl -s -m mycommand1 -o=+-mand-mod$i -y="modifyLineBreaks:mandatoryArguments:another:CommaStartsOnOwnLine:$i"
 latexindent.pl -s -m mycommand1 -o=+-mand-finish-mod$i -y="modifyLineBreaks:mandatoryArguments:another:CommaFinishesWithLineBreak:$i"
 set +x
done
latexindent.pl -s -m heart -o=+-mod0 -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:-1"

latexindent.pl -s -m -r heart -l heart1 -o=+-mod1 -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:-1"

latexindent.pl -s -l issue-520 -m issue-520 -o=+-mod1

set +x 
wrapuptasks
