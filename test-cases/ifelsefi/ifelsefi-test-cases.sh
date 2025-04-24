#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=48
. ../common.sh
[[ $loopmin -lt 33 ]] && loopmin=33
[[ $loopmax -lt 33 ]] && loopmax=33

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# if else fi code blocks, simple no line breaks
latexindent.pl -w -s ifelsefi-first.tex
latexindent.pl -w -s ifelsefi-simple-nested.tex
latexindent.pl -w -s ifelsefi-multiple-nested.tex
latexindent.pl -w -s ifelsefiSmall.tex
latexindent.pl -w -s conditional.tex

latexindent.pl -s outn.cls -o=outn-default.cls -l=notabular,resetItem,ifstar

# modify line breaks
latexindent.pl ifelsefi-first.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines1.yaml -o=ifelsefi-first-mod1.tex
latexindent.pl ifelsefi-first.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines2.yaml -o=ifelsefi-first-mod2.tex
latexindent.pl ifelsefi-first.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines3.yaml -o=ifelsefi-first-mod3.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines1.yaml -o=ifelsefi-first-mod-A-mod1.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines2.yaml -o=ifelsefi-first-mod-A-mod2.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines3.yaml -o=ifelsefi-first-mod-A-mod3.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines4.yaml -o=ifelsefi-first-mod-B-mod4.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines5.yaml -o=ifelsefi-first-mod-B-mod5.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines6.yaml -o=ifelsefi-first-mod-B-mod6.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines7.yaml -o=ifelsefi-first-mod-C-mod7.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines8.yaml -o=ifelsefi-first-mod-C-mod8.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines9.yaml -o=ifelsefi-first-mod-C-mod9.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines10.yaml -o=ifelsefi-first-mod-D-mod10.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines11.yaml -o=ifelsefi-first-mod-D-mod11.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines12.yaml -o=ifelsefi-first-mod-D-mod12.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines12.yaml -o=ifelsefi-first-mod-E-mod12.tex

# else line break experiments
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines13.yaml -o=ifelsefi-first-mod-E-mod13.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines14.yaml -o=ifelsefi-first-mod-E-mod14.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines15.yaml -o=ifelsefi-first-mod-E-mod15.tex
latexindent.pl ifelsefi-first-mod-F.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines13.yaml -o=ifelsefi-first-mod-F-mod13.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines16.yaml -o=ifelsefi-first-mod-E-mod16.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines17.yaml -o=ifelsefi-first-mod-E-mod17.tex

# removing line breaks
latexindent.pl ifelsefi-nested-blank-lines.tex -s -m -l=ifelsefi-all-on.yaml,ifelsefi-mod-lines18.yaml,removeTWS-before.yaml -o=ifelsefi-nested-blank-lines-mod18.tex

# testing a nested, one-line example
latexindent.pl ifelsefi-one-line.tex -s -m -o=ifelsefi-one-line-mod1.tex -l=ifelsefi-all-on.yaml

# first mixed example
latexindent.pl env-ifelsefi-mixed.tex -s -m -l=../environments/env-all-on.yaml,ifelsefi-all-on.yaml -o=env-ifelsefi-mixed-out1.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod1.yaml -o=env-ifelsefi-mixed-mod1.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod2.yaml -o=env-ifelsefi-mixed-mod2.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod3.yaml -o=env-ifelsefi-mixed-mod3.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod4.yaml -o=env-ifelsefi-mixed-mod4.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod5.yaml -o=env-ifelsefi-mixed-mod5.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod6.yaml -o=env-ifelsefi-mixed-mod6.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod7.yaml -o=env-ifelsefi-mixed-mod7.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod8.yaml -o=env-ifelsefi-mixed-mod8.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod9.yaml -o=env-ifelsefi-mixed-mod9.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod10.yaml -o=env-ifelsefi-mixed-mod10.tex
latexindent.pl env-ifelsefi-mixed.tex -s  -m -l=ifelsefi-all-on.yaml,env-ifelsefi-mixed-mod11.yaml -o=env-ifelsefi-mixed-mod11.tex

# remove all example
latexindent.pl -s ifelsefi-remove-line-breaks.tex -m -l env-ifelsefi-mixed-mod1.yaml -o ifelsefi-remove-line-breaks-mod1.tex 

# recursive object examples
latexindent.pl env-ifelsefi-mixed-recursive.tex -s -m -o=env-ifelsefi-mixed-recursive-mod1.tex -l=ifelsefi-all-on.yaml
latexindent.pl env-ifelsefi-mixed-recursive.tex -s -m -o=env-ifelsefi-mixed-recursive-mod2.tex -l=ifelsefi-all-on.yaml,env-conflicts-mod2.yaml
latexindent.pl ifelsefi-env-mixed-recursive.tex  -m -l=ifelsefi-all-on.yaml,if-env-recursive-conflicts.yaml -s -o=ifelsefi-env-mixed-recursive-mod1.tex

# condense/protect line breaks
latexindent.pl ifelsefi-nested-blank-lines.tex -s -m -o=ifelsefi-nested-blank-lines-condense.tex
latexindent.pl ifelsefi-nested-blank-lines.tex -s -m -o=ifelsefi-nested-blank-lines-condense-mod1.tex -l=ifelsefi-all-on.yaml,ifelsefi-condense-mod1.yaml
latexindent.pl ifelsefi-nested-blank-lines.tex -s -m -o=ifelsefi-nested-blank-lines-condense-mod2.tex -l=ifelsefi-all-on.yaml,ifelsefi-condense-mod2.yaml

# multi-switch takes value of 2
latexindent.pl -s -m -l=ifelsefi-all-on.yaml,ifelsefi-addPercentBeforeBegin.yaml ifelsefi-simpletrailing-comments.tex -o=ifelsefi-simpletrailing-comments-addPercentBeforeBegin.tex 
latexindent.pl -s -m -l=ifelsefi-all-on.yaml,ifelsefi-addPercentAfterBegin.yaml ifelsefi-simpletrailing-comments.tex -o=ifelsefi-simpletrailing-comments-addPercentAfterBegin.tex 
latexindent.pl -s -m -l=ifelsefi-all-on.yaml,ifelsefi-addPercentAfterBody.yaml ifelsefi-simpletrailing-comments.tex -o=ifelsefi-simpletrailing-comments-addPercentAfterBody.tex 
latexindent.pl -s -m -l=ifelsefi-all-on.yaml,ifelsefi-addPercentAfterEnd.yaml ifelsefi-simpletrailing-comments.tex -o=ifelsefi-simpletrailing-comments-addPercentAfterEnd.tex 
latexindent.pl -s -m -l=ifelsefi-add-comments-all.yaml ifelsefi-one-line-mk1.tex -o ifelsefi-one-line-mk1-all-comments.tex

# noAdditionalIndent
latexindent.pl -s ifelsefi-multiple-nested.tex -l=ifelsefi-all-on.yaml,noAdditionalIndentGlobal.yaml -o=ifelsefi-multiple-nested-global.tex

# indentRules
latexindent.pl -s ifelsefi-multiple-nested.tex -l=ifelsefi-all-on.yaml,indentRulesGlobal.yaml -o=ifelsefi-multiple-nested-indent-rules-global.tex

# ifx
latexindent.pl -s ifnum-bug.tex -o ifnum-bug-out.tex

# bug fix from tcbbreakable-small.tex
latexindent.pl -s tcbbreakable-small.tex -o=+-default

# mixed test case
latexindent.pl -s tabdo.sty -o tabdo-default.sty

# or test case
latexindent.pl -s ifelsefi-first-or.tex -o=+-default
# modifyLineBreaks loop test cases
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   for (( j=1 ; j <= 10 ; j++ )) 
   do 
     [[ $silentMode == 0 ]] && set -x 
     # else test cases
     latexindent.pl -s ifelsefi-loop-test.tex -o +-mod$i-else$j.tex -m -l=ifelsefi-mod$i.yaml,else-mod$j.yaml
     # or test cases
     latexindent.pl -s ifelsefi-loop-test-or.tex -o +-mod$i-or$j.tex -m -l=ifelsefi-mod$i.yaml,or-mod$j.yaml
     [[ $silentMode == 0 ]] && set +x 
    done
done

# https://github.com/cmhughes/latexindent.pl/issues/250
latexindent.pl -s issue-250.tex -o=+-mod1
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
exit
