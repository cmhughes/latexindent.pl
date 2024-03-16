#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=48
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 
latexindent.pl -w -s environments-simple.tex
latexindent.pl -w -s environments-simple-nested.tex
latexindent.pl -w -s environments-nested-nested.tex
latexindent.pl -w -s environments-one-line.tex
latexindent.pl -w -s environments-challenging.tex
latexindent.pl -w -s environments-verbatim-simple.tex
latexindent.pl -w -s environments-verbatim-harder.tex
latexindent.pl -w -s environments-noindent-block.tex
latexindent.pl -w -s environments-noindent-block-mk1.tex
latexindent.pl -w -s noIndent-maetra.tex
latexindent.pl -w -s no-environments.tex
latexindent.pl -w -s environments-repeated.tex
latexindent.pl -w -s environments-trailing-comments.tex
latexindent.pl -w -s -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l=env-all-on.yaml,env-chall.yaml -s -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l env-all-on.yaml,env-chall.yaml -s -o environments-challenging-output.tex environments-challenging.tex
# go from one line to multi-line environments
latexindent.pl -s -l=env-all-on.yaml,env-mod-lines1.yaml -m -o=+-mod-lines1.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines2.yaml -m -o=+-mod-lines2.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines3.yaml -m -o=+-mod-lines3.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines4.yaml -m -o=+-mod-lines4.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines5.yaml -m -o=+-mod-lines5.tex environments-one-line.tex
latexindent.pl -s -l env-all-on.yaml,env-mod-lines5.yaml -m -o=+-mod1.tex environments-one-line-simple.tex
latexindent.pl -s -l env-all-on.yaml -w -o +-mod1.tex -m environments-nested-fourth.tex
# change log file name
latexindent.pl -s -l=env-all-on.yaml,testlogfile.yaml environments-nested-fourth.tex
# go from multiline to non-multi line
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines6.yaml -o +-mod1.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o +-mod2.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o +-mod1.tex environments-remove-line-breaks-mk1.tex
# this next one tests undisclosed linebreaks!
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines7.yaml -o +-mod1.tex environments-remove-line-breaks-trailing-comments.tex
latexindent.pl  -s -m -l=env-all-on.yaml,env-mod-lines8.yaml -o=+-mod1.tex environments-remove-line-breaks-trailing-comments-mk1.tex
latexindent.pl -s -o=+-mod1.tex -m -l=env-all-on.yaml,env-mod-lines9.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=+-mod2.tex -m -l=env-all-on.yaml,env-mod-lines10.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=+-mod3.tex -m -l=env-all-on.yaml,env-mod-lines11.yaml environments-modify-multiple-line-breaks.tex
# conflicting line breaks
latexindent.pl environments-line-break-conflict.tex -s -m -o +-mod1.tex -l=env-all-on.yaml,env-conflicts-mod1.yaml
latexindent.pl environments-line-break-conflict.tex -s -m -o +-mod4.tex -l=env-all-on.yaml,env-conflicts-mod4.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -m -o +-mod-2.tex -l=env-all-on.yaml,env-conflicts-mod2.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -m -o +-mod-3.tex -l=env-all-on.yaml,env-conflicts-mod3.yaml
# condense/protect line breaks
latexindent.pl -s -o=+-mod4.tex -m -l=env-all-on.yaml,env-mod-lines12.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=+-mod5.tex -m -l=env-all-on.yaml,env-mod-lines13.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=+-mod6.tex -m -l=env-all-on.yaml,env-mod-lines14.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl environments-modify-multiple-line-breaks-verbatim.tex -s -m -o=+-mod1.tex -l=env-all-on.yaml,env-mod-lines12.yaml 
# multi-switch == 2 (trailing comment stuff)
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterBegin.yaml -m environments-simple-trailing-comments.tex -o=+-percent-after-begin.tex
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterBody.yaml -m environments-simple-trailing-comments.tex -o=+-percent-after-Body.tex
latexindent.pl -s -l=env-all-on.yaml,env-addPercentAfterEnd.yaml -m environments-simple-trailing-comments.tex -o=+-percent-after-End.tex
# global noAdditionalIndent test
latexindent.pl -s -l=env-all-on.yaml,noAdditionalIndentGlobal.yaml environments-simple.tex -o=+-global.tex
latexindent.pl -s -l=env-all-on.yaml,noAdditionalIndentGlobal.yaml environments-ifelsefi.tex -o=+-global.tex
# global indentRules test
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml environments-simple.tex -o=+-indent-rules-global.tex
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml environments-ifelsefi.tex -o=+-indent-rules-global.tex
# conflicting global noAdditionalIndent and indentRules 
latexindent.pl -s -l=env-all-on.yaml,indentRulesGlobal.yaml,noAdditionalIndentGlobal.yaml  environments-simple.tex -o=+-indent-rules-global-conflict.tex
# special characters
latexindent.pl -s environments-special-characters.tex -o +-default.tex
# loop! this file was the first test-case file I created, and I hadn't yet explored looping. better late than never
# modifyLineBreaks test cases
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   latexindent.pl -s env-single-line.tex -o +-mod$i.tex -m -l=env-mod$i.yaml
   latexindent.pl -s -o=+-protect-mod$i.tex -m -l=env-mod$i.yaml  environments-modify-multiple-line-breaks.tex
   latexindent.pl -s -o=+-un-protect-mod$i.tex -m -l=env-mod$i.yaml,unprotect-blank-lines.yaml  environments-modify-multiple-line-breaks.tex
   latexindent.pl -s env-no-blank-after-end.tex -o +-mod$i.tex -m -l=env-mod$i.yaml 
   [[ $silentMode == 0 ]] && set +x 
done
# maximum indentation test cases
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation1.tex -l=max-indentation1.yaml
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation2.tex -l=max-indentation2.yaml
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation3.tex -l=max-indentation3.yaml
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation4.tex -l=max-indentation4.yaml
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation5.tex -l=max-indentation5.yaml
latexindent.pl -s environments-nested-fourth.tex -o=+-max-indentation-mod1.tex -l=max-indentation1,env-mod-lines1 -m 
latexindent.pl -s environments-verbatim-harder.tex -o=+-max-ind1 -l=max-indentation1.yaml
# empty body environment
latexindent.pl -s env-no-body -o +-mod1 -l=env-mod1 -m
latexindent.pl -s env-no-body -o +-mod17 -l=env-mod17 -m
# new-line polyswitch
latexindent.pl -s -m aronvgi -l=aronvgi -o=+mod
# testing the -y switch
latexindent.pl -s -o=+-yaml-switch0.tex environments-nested-fourth.tex -yaml="defaultIndent: ' '" -d 
latexindent.pl -s -o=+-yaml-switch1.tex environments-nested-fourth.tex -yaml="defaultIndent: ' '"
latexindent.pl -s -o=+-yaml-switch1A.tex environments-nested-fourth.tex -y="defaultIndent: ' ',maximumIndentation:' '"
latexindent.pl -s -o=+-yaml-switch2.tex environments-nested-fourth.tex -y="defaultIndent: '\t\t\t\t'"
latexindent.pl -s -o=+-yaml-switch3.tex environments-nested-fourth.tex -y='indentRules:one:"\t\t\t\t"'
latexindent.pl -s -o=+-yaml-switch4.tex environments-nested-fourth.tex -y='indentRules:one:"\t\t\t\t",defaultIndent: " "'
latexindent.pl -s -o=+-yaml-switch4A.tex environments-nested-fourth.tex -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3' -m
latexindent.pl -s -o=+-yaml-switch5.tex environments-nested-fourth.tex -y='modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m
latexindent.pl -s -o=+-yaml-switch6.tex environments-nested-fourth.tex -y='defaultIndent: "",modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m
# testing subfields of -y switch using ;
latexindent.pl -s -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3' -t -m env-single-line.tex -o=+-yswitch1
latexindent.pl -s -y='modifyLineBreaks  :  environments: myenv  : EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3' -t -m env-single-line.tex -o=+-yswitch2
latexindent.pl -s -y='modifyLineBreaks:environments: myenv:EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3;BodyStartsOnOwnLine:2,modifyLineBreaks:environments:EndFinishesWithLineBreak:1;BodyStartsOnOwnLine:2' -t -m env-single-line.tex -o=+-yswitch3

# dos2unix line breaks https://github.com/cmhughes/latexindent.pl/issues/256
# unix2dos issue-256.tex
latexindent.pl -s issue-256.tex -o +-mod1
latexindent.pl -s -y="dos2unixlinebreaks:1" issue-256.tex -o +-mod2

latexindent.pl -s -l issue-488.yaml -r -m issue-488.tex -o=+-mod1
latexindent.pl -s -l issue-488a.yaml -m issue-488a.tex -o=+-mod1

latexindent.pl -s -l issue-508.yaml  -m issue-508.tex -o=+-mod1
latexindent.pl -s -l issue-508a.yaml -m issue-508.tex -o=+-mod2
latexindent.pl -s -l issue-508b.yaml -m issue-508.tex -o=+-mod3
latexindent.pl -s -l issue-508c.yaml -r issue-508.tex -o=+-mod4
latexindent.pl -s -l issue-508d.yaml -m issue-508.tex -o=+-mod5

[[ $silentMode == 0 ]] && set -x 
[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status
