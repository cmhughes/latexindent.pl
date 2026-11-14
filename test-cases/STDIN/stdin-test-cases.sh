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

# issue 662: in text mode, as on Windows (emulated here with PERLIO=:unix:crlf),
# LF input from STDIN is written to STDOUT with LF line breaks
cat issue-662.tex | PERLIO=:unix:crlf latexindent.pl - > issue-662-mod1.tex

cat 713971.tex| latexindent.pl -s -o=713971-mod1 -

set +x 
wrapuptasks
