#!/bin/bash
loopmax=0
verbatimTest=1
. ../common.sh

openingtasks

# =======  tabular tag  =========
latexindent.pl -s  2441-Bernard -o +-default
latexindent.pl -s 31672-Werner -o +-default
latexindent.pl -s 31672-s1l3n0 -o +-default
latexindent.pl -s 31672-Bernard -o +-default -l indentPreamble
latexindent.pl -s 112343-Tom-Bombadil -l 112343.yaml -o +-mod1
latexindent.pl -s 112343-dcmst -o +-default -l indentPreamble,tcolorboxAlignDelims
latexindent.pl -s 112343-jon -o +-default -l indentPreamble -m 
latexindent.pl -s 112343-gekkostate -o +-default -l indentPreamble
latexindent.pl -s 112343-morbusg -o +-default -l indentPreamble,halignDelims
latexindent.pl -s 112343-gonzalo -o +-default -l indentPreamble
latexindent.pl -s 112343-quinmars -o +-default -l indentPreamble,112343 -m

# =======  tikz tag  =========
latexindent.pl -s 74878 -o +-default
latexindent.pl -s -l indentPreamble 350144 -o +-default
latexindent.pl -s -l indentPreamble,nextGroupPlot 350144 -o +-default-ngp -t
cp indent.log nextgroupplot.txt
perl -p0i -e 's/.*?(WARN:\s*Obsolete)/$1/s' nextgroupplot.txt
perl -p0i -e 's/INFO:.*//s' nextgroupplot.txt
latexindent.pl -s -l indentPreamble,nextGroupPlot-headings 350144 -o +-default-ngp-headings 
latexindent.pl -s 5461 -o +-default

# christmas tree
latexindent.pl -s 39149-alain -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-alain -outputfile +-draw -l indentPreamble,draw
latexindent.pl -s 39149-alain -outputfile +-draw1 -l indentPreamble,draw1 -t
egrep 'found: ' indent.log > 39149.txt
latexindent.pl -s 39149-loop-space -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-loop-space -outputfile +-no-add-named -l indentPreamble,no-add-named-braces
latexindent.pl -s 39149-loop-space2 -outputfile +-default -l indentPreamble,beamer
latexindent.pl -s 39149-ruler-compass.sty -outputfile +-default.sty -l beamer
latexindent.pl -s 39149-jake -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-morbusg -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-mark-wibrow1 -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-mark-wibrow2 -outputfile +-default -l indentPreamble
latexindent.pl -s 39149-SztupY -outputfile +-default -l=indentPreamble,fine-tuning-args1
latexindent.pl -s 103863-kiss-my-armpit1 -o=+-default -l indentPreamble,pstricks
latexindent.pl -s 135683-kiss-my-armpit1 -o=+-default -l indentPreamble,pstricks
latexindent.pl -s 348-cmhughes1 -o=+-default -l=indentPreamble,pstricks
latexindent.pl -s 348-cmhughes2 -o=+-default -l=indentPreamble
latexindent.pl -s 348-cmhughes2 -o=+-addplot-indent-rules -l addplot3,indentPreamble
latexindent.pl -s 348-cmhughes1 -o=+-mod5 -m -l=348,indentPreamble,pstricks
latexindent.pl -s 43884 -o=+-default -l indentPreamble,round-brackets-args
latexindent.pl -s 104498 -o=+-default -l indentPreamble
latexindent.pl -s 353493 -o=+-default -l indentPreamble
latexindent.pl -s 49814 -o=+-default -y="indentPreamble:1" -l round-brackets-args
latexindent.pl -s 49814-old -o=+-default -y="indentPreamble:1" -l=round-brackets-args
latexindent.pl -s 571012 -o=+-default -l=fine-tune
latexindent.pl -s 571012 -o=+-mod1 -l=draw-filldraw
latexindent.pl -s 578179 -o=+-default 
latexindent.pl -s 578179 -o=+-mod1 -y="defaultIndent:'  ';indentPreamble:1" -l 578179,nextGroupPlot

# =======  pgfplots tag  =========
latexindent.pl -s 36297-jake -outputfile 36297-jake-default -l indentPreamble 
latexindent.pl -s 36297-patrick-hacker -outputfile +-default -l indentPreamble 
latexindent.pl -s 52987-jake -outputfile +-default -l indentPreamble 
latexindent.pl -s 52987-anton -outputfile +-default -l indentPreamble 
latexindent.pl -s 46422-michi -outputfile +-default -l indentPreamble 
latexindent.pl -s 29293-christian-feuersanger -outputfile +-default -l indentPreamble 
latexindent.pl -s 29359-jake -outputfile +-default -l indentPreamble
latexindent.pl -s 29359-marco-daniel -outputfile +-default -l indentPreamble
latexindent.pl -s 29359-christian-feuersanger -outputfile +-default -l indentPreamble
latexindent.pl -s 31276-peter-grill -outputfile +-default -l indentPreamble
latexindent.pl -s 11368-jake -outputfile +-default -l indentPreamble
latexindent.pl -s 127375-jake -outputfile +-default -l indentPreamble
latexindent.pl -s 127375-thomas -outputfile +-default -l indentPreamble 
latexindent.pl -s 12207-christian-feuersanger -o +-default -l indentPreamble
latexindent.pl -s 12207-christian-feuersanger -o +-pin-mlb1 -m -l mlb-pin,indentPreamble  
latexindent.pl -s 12207-jake -o +-default -l indentPreamble 
latexindent.pl -s 155194-andrew-swan -o +-default -l indentPreamble 
latexindent.pl -s 352549 -o +-default -l indentPreamble 
latexindent.pl -s 351457-CarLaTeX -o +-default -l indentPreamble,round-brackets-args
latexindent.pl -s 351457-Andrew -o +-default -l indentPreamble,preambleCommandsBeforeEnvironments
latexindent.pl -s 352502 -o +-default -l indentPreamble 
latexindent.pl -s 352495 -o +-default -l indentPreamble 
latexindent.pl -s 352396-Zarko1 -o +-default -l indentPreamble
latexindent.pl -s 354010 -o=+-default -l indentPreamble

# =======  latex3/expl3 tag  =========
latexindent.pl -s 350642 -o +-default 
latexindent.pl -s 353035 -o +-default -l indentPreamble
latexindent.pl -s 253693 -o +-default -l eq-bet-args -t
egrep 'found: ' indent.log > 253693.txt
latexindent.pl -s 253693-Sean-Allred -o +-default -local=indentPreamble
latexindent.pl -s -m 253693-Sean-Allred -o +-mod1 -local=indentPreamble,253693,groupBeginEnd
latexindent.pl -s 253693-John-Kormylo -o +-default -l indentPreamble
latexindent.pl -s 253693-Manuel -o +-default -local indentPreamble
latexindent.pl -s 96768-A-Ellett -o +-default 
latexindent.pl -s 96768-A-Ellett -o +-always-un-named -l always-un-named
latexindent.pl -s 96768-egreg -o +-default 
latexindent.pl -s 96768-egreg -o +-always-un-named -l always-un-named
latexindent.pl -s 56294-will-robertson -outputfile=+-default
latexindent.pl -s 56294-will-robertson -outputfile=+-groupBegEnd -l=groupBeginEnd
latexindent.pl -s 56294-Ahmed-Musa -o +-default -l indentPreamble
latexindent.pl -s 56294-Ahmed-Musa -o +-groupBegEnd -l indentPreamble,groupBeginEnd
latexindent.pl -s 56294-Ahmed-Musa2 -o +-default

# =======  macros tag  =========
latexindent.pl -s 353559-james-fennell -o +-default -l indentPreamble
latexindent.pl -s 353559-werner -o +-default -l indentPreamble
latexindent.pl -s 353559-egreg -o +-default -l indentPreamble
latexindent.pl -s 353559-egreg-1 -o +-default -l indentPreamble

# =======  beamer tag  =========
latexindent.pl -s 158638-cmhughes -o=+-default -l indentPreamble
latexindent.pl -s 158638-cmhughes -o=+-items -l indentPreamble,158638-cmhughes

# =======  multicolumn tag  =========
latexindent.pl -s 372580 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 371998 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 371998 -o=+-multicol5 -l ../alignment/multiColumnGrouping,../alignment/tabular5
latexindent.pl -s 371998 -o=+-multicol1 -l ../alignment/multiColumnGrouping1
latexindent.pl -s 371998 -o=+-multicol15 -l ../alignment/multiColumnGrouping1,../alignment/tabular5
latexindent.pl -s 371998-heiko -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 371319 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 369242 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 368176 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 367696 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 367278-min -o=+-mod1 
latexindent.pl -s 367278 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 366841-zarko -o=+-out -l=longtabu
latexindent.pl -s 365928 -o=+-default 
latexindent.pl -s 365928 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 365901 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 365620 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 364871 -o=+-default -m
# perhaps the script should do better with the next one? I'm not sure...
latexindent.pl -s 364871 -o=+-multicol -m -l ../alignment/multiColumnGrouping 
latexindent.pl -s 364071 -o=+-default -l ../filecontents/indentPreambleYes,longtabu
latexindent.pl -s 364071 -o=+-multicol -l tabu,../filecontents/indentPreambleYes,longtabu
latexindent.pl -s 359791 -o=+-default 
latexindent.pl -s 359791 -o=+-multicol -l longtable
latexindent.pl -s 359294 -o=+-multicol -l tabularx
latexindent.pl -s 349480 -o=+-default -l at-bet-args
latexindent.pl -s 349480 -o=+-multicol -l ../alignment/multiColumnGrouping,at-bet-args
latexindent.pl -s 348102 -o=+-default
latexindent.pl -s 348102 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 348102-mod -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 347155 -o=+-default
latexindent.pl -s 347155 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 345211 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 342914 -o=+-default 
latexindent.pl -s 342914 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 342697 -o=+-default 
latexindent.pl -s 342697 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 342679 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 342288 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 340141 -o=+-multicol -l tabularx
latexindent.pl -s 335633 -o=+-default
latexindent.pl -s 335633 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 333469 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 333469 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 331415 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 330385-min -o=+-mod1
latexindent.pl -s 330385 -o=+-multicol -l ../alignment/multiColumnGrouping
latexindent.pl -s 329346 -o=+-multicol -l tabularstar -m
# page 7 of multicolumn tag below here

# =======  tabular tag  =========
latexindent.pl -s 248166 -o=+-out 
latexindent.pl -s 141087 -o=+-out -l=pgfplotstableread

# =======  no specific tag =========
latexindent.pl -s 587491 -o=+-mod1 
latexindent.pl -s 587491 -o=+-mod2 -l sizefeatures
latexindent.pl -s 627902 -o=+-mod1 -l 627902

latexindent.pl -s 645096 -o=+-default
latexindent.pl -s 645096 -l 645096 -o=+-mod1

# =======  not from tex exchange, but seemed appropriate here  =========
latexindent.pl -s pcc-pr -o=+-default -l indentPreamble
latexindent.pl -s pcc-pr-presentation -o=pcc-pr-presentation-default -l indentPreamble
latexindent.pl -s pcc-pr -o=+-max-indentation -l indentPreamble,../environments/max-indentation1

latexindent.pl -m -s 667013 -l 667013 -o=+-mod1

latexindent.pl -s -l 709049 -m 709049 -o=+-mod1
latexindent.pl -s -l 709049a -m 709049 -o=+-mod2

latexindent.pl -s -rv -l 83663 83663 -o=+-mod1

latexindent.pl -s broken -o=+-mod1

latexindent.pl -s -m -l tex-fmt-issue-32 tex-fmt-issue-32 -o=+-mod1
latexindent.pl -s -l tex-fmt-issue-72.yaml tex-fmt-issue-72.tex -o=+-mod1
latexindent.pl -s -m -l tex-fmt-issue-74 tex-fmt-issue-74 -o=+-mod1
latexindent.pl -s tex-fmt-issue-85.tex -o=+-mod1
latexindent.pl -s -r -l tex-fmt-issue-88.yaml tex-fmt-issue-88.tex -o=+-mod1
latexindent.pl -s -l tex-fmt-issue-107.yaml tex-fmt-issue-107.tex -o=+-mod1
latexindent.pl -s tex-fmt-issue-114 -o=+-mod1
latexindent.pl -s tex-fmt-issue-114a -o=+-mod1
latexindent.pl -s -l tex-fmt-issue-120.yaml tex-fmt-issue-120.tex -o=+-mod1
latexindent.pl -s tex-fmt-issue-121 -o=+-mod1
latexindent.pl -s tex-fmt-issue-124 -o=+-mod1

set +x 
wrapuptasks
