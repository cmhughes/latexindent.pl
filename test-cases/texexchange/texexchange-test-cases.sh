#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
# =======  tabular tag  =========
# =======  tabular tag  =========
# =======  tabular tag  =========
latexindent.pl -s  2441-Bernard.tex -o  +-default.tex
latexindent.pl -s 31672-Werner.tex -o +-default.tex
latexindent.pl -s 31672-s1l3n0.tex -o +-default.tex
latexindent.pl -s 31672-Bernard.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-Tom-Bombadil.tex -o +-default.tex
latexindent.pl -s 112343-dcmst.tex -o +-default.tex -l indentPreamble.yaml,tcolorboxAlignDelims.yaml
latexindent.pl -s 112343-jon.tex -o +-default.tex -l indentPreamble.yaml -m 
latexindent.pl -s 112343-gekkostate.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-morbusg.tex -o +-default.tex -l indentPreamble.yaml,halignDelims.yaml
latexindent.pl -s 112343-gonzalo.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 112343-quinmars.tex -o +-default.tex -l indentPreamble.yaml -m

# =======  tikz tag  ========= 
# =======  tikz tag  =========
# =======  tikz tag  =========
latexindent.pl -s 74878.tex -o +-default.tex
latexindent.pl -s -l indentPreamble.yaml 350144.tex -o +-default.tex
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot.yaml 350144.tex -o +-default-ngp.tex 
latexindent.pl -s -l indentPreamble.yaml,nextGroupPlot-headings.yaml 350144.tex -o +-default-ngp-headings.tex 
latexindent.pl -s 5461.tex -o +-default.tex
# christmas tree
latexindent.pl -s 39149-alain.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-alain.tex -outputfile +-draw.tex -l indentPreamble.yaml,draw.yaml
latexindent.pl -s 39149-loop-space.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-loop-space.tex -outputfile +-no-add-named.tex -l indentPreamble.yaml,no-add-named-braces.yaml
latexindent.pl -s 39149-loop-space2.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-ruler-compass.sty -outputfile +-default.sty 
latexindent.pl -s 39149-jake.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-morbusg.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-mark-wibrow1.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-mark-wibrow2.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 39149-SztupY.tex -outputfile +-default.tex -l=indentPreamble.yaml,fine-tuning-args1
latexindent.pl -s 103863-kiss-my-armpit1.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 135683-kiss-my-armpit1.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 348-cmhughes1.tex -o=+-default.tex -l=indentPreamble.yaml
latexindent.pl -s 348-cmhughes2.tex -o=+-default.tex -l=indentPreamble.yaml
latexindent.pl -s 348-cmhughes2.tex -o=+-addplot-indent-rules.tex -l addplot3.yaml,indentPreamble.yaml
latexindent.pl -s 348-cmhughes1.tex -o=+-mod5.tex -m -l=348.yaml,indentPreamble.yaml
latexindent.pl -s 43884.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 104498.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 353493.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 49814.tex -o=+-default -y="indentPreamble:1"
latexindent.pl -s 49814-old.tex -o=+-default -y="indentPreamble:1" -l=fine-tune.yaml
latexindent.pl -s 571012.tex -o=+-default -l=fine-tune.yaml
latexindent.pl -s 571012.tex -o=+-mod1 -l=draw-filldraw.yaml
latexindent.pl -s 578179.tex -o=+-default
latexindent.pl -s 578179.tex -o=+-mod1 -y="defaultIndent:'  ';indentPreamble:1" -l 578179.yaml

# =======  pgfplots tag  =========
# =======  pgfplots tag  =========
# =======  pgfplots tag  =========
latexindent.pl -s 36297-jake.tex -outputfile 36297-jake-default.tex -l indentPreamble.yaml 
latexindent.pl -s 36297-patrick-hacker.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 52987-jake.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 52987-anton.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 46422-michi.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 29293-christian-feuersanger.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 29359-jake.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 29359-marco-daniel.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 29359-christian-feuersanger.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 31276-peter-grill.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 11368-jake.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 127375-jake.tex -outputfile +-default.tex -l indentPreamble.yaml
latexindent.pl -s 127375-thomas.tex -outputfile +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 12207-christian-feuersanger.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 12207-christian-feuersanger.tex -o +-pin-mlb1.tex -m -l mlb-pin.yaml,indentPreamble.yaml  
latexindent.pl -s 12207-jake.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 155194-andrew-swan.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352549.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 351457-CarLaTeX.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 351457-Andrew.tex -o +-default.tex -l indentPreamble.yaml,preambleCommandsBeforeEnvironments.yaml
latexindent.pl -s 352502.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352495.tex -o +-default.tex -l indentPreamble.yaml 
latexindent.pl -s 352396-Zarko1.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 354010.tex -o=+-default.tex -l indentPreamble.yaml

# =======  latex3/expl3 tag  =========
# =======  latex3/expl3 tag  =========
# =======  latex3/expl3 tag  =========
latexindent.pl -s 350642 -o +-default.tex 
latexindent.pl -s 353035 -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 253693 -o +-default.tex
latexindent.pl -s 253693-Sean-Allred.tex -o +-default.tex -local=indentPreamble.yaml
latexindent.pl -s -m 253693-Sean-Allred.tex -o +-mod1.tex -local=indentPreamble.yaml,253693.yaml,groupBeginEnd.yaml
latexindent.pl -s 253693-John-Kormylo -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 253693-Manuel -o +-default.tex -local indentPreamble.yaml
latexindent.pl -s 96768-A-Ellett.tex -o +-default.tex 
latexindent.pl -s 96768-A-Ellett.tex -o +-always-un-named.tex -l always-un-named.yaml
latexindent.pl -s 96768-egreg.tex -o +-default.tex 
latexindent.pl -s 96768-egreg.tex -o +-always-un-named.tex -l always-un-named.yaml
latexindent.pl -s 56294-will-robertson.tex -outputfile=+-default.tex
latexindent.pl -s 56294-will-robertson.tex -outputfile=+-groupBegEnd.tex -l=groupBeginEnd.yaml
latexindent.pl -s 56294-Ahmed-Musa.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 56294-Ahmed-Musa.tex -o +-groupBegEnd.tex -l indentPreamble.yaml,groupBeginEnd.yaml
latexindent.pl -s 56294-Ahmed-Musa2.tex -o +-default.tex -tt

# =======  macros tag  =========
# =======  macros tag  =========
# =======  macros tag  =========
latexindent.pl -s 353559-james-fennell.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-werner.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-egreg.tex -o +-default.tex -l indentPreamble.yaml
latexindent.pl -s 353559-egreg-1.tex -o +-default.tex -l indentPreamble.yaml

# =======  beamer tag  =========
# =======  beamer tag  =========
# =======  beamer tag  =========
latexindent.pl -s 158638-cmhughes.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s 158638-cmhughes.tex -o=+-items.tex -l indentPreamble.yaml,158638-cmhughes.yaml

# =======  multicolumn tag  =========
# =======  multicolumn tag  =========
# =======  multicolumn tag  =========
latexindent.pl -s 372580.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 371998.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 371998.tex -o=+-multicol5.tex -l ../alignment/multiColumnGrouping.yaml,../alignment/tabular5.yaml
latexindent.pl -s 371998.tex -o=+-multicol1.tex -l ../alignment/multiColumnGrouping1.yaml
latexindent.pl -s 371998.tex -o=+-multicol15.tex -l ../alignment/multiColumnGrouping1.yaml,../alignment/tabular5.yaml
latexindent.pl -s 371998-heiko.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 371319.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 369242.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 368176.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 367696.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 367278.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 366841-zarko.tex -o=+-out.tex -l=longtabu.yaml
latexindent.pl -s 365928.tex -o=+-default.tex 
latexindent.pl -s 365928.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 365901.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 365620.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 364871.tex -o=+-default.tex -m
# perhaps the script should do better with the next one? I'm not sure...
latexindent.pl -s 364871.tex -o=+-multicol.tex -m -l ../alignment/multiColumnGrouping.yaml 
latexindent.pl -s 364071.tex -o=+-default.tex -l ../filecontents/indentPreambleYes.yaml
latexindent.pl -s 364071.tex -o=+-multicol.tex -l tabu.yaml,../filecontents/indentPreambleYes.yaml
latexindent.pl -s 359791.tex -o=+-default.tex 
latexindent.pl -s 359791.tex -o=+-multicol.tex -l longtable.yaml
latexindent.pl -s 359294.tex -o=+-multicol.tex -l tabularx.yaml
latexindent.pl -s 349480.tex -o=+-default.tex
latexindent.pl -s 349480.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 348102.tex -o=+-default.tex
latexindent.pl -s 348102.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 348102-mod.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 347155.tex -o=+-default.tex
latexindent.pl -s 347155.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 345211.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 342914.tex -o=+-default.tex 
latexindent.pl -s 342914.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 342697.tex -o=+-default.tex 
latexindent.pl -s 342697.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 342679.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 342288.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 340141.tex -o=+-multicol.tex -l tabularx.yaml
latexindent.pl -s 335633.tex -o=+-default.tex
latexindent.pl -s 335633.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 333469.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 333469.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 331415.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 330385.tex -o=+-multicol.tex -l ../alignment/multiColumnGrouping.yaml
latexindent.pl -s 329346.tex -o=+-multicol.tex -l tabularstar.yaml -m
# page 7 of multicolumn tag below here

# =======  tabular tag  =========
# =======  tabular tag  =========
# =======  tabular tag  =========
latexindent.pl -s 248166.tex -o=+-out.tex 
latexindent.pl -s 141087.tex -o=+-out.tex -l=pgfplotstableread.yaml

# =======  no specific tag =========
# =======  no specific tag =========
# =======  no specific tag =========
latexindent.pl -s 587491.tex -o=+-default.tex 
latexindent.pl -s 627902.tex -o=+-mod1.tex -l 627902.yaml

# =======  not from tex exchange, but seemed appropriate here  =========
# =======  not from tex exchange, but seemed appropriate here  =========
# =======  not from tex exchange, but seemed appropriate here  =========
latexindent.pl -s pcc-pr.tex -o=+-default.tex -l indentPreamble.yaml
latexindent.pl -s pcc-pr-presentation.tex -o=pcc-pr-presentation-default.tex -l indentPreamble.yaml
latexindent.pl -s pcc-pr.tex -o=+-max-indentation -l indentPreamble.yaml,../environments/max-indentation1.yaml

latexindent.pl -s 645096.tex -o=+-default
latexindent.pl -s 645096.tex -l 645096.yaml -o=+-mod1

latexindent.pl -m -s 667013.tex -l 667013 -o=+-mod1

latexindent.pl -s -l 709049.yaml -m 709049.tex -o=+-mod1
latexindent.pl -s -l 709049a.yaml -m 709049.tex -o=+-mod2

latexindent.pl -s -rv -l 83663.yaml 83663.tex -o=+-mod1
[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status
