#!/bin/bash
. ../common.sh

openingtasks
latexindent.pl -s -a env1.ast env1.tex -y "indentPreamble: 1"
cp indent.log env1a.txt
perl -p0i -e 's/.*?(INFO:\s+AST\sswitch)/$1/s' env1a.txt
perl -p0i -e 's/\s+------.*//s' env1a.txt

latexindent.pl -s -a env1 env1 -y "indentPreamble: 1"
cp indent.log env1b.txt
perl -p0i -e 's/.*?(INFO:\s+AST\sswitch)/$1/s' env1b.txt
perl -p0i -e 's/\s+------.*//s' env1b.txt

./ast-demo.py env1.ast --output env1.html
# to do
#   arguments   
#   between arguments
#   items
#   verbatim
#   trailing comments
#   align at ampersands
#   tables
#   figures
#
#   html
#   ePUB
set +x 
wrapuptasks
