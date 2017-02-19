#!/bin/bash
loopmax=32
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s contributors.bib -o contributors-default.bib
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-vo-nameStartsOnOwnLine.bib -l=NameStartsOnOwnLineYes.yaml 
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-vo-nameStartsOnOwnLine-no.bib -l=NameStartsOnOwnLineNo.yaml,../commands/unprotect-blank-lines.yaml 
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-remove-line-breaks-vo-name-finishes-lb-mod1.bib -l=mand-args-Vo-mod1.yaml,../commands/unprotect-blank-lines.yaml,NameFinishesWithLineBreakYes.yaml 
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-remove-line-breaks-vo-name-finishes-lb-mod2.bib -l=mand-args-Vo-mod2.yaml,../commands/unprotect-blank-lines.yaml,NameFinishesWithLineBreakNo.yaml 
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-remove-line-breaks-vo-name-finishes-lb-mod3.bib -l=mand-args-Vo-mod1.yaml,../commands/unprotect-blank-lines.yaml,NameFinishesWithLineBreakNo.yaml 
latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-remove-line-breaks-vo-name-finishes-lb-mod4.bib -l=mand-args-Vo-mod2.yaml,../commands/unprotect-blank-lines.yaml,NameFinishesWithLineBreakYes.yaml 

# modifyLineBreaks experiments
[[ $silentMode == 0 ]] && set +x 
 for (( i=$loopmin ; i <= $loopmax ; i++ )) 
 do 
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    [[ $silentMode == 0 ]] && set -x 
    # just linebreak modification
    latexindent.pl -m -s contributors.bib -o contributors-vo-mod$i.bib -l=mand-args-Vo-mod$i.yaml 
    latexindent.pl -m -s contributors-remove-line-breaks.bib -o contributors-remove-line-breaks-vo-mod$i.bib -l=mand-args-Vo-mod$i.yaml,../commands/unprotect-blank-lines.yaml 
    [[ $silentMode == 0 ]] && set +x 
 done
# special characters
latexindent.pl -s special-characters.tex -m -l=mand-args-mod1.yaml,../filecontents/indentPreambleYes.yaml -o=special-characters-mod1.tex 
latexindent.pl -s special-characters-minimal.tex -o special-characters-minimal-default.tex
latexindent.pl -s special-characters-minimal-blank-lines.tex -o special-characters-minimal-blank-lines-default.tex -g=one.log
# m switch active
latexindent.pl -s -m special-characters-minimal-blank-lines.tex -o special-characters-minimal-blank-lines-m-switch.tex -l=noCondenseBlankLines.yaml -g=two.log
latexindent.pl -s -m special-characters-minimal-blank-lines.tex -o special-characters-minimal-blank-lines-m-switch-condense.tex
# legacy test case
latexindent.pl -s tikz3.tex -o tikz3-default.tex
latexindent.pl -s tikz4.tex -o tikz4-default.tex -l ../texexchange/indentPreamble.yaml
latexindent.pl -s tikz4.tex -o tikz4-no-add-global.tex -l ../texexchange/indentPreamble.yaml,noAddGlobNamed.yaml
git status
[[ $noisyMode == 1 ]] && makenoise
