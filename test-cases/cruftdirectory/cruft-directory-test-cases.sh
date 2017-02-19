#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s  cruft-directory1 -c ~/Desktop -w -g=one.log
latexindent.pl -s  cruft-directory1 -c ~/Desktop -w -g=two.log 
latexindent.pl -s  cruft-directory1 -c ~/Desktop -w -l=more-than-one-back-up.yaml -g=three.log 
latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml -g=four.log 
latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml,noCycle.yaml -g=five.log 
git status
