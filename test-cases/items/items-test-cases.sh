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
latexindent.pl -s -w items3.tex
# noAdditionalIndent
latexindent.pl -s -l=noAdditionalIndentItemize.yaml items1.tex -o=items1-noAdditionalIndentItemize.tex
latexindent.pl -s -l=noAdditionalIndentItems.yaml items1.tex -o=items1-noAdditionalIndentItems.tex
latexindent.pl -s -g=other.log -l=noAdditionalIndent-myenv.yaml items3.tex -o=items3-noAdditionalIndent-myenv.tex
# indentRules
latexindent.pl -s -l=indentRulesItemize.yaml items1.tex -o=items1-indentRulesItemize.tex
latexindent.pl -s -l=indentRulesItems.yaml items1.tex -o=items1-indentRulesItems.tex
# test different item names
latexindent.pl -s -l=myitem.yaml -w items1-myitem.tex
latexindent.pl -s -l=part.yaml -w items1-part.tex
# modify linebreaks starts here
latexindent.pl -s -m items1.tex -o=items1-mod0.tex
latexindent.pl -s -m items2.tex -o=items2-mod0.tex
git status
