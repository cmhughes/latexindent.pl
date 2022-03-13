#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s whitespace -l=remove-TWS.yaml -o +-rm-yes
latexindent.pl -s whitespace -l=remove-TWS1.yaml -o +-rm-no

[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
