#!/bin/bash
loopmax=0
. ../common.sh

[[ $silentMode == 0 ]] && set -x 
# environments
latexindent.pl -s environment1 -o=+-mod0
latexindent.pl -s environment1 -o=+-mod1 -l=fine-tuning-env1.yaml
latexindent.pl -s environment2 -o=+-mod0
latexindent.pl -s environment2 -o=+-mod2 -l=fine-tuning-env2.yaml

# ifelsefi
latexindent.pl -s ifelsefi1 -o=+-mod0
latexindent.pl -s ifelsefi1 -o=+-mod1 -l=fine-tuning-ifelsefi1.yaml

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

# unnamed braces brackets
latexindent.pl -s unnamedbracesbrackets1 -o=+-mod0
latexindent.pl -s unnamedbracesbrackets1 -o=+-mod1 -l=fine-tuning-unnamed1.yaml

# arguments
latexindent.pl -s arguments1 -o=+-mod0
latexindent.pl -s arguments1 -o=+-mod1 -l=fine-tuning-args1.yaml

latexindent.pl -s arguments2 -o=+-mod0
latexindent.pl -s arguments2 -o=+-mod2 -l=fine-tuning-args2.yaml

# trailing comments, Larry's Speak Easy
latexindent.pl -s href.tex -m -o=+-mod1 -l href1.yaml
latexindent.pl -s href.tex -m -o=+-mod2 -l href2.yaml
git status
[[ $noisyMode == 1 ]] && makenoise
