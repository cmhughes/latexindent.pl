#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
# =======  tabular tag  =========
# =======  tabular tag  =========
# =======  tabular tag  =========
latexindent.pl -s  2441-Bernard.tex -o  2441-Bernard-default.tex
latexindent.pl -s 31672-Werner.tex -o 31672-Werner-default.tex
latexindent.pl -s 31672-s1l3n0.tex -o 31672-s1l3n0-default.tex
latexindent.pl -s 31672-Bernard.tex -o 31672-Bernard-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-Tom-Bombadil.tex -o 112343-Tom-Bombadil-default.tex
latexindent.pl -s 112343-dcmst.tex -o 112343-dcmst-default.tex -l indentPreamble.yaml,tcolorboxAlignDelims.yaml
latexindent.pl -s 112343-jon.tex -o 112343-jon-default.tex -l indentPreamble.yaml -m 
latexindent.pl -s 112343-gekkostate.tex -o 112343-gekkostate-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-morbusg.tex -o 112343-morbusg-default.tex -l indentPreamble.yaml,halignDelims.yaml
latexindent.pl -s 112343-gonzalo.tex -o 112343-gonzalo-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-quinmars.tex -o 112343-quinmars-default.tex -l indentPreamble.yaml -m

# =======  tikz tag  ========= 
# =======  tikz tag  =========
# =======  tikz tag  =========
latexindent.pl -s 74878.tex -o 74878-default.tex
latexindent.pl -s -l indentPreamble.yaml 350144.tex -o 350144-default.tex
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot.yaml 350144.tex -o 350144-default-ngp.tex 
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot-headings.yaml 350144.tex -o 350144-default-ngp-headings.tex 
latexindent.pl -s 5461.tex -o 5461-default.tex
# christmas tree
latexindent.pl -s 39149-alain.tex -outputfile 39149-alain-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-alain.tex -outputfile 39149-alain-draw.tex -l indentPreamble.yaml,draw.yaml
latexindent.pl -s 39149-loop-space.tex -outputfile 39149-loop-space-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-loop-space.tex -outputfile 39149-loop-space-no-add-named.tex -l indentPreamble.yaml,no-add-named-braces.yaml
latexindent.pl -s 39149-loop-space2.tex -outputfile 39149-loop-space2-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-ruler-compass.sty -outputfile 39149-ruler-compass-default.sty 
latexindent.pl -s 39149-jake.tex -outputfile 39149-jake-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-morbusg.tex -outputfile 39149-morbusg-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-mark-wibrow1.tex -outputfile 39149-mark-wibrow1-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-mark-wibrow2.tex -outputfile 39149-mark-wibrow2-default.tex -l indentPreamble.yaml
#latexindent.pl -s 39149-SztupY.tex -outputfile 39149-SztupY-default.tex -l indentPreamble.yaml
latexindent.pl -s 103863-kiss-my-armpit1.tex -o=103863-kiss-my-armpit1-default.tex -l indentPreamble.yaml
latexindent.pl -s 135683-kiss-my-armpit1.tex -o=135683-kiss-my-armpit1-default.tex -l indentPreamble.yaml
latexindent.pl -s 348-cmhughes1.tex -o=348-cmhughes1-default.tex -l=indentPreamble.yaml
latexindent.pl -s 348-cmhughes2.tex -o=348-cmhughes2-default.tex -l=indentPreamble.yaml
latexindent.pl -s 348-cmhughes2.tex -o=348-cmhughes2-addplot-indent-rules.tex -l addplot3.yaml,indentPreamble.yaml
latexindent.pl -s 348-cmhughes1.tex -o=348-cmhughes1-mod5.tex -m -l=348.yaml,indentPreamble.yaml
latexindent.pl -s 43884.tex -o=43884-default.tex -l indentPreamble.yaml
latexindent.pl -s 104498.tex -o=104498-default.tex -l indentPreamble.yaml
latexindent.pl -s 353493.tex -o=353493-default.tex -l indentPreamble.yaml

# =======  pgfplots tag  =========
# =======  pgfplots tag  =========
# =======  pgfplots tag  =========
latexindent.pl -s 36297-jake.tex -outputfile 36297-jake-default.tex -l indentPreamble.yaml 
latexindent.pl -s 36297-patrick-hacker.tex -outputfile 36297-patrick-hacker-default.tex -l indentPreamble.yaml 
latexindent.pl -s 52987-jake.tex -outputfile 52987-jake-default.tex -l indentPreamble.yaml 
latexindent.pl -s 52987-anton.tex -outputfile 52987-anton-default.tex -l indentPreamble.yaml 
latexindent.pl -s 46422-michi.tex -outputfile 46422-michi-default.tex -l indentPreamble.yaml 
latexindent.pl -s 29293-christian-feuersanger.tex -outputfile 29293-christian-feuersanger-default.tex -l indentPreamble.yaml 
latexindent.pl -s 29359-jake.tex -outputfile 29359-jake-default.tex -l indentPreamble.yaml
latexindent.pl -s 29359-marco-daniel.tex -outputfile 29359-marco-daniel-default.tex -l indentPreamble.yaml
latexindent.pl -s 29359-christian-feuersanger.tex -outputfile 29359-christian-feuersanger-default.tex -l indentPreamble.yaml
latexindent.pl -s 31276-peter-grill.tex -outputfile 31276-peter-grill-default.tex -l indentPreamble.yaml
latexindent.pl -s 11368-jake.tex -outputfile 11368-jake-default.tex -l indentPreamble.yaml
latexindent.pl -s 127375-jake.tex -outputfile 127375-jake-default.tex -l indentPreamble.yaml
latexindent.pl -s 127375-thomas.tex -outputfile 127375-thomas-default.tex -l indentPreamble.yaml 
latexindent.pl -s 12207-christian-feuersanger.tex -o 12207-christian-feuersanger-default.tex -l indentPreamble.yaml 
latexindent.pl -s 12207-christian-feuersanger.tex -o 12207-christian-feuersanger-pin-mlb1.tex -m -l mlb-pin.yaml,indentPreamble.yaml  
latexindent.pl -s 12207-jake.tex -o 12207-jake-default.tex -l indentPreamble.yaml 
latexindent.pl -s 155194-andrew-swan.tex -o 155194-andrew-swan-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352549.tex -o 352549-default.tex -l indentPreamble.yaml 
latexindent.pl -s 351457-CarLaTeX.tex -o 351457-CarLaTeX-default.tex -l indentPreamble.yaml 
latexindent.pl -s 351457-Andrew.tex -o 351457-Andrew-default.tex -l indentPreamble.yaml,preambleCommandsBeforeEnvironments.yaml
latexindent.pl -s 352502.tex -o 352502-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352495.tex -o 352495-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352396-Zarko1.tex -o 352396-Zarko1-default.tex -l indentPreamble.yaml
latexindent.pl -s 354010.tex -o=354010-default.tex -l indentPreamble.yaml

# =======  latex3/expl3 tag  =========
# =======  latex3/expl3 tag  =========
# =======  latex3/expl3 tag  =========
latexindent.pl -s 350642 -o 350642-default.tex 
latexindent.pl -s 353035 -o 353035-default.tex -l indentPreamble.yaml
latexindent.pl -s 253693 -o 253693-default.tex
latexindent.pl -s 253693-Sean-Allred.tex -o 253693-Sean-Allred-default.tex -local=indentPreamble.yaml
latexindent.pl -s -m 253693-Sean-Allred.tex -o 253693-Sean-Allred-mod1.tex -local=indentPreamble.yaml,253693.yaml,groupBeginEnd.yaml
latexindent.pl -s 253693-John-Kormylo -o 253693-John-Kormylo-default.tex -l indentPreamble.yaml
latexindent.pl -s 253693-Manuel -o 253693-Manuel-default.tex -local indentPreamble.yaml
latexindent.pl -s 96768-A-Ellett.tex -o 96768-A-Ellett-default.tex 
latexindent.pl -s 96768-A-Ellett.tex -o 96768-A-Ellett-always-un-named.tex -l always-un-named.yaml
latexindent.pl -s 96768-egreg.tex -o 96768-egreg-default.tex 
latexindent.pl -s 96768-egreg.tex -o 96768-egreg-always-un-named.tex -l always-un-named.yaml
latexindent.pl -s 56294-will-robertson.tex -outputfile=56294-will-robertson-default.tex
latexindent.pl -s 56294-will-robertson.tex -outputfile=56294-will-robertson-groupBegEnd.tex -l=groupBeginEnd.yaml
latexindent.pl -s 56294-Ahmed-Musa.tex -o 56294-Ahmed-Musa-default.tex -l indentPreamble.yaml
latexindent.pl -s 56294-Ahmed-Musa.tex -o 56294-Ahmed-Musa-groupBegEnd.tex -l indentPreamble.yaml,groupBeginEnd.yaml
latexindent.pl -s 56294-Ahmed-Musa2.tex -o 56294-Ahmed-Musa2-default.tex -tt

# =======  macros tag  =========
# =======  macros tag  =========
# =======  macros tag  =========
latexindent.pl -s 353559-james-fennell.tex -o 353559-james-fennell-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-werner.tex -o 353559-werner-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-egreg.tex -o 353559-egreg-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-egreg-1.tex -o 353559-egreg-1-default.tex -l indentPreamble.yaml

# =======  beamer tag  =========
# =======  beamer tag  =========
# =======  beamer tag  =========
latexindent.pl -s 158638-cmhughes.tex -o=158638-cmhughes-default.tex -l indentPreamble.yaml
latexindent.pl -s 158638-cmhughes.tex -o=158638-cmhughes-items.tex -l indentPreamble.yaml,158638-cmhughes.yaml

# =======  not from tex exchange, but seemed appropriate here  =========
# =======  not from tex exchange, but seemed appropriate here  =========
# =======  not from tex exchange, but seemed appropriate here  =========
latexindent.pl -s pcc-pr.tex -o=pcc-pr-default.tex -l indentPreamble.yaml
latexindent.pl -s pcc-pr-presentation.tex -o=pcc-pr-presentation-default.tex -l indentPreamble.yaml
git status
