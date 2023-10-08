#!/bin/bash
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s -w -l backup1.yaml -g one.log myfile
cp one.log backup-info1.txt
perl -p0i -e 's/.*?(Backup\sprocedure)/$1/s' backup-info1.txt
perl -p0i -e 's/INFO:.*//s' backup-info1.txt

latexindent.pl -s -w -l backup2.yaml -g two.log myfile
cp two.log backup-info2.txt
perl -p0i -e 's/.*?(Backup\sprocedure)/$1/s' backup-info2.txt
perl -p0i -e 's/INFO:.*//s' backup-info2.txt

set +x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
