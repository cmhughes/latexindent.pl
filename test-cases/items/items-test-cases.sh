#!/bin/bash
loopmax=10
. ../common.sh

openingtasks

# making strings of tabs and spaces gives different results; 
# this first came to light when studying items1 -- the following test cases helped to 
# resolve the issue
latexindent.pl -s spaces-and-tabs -l=../environments/env-all-on,tabs-follow-tabs -o=spaces-and-tabs-tft
latexindent.pl -s spaces-and-tabs -l=../environments/env-all-on,spaces-follow-tabs -o=spaces-and-tabs-sft
latexindent.pl -s spaces-and-tabs -l=../environments/env-all-on,tabs-follow-spaces -o=spaces-and-tabs-tfs

# first lot of items
latexindent.pl -s items1 -o=+-default

# nested itemize/enumerate environments
latexindent.pl -s items1-5 -o=+-mod1
latexindent.pl -s -t items2   -o=+-default
egrep 'found:' indent.log > items2.txt
latexindent.pl -s items2-5 -o=+-mod1
latexindent.pl -s items3   -o=+-default
latexindent.pl -s -w items4
latexindent.pl -s -w items4-5 

# this next one won't treat yetanotheritem as an item
latexindent.pl -s -w items4-6 

# but this one will -- see yetanotheritem for the difference
latexindent.pl -s items4-6 -l yetanotheritem -o=+-yetanotheritem
latexindent.pl -s items5 -o=+-default

# noAdditionalIndent
latexindent.pl -s -l noAdditionalIndentItemize items1 -o=+-noAdditionalIndentItemize
latexindent.pl -s -l noAdditionalIndentItems items1   -o=+-noAdditionalIndentItems
latexindent.pl -s -l noAdditionalIndent-myenv items3  -o=+-noAdditionalIndent-myenv

# indentRules
latexindent.pl -s -l indentRulesItemize items1 -o=+-indentRulesItemize
latexindent.pl -s -l indentRulesItems items1   -o=+-indentRulesItems

# test different item names
latexindent.pl -s -l myitem -w items1-myitem
latexindent.pl -s -l part   -w items1-part

# modify linebreaks starts here
latexindent.pl -s -m items1 -o=+-mod0
latexindent.pl -s -m items1-blanklines -o=+-mod0 
latexindent.pl -s -m items2 -o=+-mod0
latexindent.pl -s -m items2-1 -l items-mod3 -o=+-mod3
latexindent.pl -s -m items2-1 -l items-mod3,removeTWS-before -o=+-mod4

set +x
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
 [[ $showCounter == 1 ]] && echo $i of $loopmax

 keepappendinglogfile

 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items1 -o=+-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items2 -o=+-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items3 -o=+-mod$i

 # blank line tests
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items1-blanklines -o=+-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i,unPreserveBlankLines items1-blanklines -o=+-unPreserveBlankLines-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i,BodyStartsOnOwnLine items1 -o=+-BodyStartsOnOwnLine-mod$i

 # starts on one line, adds linebreaks accordingly
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items5 -o=+-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items6 -o=+-mod$i
 latexindent.pl -s -m -l=../environments/env-all-on,items-mod$i items7 -o=+-mod$i
 set +x
done

keepappendinglogfile

latexindent.pl -s items13 -m -l=items-mod2 -o=+-mod2
latexindent.pl -s items13 -m -l=items-mod2,removeTWS-before -o=+-remove-before-mod2

# ifelsefi within an item
latexindent.pl -s items8 -o=+-mod0 -l=../environments/env-all-on
latexindent.pl -s items9 -o=+-mod0 -l=../environments/env-all-on
latexindent.pl -s items10 -w
latexindent.pl -s items10 -o=+-myenv-noAdditionalIndent -l=../environments/env-all-on,myenv
latexindent.pl -s items10 -o=+-items-noAdditionalIndent -l=../environments/env-all-on,noAdditionalIndentItems
latexindent.pl -s items11 -w
latexindent.pl -s items12 -o=+-mod0 -l=../environments/env-all-on
latexindent.pl -s items12 -m -l=../opt-args/opt-args-remove-all,../environments/env-all-on,env-mod-lines1 -o=+-mod1

# noAdditionalIndent
latexindent.pl -s items12 -o=items12-Global -l=../environments/env-all-on,noAdditionalIndentGlobal,resetItem

# indentRules
latexindent.pl -s items12 -o=items12-indent-rules-Global -l=../environments/env-all-on,indentRulesGlobal,resetItem

# poly-switch bug reported at https://github.com/cmhughes/latexindent.pl/issues/94
latexindent.pl -s -m bug1 -o=+-mod0 -l=bug

# itemsep issue https://github.com/cmhughes/latexindent.pl/issues/249
latexindent.pl -s issue-249 -o=+-mod0

# can be followed by, beamer stuff
latexindent.pl -s issue-307 -o=+-mod0

# issue 467, comments following item
latexindent.pl -s issue-467 -o +-mod1

# issue 492
latexindent.pl -s -m -l issue-492a issue-492 -o +-mod2

latexindent.pl -s -l issue-507 issue-507 -o=+-mod1
latexindent.pl -s -l issue-507a issue-507 -o=+-mod2

latexindent.pl -s -l issue-518 issue-518 -o=+-mod1

set +x 
wrapuptasks
