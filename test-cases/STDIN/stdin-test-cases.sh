#!/bin/bash
. ../common.sh

openingtasks
cat myfile.tex | latexindent.pl -s -o=myfile-default 
cat myfile.tex | latexindent.pl -s -o=myfile-default -l=dontMeasure.yaml -

# issue 493
cat issue-493.tex| latexindent.pl -s -m -l latexindent.yaml -o=issue-493-mod1 -
latexindent.pl -s -l -m -o=+-mod2 issue-493.tex 
cat issue-493.tex| latexindent.pl -s -m -l issue-493a.yaml -o=issue-493-mod3 -

cat issue-528.tex| latexindent.pl -s -o=issue-528-mod1 -
cat 713971.tex| latexindent.pl -s -o=713971-mod1 -

# -o=++ needs an input file name, so it is ignored for STDIN (and no file called .tex is written)
cat myfile.tex | latexindent.pl -s -o=++ - -g stdin-plusplus.log
egrep 'WARN|ignoring' stdin-plusplus.log > stdin-plusplus.txt
ls -a | grep -x '\.tex' >> stdin-plusplus.txt
rm -f .tex

set +x 
wrapuptasks
