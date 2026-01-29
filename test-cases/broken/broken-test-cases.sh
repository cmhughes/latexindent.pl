#!/bin/bash
loopmax=0
verbatimTest=1
. ../common.sh

openingtasks
latexindent.pl -s broken -o=+-mod1
latexindent.pl -s -l no-specials.yaml broken -o=+-mod2 -t 

egrep 'specialBeginEnd empty' indent.log > no-specials.txt
latexindent.pl -s ifnextchar -o=+-mod1 -l=com-name-special1.yaml

latexindent.pl -s broken1 -o=+-mod1 -t
egrep 'found:' indent.log > broken1.txt

latexindent.pl -s broken2 -o=+-mod1 -t
egrep 'found:' indent.log > broken2.txt

latexindent.pl -s broken3 -o=+-mod1 -t
egrep 'found:' indent.log > broken3.txt

set +x 
wrapuptasks
