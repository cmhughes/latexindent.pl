#!/bin/bash
. ../common.sh

openingtasks

if [ -d ~/Desktop/tmp/ ]; then
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -g=one.log
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -g=two.log 
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -l=more-than-one-back-up.yaml -g=three.log 
else
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -g=one.log
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -g=two.log 
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -l=more-than-one-back-up.yaml -g=three.log 
fi

# the directory of a file that does not exist is not created for the log file
tmpdir=$(mktemp -d)
latexindent.pl -s  $tmpdir/missing-dir/cruft-directory2.tex
echo "contents of the temporary directory:" > missing-directory.txt
ls $tmpdir >> missing-directory.txt

latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml -g=four.log 
latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml,noCycle.yaml -g=five.log 

set +x 
wrapuptasks
