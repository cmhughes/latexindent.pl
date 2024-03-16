#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
#
# hugely useful, for example:
#       vim opt-args-test-cases.sh && ./opt-args-test-cases.sh && vim -p environments-second-opt-args.tex environments-second-opt-args-mod2.tex
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
# add linebreaks
latexindent.pl -m -s environments-opt-mand-args1.tex -o=environments-opt-mand-args1-default.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml
latexindent.pl -m -s environments-opt-mand-args1.tex -o=environments-opt-mand-args1-addPercent-all.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,addPercentAll-mand.yaml,addPercentAll-opts.yaml
# remove linebreaks
latexindent.pl -m -s environments-opt-mand-args1-remove-linebreaks1.tex -o=environments-opt-mand-args1-remove-linebreaks1-mod1.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,opt-args-mod5.yaml,mand-args-mod5.yaml
latexindent.pl -m -s environments-opt-mand-args1-remove-linebreaks1.tex -o=environments-opt-mand-args1-remove-linebreaks1-mod2.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,opt-args-mod5.yaml,mand-args-mod5.yaml,unprotect-blank-lines.yaml
# noAdditionalIndent
latexindent.pl -s environments-opt-mand-args1-addPercent-all.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,noAdditionalIndentGlobal.yaml -o=environments-opt-mand-args1-addPercent-all-Global.tex
# indentRules
latexindent.pl -s environments-opt-mand-args1-addPercent-all.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,indentRulesGlobal.yaml -o=environments-opt-mand-args1-addPercent-all-indent-rules-Global.tex
latexindent.pl -s environments-opt-mand-args1-addPercent-all.tex -l=../opt-args/opt-args-remove-all.yaml,../environments/env-all-on.yaml,indentRulesGlobal.yaml,indentRulesGlobalEnv.yaml -o=environments-opt-mand-args1-addPercent-all-indent-rules-all-Global.tex
# comma poly-switch, https://github.com/cmhughes/latexindent.pl/issues/106
for (( i=-1 ; i <= 3 ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set -x 
    [[ $showCounter == 1 ]] && echo $i of 3
    # CommaStartsOnOwnLine, opt args
    latexindent.pl -s -m mycommand.tex -o=+-opt-mod$i -y="modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i"
    # CommaStartsOnOwnLine, mand args
    latexindent.pl -s -m mycommand.tex -o=+-mand-mod$i -y="modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i"
    # CommaFinishesWithLineBreak, opt args
    latexindent.pl -s -m mycommand.tex -o=+-opt-finish-mod$i -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i"
    # CommaFinishesWithLineBreak, mand args
    latexindent.pl -s -m mycommand.tex -o=+-mand-finish-mod$i -y="modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i"
    # CommaStartsOnOwnLine, opt and args
    latexindent.pl -s -m mycommand.tex -o=+-opt-mand-mod$i -y="modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i,modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i"
    # CommaFinishesWithLineBreak, opt and mand args
    latexindent.pl -s -m mycommand.tex -o=+-opt-mand-finish-mod$i -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i"
    latexindent.pl -s -m mycommand2.tex -o=+-opt-mand-finish-mod$i -l=remove-blank-lines.yaml -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaFinishesWithLineBreak:$i,modifyLineBreaks:mandatoryArguments:CommaStartsOnOwnLine:$i,modifyLineBreaks:optionalArguments:CommaStartsOnOwnLine:$i"
    # per-name testing
    latexindent.pl -s -m mycommand1.tex -o=+-opt-mod$i -y="modifyLineBreaks:optionalArguments:cmh:CommaStartsOnOwnLine:$i"
    latexindent.pl -s -m mycommand1.tex -o=+-mand-mod$i -y="modifyLineBreaks:mandatoryArguments:another:CommaStartsOnOwnLine:$i"
    latexindent.pl -s -m mycommand1.tex -o=+-mand-finish-mod$i -y="modifyLineBreaks:mandatoryArguments:another:CommaFinishesWithLineBreak:$i"
    [[ $silentMode == 0 ]] && set +x 
done
latexindent.pl -s -m heart.tex -o=+-mod0 -y="modifyLineBreaks:optionalArguments:CommaFinishesWithLineBreak:-1"

latexindent.pl -s -l issue-520.yaml -m issue-520.tex -o=+-mod1

[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
exit
