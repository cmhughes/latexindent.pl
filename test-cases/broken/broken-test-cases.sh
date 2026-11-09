#!/bin/bash
. ../common.sh

openingtasks
latexindent.pl -s broken -o=+-mod1
latexindent.pl -s -l no-specials.yaml broken -o=+-mod2 -t 
egrep 'specialBeginEnd empty' indent.log > no-specials.txt

latexindent.pl -s ifnextchar -o=+-mod1 -l=com-name-special1.yaml -t
egrep 'found:' indent.log > ifnextchar.txt

latexindent.pl -s broken1 -o=+-mod1 -t
egrep 'found:' indent.log > broken1.txt

latexindent.pl -s broken2 -o=+-mod1 -t
egrep 'found:' indent.log > broken2.txt

latexindent.pl -s broken3 -o=+-mod1 -t
egrep 'found:' indent.log > broken3.txt

latexindent.pl -s broken4 -o=+-mod1 -t
egrep 'found:' indent.log > broken4.txt

latexindent.pl -s -l obsolete.yaml obsolete.tex
cp indent.log obsolete.txt
perl -p0i -e 's/.*?(WARN:\s*Obsolete)/$1/s' obsolete.txt
perl -p0i -e 's/INFO:.*//s' obsolete.txt

# malformed YAML is reported in indent.log and skipped: -l file, then indentconfig file
latexindent.pl -s -l malformed.yaml malformed-yaml.tex -o=+-mod1
egrep 'WARN|YAML::Tiny found' indent.log | perl -pe 's/ at .+ line \d+\.$//' > malformed-yaml.txt
LATEXINDENT_CONFIG=malformed-indentconfig.yaml latexindent.pl -s malformed-yaml.tex -o=+-mod2
egrep 'WARN|YAML::Tiny found' indent.log | perl -pe 's/ at .+ line \d+\.$//' > malformed-indentconfig.txt

set +x 
wrapuptasks
