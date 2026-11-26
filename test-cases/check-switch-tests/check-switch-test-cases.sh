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

# -kv diff output
latexindent.pl -s -m -kv diff-trailing-blank-lines.tex -g diff-trailing-blank-lines.log
latexindent.pl -s -kv diff-hunks.tex -y "defaultIndent: ' '" -g diff-hunks.log
latexindent.pl -s -r -kv diff-replacements.tex -l diff-replacements.yaml -g diff-replacements.log
latexindent.pl -s -m -r -kv diff-replacements.tex -l diff-replacements.yaml -g diff-replacements-m.log
for name in diff-trailing-blank-lines diff-hunks diff-replacements diff-replacements-m
do
   cp $name.log $name.txt
   perl -p0i -e 's/.*?(simple\sdiff)/$1/s' $name.txt
   perl -p0i -e 's/INFO:.*//s' $name.txt
done

set +x 

# --lines: lines that are not changed are not reported as changed
latexindent.pl -s -k --lines 2 environments-simple-nested.tex -g lines-switch-check.log
cp lines-switch-check.log lines-switch-check.txt
perl -p0i -e 's/.*?(INFO:\s*simple\sdiff)/$1/s' lines-switch-check.txt

latexindent.pl -s -wd --lines 2 environments-simple-nested.tex -g lines-switch-wd.log
cp lines-switch-wd.log lines-switch-wd.txt
perl -p0i -e 's/.*?(INFO:\s*\-wd)/$1/s' lines-switch-wd.txt

wrapuptasks
