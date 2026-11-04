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

# --lines: lines that are not changed are not reported as changed
latexindent.pl -s -k --lines 2 environments-simple-nested.tex -g lines-switch-check.log
cp lines-switch-check.log lines-switch-check.txt
perl -p0i -e 's/.*?(INFO:\s*simple\sdiff)/$1/s' lines-switch-check.txt

latexindent.pl -s -wd --lines 2 environments-simple-nested.tex -g lines-switch-wd.log
cp lines-switch-wd.log lines-switch-wd.txt
perl -p0i -e 's/.*?(INFO:\s*\-wd)/$1/s' lines-switch-wd.txt

wrapuptasks
