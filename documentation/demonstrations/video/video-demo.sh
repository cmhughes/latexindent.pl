#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
loopmax=1
. ../../../test-cases/common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# four nested environments
latexindent.pl -s environments-nested-fourth.tex -o environments-nested-fourth-default.tex
vim -p environments-nested-fourth.tex environments-nested-fourth-default.tex

# change default indent
latexindent.pl -s environments-nested-fourth.tex -o environments-nested-fourth-def-ind.tex -l change-default-indent.yaml
vim -p environments-nested-fourth.tex change-default-indent.yaml environments-nested-fourth-def-ind.tex

# customise indentation
latexindent.pl -s environments-nested-fourth.tex -o environments-nested-fourth-no-add.tex -l no-add-env.yaml
vim -p environments-nested-fourth.tex no-add-env.yaml environments-nested-fourth-no-add.tex

# modify line breaks
latexindent.pl -s environments-nested-fourth.tex -o environments-nested-fourth-mod1.tex -l env-mod1.yaml -m
vim -p environments-nested-fourth.tex env-mod1.yaml environments-nested-fourth-mod1.tex

# command
vim -p ../mycommand.tex ../mycommand-default.tex
vim -p ../mycommand.tex ../mycommand-noAdd1.yaml ../mycommand-noAdd1.tex
vim -p ../mycommand.tex ../mycommand-noAdd2.yaml ../mycommand-noAdd2.tex
vim -p ../mycommand.tex ../mycommand-noAdd3.yaml ../mycommand-noAdd3.tex
vim -p ../mycommand.tex ../mycommand-noAdd4.yaml ../mycommand-noAdd4.tex

# pgfkeys
latexindent.pl -s pgfkeys-simple.tex -o pgfkeys-simple-default.tex
vim -p pgfkeys-simple.tex pgfkeys-simple-default.tex
latexindent.pl -s pgfkeys-simple.tex -o pgfkeys-simple-no-add.tex -l=keyVal-no-Add-Glob.yaml
vim -p pgfkeys-simple.tex keyVal-no-Add-Glob.yaml pgfkeys-simple-no-add.tex

# table
latexindent.pl -s table1.tex -o table1-default.tex
vim -p table1.tex table1-default.tex

# special
latexindent.pl -s -m special1.tex -o special1-mod1.tex -l special1-cmh.yaml
vim -p special1.tex special1-cmh.yaml special1-mod1.tex
git status
