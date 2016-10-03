#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
set -x 

# making strings of tabs and spaces gives different results; 
# this first came to light when studying items1.tex -- the following test cases helped to 
# resolve the issue
latexindent.pl -s -t spaces-and-tabs.tex -l=tabs-follow-tabs.yaml -o=spaces-and-tabs-tft.tex
latexindent.pl -s -t spaces-and-tabs.tex -l=spaces-follow-tabs.yaml -o=spaces-and-tabs-sft.tex
latexindent.pl -s -t spaces-and-tabs.tex -l=tabs-follow-spaces -o=spaces-and-tabs-tfs.tex
# first lot of items
latexindent.pl -s -w items1.tex
# nested itemize/enumerate environments -- these ones needed ancestors, the understanding/development of which took about a week!
latexindent.pl -s -w items1.5.tex
latexindent.pl -s -w items2.tex
git status
