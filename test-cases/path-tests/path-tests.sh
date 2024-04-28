#!/bin/bash
loopmax=3
verbatimTest=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s -l nested-paths1.yaml mwe.tex 
cp indent.log path-test1.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test1.txt
perl -p0i -e 's/INFO:.*//s' path-test1.txt

latexindent.pl -s -l nested-paths2.yaml mwe.tex -o=+-mod2
cp indent.log path-test2.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test2.txt
perl -p0i -e 's/INFO:.*//s' path-test2.txt

latexindent.pl -s -l nested-paths3.yaml mwe.tex -o=+-mod3
cp indent.log path-test3.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test3.txt
perl -p0i -e 's/INFO:.*//s' path-test3.txt

latexindent.pl -s -l nested-paths4.yaml mwe.tex -o=+-mod4
cp indent.log path-test4.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test4.txt
perl -p0i -e 's/INFO:.*//s' path-test4.txt

latexindent.pl -s -l nested-paths5.yaml mwe.tex -o=+-mod5
cp indent.log path-test5.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test5.txt
perl -p0i -e 's/INFO:.*//s' path-test5.txt

latexindent.pl -s -l nested-paths6.yaml mwe.tex -o=+-mod6
cp indent.log path-test6.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test6.txt
perl -p0i -e 's/INFO:.*//s' path-test6.txt

latexindent.pl -s -l nested-paths7.yaml mwe.tex -o=+-mod7
cp indent.log path-test7.txt
perl -p0i -e 's/.*?(YAML\ssettings, reading)/$1/s' path-test7.txt
perl -p0i -e 's/INFO:.*//s' path-test7.txt

set +x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
