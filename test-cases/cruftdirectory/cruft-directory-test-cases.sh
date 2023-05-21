#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

if [ -d ~/Desktop/tmp/ ]; then
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -g=one.log
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -g=two.log 
   latexindent.pl -s  cruft-directory1 -c ~/Desktop/tmp/ -w -l=more-than-one-back-up.yaml -g=three.log 
else
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -g=one.log
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -g=two.log 
   latexindent.pl -s  cruft-directory1 -c $(mktemp -d) -w -l=more-than-one-back-up.yaml -g=three.log 
fi

latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml -g=four.log 
latexindent.pl -s  cruft-directory1  -w -l=cycleThroughBackUps.yaml,noCycle.yaml -g=five.log 
[[ $gitStatus == 1 ]] && git status
