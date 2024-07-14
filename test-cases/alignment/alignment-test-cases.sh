#!/bin/bash
loopmax=4
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# table-based test cases
latexindent.pl -s simple.tex -o=+-default.tex
latexindent.pl -s simple-multi-column.tex -o=+-mod1 -y="lookForAlignDelims:tabular:multiColumnGrouping:1"
latexindent.pl -s simple-multi-column.tex -o=+-mod2 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;justification:right"
latexindent.pl -s simple-multi-column.tex -o=+-mod3 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s simple-multi-column.tex -o=+-mod4 -y="lookForAlignDelims:tabular:multiColumnGrouping:1;spacesAfterAmpersand:3;justification:right"
latexindent.pl -s table1.tex -o table1-default.tex
latexindent.pl -s unicode1.tex -o unicode1-default.tex

[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set -x 
    # basic tests
    latexindent.pl -s table1.tex -o=+-mod$i.tex -l=tabular$i.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table3.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table4.tex -o=+-mod$i.tex -l=tabular$i.yaml
    latexindent.pl -s table5.tex -o=+-mod$i.tex -l=tabular$i.yaml
    # tests with \\ not aligned
    latexindent.pl -s table1.tex -o table1-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+4)).tex -l=tabular$i.yaml,tabular5.yaml
    # tests with \\ not aligned, and with spaces before \\
    latexindent.pl -s table1.tex -o table1-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml,multiColumnGrouping2.yaml
    latexindent.pl -s table2.tex -o table2-mod$((i+8)).tex -l=tabular$i.yaml,tabular6.yaml
    # alignment inside commented block
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-mod$i.tex -l tabular$i.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-1-mod$i.tex -l tabular$i.yaml,noAddtabular1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-2-mod$i.tex -l tabular$i.yaml,noAddtabular2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-no-Add-3-mod$i.tex -l tabular$i.yaml,noAddtabular3.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-1-mod$i.tex -l tabular$i.yaml,indentRules1.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-2-mod$i.tex -l tabular$i.yaml,indentRules2.yaml
    latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-indent-rules-3-mod$i.tex -l tabular$i.yaml,indentRules3.yaml
    [[ $silentMode == 0 ]] && set +x 
done
latexindent.pl -s table1.tex -o=+-mod3.tex -l=tabular3.yaml
# legacy matrix test case
latexindent.pl -s matrix.tex -o=+-default.tex

# legacy environment test case
latexindent.pl -s environments.tex -o=+-default.tex
latexindent.pl -s environments.tex -o=+-no-align-double-back-slash.tex -l=align-no-double-back-slash.yaml
latexindent.pl -s legacy-align.tex -o=+-default.tex

# alignment inside a mandatory argument
latexindent.pl -s matrix1.tex -o=+-default.tex
latexindent.pl -s matrix1.tex -o=+-no-align.tex -l=noMatrixAlign.yaml

# nested
latexindent.pl nested-align1.tex -s -l=indentPreamble.yaml  -m -o=+-mod0.tex

# using comments
latexindent.pl -s alignmentoutsideEnvironmentsCommands.tex -o=+-default.tex

# end statement not on own line
latexindent.pl -s end-not-on-own-line.tex -o=+-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o=+-default.tex
latexindent.pl -s end-not-on-own-line1.tex -o=+-mod1.tex -m -l=env-mod-lines1.yaml

# pmatrix
latexindent.pl -s pmatrix.tex -outputfile=pmatrix-default.tex -l=noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-special-mod1.tex -m -l=../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-pmatrix-mod1.tex -m -l=pmatrix-mod1.yaml,noRoundParenthesisInArgs.yaml
latexindent.pl -s pmatrix.tex -o=+-special-mod0.tex -m -l=pmatrix-mod1.yaml,../specials/special-mod1.yaml,noRoundParenthesisInArgs.yaml

# special
latexindent.pl -s special1.tex -o=+-aligned.tex -l special-align.yaml

# uni code
for (( i=1 ; i <= 6 ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set +x 
    latexindent.pl -s uni-code1.tex -o=+-mod$i.tex -l=tabular$i.yaml
    [[ $silentMode == 0 ]] && set -x 
done

# multiColumnGrouping
latexindent.pl -s tabular-karl.tex -o=+-default.tex
latexindent.pl -s tabular-karl.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s tabular-karl.tex -o=+-out1.tex -l multiColumnGrouping1.yaml
latexindent.pl -s tabular-karl.tex -o=+-out2.tex -l multiColumnGrouping2.yaml
latexindent.pl -s tabular-karl.tex -o=+-out3.tex -l multiColumnGrouping3.yaml
latexindent.pl -s tabular-karl.tex -o=+-out5.tex -l multiColumnGrouping.yaml,tabular5.yaml
latexindent.pl -s tabular-karl.tex -o=+-out6.tex -l multiColumnGrouping.yaml,tabular6.yaml
latexindent.pl -s multicol.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s unicode-multicol.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s table3.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s tabular-multiple-multicol -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s multicol-no-ampersands -o=+-default.tex
latexindent.pl -s multicol-no-ampersands.tex -o=+-out.tex -l multiColumnGrouping.yaml
latexindent.pl -s multicol-no-ampersands.tex -o=+-out5.tex -l multiColumnGrouping.yaml,tabular5.yaml
latexindent.pl -s multicol-no-ampersands.tex -o=+-out6.tex -l multiColumnGrouping.yaml,tabular6.yaml
latexindent.pl -s longcells.tex -o=+-default.tex
latexindent.pl -s longcells.tex -o=+-multicol.tex -l multiColumnGrouping.yaml

# spaces before and after ampersands
latexindent.pl -s table5.tex -o=+-mod7 -l=tabular7
latexindent.pl -s table5.tex -o=+-mod8 -l=tabular8
latexindent.pl -s table5.tex -o=+-mod9 -l=tabular9
latexindent.pl -s table5.tex -o=+-mod10 -l=tabular10
latexindent.pl -s tabular-karl.tex -o=+-out9.tex -l multiColumnGrouping.yaml,tabular9.yaml
latexindent.pl -s tabular-karl.tex -o=+-out10.tex -l multiColumnGrouping.yaml,tabular10.yaml
latexindent.pl -s matrix1.tex -o=+-mod1 -l=matrix1
latexindent.pl -s matrix1.tex -o=+-mod2 -l=matrix2

# left/right justification
latexindent.pl -s table5.tex -o=+-mod11 -l=tabular11
latexindent.pl -s table5.tex -o=+-mod12 -l=tabular11,tabular7,tabular8
latexindent.pl -s table5.tex -o=+-mod13 -l=tabular11,tabular9
latexindent.pl -s tabular-karl.tex -o=+-out11.tex -l multiColumnGrouping.yaml,tabular11.yaml

# issue 95 demo
latexindent.pl -s issue-95 -o=+-mod0
latexindent.pl -s issue-95 -o=+-mod1 -l=noMaxDelims.yaml

# double back slash polyswitch, https://github.com/cmhughes/latexindent.pl/issues/106
for (( i=-1 ; i <= 3 ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set -x 
    # DBSStartsOnOwnLine
    latexindent.pl -s -m pmatrix1.tex -o=+-mod$i -l=double-back-slash$i.yaml
    # DBSOrFinishesWithLineBreak
    latexindent.pl -s -m pmatrix1.tex -o=+-finish-mod$i -l=double-back-slash-finish$i.yaml
    # per-name testing
    latexindent.pl -s -m pmatrix1.tex -o=+-mod-per-name$i -l=double-back-slash-per-name$i.yaml
    # commands
    latexindent.pl -s -m command-align.tex -o=+-opt-mod$i -l=command-dbs-optional$i.yaml,mycommand.yaml
    latexindent.pl -s -m command-align.tex -o=+-mand-mod$i -l=command-dbs-mandatory$i.yaml,mycommand.yaml
    latexindent.pl -s -m command-align.tex -o=+-opt-finish-mod$i -l=mycommand.yaml -y="modifyLineBreaks:optionalArguments:DBSFinishesWithLineBreak:$i"
    latexindent.pl -s -m command-align.tex -o=+-mand-finish-mod$i -l=mycommand.yaml -y="modifyLineBreaks:mandatoryArguments:DBSFinishesWithLineBreak:$i"
    # special
    latexindent.pl -s -m special-align.tex -o=+-mod$i -l=special-align1.yaml -y="modifyLineBreaks:specialBeginEnd:DBSStartsOnOwnLine:$i"
    latexindent.pl -s -m special-align.tex -o=+-finish-mod$i -l=special-align1.yaml -y="modifyLineBreaks:specialBeginEnd:DBSFinishesWithLineBreak:$i"
    latexindent.pl -s -m special-align1.tex -o=+-mod$i -l=special-align1.yaml -y="modifyLineBreaks:specialBeginEnd:DBSStartsOnOwnLine:$i"
    latexindent.pl -s -m special-align1.tex -o=+-finish-mod$i -l=special-align1.yaml -y="modifyLineBreaks:specialBeginEnd:DBSFinishesWithLineBreak:$i"
    [[ $silentMode == 0 ]] && set +x 
done
latexindent.pl -s -m pmatrix2.tex -o=+-mod1 -l=double-back-slash-finish1.yaml,pmatrix.yaml
latexindent.pl -s -m pmatrix3.tex -o=+-mod1 -l=double-back-slash-finish1.yaml,pmatrix.yaml

# multicolumn grouping issue from douglasrizzo, https://github.com/cmhughes/latexindent.pl/issues/143
latexindent.pl -s douglasrizzo.tex -o=+-mod1 -l=multiColumnGrouping.yaml
latexindent.pl -s douglasrizzo1.tex -o=+-mod1 -l=multiColumnGrouping.yaml
latexindent.pl -s douglasrizzo2.tex -o=+-mod1 -l=multiColumnGrouping.yaml
latexindent.pl -s issue-301 -o=+-mod1 -l=issue-301.yaml

# alignFinalDoubleBackSlash, as in https://github.com/cmhughes/latexindent.pl/issues/179
latexindent.pl -s hudcap.tex -o=+-default
latexindent.pl -s hudcap.tex -o=+-mod1 -l=alignFinalDoubleBackSlash.yaml
latexindent.pl -s hudcap1.tex -o=+-default
latexindent.pl -s hudcap1.tex -o=+-mod1 -l=alignFinalDoubleBackSlash.yaml
latexindent.pl -s hudcap1.tex -o=+-mod2 -l=alignFinalDoubleBackSlash.yaml -y="lookForAlignDelims:tabular:spacesBeforeDoubleBackSlash:5"
latexindent.pl -s hudcap1.tex -o=+-mod3 -l=alignFinalDoubleBackSlash.yaml -y="lookForAlignDelims:tabular:spacesBeforeDoubleBackSlash:5;alignDoubleBackSlash:0"

# dontMeasure, https://github.com/cmhughes/latexindent.pl/issues/182
latexindent.pl -s yangmw.tex -o=+-default -y="lookForAlignDelims:tabular:dontMeasure:0"
latexindent.pl -s yangmw.tex -o=+-mod1 -l=dontMeasure.yaml
latexindent.pl -s yangmw.tex -o=+-mod2 -l=dontMeasure2.yaml
latexindent.pl -s yangmw.tex -o=+-mod3 -l=dontMeasure3.yaml
latexindent.pl -s yangmw.tex -o=+-mod4 -l=dontMeasure4.yaml
latexindent.pl -s yangmw.tex -o=+-mod5 -l=dontMeasure5.yaml
latexindent.pl -s yangmw.tex -o=+-mod6 -l=dontMeasure6.yaml
latexindent.pl -s yangmw.tex -o=+-mod7 -l=dontMeasure7.yaml
latexindent.pl -s yangmw.tex -o=+-mod8 -l=dontMeasure8.yaml
latexindent.pl -s yangmw.tex -o=+-mod9 -l=dontMeasure9.yaml
latexindent.pl -s yangmw.tex -o=+-just-right -l=dontMeasure.yaml -y="lookForAlignDelims:tabular:spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s swaroopguggilam.tex -o=+-mod1 -l=dontMeasure1.yaml

# delimiterRegex feature: https://github.com/cmhughes/latexindent.pl/issues/187
latexindent.pl -s tabbing.tex -o=+-default
latexindent.pl -s tabbing.tex -o=+-mod1 -l=delimiterRegEx1.yaml
latexindent.pl -s tabbing.tex -o=+-mod2 -l=delimiterRegEx2.yaml
latexindent.pl -s tabbing1.tex -o=+-mod3 -l=delimiterRegEx3.yaml

latexindent.pl -s tabbing2.tex -o=+-mod5 -l=delimiterRegEx5.yaml
latexindent.pl -s tabbing2.tex -o=+-mod6 -l=delimiterRegEx6.yaml
latexindent.pl -s tabbing2.tex -o=+-mod7 -l=delimiterRegEx7.yaml
latexindent.pl -s tabbing2.tex -o=+-mod8 -l=delimiterRegEx8.yaml

latexindent.pl -s mixed.tex -o=+-out -l=mixed.yaml

# issue 201: https://github.com/cmhughes/latexindent.pl/issues/201
latexindent.pl -s issue-201-mk1.tex -o=+-out
latexindent.pl -s issue-201-mk2.tex -o=+-out
latexindent.pl -s issue-201-mk3.tex -o=+-out
latexindent.pl -s issue-201-mk4.tex -o=+-out

# issue 207: https://github.com/cmhughes/latexindent.pl/issues/207
latexindent.pl -s issue-207.tex -o=+-mod0
latexindent.pl -s issue-207.tex -l alusiani.yaml -o=+-mod1

# issue 223 https://github.com/cmhughes/latexindent.pl/issues/223
latexindent.pl -s vassar.tex -l vassar1.yaml -o=+-mod1

# including more environments for lookForAlignDelims
latexindent.pl -s amsmath.tex -o=+-default
latexindent.pl -s mathtools.tex -o=+-default
latexindent.pl -s nicematrix.tex -o=+-default

# issue 209: https://github.com/cmhughes/latexindent.pl/issues/209
latexindent.pl -s -m pgregory.tex -l pgregory1.yaml -o=+-mod1
latexindent.pl -s -m pgregory.tex -l pgregory2.yaml -o=+-mod2
latexindent.pl -s -m pgregory.tex -l pgregory3.yaml -o=+-mod3
latexindent.pl -s -m pgregory.tex -l pgregory4.yaml -o=+-mod4

# spacesBeforeAmpersand upgrade, https://github.com/cmhughes/latexindent.pl/issues/275
latexindent.pl -s issue-275.tex -o=+-default -y="defaultIndent: ' '"

for i in {1..6}; do
    latexindent.pl -s issue-275.tex -o=+-mod$i  -l=sba$i.yaml
    latexindent.pl -s issue-275a.tex -o=+-mod$i -l=sba$i.yaml
    latexindent.pl -s issue-275b.tex -o=+-mod$i -l=sba$i.yaml
    latexindent.pl -s issue-275c.tex -o=+-mod$i -l=sba$i.yaml
done

# nested code blocks, hidden children: https://github.com/cmhughes/latexindent.pl/issues/85
for i in {1..6}; do
    latexindent.pl -s hidden-child$i -o=+-default
done

latexindent.pl -s hidden-child1 -o=+-mod1 -l=sba-align1.yaml
latexindent.pl -s hidden-child1 -o=+-mod2 -l=sba-align2.yaml

latexindent.pl -s issue-85.tex -o=+-default

latexindent.pl -s issue-162.tex -o=+-default
latexindent.pl -s issue-162.tex -o=+-mod1 -l align1.yaml
latexindent.pl -s issue-162.tex -o=+-mod2 -l align2.yaml

latexindent.pl -s issue-212.tex -o=+-default

latexindent.pl -s issue-251.tex -o=+-default
latexindent.pl -s issue-251.tex -o=+-mod1 -y="lookForAlignDelims:tabular:spacesBeforeAmpersand:3;justification:right"
latexindent.pl -s issue-251.tex -o=+-mod2 -y="lookForAlignDelims:tabular:spacesAfterAmpersand:5;justification:right"

# don't search for child code blocks, issue 308
latexindent.pl -s issue-308.tex -l issue-308.yaml  -o=+-mod1
latexindent.pl -s issue-308.tex -l issue-308a.yaml -o=+-mod1a

latexindent.pl -s issue-308-special.tex -l issue-308-special.yaml  -o=+-mod1
latexindent.pl -s issue-308-special.tex -l issue-308-special-a.yaml -o=+-mod1a

latexindent.pl -s issue-308-mand-arg.tex -l issue-308-mand-arg.yaml  -o=+-mod1
latexindent.pl -s issue-308-mand-arg.tex -l issue-308-mand-arg-a.yaml -o=+-mod1a

latexindent.pl -s issue-308-opt-arg.tex -l issue-308-mand-arg.yaml  -o=+-mod1
latexindent.pl -s issue-308-opt-arg.tex -l issue-308-mand-arg-a.yaml -o=+-mod1a

# issue-326 demo
latexindent.pl -s -w -r -l issue-326.yaml issue-326.tex
latexindent.pl -s -w -l issue-326a.yaml issue-326a.tex
latexindent.pl -s -w -l issue-326b.yaml issue-326b.tex
latexindent.pl -s -w -l issue-326c.yaml issue-326c.tex
latexindent.pl -s -w -l issue-326d.yaml issue-326d.tex
latexindent.pl -s    -l issue-326d2.yaml issue-326d.tex -o +-mod2

# optional loading of GCString testing
latexindent.pl unicode-quick-brown.tex -s -o=+-no-GCString
latexindent.pl unicode-quick-brown.tex -s --GCString -o=+-with-GCString

# tikz edge/node replacement example
latexindent.pl -s -r -l issue-382.yaml issue-382.tex -o=+-mod1
latexindent.pl -s -r -l issue-382a.yaml issue-382.tex -o=+-mod1a

# DBS poly-switches without lookForAlignDelims, issue-402
latexindent.pl -s -m -l issue-402.yaml issue-402.tex -o=+-mod1
latexindent.pl -s -m -l issue-402a.yaml issue-402.tex -o=+-mod2
latexindent.pl -s -m -l issue-402b.yaml issue-402.tex -o=+-mod3

latexindent.pl -s -m -l issue-402.yaml issue-402a.tex -o=+-mod1
latexindent.pl -s -m -l issue-402a.yaml issue-402a.tex -o=+-mod2
latexindent.pl -s -m -l issue-402b.yaml issue-402a.tex -o=+-mod3

latexindent.pl -s -m -l issue-402c.yaml issue-402c.tex -o=+-mod1

latexindent.pl -s -m -l issue-402d.yaml issue-402d.tex -o=+-mod1

# dontMeasure and -m switch interaction bug, issue 426
latexindent.pl -s -m issue-426.tex                   -o=+-mod0
latexindent.pl -s -m issue-426.tex -l issue-426.yaml -o=+-mod1
latexindent.pl -s -m issue-426a.tex                   -o=+-mod0
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml -o=+-mod1

# DBS poly-switch tests, issue 426
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash2 -o=+-mod2
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash3 -o=+-mod3
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash2 -o=+-mod2
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash3 -o=+-mod3

latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash-finish-1 -o=+-mod-1
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash-finish1 -o=+-mod-fin1
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash-finish2 -o=+-mod-fin2
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash-finish3 -o=+-mod-fin3
latexindent.pl -s -m issue-426.tex -l issue-426.yaml,double-back-slash-finish4 -o=+-mod-fin4

latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash-finish-1 -o=+-mod-1
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash-finish1 -o=+-mod-fin1
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash-finish2 -o=+-mod-fin2
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash-finish3 -o=+-mod-fin3
latexindent.pl -s -m issue-426a.tex -l issue-426.yaml,double-back-slash-finish4 -o=+-mod-fin4

# issue 393: alignment *AFTER* \\
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1 issue-393.tex -o=+-mod1
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS issue-393.tex -o=+-mod2
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS,cases3 issue-393.tex -o=+-mod3
latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS4 issue-393.tex -o=+-mod4

latexindent.pl -s -m -l double-back-slash1,double-back-slash-finish-1,alignContentAfterDBS,cases3 issue-393a.tex -o=+-mod3

latexindent.pl -s issue-393b.tex -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS2 issue-393b.tex -o=+-mod2
latexindent.pl -s -l alignContentAfterDBS3 issue-393b.tex -o=+-mod3
latexindent.pl -s -l alignContentAfterDBS4 issue-393b.tex -o=+-mod4

latexindent.pl -s issue-393c.tex -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS3 issue-393c.tex -o=+-mod3
latexindent.pl -s -l alignContentAfterDBS4 issue-393c.tex -o=+-mod4
latexindent.pl -s -l alignContentAfterDBS5 issue-393c.tex -o=+-mod5
latexindent.pl -s -l alignContentAfterDBS6 issue-393c.tex -o=+-mod6
latexindent.pl -s -l alignContentAfterDBS7 issue-393c.tex -o=+-mod7

latexindent.pl -s -l alignContentAfterDBS.yaml issue-393d.tex -o=+-mod1

latexindent.pl -s -l alignContentAfterDBS1.yaml tabular5.tex -o=+-mod1
latexindent.pl -s -l alignContentAfterDBS8.yaml tabular5.tex -o=+-mod8

latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:2"  -m issue-456.tex -o=+-mod2
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:3"  -m issue-456.tex -o=+-mod3
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:4"  -m issue-456.tex -o=+-mod4
latexindent.pl -s -y="modifyLineBreaks:environments:EndStartsOnOwnLine:-1" -m issue-456.tex -o=+-mod-1

latexindent.pl -s issue-526.tex -o=+-mod1

latexindent.pl -s issue-535.tex -o=+-mod1

latexindent.pl -s issue-543.tex -o=+-mod1

latexindent.pl -s -m issue-541.tex -l issue-541.yaml -o=+-mod1

latexindent.pl -y="lookForAlignDelims:tblr:alignFinalDoubleBackSlash:1" -s issue-551.tex -o=+-mod1
[[ $silentMode == 0 ]] && set -x 
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
