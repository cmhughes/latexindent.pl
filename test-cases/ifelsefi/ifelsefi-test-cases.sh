#!/bin/bash
. ../common.sh

set +x 
[[ $loopmin -lt 33 ]] && loopmin=33
[[ $userSpecifiedLoopMin -eq 0 ]] && loopmax=48
[[ $userSpecifiedLoopMin -eq 1 ]] && [[ $loopmax -lt 33 ]] && loopmax=33

openingtasks

# if else fi code blocks, simple no line breaks
latexindent.pl -s ifelsefi-first -o=+-mod0
latexindent.pl -s ifelsefi-simple-nested -o=+-mod1
latexindent.pl -s ifelsefi-multiple-nested -o=+-mod1
latexindent.pl -w -s ifelsefiSmall
latexindent.pl -w -s conditional
latexindent.pl -s outn -o=+-default -l=notabular,resetItem,ifstar

# modify line breaks
latexindent.pl ifelsefi-first -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines1 -o=+-mod1
latexindent.pl ifelsefi-first -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines2 -o=+-mod2
latexindent.pl ifelsefi-first -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines3 -o=+-mod3
latexindent.pl ifelsefi-first-mod-A -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines1  -o=+-mod1
latexindent.pl ifelsefi-first-mod-A -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines2  -o=+-mod2
latexindent.pl ifelsefi-first-mod-A -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines3  -o=+-mod3
latexindent.pl ifelsefi-first-mod-B -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines4  -o=+-mod4
latexindent.pl ifelsefi-first-mod-B -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines5  -o=+-mod5
latexindent.pl ifelsefi-first-mod-B -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines6  -o=+-mod6
latexindent.pl ifelsefi-first-mod-C -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines7  -o=+-mod7
latexindent.pl ifelsefi-first-mod-C -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines8  -o=+-mod8
latexindent.pl ifelsefi-first-mod-C -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines9  -o=+-mod9
latexindent.pl ifelsefi-first-mod-D -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines10 -o=+-mod10
latexindent.pl ifelsefi-first-mod-D -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines11 -o=+-mod11
latexindent.pl ifelsefi-first-mod-D -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines12 -o=+-mod12
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines12 -o=+-mod12

# else line break experiments
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines13 -o=+-mod13
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines14 -o=+-mod14
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines15 -o=+-mod15
latexindent.pl ifelsefi-first-mod-F -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines13 -o=+-mod13
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines16 -o=+-mod16
latexindent.pl ifelsefi-first-mod-E -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines17 -o=+-mod17

# removing line breaks
latexindent.pl ifelsefi-nested-blank-lines -s -m -l=ifelsefi-all-on,ifelsefi-mod-lines18,removeTWS-before -o=+-mod18

# testing a nested, one-line example
latexindent.pl ifelsefi-one-line -s -m -o=+-mod1 -l=ifelsefi-all-on

# first mixed example
latexindent.pl env-ifelsefi-mixed -s -m -l=../environments/env-all-on,ifelsefi-all-on -o=+-out1
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod1 -o=+-mod1
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod2 -o=+-mod2
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod3 -o=+-mod3
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod4 -o=+-mod4
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod5 -o=+-mod5
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod6 -o=+-mod6
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod7 -o=+-mod7
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod8 -o=+-mod8
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod9 -o=+-mod9
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod10 -o=+-mod10
latexindent.pl env-ifelsefi-mixed -s -m -l=ifelsefi-all-on,env-ifelsefi-mixed-mod11 -o=+-mod11

# remove all example
latexindent.pl -s ifelsefi-remove-line-breaks -m -l env-ifelsefi-mixed-mod1 -o=+-mod1 

# recursive object examples
latexindent.pl env-ifelsefi-mixed-recursive -s -m -o=+-mod1 -l=ifelsefi-all-on
latexindent.pl env-ifelsefi-mixed-recursive -s -m -o=+-mod2 -l=ifelsefi-all-on,env-conflicts-mod2
latexindent.pl ifelsefi-env-mixed-recursive  -m -l=ifelsefi-all-on,if-env-recursive-conflicts -s -o=+-mod1

# condense/protect line breaks
latexindent.pl ifelsefi-nested-blank-lines -s -m -o=+-condense
latexindent.pl ifelsefi-nested-blank-lines -s -m -o=+-condense-mod1 -l=ifelsefi-all-on,ifelsefi-condense-mod1
latexindent.pl ifelsefi-nested-blank-lines -s -m -o=+-condense-mod2 -l=ifelsefi-all-on,ifelsefi-condense-mod2

# multi-switch takes value of 2
latexindent.pl -s -m -l=ifelsefi-all-on,ifelsefi-addPercentBeforeBegin ifelsefi-simpletrailing-comments -o=+-addPercentBeforeBegin 
latexindent.pl -s -m -l=ifelsefi-all-on,ifelsefi-addPercentAfterBegin ifelsefi-simpletrailing-comments -o=+-addPercentAfterBegin 
latexindent.pl -s -m -l=ifelsefi-all-on,ifelsefi-addPercentAfterBody ifelsefi-simpletrailing-comments -o=+-addPercentAfterBody 
latexindent.pl -s -m -l=ifelsefi-all-on,ifelsefi-addPercentAfterEnd ifelsefi-simpletrailing-comments -o=+-addPercentAfterEnd 
latexindent.pl -s -m -l=ifelsefi-add-comments-all ifelsefi-one-line-mk1 -o=+-all-comments

# noAdditionalIndent
latexindent.pl -s ifelsefi-multiple-nested -l=ifelsefi-all-on,noAdditionalIndentGlobal -o=+-global

# indentRules
latexindent.pl -s ifelsefi-multiple-nested -l=ifelsefi-all-on,indentRulesGlobal -o=+-indent-rules-global

# ifx
latexindent.pl -s ifnum-bug -o=+-out

# bug fix from tcbbreakable-small
latexindent.pl -s tcbbreakable-small -o=+-default

# or test case
latexindent.pl -s ifelsefi-first-or -o=+-default

# modifyLineBreaks loop test cases
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   for (( j=1 ; j <= 10 ; j++ )) 
   do 
     keepappendinglogfile
     # else test cases
     latexindent.pl -s ifelsefi-loop-test -o +-mod$i-else$j -m -l=ifelsefi-mod$i,else-mod$j
     # or test cases
     latexindent.pl -s ifelsefi-loop-test-or -o +-mod$i-or$j -m -l=ifelsefi-mod$i,or-mod$j
     set +x
    done
done
keepappendinglogfile

# https://github.com/cmhughes/latexindent.pl/issues/250
latexindent.pl -s issue-250 -o=+-mod1

# mixed test case
latexindent.pl -s tabdo.sty -o=+-default

set +x 
wrapuptasks
