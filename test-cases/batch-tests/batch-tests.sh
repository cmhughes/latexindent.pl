#!/bin/bash
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# with -w switch
latexindent.pl -s -w env-batch*.tex -g env-batch.log -y 'onlyOneBackUp:1'

latexindent.pl -s    env-batch*.tex -g yaml-batch.log -y 'onlyOneBackUp:1' -l cmh.yaml -t

# multiple files, different directories, with -w switch
latexindent.pl -s -w ../environments/environments-simple.tex env-batch*.tex -g diff-directories.log -y 'onlyOneBackUp:1'

# test batch files with -o switch
latexindent.pl -s -w env-batch*.tex -g o-switch-fail.log -o=myfile.tex
latexindent.pl -s    env-batch1 env-batch2 env-batch3 -g o-switch-pass.log -o=+-myfile.tex

# test batch files with --lines switch
latexindent.pl -s --lines 1---7 lines*.tex -g lines-log.log

# check switch interaction
latexindent.pl --check -s lines*.tex -g check-switch-pass.log
latexindent.pl --check -s env-batch*.tex env-batch11.tex -g check-switch-fail.log -y "defaultIndent: ' '"

# fatal checks
latexindent.pl -s cmh.tex lines*.tex -g fatal-file-not-exist.log
latexindent.pl -s cmh1.tex lines*.tex -g fatal-file-no-read.log

latexindent.pl -l documentation.yaml -rv -w -m -s -g not-working.log doc*.tex

# local settings found with default name (friend #1)
latexindent.pl -s -l local-settings-friend-1/mwe.tex
(cd local-settings-friend-1 && (cat indent.log | grep "defaultIndent" | sed 's/^ *//g' > localSettings.yaml))

# local settings found (friend #2)
latexindent.pl -s -l local-settings-friend-2/mwe.tex
(cd local-settings-friend-2 && (cat indent.log | grep "defaultIndent" | sed 's/^ *//g' > latexindent.yaml))

# local settings found (friend #3)
latexindent.pl -s -l local-settings-friend-3/mwe.tex
(cd local-settings-friend-3 && (cat indent.log | grep "defaultIndent" | sed 's/^ *//g' > .localSettings.yaml))

# local settings found (friend #4)
latexindent.pl -s -l local-settings-friend-4/mwe.tex
(cd local-settings-friend-4 && (cat indent.log | grep "defaultIndent" | sed 's/^ *//g' > .latexindent.yaml))  

[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise
