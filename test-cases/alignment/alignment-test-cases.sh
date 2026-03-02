#!/bin/bash
loopmax=4
. ../common.sh

openingtasks

# table-based test cases
latexindent.pl -s simple -o=+-default
latexindent.pl -s simple-multi-column -o=+-mod1 -y="lookForAlignDelims:tabular:multiColumnGrouping:1"
latexindent.pl -s simple-multi-column -o=+-mod2 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;justification:right"
latexindent.pl -s simple-multi-column -o=+-mod3 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s simple-multi-column -o=+-mod4 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;spacesAfterAmpersand:3;justification:right"
latexindent.pl -s table1 -o table1-default
latexindent.pl -s unicode1 -o unicode1-default

set +x
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    keepappendinglogfile

    # basic tests
    latexindent.pl -s table1 -o=+-mod$i -l=tabular$i,multiColumnGrouping2
    latexindent.pl -s table2 -o=+-mod$i -l=tabular$i
    latexindent.pl -s table3 -o=+-mod$i -l=tabular$i
    latexindent.pl -s table4 -o=+-mod$i -l=tabular$i
    latexindent.pl -s table5 -o=+-mod$i -l=tabular$i

    # tests with \\ not aligned
    latexindent.pl -s table1 -o table1-mod$((i+4)) -l=tabular$i,tabular5,multiColumnGrouping2
    latexindent.pl -s table2 -o table2-mod$((i+4)) -l=tabular$i,tabular5

    # tests with \\ not aligned, and with spaces before \\
    latexindent.pl -s table1 -o table1-mod$((i+8)) -l=tabular$i,tabular6,multiColumnGrouping2
    latexindent.pl -s table2 -o table2-mod$((i+8)) -l=tabular$i,tabular6

    # alignment inside commented block
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-mod$i -l tabular$i
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-no-Add-1-mod$i -l tabular$i,noAddtabular1
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-no-Add-2-mod$i -l tabular$i,noAddtabular2
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-no-Add-3-mod$i -l tabular$i,noAddtabular3
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-indent-rules-1-mod$i -l tabular$i,indentRules1
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-indent-rules-2-mod$i -l tabular$i,indentRules2
    latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-indent-rules-3-mod$i -l tabular$i,indentRules3
    set +x 
done
keepappendinglogfile

latexindent.pl -s align-mark-down -o=+-mod1
latexindent.pl -s align-mark-down -o=+-mod2 -y="lookForAlignDelims:tabular:0"
latexindent.pl -s table1 -o=+-mod3 -l=tabular3

# legacy matrix test case
latexindent.pl -s matrix -o=+-default

# legacy environment test case
latexindent.pl -s environments -o=+-default
latexindent.pl -s environments -o=+-no-align-double-back-slash -l=align-no-double-back-slash
latexindent.pl -s legacy-align -o=+-default

# alignment inside a mandatory argument
latexindent.pl -s matrix1 -o=+-default
latexindent.pl -s matrix1 -o=+-no-align -l=noMatrixAlign

# using comments
latexindent.pl -s alignmentoutsideEnvironmentsCommands -o=+-default

# end statement not on own line
latexindent.pl -s end-not-on-own-line -o=+-default
latexindent.pl -s end-not-on-own-line1 -o=+-default
latexindent.pl -s end-not-on-own-line1 -o=+-mod1 -m -l=env-mod-lines1

# special
latexindent.pl -s special1 -o=+-aligned -l special-align

set +x
# uni code
for (( i=1 ; i <= 6 ; i++ )) 
do 
    keepappendinglogfile
    latexindent.pl -s uni-code1 -o=+-mod$i -l=tabular$i
    set +x 
done

keepappendinglogfile

# multiColumnGrouping
latexindent.pl -s tabular-karl -o=+-default
latexindent.pl -s tabular-karl -o=+-out -l multiColumnGrouping
latexindent.pl -s tabular-karl -o=+-out1 -l multiColumnGrouping1
latexindent.pl -s tabular-karl -o=+-out2 -l multiColumnGrouping2
latexindent.pl -s tabular-karl -o=+-out3 -l multiColumnGrouping3
latexindent.pl -s tabular-karl -o=+-out5 -l multiColumnGrouping,tabular5
latexindent.pl -s tabular-karl -o=+-out6 -l multiColumnGrouping,tabular6
latexindent.pl -s multicol -o=+-out -l multiColumnGrouping
latexindent.pl -s unicode-multicol -o=+-out -l multiColumnGrouping
latexindent.pl -s table3 -o=+-out -l multiColumnGrouping
latexindent.pl -s tabular-multiple-multicol -o=+-out -l multiColumnGrouping
latexindent.pl -s multicol-no-ampersands -o=+-default
latexindent.pl -s multicol-no-ampersands -o=+-out -l multiColumnGrouping
latexindent.pl -s multicol-no-ampersands -o=+-out5 -l multiColumnGrouping,tabular5
latexindent.pl -s multicol-no-ampersands -o=+-out6 -l multiColumnGrouping,tabular6
latexindent.pl -s longcells -o=+-default
latexindent.pl -s longcells -o=+-multicol -l multiColumnGrouping

# spaces before and after ampersands
latexindent.pl -s table5 -o=+-mod7 -l=tabular7
latexindent.pl -s table5 -o=+-mod8 -l=tabular8
latexindent.pl -s table5 -o=+-mod9 -l=tabular9
latexindent.pl -s table5 -o=+-mod10 -l=tabular10
latexindent.pl -s tabular-karl -o=+-out9 -l multiColumnGrouping,tabular9
latexindent.pl -s tabular-karl -o=+-out10 -l multiColumnGrouping,tabular10
latexindent.pl -s matrix1 -o=+-mod1 -l=matrix1
latexindent.pl -s matrix1 -o=+-mod2 -l=matrix2

# left/right justification
latexindent.pl -s table5 -o=+-mod11 -l=tabular11
latexindent.pl -s table5 -o=+-mod12 -l=tabular11,tabular7,tabular8
latexindent.pl -s table5 -o=+-mod13 -l=tabular11,tabular9
latexindent.pl -s tabular-karl -o=+-out11 -l multiColumnGrouping,tabular11

# issue 95 demo
latexindent.pl -s issue-95 -o=+-mod0
latexindent.pl -s issue-95 -o=+-mod1 -l=noMaxDelims
set +x

# double back slash polyswitch, https://github.com/cmhughes/latexindent.pl/issues/106
for (( i=-1 ; i <= 3 ; i++ )) 
do 
    keepappendinglogfile
    # DBSStartsOnOwnLine
    latexindent.pl -s -m pmatrix1 -o=+-mod$i -l=double-back-slash$i
    # DBSOrFinishesWithLineBreak
    latexindent.pl -s -m pmatrix1 -o=+-finish-mod$i -l=double-back-slash-finish$i
    # per-name testing
    latexindent.pl -s -m pmatrix1 -o=+-mod-per-name$i -l=double-back-slash-per-name$i
    # commands
    latexindent.pl -s -m command-align -o=+-opt-mod$i -l=command-dbs-optional$i,mycommand
    latexindent.pl -s -m command-align -o=+-mand-mod$i -l=command-dbs-mandatory$i,mycommand
    latexindent.pl -s -m command-align -o=+-opt-finish-mod$i -l=mycommand -y="modifyLineBreaks:optionalArguments:DBSFinishesWithLineBreak:$i"
    latexindent.pl -s -m command-align -o=+-mand-finish-mod$i -l=mycommand -y="modifyLineBreaks:mandatoryArguments:DBSFinishesWithLineBreak:$i"
    # special
    latexindent.pl -s -m special-align -o=+-mod$i -l=special-align1 -y="modifyLineBreaks:specialBeginEnd:DBSStartsOnOwnLine:$i"
    latexindent.pl -s -m special-align -o=+-finish-mod$i -l=special-align1 -y="modifyLineBreaks:specialBeginEnd:DBSFinishesWithLineBreak:$i"
    latexindent.pl -s -m special-align1 -o=+-mod$i -l=special-align1 -y="modifyLineBreaks:specialBeginEnd:DBSStartsOnOwnLine:$i"
    latexindent.pl -s -m special-align1 -o=+-finish-mod$i -l=special-align1 -y="modifyLineBreaks:specialBeginEnd:DBSFinishesWithLineBreak:$i"
    set +x 
done
keepappendinglogfile

latexindent.pl -s -m pmatrix2 -o=+-mod1 -l=double-back-slash-finish1,pmatrix
latexindent.pl -s -m pmatrix3 -o=+-mod1 -l=double-back-slash-finish1,pmatrix

# multicolumn grouping issue from douglasrizzo, https://github.com/cmhughes/latexindent.pl/issues/143
latexindent.pl -s douglasrizzo -o=+-mod1 -l=multiColumnGrouping
latexindent.pl -s douglasrizzo1 -o=+-mod1 -l=multiColumnGrouping
latexindent.pl -s douglasrizzo2 -o=+-mod1 -l=multiColumnGrouping
latexindent.pl -s issue-301 -o=+-mod1 -l=issue-301

# alignFinalDoubleBackSlash, as in https://github.com/cmhughes/latexindent.pl/issues/179
latexindent.pl -s hudcap -o=+-default
latexindent.pl -s hudcap -o=+-mod1 -l=alignFinalDoubleBackSlash
latexindent.pl -s hudcap1 -o=+-default
latexindent.pl -s hudcap1 -o=+-mod1 -l=alignFinalDoubleBackSlash
latexindent.pl -s hudcap1 -o=+-mod2 -l=alignFinalDoubleBackSlash -y="lookForAlignDelims:tabular:spacesBeforeDoubleBackSlash:5"
latexindent.pl -s hudcap1 -o=+-mod3 -l=alignFinalDoubleBackSlash -y="lookForAlignDelims:tabular:spacesBeforeDoubleBackSlash:5;alignDoubleBackSlash:0"

# dontMeasure, https://github.com/cmhughes/latexindent.pl/issues/182
latexindent.pl -s yangmw -o=+-default -y="lookForAlignDelims:tabular:dontMeasure:0"
latexindent.pl -s yangmw -o=+-mod1 -l=dontMeasure
latexindent.pl -s yangmw -o=+-mod2 -l=dontMeasure2
latexindent.pl -s yangmw -o=+-mod3 -l=dontMeasure3
latexindent.pl -s yangmw -o=+-mod4 -l=dontMeasure4
latexindent.pl -s yangmw -o=+-mod5 -l=dontMeasure5
latexindent.pl -s yangmw -o=+-mod6 -l=dontMeasure6
latexindent.pl -s yangmw -o=+-mod7 -l=dontMeasure7
latexindent.pl -s yangmw -o=+-mod8 -l=dontMeasure8
latexindent.pl -s yangmw -o=+-mod9 -l=dontMeasure9
latexindent.pl -s yangmw -o=+-just-right -l=dontMeasure -y="lookForAlignDelims:tabular:spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s swaroopguggilam -o=+-mod1 -l=dontMeasure1

# delimiterRegex feature: https://github.com/cmhughes/latexindent.pl/issues/187
latexindent.pl -s tabbing -o=+-default
latexindent.pl -s tabbing -o=+-mod1 -l=delimiterRegEx1
latexindent.pl -s tabbing -o=+-mod2 -l=delimiterRegEx2
latexindent.pl -s tabbing1 -o=+-mod3 -l=delimiterRegEx3

latexindent.pl -s tabbing2 -o=+-mod5 -l=delimiterRegEx5
latexindent.pl -s tabbing2 -o=+-mod6 -l=delimiterRegEx6
latexindent.pl -s tabbing2 -o=+-mod7 -l=delimiterRegEx7
latexindent.pl -s tabbing2 -o=+-mod8 -l=delimiterRegEx8

latexindent.pl -s mixed -o=+-out -l=mixed

# issue 201: https://github.com/cmhughes/latexindent.pl/issues/201
latexindent.pl -s issue-201-mk1 -o=+-out
latexindent.pl -s issue-201-mk2 -o=+-out
latexindent.pl -s issue-201-mk3 -o=+-out
latexindent.pl -s issue-201-mk4 -o=+-out

# issue 207: https://github.com/cmhughes/latexindent.pl/issues/207
latexindent.pl -s issue-207 -o=+-mod0
latexindent.pl -s issue-207 -l alusiani -o=+-mod1

# including more environments for lookForAlignDelims
latexindent.pl -s amsmath -o=+-default
latexindent.pl -s mathtools -o=+-default
latexindent.pl -s nicematrix -o=+-default

# issue 209: https://github.com/cmhughes/latexindent.pl/issues/209
latexindent.pl -s -m pgregory -l pgregory1 -o=+-mod1
latexindent.pl -s -m pgregory -l pgregory2 -o=+-mod2
latexindent.pl -s -m pgregory -l pgregory3 -o=+-mod3
latexindent.pl -s -m pgregory -l pgregory4 -o=+-mod4

# issue 223 https://github.com/cmhughes/latexindent.pl/issues/223
latexindent.pl -s vassar0 -o=+-mod1
latexindent.pl -s vassar00 -o=+-mod1
latexindent.pl -s vassar1 -o=+-mod1
latexindent.pl -s vassar -l vassar1 -o=+-mod1

# spacesBeforeAmpersand upgrade, https://github.com/cmhughes/latexindent.pl/issues/275
latexindent.pl -s issue-275 -o=+-default -y="defaultIndent: ' '"

set +x
for i in {1..6}; do
    keepappendinglogfile
    latexindent.pl -s issue-275 -o=+-mod$i  -l=sba$i
    latexindent.pl -s issue-275a -o=+-mod$i -l=sba$i
    latexindent.pl -s issue-275b -o=+-mod$i -l=sba$i
    latexindent.pl -s issue-275c -o=+-mod$i -l=sba$i
    set +x
done


keepappendinglogfile

# nested code blocks, hidden children: https://github.com/cmhughes/latexindent.pl/issues/85
set +x
for i in {1..6}; do
    keepappendinglogfile
    latexindent.pl -s hidden-child$i -o=+-default
    set +x
done
keepappendinglogfile

latexindent.pl -s hidden-child1 -o=+-mod1 -l=sba-align1
latexindent.pl -s hidden-child1 -o=+-mod2 -l=sba-align2

latexindent.pl -s issue-85 -o=+-default

latexindent.pl -s issue-162 -o=+-default
latexindent.pl -s issue-162 -o=+-mod1 -l align1
latexindent.pl -s issue-162 -o=+-mod2 -l align2

latexindent.pl -s issue-212 -o=+-default

latexindent.pl -s issue-251 -o=+-default
latexindent.pl -s issue-251 -o=+-mod1 -y="lookForAlignDelims:tabular:spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s issue-251 -o=+-mod2 -y="lookForAlignDelims:tabular:spacesAfterAmpersand:5;justification:right"


# don't search for child code blocks, issue 308
latexindent.pl -s issue-308 -l issue-308  -o=+-mod1
latexindent.pl -s issue-308 -l issue-308a -o=+-mod1a

latexindent.pl -s issue-308-special -l issue-308-special  -o=+-mod1
latexindent.pl -s issue-308-special -l issue-308-special-a -o=+-mod1a

latexindent.pl -s issue-308-mand-arg -l issue-308-mand-arg  -o=+-mod1
latexindent.pl -s issue-308-mand-arg -l issue-308-mand-arg-a -o=+-mod1a

latexindent.pl -s issue-308-opt-arg -l issue-308-mand-arg  -o=+-mod1
latexindent.pl -s issue-308-opt-arg -l issue-308-mand-arg-a -o=+-mod1a

# issue-326 demo
latexindent.pl -s -r -l issue-326 issue-326 -o=+-mod1
latexindent.pl -s -l issue-326a issue-326a  -o=+-mod1
latexindent.pl -s -l issue-326b issue-326b  -o=+-mod1
latexindent.pl -s -l issue-326c issue-326c  -o=+-mod1
latexindent.pl -s -l issue-326d issue-326d  -o=+-mod1
latexindent.pl -s -l issue-326d2 issue-326d -o +-mod2

# optional loading of GCString testing
latexindent.pl unicode-quick-brown -s -o=+-no-GCString
latexindent.pl unicode-quick-brown -s --GCString -o=+-with-GCString

# tikz edge/node replacement example
latexindent.pl -s -r -l issue-382 issue-382 -o=+-mod1
latexindent.pl -s -r -l issue-382a issue-382 -o=+-mod1a

# DBS poly-switches without lookForAlignDelims, issue-402
latexindent.pl -s -m -l issue-402 issue-402 -o=+-mod1

latexindent.pl -s -m -l issue-402a issue-402 -o=+-mod2
latexindent.pl -s -m -l issue-402b issue-402 -o=+-mod3

latexindent.pl -s -m -l issue-402 issue-402a -o=+-mod1
latexindent.pl -s -m -l issue-402a issue-402a -o=+-mod2
latexindent.pl -s -m -l issue-402b issue-402a -o=+-mod3

latexindent.pl -s -m -l issue-402c issue-402c -o=+-mod1
latexindent.pl -s -m -l issue-402cc issue-402c -o=+-mod2

latexindent.pl -s -m -l issue-402d issue-402d -o=+-mod1

# dontMeasure and -m switch interaction bug, issue 426
latexindent.pl -s -m issue-426               -o=+-mod0
latexindent.pl -s -m issue-426 -l issue-426  -o=+-mod1
latexindent.pl -s -m issue-426a              -o=+-mod0
latexindent.pl -s -m issue-426a -l issue-426 -o=+-mod1

# DBS poly-switch tests, issue 426
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash2 -o=+-mod2
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash3 -o=+-mod3
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash2 -o=+-mod2
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash3 -o=+-mod3

latexindent.pl -s -m issue-426 -l issue-426,double-back-slash-finish-1 -o=+-mod-1
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash-finish1 -o=+-mod-fin1
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash-finish2 -o=+-mod-fin2
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash-finish3 -o=+-mod-fin3
latexindent.pl -s -m issue-426 -l issue-426,double-back-slash-finish4 -o=+-mod-fin4

latexindent.pl -s -m issue-426a -l issue-426,double-back-slash-finish-1 -o=+-mod-1
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash-finish1 -o=+-mod-fin1
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash-finish2 -o=+-mod-fin2
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash-finish3 -o=+-mod-fin3
latexindent.pl -s -m issue-426a -l issue-426,double-back-slash-finish4 -o=+-mod-fin4

# issue 393: alignment *AFTER* \\
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1 issue-393 -o=+-mod1
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS issue-393 -o=+-mod2
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS,cases3 issue-393 -o=+-mod3
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS4 issue-393 -o=+-mod4

latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS,cases3 issue-393a -o=+-mod3

latexindent.pl -s issue-393b -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS2 issue-393b -o=+-mod2
latexindent.pl -s -l alignContentAfterDBS3 issue-393b -o=+-mod3
latexindent.pl -s -l alignContentAfterDBS4 issue-393b -o=+-mod4

latexindent.pl -s issue-393c -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS3 issue-393c -o=+-mod3
latexindent.pl -s -l alignContentAfterDBS4 issue-393c -o=+-mod4
latexindent.pl -s -l alignContentAfterDBS5 issue-393c -o=+-mod5
latexindent.pl -s -l alignContentAfterDBS6 issue-393c -o=+-mod6
latexindent.pl -s -l alignContentAfterDBS7 issue-393c -o=+-mod7

latexindent.pl -s -l alignContentAfterDBS issue-393d -o=+-mod1

latexindent.pl -s -l alignContentAfterDBS1 tabular5 -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS8 tabular5 -o=+-mod8

latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:2"  -m issue-456 -o=+-mod2
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:3"  -m issue-456 -o=+-mod3
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:4"  -m issue-456 -o=+-mod4
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:-1" -m issue-456 -o=+-mod-1

latexindent.pl -s issue-526 -o=+-mod1

latexindent.pl -s issue-535 -o=+-mod1

latexindent.pl -s issue-543 -o=+-mod1

latexindent.pl -s -m issue-541 -l issue-541 -o=+-mod1

latexindent.pl -s -l issue-551 issue-551 -o=+-mod1

latexindent.pl -s -l issue-445a -m issue-445a -o=+-mod2
latexindent.pl -s -l issue-445b -m issue-445a -o=+-mod3
latexindent.pl -s -l issue-445c -m issue-445a -o=+-mod4

# new specials test-cases
latexindent.pl -s nestedalignment -o nestedalignment-NEW -local new-specials
latexindent.pl -s nestedalignment -o nestedalignment-NEW1 -local new-specials1

# nested
latexindent.pl nested-align1 -s -l=indentPreamble  -m -o=+-mod0

# pmatrix
latexindent.pl -s pmatrix -o=+-default
latexindent.pl -s pmatrix -o=+-special-mod1 -m -l=../specials/special-mod1
latexindent.pl -s pmatrix -o=+-pmatrix-mod1 -m -l=pmatrix-mod1
latexindent.pl -s pmatrix -o=+-pmatrix-mod2 -m -l=pmatrix-mod1,special-left-right
latexindent.pl -s pmatrix -o=+-special-mod0 -m -l=pmatrix-mod1,../specials/special-mod1
latexindent.pl -y="lookForAlignDelims:tblr:alignFinalDoubleBackSlash:1" -s issue-551.tex -o=+-mod1

latexindent.pl -s issue-611.tex -o=+-mod1
latexindent.pl -s -l issue-611a issue-611.tex -o=+-mod2

latexindent.pl -s te-752552.tex -o=+-mod1
latexindent.pl -s -r -l te-752552a.yaml te-752552.tex -o=+-mod2

latexindent.pl -s issue-599 -o=+-mod1
latexindent.pl -s issue-599a -o=+-mod1
latexindent.pl -s issue-599b -o=+-mod1

latexindent.pl -s -l issue-583 simple -o=+-mod1
latexindent.pl -s -l issue-583a simple -o=+-mod2

latexindent.pl -m -s -l issue-564 issue-564 -o=+-mod1 -t
egrep -i 'found:' indent.log > issue-564.txt

latexindent.pl -s -l issue-602.yaml issue-602.tex -o=+-mod1
latexindent.pl -s issue-602a.tex -o=+-mod1
set +x 
wrapuptasks
