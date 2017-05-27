#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=8
. ../../test-cases/common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# demonstration
latexindent.pl -s filecontents1.tex -o filecontents1-default.tex
latexindent.pl -s tikzset.tex -o tikzset-default.tex
latexindent.pl -s pstricks.tex --outputfile pstricks-default.tex
latexindent.pl -s pstricks.tex --outputfile pstricks-default.tex -logfile cmh.log

# alignment
latexindent.pl -s tabular1.tex --outputfile tabular1-default.tex -logfile cmh.log
latexindent.pl -s -l tabular.yaml tabular1.tex --outputfile tabular1-advanced.tex 
latexindent.pl -s -l tabular1.yaml tabular1.tex --outputfile tabular1-advanced-3spaces.tex 
latexindent.pl -s matrix1.tex -o matrix1-default.tex
latexindent.pl -s align-block.tex -o align-block-default.tex
# items
latexindent.pl -s items1.tex -o items1-default.tex
# special
latexindent.pl -s special1.tex -o special1-default.tex
# headings
latexindent.pl -s headings1.tex -o headings1-mod1.tex -l=headings1.yaml
latexindent.pl -s headings1.tex -o headings1-mod2.tex -l=headings2.yaml
# previously important example
latexindent.pl -s previously-important-example.tex -o previously-important-example-default.tex
##### ENVIRONMENTS ######
##### ENVIRONMENTS ######
##### ENVIRONMENTS ######
# noAdditionalIndent, environment
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body1.tex -l myenv-noAdd1.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body2.tex -l myenv-noAdd2.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body3.tex -l myenv-noAdd3.yaml
latexindent.pl -s myenvironment-simple.tex -o myenvironment-simple-noAdd-body4.tex -l myenv-noAdd4.yaml
# arguments
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-noAdd-body1.tex -l myenv-noAdd1.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-noAdd5.tex -l myenv-noAdd5.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-noAdd6.tex -l myenv-noAdd6.yaml
# indentRules
latexindent.pl -s myenvironment-simple.tex -l myenv-rules1.yaml -o myenv-rules1.tex
latexindent.pl -s myenvironment-simple.tex -l myenv-rules2.yaml -o myenv-rules2.tex
# arguments
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules1.tex -l myenv-rules1.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules3.tex -l myenv-rules3.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules4.tex -l myenv-rules4.yaml
# noAdditionalIndentGlobal
# body
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules1-noAddGlobal1.tex -l env-noAdditionalGlobal.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules1-noAddGlobal2.tex -l myenv-rules1.yaml,env-noAdditionalGlobal.yaml
# arguments
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules1-noAddGlobal3.tex -l opt-args-no-add-glob.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-rules1-noAddGlobal4.tex -l mand-args-no-add-glob.yaml
# indentRules
# body
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-global-rules1.tex -l env-indentRules.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-global-rules2.tex -l myenv-rules1.yaml,env-indentRules.yaml
# arguments
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-global-rules3.tex -l opt-args-indent-rules-glob.yaml
latexindent.pl -s myenvironment-args.tex -o myenvironment-args-global-rules4.tex -l mand-args-indent-rules-glob.yaml
# items
latexindent.pl -s items1.tex -o items1-noAdd1.tex -local item-noAdd1.yaml
latexindent.pl -s items1.tex -o items1-rules1.tex -local item-rules1.yaml
# global rules
latexindent.pl -s items1.tex -o items1-no-add-global.tex -local items-noAdditionalGlobal.yaml
latexindent.pl -s items1.tex -o items1-rules-global.tex -local items-indentRulesGlobal.yaml
##### COMMANDS ######
##### COMMANDS ######
##### COMMANDS ######
latexindent.pl -s mycommand.tex -o mycommand-default.tex
# noAdditionalIndent
latexindent.pl -s mycommand.tex -o mycommand-noAdd1.tex -local mycommand-noAdd1.yaml
latexindent.pl -s mycommand.tex -o mycommand-noAdd2.tex -local mycommand-noAdd2.yaml
latexindent.pl -s mycommand.tex -o mycommand-noAdd3.tex -local mycommand-noAdd3.yaml
latexindent.pl -s mycommand.tex -o mycommand-noAdd4.tex -local mycommand-noAdd4.yaml
latexindent.pl -s mycommand.tex -o mycommand-noAdd5.tex -local mycommand-noAdd5.yaml
latexindent.pl -s mycommand.tex -o mycommand-noAdd6.tex -local mycommand-noAdd6.yaml
##### ifElseFi ######
##### ifElseFi ######
##### ifElseFi ######
latexindent.pl -s ifelsefi1.tex -o ifelsefi1-default.tex
latexindent.pl -s ifelsefi1.tex -o ifelsefi1-noAdd.tex -local ifnum-noAdd.yaml
latexindent.pl -s ifelsefi1.tex -o ifelsefi1-indent-rules.tex -local ifnum-indent-rules.yaml
latexindent.pl -s ifelsefi1.tex -local ifelsefi-noAdd-glob.yaml -o ifelsefi1-noAdd-glob.tex 
latexindent.pl -s ifelsefi1.tex -l ifelsefi-indent-rules-global.yaml -o ifelsefi1-indent-rules-global.tex 
##### special ######
##### special ######
##### special ######
latexindent.pl -s special1.tex -o special1-noAdd.tex -local displayMath-noAdd.yaml
latexindent.pl -s special1.tex -o special1-indent-rules.tex -local displayMath-indent-rules.yaml
latexindent.pl -s special1.tex -local special-noAdd-glob.yaml -o special1-noAdd-glob.tex 
latexindent.pl -s special1.tex -l special-indent-rules-global.yaml -o special1-indent-rules-global.tex 
##### headings ######
##### headings ######
##### headings ######
for (( i=3; i <= 9 ; i++ )) 
do 
latexindent.pl -s headings2.tex -l headings$i.yaml -o headings2-mod$i.tex
done
##### keyequalsvalue ######
##### keyequalsvalue ######
##### keyequalsvalue ######
latexindent.pl -s pgfkeys1.tex -o=pgfkeys1-default.tex
##### namedbraces ######
##### namedbraces ######
##### namedbraces ######
latexindent.pl -s child1.tex -o=child1-default.tex
##### unnamedbraces ######
##### unnamedbraces ######
##### unnamedbraces ######
latexindent.pl -s psforeach1.tex -o=psforeach1-default.tex

# -m switch #
# -m switch #
# -m switch #
latexindent.pl -s -m mlb1.tex -o mlb1-out.tex
for (( i=$loopmin; i <= $loopmax ; i++ )) 
do 
latexindent.pl -s -m env-mlb.tex -l env-mlb$i.yaml -o env-mlb-mod$i.tex
latexindent.pl -s -m env-mlb2.tex -l env-mlb$i.yaml -o env-mlb2-mod$i.tex
done
latexindent.pl -s -m env-mlb3.tex -l env-mlb2.yaml -o env-mlb3-mod2.tex
latexindent.pl -s -m env-mlb3.tex -l env-mlb4.yaml -o env-mlb3-mod4.tex
# remove line breaks
latexindent.pl -s -m env-mlb4.tex -l env-mlb9.yaml -o env-mlb4-mod9.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb10.yaml -o env-mlb4-mod10.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb11.yaml -o env-mlb4-mod11.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb12.yaml -o env-mlb4-mod12.tex
# trailing white space demo
latexindent.pl -s env-mlb5.tex -m -l env-mlb9.yaml,env-mlb10.yaml,env-mlb11.yaml,env-mlb12.yaml -o env-mlb5-modAll.tex
latexindent.pl -s env-mlb5.tex -m -l env-mlb9.yaml,env-mlb10.yaml,env-mlb11.yaml,env-mlb12.yaml,removeTWS-before.yaml -o env-mlb5-modAll-remove-WS.tex
# blank lines
latexindent.pl -s env-mlb6.tex -m -l env-mlb9.yaml,env-mlb10.yaml,env-mlb11.yaml,env-mlb12.yaml -o env-mlb6-modAll.tex
latexindent.pl -s env-mlb6.tex -m -l env-mlb9.yaml,env-mlb10.yaml,env-mlb11.yaml,env-mlb12.yaml,UnpreserveBlankLines.yaml -o env-mlb6-modAll-un-Preserve-Blank-Lines.tex

# partnering poly-switches
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb1.yaml -outputfile=mycommand1-mlb1.tex
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb2.yaml -outputfile=mycommand1-mlb2.tex
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb3.yaml -outputfile=mycommand1-mlb3.tex

# conflicting poly-switches, sequential
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb4.yaml -outputfile=mycommand1-mlb4.tex
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb5.yaml -outputfile=mycommand1-mlb5.tex
latexindent.pl -s -m mycommand1.tex -l=mycom-mlb6.yaml -outputfile=mycommand1-mlb6.tex
# conflicting poly-switches, nested
latexindent.pl -s -m nested-env.tex -l=nested-env-mlb1.yaml -outputfile=nested-env-mlb1.tex
latexindent.pl -s -m nested-env.tex -l=nested-env-mlb2.yaml -outputfile=nested-env-mlb2.tex

# commands with round brackets
latexindent.pl -s pstricks1.tex -o pstricks1-default.tex
latexindent.pl -s pstricks1.tex -o pstricks1-nrp.tex -l noRoundParentheses.yaml
latexindent.pl -s pstricks1.tex -o pstricks1-indent-rules.tex -l defFunction.yaml
# string between args
latexindent.pl -s tikz-node1.tex -o tikz-node1-default.tex
latexindent.pl -s tikz-node1.tex -o tikz-node1-draw.tex -l=draw.yaml
latexindent.pl -s tikz-node1.tex -o tikz-node1-no-to.tex -l=no-to.yaml

# text wrap demonstration
latexindent.pl -s textwrap1.tex -o textwrap1-mod1.tex -l=textwrap1.yaml -m
latexindent.pl -s textwrap2.tex -o textwrap2-mod1.tex -l=textwrap1.yaml -m
latexindent.pl -s textwrap3.tex -o textwrap3-mod1.tex -l=textwrap1.yaml -m
latexindent.pl -s textwrap4.tex -o textwrap4-mod2.tex -l=textwrap2.yaml -m

# remove paragraph line breaks
latexindent.pl -s shortlines.tex -o shortlines1.tex -l=remove-para1.yaml -m
latexindent.pl -s shortlines.tex -o shortlines1-tws.tex -l=remove-para1.yaml,removeTWS-before.yaml  -m
latexindent.pl -s shortlines-mand.tex -o shortlines-mand1.tex -l=remove-para1.yaml -m
latexindent.pl -s shortlines-opt.tex -o shortlines-opt1.tex -l=remove-para1.yaml -m
latexindent.pl -s shortlines-envs.tex -o shortlines-envs2.tex -l=remove-para2.yaml -m
latexindent.pl -s shortlines-envs.tex -o shortlines-envs3.tex -l=remove-para3.yaml -m
latexindent.pl -s shortlines-md.tex -o shortlines-md4.tex -l=remove-para4.yaml -m

# paragraph stops at routine
latexindent.pl -s sl-stop.tex -o sl-stop4.tex -l=remove-para4.yaml -m
latexindent.pl -s sl-stop.tex -o sl-stop4-command.tex -l=remove-para4.yaml,stop-command.yaml -m
latexindent.pl -s sl-stop.tex -o sl-stop4-comment.tex -l=remove-para4.yaml,stop-comment.yaml -m
[[ $noisyMode == 1 ]] && makenoise
git status
