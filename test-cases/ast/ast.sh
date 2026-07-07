#!/bin/bash
. ../common.sh

openingtasks
latexindent.pl -s -a env1.ast env1.tex
cp indent.log env1a.txt
perl -p0i -e 's/.*?(INFO:\s+AST\sswitch)/$1/s' env1a.txt
perl -p0i -e 's/\s+------.*//s' env1a.txt

latexindent.pl -s -a env1 env1
cp indent.log env1b.txt
perl -p0i -e 's/.*?(INFO:\s+AST\sswitch)/$1/s' env1b.txt
perl -p0i -e 's/\s+------.*//s' env1b.txt

# to do
#   arguments   
#   between arguments
#   items
#   verbatim
#   trailing comments
#
#   html
#   ePUB
set +x 
wrapuptasks
