#!/bin/bash
loopmax=48
. ../common.sh

openingtasks

latexindent.pl -w -s environments-simple
latexindent.pl -w -s environments-simple-nested
latexindent.pl -w -s environments-nested-nested
latexindent.pl -w -s environments-one-line
latexindent.pl -w -s environments-challenging
latexindent.pl -w -s environments-verbatim-simple
latexindent.pl -w -s environments-verbatim-harder
latexindent.pl -w -s environments-noindent-block
latexindent.pl -w -s environments-noindent-block-mk1
latexindent.pl -w -s noIndent-maetra
latexindent.pl -w -s no-environments
latexindent.pl -w -s environments-repeated
latexindent.pl -w -s environments-trailing-comments
latexindent.pl -w -s -o=environments-challenging-output environments-challenging
latexindent.pl -w -l=env-all-on,env-chall -s -o +-output environments-challenging
latexindent.pl -w -l env-all-on,env-chall -s -o environments-challenging-output environments-challenging

# go from one line to multi-line environments
latexindent.pl -s -l=env-all-on,env-mod-lines1 -m -o=+-mod-lines1 environments-one-line
latexindent.pl -s -l env-all-on,env-mod-lines2 -m -o=+-mod-lines2 environments-one-line
latexindent.pl -s -l env-all-on,env-mod-lines3 -m -o=+-mod-lines3 environments-one-line
latexindent.pl -s -l env-all-on,env-mod-lines4 -m -o=+-mod-lines4 environments-one-line
latexindent.pl -s -l env-all-on,env-mod-lines5 -m -o=+-mod-lines5 environments-one-line
latexindent.pl -s -l env-all-on,env-mod-lines5 -m -o=+-mod1 environments-one-line-simple
latexindent.pl -s -l env-all-on -w -o +-mod1 -m environments-nested-fourth

# change log file name
latexindent.pl -s -l=env-all-on,testlogfile environments-nested-fourth

# go from multiline to non-multi line
latexindent.pl  -s -m -l=env-all-on,env-mod-lines6 -o +-mod1 environments-remove-line-breaks
latexindent.pl  -s -m -l=env-all-on,env-mod-lines7 -o +-mod2 environments-remove-line-breaks
latexindent.pl  -s -m -l=env-all-on,env-mod-lines7 -o +-mod1 environments-remove-line-breaks-mk1

# this next one tests undisclosed linebreaks!
latexindent.pl  -s -m -l=env-all-on,env-mod-lines7 -o +-mod1 environments-remove-line-breaks-trailing-comments
latexindent.pl  -s -m -l=env-all-on,env-mod-lines8 -o=+-mod1 environments-remove-line-breaks-trailing-comments-mk1
latexindent.pl -s -o=+-mod1 -m -l=env-all-on,env-mod-lines9 environments-modify-multiple-line-breaks
latexindent.pl -s -o=+-mod2 -m -l=env-all-on,env-mod-lines10 environments-modify-multiple-line-breaks
latexindent.pl -s -o=+-mod3 -m -l=env-all-on,env-mod-lines11 environments-modify-multiple-line-breaks

# conflicting line breaks
latexindent.pl environments-line-break-conflict -s -m -o +-mod1 -l=env-all-on,env-conflicts-mod1
latexindent.pl environments-line-break-conflict -s -m -o +-mod4 -l=env-all-on,env-conflicts-mod4
latexindent.pl environments-line-break-conflict-nested -s -m -o +-mod-2 -l=env-all-on,env-conflicts-mod2
latexindent.pl environments-line-break-conflict-nested -s -m -o +-mod-3 -l=env-all-on,env-conflicts-mod3

# condense/protect line breaks
latexindent.pl -s -o=+-mod4 -m -l=env-all-on,env-mod-lines12 environments-modify-multiple-line-breaks
latexindent.pl -s -o=+-mod5 -m -l=env-all-on,env-mod-lines13 environments-modify-multiple-line-breaks
latexindent.pl -s -o=+-mod6 -m -l=env-all-on,env-mod-lines14 environments-modify-multiple-line-breaks
latexindent.pl environments-modify-multiple-line-breaks-verbatim -s -m -o=+-mod1 -l=env-all-on,env-mod-lines12 

# multi-switch == 2 (trailing comment stuff)
latexindent.pl -s -l=env-all-on,env-addPercentAfterBegin -m environments-simple-trailing-comments -o=+-percent-after-begin
latexindent.pl -s -l=env-all-on,env-addPercentAfterBody -m environments-simple-trailing-comments -o=+-percent-after-Body
latexindent.pl -s -l=env-all-on,env-addPercentAfterEnd -m environments-simple-trailing-comments -o=+-percent-after-End

# global noAdditionalIndent test
latexindent.pl -s -l=env-all-on,noAdditionalIndentGlobal environments-simple -o=+-global
latexindent.pl -s -l=env-all-on,noAdditionalIndentGlobal environments-ifelsefi -o=+-global

# global indentRules test
latexindent.pl -s -l=env-all-on,indentRulesGlobal environments-simple -o=+-indent-rules-global
latexindent.pl -s -l=env-all-on,indentRulesGlobal environments-ifelsefi -o=+-indent-rules-global

# conflicting global noAdditionalIndent and indentRules 
latexindent.pl -s -l=env-all-on,indentRulesGlobal,noAdditionalIndentGlobal  environments-simple -o=+-indent-rules-global-conflict

# special characters
latexindent.pl -s environments-special-characters -o +-default

# loop! this file was the first test-case file I created, and I hadn't yet explored looping. better late than never
# modifyLineBreaks test cases
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
   latexindent.pl -s env-single-line -o +-mod$i -m -l=env-mod$i
   latexindent.pl -s -o=+-protect-mod$i -m -l=env-mod$i  environments-modify-multiple-line-breaks
   latexindent.pl -s -o=+-un-protect-mod$i -m -l=env-mod$i,unprotect-blank-lines  environments-modify-multiple-line-breaks
   latexindent.pl -s env-no-blank-after-end -o +-mod$i -m -l=env-mod$i 
   [[ $silentMode == 0 ]] && set +x 
done

# maximum indentation test cases
latexindent.pl -s environments-nested-fourth -o=+-max-indentation1 -l=max-indentation1
latexindent.pl -s environments-nested-fourth -o=+-max-indentation2 -l=max-indentation2
latexindent.pl -s environments-nested-fourth -o=+-max-indentation3 -l=max-indentation3
latexindent.pl -s environments-nested-fourth -o=+-max-indentation4 -l=max-indentation4
latexindent.pl -s environments-nested-fourth -o=+-max-indentation5 -l=max-indentation5
latexindent.pl -s environments-nested-fourth -o=+-max-indentation-mod1 -l=max-indentation1,env-mod-lines1 -m 
latexindent.pl -s environments-verbatim-harder -o=+-max-ind1 -l=max-indentation1

# empty body environment
latexindent.pl -s env-no-body -o +-mod1 -l=env-mod1 -m
latexindent.pl -s env-no-body -o +-mod17 -l=env-mod17 -m

# new-line polyswitch
latexindent.pl -s -m aronvgi -l=aronvgi -o=+mod

# testing the -y switch
latexindent.pl -s -o=+-yaml-switch0 environments-nested-fourth -yaml="defaultIndent: ' '" -d 
latexindent.pl -s -o=+-yaml-switch1 environments-nested-fourth -yaml="defaultIndent: ' '"
latexindent.pl -s -o=+-yaml-switch1A environments-nested-fourth -y="defaultIndent: ' ',maximumIndentation:' '"
latexindent.pl -s -o=+-yaml-switch2 environments-nested-fourth -y="defaultIndent: '\t\t\t\t'"
latexindent.pl -s -o=+-yaml-switch3 environments-nested-fourth -y='indentRules:one:"\t\t\t\t"'
latexindent.pl -s -o=+-yaml-switch4 environments-nested-fourth -y='indentRules:one:"\t\t\t\t",defaultIndent: " "'
latexindent.pl -s -o=+-yaml-switch4A environments-nested-fourth -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3' -m
latexindent.pl -s -o=+-yaml-switch5 environments-nested-fourth -y='modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m
latexindent.pl -s -o=+-yaml-switch6 environments-nested-fourth -y='defaultIndent: "",modifyLineBreaks  :  environments: one: EndStartsOnOwnLine:3' -m

# testing subfields of -y switch using ;
latexindent.pl -s -y='modifyLineBreaks  :  environments: EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3' -t -m env-single-line -o=+-yswitch1
latexindent.pl -s -y='modifyLineBreaks  :  environments: myenv  : EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3' -t -m env-single-line -o=+-yswitch2
latexindent.pl -s -y='modifyLineBreaks:environments: myenv:EndStartsOnOwnLine:3; BeginStartsOnOwnLine:3;BodyStartsOnOwnLine:2,modifyLineBreaks:environments:EndFinishesWithLineBreak:1;BodyStartsOnOwnLine:2' -t -m env-single-line -o=+-yswitch3

# dos2unix line breaks https://github.com/cmhughes/latexindent.pl/issues/256
# unix2dos issue-256
latexindent.pl -s issue-256 -o +-mod1
latexindent.pl -s -y="dos2unixlinebreaks:1" issue-256 -o +-mod2

latexindent.pl -s -l issue-488 -r -m issue-488 -o=+-mod1
latexindent.pl -s -l issue-488a -m issue-488a -o=+-mod1

# goal to output warning to log file
latexindent.pl -s -m -l issue-488b issue-488a
egrep -i 'warn:' indent.log > issue-488b.txt
latexindent.pl -s -m -l issue-488c issue-488a
egrep -i 'warn:' indent.log > issue-488c.txt

latexindent.pl -s -l issue-508  -m issue-508 -o=+-mod1
latexindent.pl -s -l issue-508a -m issue-508 -o=+-mod2
latexindent.pl -s -l issue-508b -m issue-508 -o=+-mod3
latexindent.pl -s -l issue-508c -r issue-508 -o=+-mod4
latexindent.pl -s -l issue-508d -m issue-508 -o=+-mod5

set +x 
wrapuptasks
