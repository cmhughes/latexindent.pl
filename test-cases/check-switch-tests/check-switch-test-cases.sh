#!/bin/bash
. ../common.sh
openingtasks

# a misspelt switch is an error (exit code 8), and no indentation is done
latexindent.pl --chek -s verbatim1.tex > unknown-switch.txt 2>&1
echo "exit code: $?" >> unknown-switch.txt

set +x
for file in *.tex
do
   keepappendinglogfile
   latexindent.pl --check -s -w $file && echo "latexindent.pl check passed for $file (file unchanged by latexindent.pl)"
   set +x
done
keepappendinglogfile
set +x 
wrapuptasks
