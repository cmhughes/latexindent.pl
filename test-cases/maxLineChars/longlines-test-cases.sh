#!/bin/bash
loopmax=5
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# proof of concept
latexindent.pl -s long-lines1.tex -o long-lines1-default.tex
latexindent.pl -s long-lines2.tex -o long-lines2-default.tex

# the issue that motivated this pursuit  https://github.com/cmhughes/latexindent.pl/issues/33
latexindent.pl -s jowens-short.tex -o jowens-short-mod-4.tex -l=text-wrap-4.yaml -m
latexindent.pl -s jowens-long.tex -o jowens-long-mod-4.tex -l=text-wrap-4.yaml -m

# long lines test cases
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
    # basic tests
    latexindent.pl -s long-lines1.tex -o long-lines1-mod-$i.tex -l=text-wrap-$i.yaml -m
    latexindent.pl -s long-lines2.tex -o long-lines2-mod-$i.tex -l=text-wrap-$i.yaml -m
    latexindent.pl -s long-lines3.tex -o long-lines3-mod-$i.tex -l=text-wrap-$i.yaml -m 
   [[ $silentMode == 0 ]] && set +x 
done

# verbatim
latexindent.pl -s -m verbatim-long-lines.tex -o verbatim-long-lines-mod1.tex -l=text-wrap-1.yaml

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
latexindent.pl -m -s jowens-long-mod-4.tex -l removeParaLineBreaks0.yaml -o jowens-long-para0.tex

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

git status
[[ $noisyMode == 1 ]] && makenoise
