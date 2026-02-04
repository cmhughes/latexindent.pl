#!/bin/bash
. ../common.sh

openingtasks

# diacritics, https://github.com/cmhughes/latexindent.pl/pull/439
latexindent.pl -s -w äö.tex -g diacritics0.log
latexindent.pl -s -w äö/äö.tex 
latexindent.pl -s äö.tex -l äö.yaml -g diacritics.log
latexindent.pl -s äö.tex -l äö.yaml -g diacritics1.log -o=+-mod1
latexindent.pl -s äö.tex -l äö.yaml -g diacritics2.log -o=+-mod2 -c ./äö
latexindent.pl -s äö.tex -l äö.yaml -g äö-log-file.log -o=+-mod3 -c ./äö
latexindent.pl -s äö.tex -l äö.yaml -g diacritics3.log -o=+-äö1
latexindent.pl -s -w ěščřž/test.tex

set +x 
wrapuptasks
