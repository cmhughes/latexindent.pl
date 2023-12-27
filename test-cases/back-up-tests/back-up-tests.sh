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

latexindent.pl -s -wd -l backup2.yaml -g three.log myfile
cp three.log backup-info3.txt
perl -p0i -e 's/.*?(INFO:\s*\-wd)/$1/s' backup-info3.txt

latexindent.pl -w 新建.tex -g issue-505.log -y 'onlyOneBackUp:1'
cp issue-505.log issue-505.txt
perl -p0i -e 's/.*?(INFO:\s*Backup)/$1/s' issue-505.txt

set +x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
