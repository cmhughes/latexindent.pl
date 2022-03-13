#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=12
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
latexindent.pl -s matrix1.tex -o=+-default.tex
latexindent.pl -s matrix2.tex -o=+-default.tex
latexindent.pl -s align-block.tex -o align-block-default.tex
latexindent.pl -s tabular2.tex -o tabular2-default.tex
latexindent.pl -s tabular2.tex -o=+-mod2 -l tabular2.yaml
latexindent.pl -s tabular2.tex -o=+-mod3 -l tabular3.yaml
latexindent.pl -s tabular2.tex -o=+-mod4 -l tabular2,tabular4.yaml
latexindent.pl -s tabular2.tex -o=+-mod5 -l tabular2,tabular5.yaml
latexindent.pl -s tabular2.tex -o=+-mod6 -l tabular2,tabular6.yaml
latexindent.pl -s tabular2.tex -o=+-mod7 -l tabular2,tabular7.yaml
latexindent.pl -s tabular2.tex -o=+-mod8 -l tabular2,tabular8.yaml

# items
latexindent.pl -s items1.tex -o items1-default.tex

# special
latexindent.pl -s special1.tex -o special1-default.tex
latexindent.pl -s special2.tex -o=+-mod1 -l=middle.yaml
latexindent.pl -s special2.tex -o=+-mod2 -l=middle1.yaml
latexindent.pl -s special3.tex -o=+-mod1 -l=special-verb1.yaml

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
latexindent.pl -s ifelsefi2.tex -o ifelsefi2-default.tex

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
latexindent.pl -s -m env-mlb4.tex -l env-mlb13.yaml -o env-mlb4-mod13.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb14.yaml -o env-mlb4-mod14.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb15.yaml -o env-mlb4-mod15.tex
latexindent.pl -s -m env-mlb4.tex -l env-mlb16.yaml -o env-mlb4-mod16.tex
# trailing white space demo
latexindent.pl -s env-mlb5.tex -m -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml -o env-mlb5-modAll.tex
latexindent.pl -s env-mlb5.tex -m -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml,removeTWS-before.yaml -o env-mlb5-modAll-remove-WS.tex
# blank lines
latexindent.pl -s env-mlb6.tex -m -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml -o env-mlb6-modAll.tex
latexindent.pl -s env-mlb6.tex -m -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml,UnpreserveBlankLines.yaml -o env-mlb6-modAll-un-Preserve-Blank-Lines.tex

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
latexindent.pl -s tikz-node1.tex -o tikz-node1-no-strings.tex -l=no-strings.yaml
latexindent.pl -s for-each.tex -o=+-default
latexindent.pl -s for-each.tex -o=+-mod1 -l=foreach.yaml

# text wrap demonstration
latexindent.pl -s textwrap1.tex -o=+-mod1.tex -l=textwrap1.yaml -m
latexindent.pl -s textwrap1-mod1.tex -o=+A.tex -l=textwrap1A.yaml -m
latexindent.pl -s textwrap1.tex -o=+-mod1B.tex -l=textwrap1B.yaml -m

# blocksFollow
latexindent.pl -s -m -l textwrap1.yaml tw-headings1.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1.yaml,bf-no-headings.yaml tw-headings1.tex -o=+-mod2

latexindent.pl -s -m -l textwrap1.yaml tw-comments1.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1.yaml,bf-no-comments.yaml tw-comments1.tex -o=+-mod2

latexindent.pl -s -m -l textwrap1.yaml tw-disp-math1.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1.yaml,bf-no-disp-math.yaml tw-disp-math1.tex -o=+-mod2

latexindent.pl -s -m -l textwrap1.yaml tw-bf-myenv1.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1.yaml,tw-bf-myenv.yaml tw-bf-myenv1.tex -o=+-mod2

latexindent.pl -m -l textwrap1.yaml tw-0-9.tex -o=+-mod1
latexindent.pl -m -l textwrap1.yaml,bb-0-9.yaml tw-0-9.tex -o=+-mod2

latexindent.pl -s -m -l textwrap1.yaml tw-bb-announce1.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1.yaml,tw-bb-announce.yaml tw-bb-announce1.tex -o=+-mod2

latexindent.pl -s -m -l textwrap1A.yaml tw-be-equation.tex -o=+-mod1
latexindent.pl -s -m -l textwrap1A.yaml,tw-be-equation.yaml tw-be-equation.tex -o=+-mod2

latexindent.pl -s textwrap2.tex -o=+-mod1.tex -l=textwrap1.yaml -m

latexindent.pl -s textwrap3.tex -o=+-mod1.tex -l=textwrap1.yaml -m

latexindent.pl -s textwrap4.tex -o=+-mod2.tex -l=textwrap2.yaml -m
latexindent.pl -s textwrap4.tex -o=+-mod2A -l=textwrap2A.yaml -m
latexindent.pl -s textwrap4.tex -o=+-mod2B -l=textwrap2B.yaml -m

latexindent.pl -s textwrap5.tex -o=+-mod3.tex -l=textwrap3.yaml -m
latexindent.pl -s textwrap5.tex -o=+-mod4.tex -l=textwrap4.yaml -m
latexindent.pl -s textwrap5.tex -o=+-mod5.tex -l=textwrap5.yaml -m

latexindent.pl -s textwrap6.tex -o=+-mod5.tex -l=textwrap5.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod6.tex -l=textwrap6.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod7.tex -l=textwrap7.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod8.tex -l=textwrap8.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod9.tex -l=textwrap9.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod10.tex -l=textwrap10.yaml -m
latexindent.pl -s textwrap6.tex -o=+-mod11.tex -l=textwrap11.yaml -m

latexindent.pl -s tabular2.tex -o=+-wrap-mod3.tex -l=textwrap3.yaml -m
latexindent.pl -s tabular2.tex -o=+-wrap-mod3A.tex -l=textwrap3.yaml -m -y="modifyLineBreaks:textWrapOptions:alignAtAmpersandTakesPriority:0"
latexindent.pl -s textwrap7.tex -o=+-mod3.tex -l=textwrap3.yaml -m
latexindent.pl -s textwrap7.tex -o=+-mod12.tex -l=textwrap12.yaml -m
latexindent.pl -s textwrap-ts.tex -o=+-mod1.tex -l=tabstop.yaml -m
latexindent.pl -s textwrap-bfccb.tex -o=+-mod12.tex -l=textwrap12.yaml,addruler1 -m -r
latexindent.pl -s textwrap-bfccb.tex -o=+-mod13.tex -l=textwrap13.yaml,addruler2 -m -r
latexindent.pl -s textwrap-bfccb.tex -o=+-mod14.tex -l=textwrap14.yaml,addruler1 -m -r

# remove paragraph line breaks
latexindent.pl -s shortlines.tex -o=+1.tex -l=remove-para1,remove-para4 -m
latexindent.pl -s shortlines.tex -o=+1-tws.tex -l=remove-para1,removeTWS-before,remove-para4  -m
latexindent.pl -s shortlines-mand.tex -o=+1.tex -l=remove-para1.yaml,mycommand.yaml -m
latexindent.pl -s shortlines-opt.tex -o=+1.tex -l=remove-para1.yaml,mycommand-opt.yaml -m
latexindent.pl -s shortlines-envs.tex -o=+2.tex -l=remove-para2.yaml -m
latexindent.pl -s shortlines-envs.tex -o=+3.tex -l=remove-para3.yaml -m
latexindent.pl -s shortlines-md.tex -o=+4.tex -l=remove-para4.yaml -m

# paragraph stops at routine
latexindent.pl -s sl-stop.tex -o sl-stop4.tex -l=remove-para4.yaml -m
latexindent.pl -s sl-stop.tex -o sl-stop4-command.tex -l=remove-para4.yaml -m

# maximum indentation
latexindent.pl -s mult-nested.tex -o=+-default
latexindent.pl -s mult-nested.tex -l=max-indentation1 -o=+-max-ind1

# ifnextchar
latexindent.pl -s ifnextchar.tex -o=+-default
latexindent.pl -s ifnextchar.tex -o=+-off -l no-ifnextchar.yaml

# poly-switch set to 3 with/without unpreserved blank lines
latexindent.pl -s -m env-mlb7 -o=+-preserve -l=env-mlb12.yaml,env-mlb13.yaml
latexindent.pl -s -m env-mlb7 -o=+-no-preserve -l=env-mlb12.yaml,env-mlb13.yaml,UnpreserveBlankLines.yaml

# special before command
latexindent.pl -s specialLR.tex -l specialsLeftRight.yaml -o=+-comm-first
latexindent.pl -s specialLR.tex -l specialsLeftRight.yaml,specialBeforeCommand.yaml -o=+-special-first

# specialBeginEnd with alignment
latexindent.pl -s special-align.tex -l edge-node1.yaml -o=+-mod1
latexindent.pl -s special-align.tex -l edge-node2.yaml -o=+-mod2

# one sentence per line
latexindent.pl -s multiple-sentences -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s multiple-sentences -m -l=keep-sen-line-breaks.yaml -o=+-mod2
latexindent.pl -s multiple-sentences -m -l=sentences-follow1.yaml -o=+-mod3
latexindent.pl -s multiple-sentences -m -l=sentences-end1.yaml -o=+-mod4
latexindent.pl -s multiple-sentences -m -l=sentences-end2.yaml -o=+-mod5
latexindent.pl -s multiple-sentences1 -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s multiple-sentences1 -m -l=manipulate-sentences.yaml,sentences-follow2.yaml -o=+-mod2
latexindent.pl -s multiple-sentences2 -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s multiple-sentences2 -m -l=manipulate-sentences.yaml,sentences-begin1 -o=+-mod2
latexindent.pl -s multiple-sentences3 -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s multiple-sentences4 -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s multiple-sentences4 -m -l=keep-sen-line-breaks.yaml -o=+-mod2
latexindent.pl -s multiple-sentences4 -m -l=item-rules2 -o=+-mod3
latexindent.pl -s url.tex -m -l=manipulate-sentences.yaml -o=+-mod1
latexindent.pl -s url.tex -m -l=alt-full-stop1 -o=+-mod2
latexindent.pl -s multiple-sentences5 -m -l=sentence-wrap1.yaml -o=+-mod1
latexindent.pl -s multiple-sentences6 -m -l=sentence-wrap1.yaml -o=+-mod1
latexindent.pl -s multiple-sentences6 -m -l=sentence-wrap1.yaml -o=+-mod2 -y="modifyLineBreaks:oneSentencePerLine:sentenceIndent:''"
latexindent.pl -s multiple-sentences6 -m -l=sentence-wrap1.yaml,itemize.yaml -o=+-mod3

# double back slash demonstrations
latexindent.pl -s -m tabular3.tex -l=DBS1.yaml -o=+-mod1
latexindent.pl -s -m tabular3.tex -l=DBS2.yaml -o=+-mod2
latexindent.pl -s -m tabular3.tex -l=DBS3.yaml -o=+-mod3
latexindent.pl -s -m tabular3.tex -l=DBS4.yaml -o=+-mod4
latexindent.pl -s -m special4.tex -l=DBS5.yaml -o=+-mod5
latexindent.pl -s -m mycommand2.tex -l=DBS6.yaml -o=+-mod6
latexindent.pl -s -m mycommand2.tex -l=DBS7.yaml -o=+-mod7
latexindent.pl -s -m pmatrix3.tex -l=DBS3.yaml -o=+-mod3

# replacement mode demonstrations
# replacement mode demonstrations
# replacement mode demonstrations
latexindent.pl -s -r replace1 -o=+-r1
latexindent.pl -s -r replace1 -l=replace1.yaml -o=+-mod1

latexindent.pl -s -r colsep -o=+-mod0 -l=colsep.yaml
latexindent.pl -s -r colsep -o=+-mod1 -l=colsep1.yaml
latexindent.pl -s -r colsep -o=+-mod2 -l=multi-line.yaml
latexindent.pl -s -r colsep -o=+-mod3 -l=multi-line1yaml

latexindent.pl -s -r displaymath -o=+-mod1 -l=displaymath1.yaml
latexindent.pl -s -r -m displaymath -o=+-mod2 -l=displaymath1.yaml,equation.yaml

latexindent.pl -s -r phrase -o=+-mod1 -l=hspace.yaml

latexindent.pl -s -r references.tex -o=+-mod1 -l=reference.yaml

latexindent.pl -s -r verb1.tex -o=+-mod1 -l=verbatim1
latexindent.pl -s -rr verb1.tex -o=+-rr-mod1 -l=verbatim1
latexindent.pl -s -rv verb1.tex -o=+-rv-mod1 -l=verbatim1

# amalgamate demonstrations
latexindent.pl -s -r amalg1.tex -l=amalg1-yaml.yaml -o=+-mod1
latexindent.pl -s -r amalg1.tex -l=amalg1-yaml.yaml,amalg2-yaml.yaml -o=+-mod12
latexindent.pl -s -r amalg1.tex -l=amalg1-yaml.yaml,amalg3-yaml,amalg3-yaml.yaml -o=+-mod123

# fine tuning
# fine tuning
# fine tuning
latexindent.pl -s finetuning1.tex -o=+-default
latexindent.pl -s finetuning1.tex -o=+-mod1 -l=fine-tuning1
latexindent.pl -s finetuning2.tex -o=+-default
latexindent.pl -s finetuning2.tex -o=+-mod1 -l=fine-tuning2
latexindent.pl -s -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1,modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1,fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' finetuning3.tex -o=+-mod1
latexindent.pl -s finetuning4.tex -o=+-mod1 -l=href1 -m 
latexindent.pl -s finetuning4.tex -o=+-mod2 -l=href2 -m 
latexindent.pl -s finetuning4.tex -o=+-mod3 -l=href3 -m 
latexindent.pl -s bib1.bib -o=+-mod1 
latexindent.pl -s bib1.bib -l bibsettings1.yaml -o=+-mod2 
latexindent.pl -s bib2.bib -l bibsettings1.yaml -o=+-mod1 
latexindent.pl -s bib2.bib -l bibsettings1.yaml,bibsettings2.yaml -o=+-mod2 

# blank line poly-switches
latexindent.pl -s -m env-mlb1.tex -l env-beg4.yaml -o=+-beg4
latexindent.pl -s -m env-mlb1.tex -l env-body4.yaml -o=+-body4
latexindent.pl -s -m env-mlb1.tex -l env-end4.yaml -o=+-end4
latexindent.pl -s -m env-mlb1.tex -l env-end-f4.yaml -o=+-end-f4

# final double back slash demo
latexindent.pl -s tabular4.tex -o=+-default
latexindent.pl -s tabular4.tex -o=+-FDBS -y="lookForAlignDelims:tabular:alignFinalDoubleBackSlash:1"

# dontMeasure
latexindent.pl -s tabular-DM -o=+-default
latexindent.pl -s tabular-DM -o=+-mod1 -l=dontMeasure1.yaml
latexindent.pl -s tabular-DM -o=+-mod2 -l=dontMeasure2.yaml
latexindent.pl -s tabular-DM -o=+-mod3 -l=dontMeasure3.yaml
latexindent.pl -s tabular-DM -o=+-mod4 -l=dontMeasure4.yaml
latexindent.pl -s tabular-DM -o=+-mod5 -l=dontMeasure5.yaml
latexindent.pl -s tabular-DM -o=+-mod6 -l=dontMeasure6.yaml

latexindent.pl -s tabular-DM-1 -o=+-mod1 -l=dontMeasure1.yaml
latexindent.pl -s tabular-DM-1 -o=+-mod1a -l=dontMeasure1a.yaml

# delimiterRegEx
latexindent.pl -s tabbing.tex -o=+-default
latexindent.pl -s tabbing.tex -o=+-mod1 -l=delimiterRegEx1.yaml
latexindent.pl -s tabbing.tex -o=+-mod2 -l=delimiterRegEx2.yaml
latexindent.pl -s tabbing.tex -o=+-mod3 -l=delimiterRegEx3.yaml
latexindent.pl -s tabbing1.tex -o=+-mod4 -l=delimiterRegEx4.yaml
latexindent.pl -s tabbing1.tex -o=+-mod5 -l=delimiterRegEx5.yaml

# noindent block
latexindent.pl -s noindentblock1.tex -l noindent1.yaml -o=+-mod1
latexindent.pl -s noindentblock1.tex -l noindent2.yaml -o=+-mod2
latexindent.pl -s noindentblock1.tex -l noindent3.yaml -o=+-mod3

# spacesBeforeAmpersand demo
latexindent.pl -s aligned1.tex -o=+-default
latexindent.pl -s aligned1.tex -l sba1.yaml -o=+-mod1
latexindent.pl -s aligned1.tex -l sba2.yaml -o=+-mod2
latexindent.pl -s aligned1.tex -l sba3.yaml -o=+-mod3
latexindent.pl -s aligned1.tex -l sba4.yaml -o=+-mod4
latexindent.pl -s aligned1.tex -l sba5.yaml -o=+-mod5
latexindent.pl -s aligned1.tex -l sba6.yaml -o=+-mod6
latexindent.pl -s aligned1.tex -l sba7.yaml -o=+-mod7

# lines switch
latexindent.pl --lines 3-7 -s myfile.tex -o=+-mod1
latexindent.pl --lines 5 -s myfile.tex -o=+-mod2
latexindent.pl --lines 3-5,8-10 -s myfile.tex -o=+-mod3
latexindent.pl --lines 1-2,4-5,9-10,12 -s myfile.tex -o=+-mod4
latexindent.pl --lines !5-7 -s myfile.tex -o=+-mod5
latexindent.pl --lines !5-7,!9-10 myfile.tex -s -o=+-mod6
latexindent.pl --lines 6 myfile1.tex -m -s -l env-mlb2,env-mlb7,env-mlb8 -o=+-mod1 

[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status
