#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
latexindent.pl -s environment1 -o=+-mod0
latexindent.pl -s environment1 -o=+-mod1 -l=fine-tuning-env1.yaml
latexindent.pl -s environment2 -o=+-mod0
latexindent.pl -s environment2 -o=+-mod2 -l=fine-tuning-env2.yaml

# commands
latexindent.pl -s commands1 -o=+-mod0
latexindent.pl -s commands1 -o=+-mod1 -l=fine-tuning-commands1.yaml

# key equals value
latexindent.pl -s keyequalsvalue1 -o=+-mod0
latexindent.pl -s keyequalsvalue1 -o=+-mod1 -l=fine-tuning-keyequalsvalue1.yaml
latexindent.pl -s keyequalsvalue1 -o=+-mod2 -l=fine-tuning-keyequalsvalue2.yaml

# named braces brackets
latexindent.pl -s namedbracketsbraces1 -o=+-mod0
latexindent.pl -s namedbracketsbraces1 -o=+-mod1 -l=fine-tuning-namedbracketsbraces1.yaml
latexindent.pl -s namedbracketsbraces1 -o=+-mod2 -l=fine-tuning-namedbracketsbraces2.yaml
git status
[[ $noisyMode == 1 ]] && makenoise
