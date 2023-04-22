#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=48
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

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

[[ $silentMode == 0 ]] && set +x 
[[ $noisyMode == 1 ]] && makenoise
[[ $gitStatus == 1 ]] && git status
