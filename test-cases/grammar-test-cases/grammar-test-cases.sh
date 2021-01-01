#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
. ../common.sh

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# Command
for i in {1..11}; do 
    latexindent.pl -s command$i.tex -o=+-default.tex
done

# Special
for i in {1..4}; do 
    latexindent.pl -s special$i.tex -o=+-default.tex
done

# KeyEqualsValue
for i in {1..3}; do 
    latexindent.pl -s key-equals-value-braces$i.tex -o=+-default.tex
done

# Environment
for i in {1..15}; do 
    latexindent.pl -s environment$i.tex -o=+-default.tex -y="indentPreamble:1"
done

# NamedGroupingBraces
for i in {1..4}; do 
    latexindent.pl -s named-grouping-braces-brackets$i.tex -o=+-default.tex
done

# IfElseFi
for i in {1..5}; do 
    latexindent.pl -s ifelsefi$i.tex -o=+-default.tex
done

# blanklines
for i in {1..1}; do 
    latexindent.pl -s blankline$i.tex -o=+-default.tex
done

# headings
for i in {1..6}; do 
    latexindent.pl -s heading$i.tex -o=+-default.tex
done

# verbatim
for i in {1..6}; do 
    latexindent.pl -s verbatim$i.tex -o=+-default.tex
done

# noindentblock
for i in {1..2}; do 
    latexindent.pl -s noindentblock$i.tex -o=+-default.tex
done

# filecontents
for i in {1..2}; do 
    latexindent.pl -s filecontents$i.tex -o=+-default.tex
done

# preamble
for i in {1..2}; do 
    latexindent.pl -s preamble$i.tex -o=+-default.tex
    latexindent.pl -s preamble$i.tex -o=+-mod1.tex -y='indentPreamble:1'
done

[[ $silentMode == 0 ]] && set -x 

[[ $noisyMode == 1 ]] && makenoise
git status
