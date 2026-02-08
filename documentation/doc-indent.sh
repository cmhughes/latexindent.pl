#!/bin/bash
. ../test-cases/common.sh

openingtasks

latexindent.pl -l=+mainfile.yaml -w -rv -m -s  latexindent.tex
latexindent.pl -w -rv -m -g tex-files.log -l -s s*.tex
latexindent.pl -w -rv -m -g bib-files.log -l bibsettings.yaml -s *.bib

set +x 
wrapuptasks
