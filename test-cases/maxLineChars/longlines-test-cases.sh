#!/bin/bash
loopmax=5
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# proof of concept
latexindent.pl -s long-lines1.tex -o long-lines1-default.tex
latexindent.pl -s long-lines2.tex -o long-lines2-default.tex

# the issue that motivated this pursuit  https://github.com/cmhughes/latexindent.pl/issues/33
latexindent.pl -s jowens-short.tex -o jowens-short-mod-4.tex -l=text-wrap-4.yaml -m
latexindent.pl -s jowens-long.tex -o jowens-long-mod-4.tex -l=text-wrap-4.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"

# long lines test cases
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    [[ $silentMode == 0 ]] && set -x 
    # basic tests
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    latexindent.pl -s long-lines1.tex -o long-lines1-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines2.tex -o long-lines2-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines3.tex -o long-lines3-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
   [[ $silentMode == 0 ]] && set +x 
done

set +x
[[ $silentMode == 0 ]] && set -x 

# verbatim
latexindent.pl -s -m verbatim-long-lines.tex -o verbatim-long-lines-mod1.tex -l=text-wrap-1.yaml -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -s -m verbatim2 -o=+-mod1 -l=verbatim1.yaml

# remove paragraph line breaks
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks0.yaml -o jowens-short-multi-line0.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks1.yaml -o jowens-short-multi-line1.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks2.yaml -o jowens-short-multi-line2.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks3.yaml -o jowens-short-multi-line3.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks4.yaml -o jowens-short-multi-line4.tex

# remove paragraph line breaks, multiple objects
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks0.yaml -o multi-object0.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks5.yaml -o multi-object5.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks6.yaml -o multi-object6.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks7.yaml -o multi-object7.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks8.yaml -o multi-object8.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks9.yaml -o multi-object9.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks10.yaml -o multi-object10.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks11.yaml -o multi-object11.tex

# trailing comments
latexindent.pl -m -s trailingComments.tex -l removeParaLineBreaks0.yaml -o trailingComments0.tex
latexindent.pl -m -s trailingComments.tex -l removeParaLineBreaks0.yaml,unprotect-blank-lines.yaml -o trailingComments-unprotect0.tex

# chapter file
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks0.yaml -o chapter-file0.tex
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks0.yaml,unprotect-blank-lines.yaml -o chapter-fileunprotect0.tex
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks12.yaml -o chapter-file12.tex
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks13.yaml,unprotect-blank-lines.yaml -o chapter-file13.tex
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks14.yaml,unprotect-blank-lines.yaml -o chapter-file14.tex

# chapter file with \par
latexindent.pl -m -s chapter-file-par.tex -l removeParaLineBreaks0.yaml -o chapter-file-par0.tex

# key equals value
latexindent.pl -m -s key-equals-value.tex -l removeParaLineBreaks0.yaml -o key-equals-value0.tex
latexindent.pl -m -s key-equals-value.tex -l removeParaLineBreaks15.yaml -o key-equals-value15.tex

# unnamed grouping braces
latexindent.pl -m -s unnamed-group-braces.tex -l removeParaLineBreaks0.yaml -o unnamed-group-braces0.tex

# the file that started this issue
latexindent.pl -m -s jowens-long-mod-4.tex -l removeParaLineBreaks0.yaml -o jowens-long-para0.tex -y="modifyLineBreaks:textWrapOptions:huge:wrap"

# test paragraph stop routine
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml -o jowens-short-multi-line-stop-mod0.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtCommands.yaml -o jowens-short-multi-line-stop-mod1.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,noStopParaAtEnvironments.yaml -o jowens-short-multi-line-stop-mod2.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtIfElseFi.yaml -o jowens-short-multi-line-stop-mod4.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtItem.yaml -o jowens-short-multi-line-stop-mod5.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtSpecial.yaml -o jowens-short-multi-line-stop-mod6.tex
# headings
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml -o jowens-short-multi-line-stop-mod7.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml,stopParaAtHeadings.yaml -o jowens-short-multi-line-stop-mod8.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml,stopParaAtHeadings.yaml,removeParaLineBreaks17.yaml   -o jowens-short-multi-line-stop-mod9.tex
# file contents
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtFileContents.yaml -o jowens-short-multi-line-stop-mod10.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtFileContents.yaml,removeParaLineBreaks16.yaml  -o jowens-short-multi-line-stop-mod11.tex
# double back slash
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,alignmentNotPriority.yaml -o jowens-short-multi-line-stop-mod12.tex
# heading
latexindent.pl -m -s jowens-follow-ups.tex -l removeParaLineBreaks0.yaml -o jowens-follow-ups-mod0.tex
latexindent.pl -m -s jowens-follow-ups.tex -l removeParaLineBreaks0.yaml,description.yaml -o jowens-follow-ups-mod1.tex
latexindent.pl -m -s jowens-follow-ups.tex -l removeParaLineBreaks0.yaml,description.yaml,stopParaAtComments.yaml -o jowens-follow-ups-mod2.tex
# bug reported at https://github.com/cmhughes/latexindent.pl/issues/90
latexindent.pl -m -s bug1 -o=+-mod0 -y="modifyLineBreaks:textWrapOptions:columns:3,modifyLineBreaks:textWrapOptions:huge:wrap"
# everything below is to do with the
# improvement to text wrap routine, requested at https://github.com/cmhughes/latexindent.pl/issues/103
latexindent.pl -m -s zoehneto.tex -l=zoehneto1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto.tex -l=zoehneto4.yaml -o=+-mod4
latexindent.pl -m -s zoehneto.tex -l=zoehneto5.yaml -o=+-mod5
latexindent.pl -m -s zoehneto.tex -l=zoehneto6.yaml -o=+-mod6
latexindent.pl -m -s zoehneto.tex -l=zoehneto7.yaml -o=+-mod7
latexindent.pl -m -s zoehneto.tex -l=zoehneto8.yaml -o=+-mod8
latexindent.pl -m -s zoehneto.tex -l=zoehneto9.yaml -o=+-mod9 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto.tex -l=zoehneto10.yaml -o=+-mod10

latexindent.pl -m -s zoehneto1.tex -l=zoehneto1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto1.tex -l=zoehneto2.yaml -o=+-mod2
latexindent.pl -m -s zoehneto2.tex -l=zoehneto3.yaml -o=+-mod3
latexindent.pl -m -s zoehneto1.tex -l=zoehneto4.yaml -o=+-mod4
latexindent.pl -m -s zoehneto1.tex -l=zoehneto5.yaml -o=+-mod5
latexindent.pl -m -s zoehneto1.tex -l=zoehneto6.yaml -o=+-mod6
latexindent.pl -m -s zoehneto1.tex -l=zoehneto7.yaml -o=+-mod7
latexindent.pl -m -s zoehneto1.tex -l=zoehneto8.yaml -o=+-mod8

latexindent.pl -m -s environments-nested-fourth.tex -l=env1 -o=+-mod1
latexindent.pl -m -s dbmrq -l=dbmrq1 -o=+-mod1
latexindent.pl -m -s zoehneto3.tex -l=zoehneto-config1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto4.tex -l=zoehneto11.yaml -o=+-mod11 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto4.tex -l=zoehneto12.yaml -o=+-mod12 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto4.tex -l=zoehneto13.yaml -o=+-mod13 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto4.tex -l=zoehneto14.yaml -o=+-mod14
latexindent.pl -m -s zoehneto4.tex -l=zoehneto15.yaml -o=+-mod15 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto4.tex -l=zoehneto16.yaml -o=+-mod16 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
# except test cases
latexindent.pl -m -s zoehneto3.tex -l=zoehneto17.yaml -o=+-mod17
latexindent.pl -m -s zoehneto3.tex -l=zoehneto18.yaml -o=+-mod18
latexindent.pl -m -s zoehneto3.tex -l=zoehneto19.yaml -o=+-mod19
latexindent.pl -m -s zoehneto3.tex -l=zoehneto20.yaml -o=+-mod20
# preamble
latexindent.pl -m -s zoehneto5.tex -l=zoehneto21.yaml -o=+-mod21
latexindent.pl -m -s zoehneto5.tex -l=zoehneto22.yaml -o=+-mod22
latexindent.pl -m -s zoehneto5.tex -l=zoehneto23.yaml -o=+-mod23
# suit of 'all' objects test cases
loopmax=47
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
   [[ $showCounter == 1 ]] && echo $i of $loopmax
latexindent.pl -m -s multi-object-all.tex -l=multi-object$i.yaml -o=+-mod$i
   [[ $silentMode == 0 ]] && set +x 
done

# https://github.com/cmhughes/latexindent.pl/issues/172, adds fields for break, huge for textwrap
latexindent.pl waschk.tex -s -m -l waschk.yaml -o=+-mod -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl waschk.tex -s -m -l waschk0.yaml -o=+-mod0
latexindent.pl waschk.tex -s -m -l waschk1.yaml -o=+-mod1

# https://github.com/cmhughes/latexindent.pl/issues/183
latexindent.pl -s -m -l issue-183-mod1.yaml issue-183.tex -o=+-mod1
latexindent.pl -s -m -l issue-183-mod2.yaml issue-183.tex -o=+-mod2
git status
[[ $noisyMode == 1 ]] && makenoise
