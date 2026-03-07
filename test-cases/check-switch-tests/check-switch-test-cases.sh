#!/bin/bash
. ../common.sh
openingtasks

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
