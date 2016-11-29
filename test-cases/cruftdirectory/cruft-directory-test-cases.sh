#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  -tt cruft-directory1 -c ~/Desktop -w -g=one.log
latexindent.pl -s  -tt cruft-directory1 -c ~/Desktop -w -g=two.log 
latexindent.pl -s  -tt cruft-directory1 -c ~/Desktop -w -l=more-than-one-back-up.yaml -g=three.log 
git status
