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
git status
[[ $noisyMode == 1 ]] && makenoise
exit
