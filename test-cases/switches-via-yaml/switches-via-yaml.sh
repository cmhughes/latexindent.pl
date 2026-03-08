#!/bin/bash
. ../common.sh

openingtasks
latexindent.pl command1 -l switches1.yaml
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches1.txt
egrep -i 'INFO:  simple diff:' indent.log >> switches1.txt

latexindent.pl command1 -l switches2.yaml
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches2.txt
egrep -i 'INFO:  simple diff:' indent.log >> switches2.txt

latexindent.pl command1 -l switches3.yaml
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches3.txt
egrep -i 'INFO:  simple diff:' indent.log >> switches3.txt

latexindent.pl command1 -l switches4.yaml -o=+-mod4
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches4.txt

latexindent.pl command1 -l switches5.yaml > command1-mod5-diff.txt
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches5.txt

latexindent.pl command1 -l switches7.yaml -o=+-mod7
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches7.txt
egrep -i 'INFO:  Replacement mode' indent.log >> switches7.txt

latexindent.pl command1 -l switches8.yaml -o=+-mod8
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches8.txt
egrep -i 'INFO:  Replacement mode' indent.log >> switches8.txt

latexindent.pl command1 -l switches9.yaml -o=+-mod9 > command1-mod9-sl.txt
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches9.txt

latexindent.pl command1 -l switches10.yaml -o=+-mod10 
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches10.txt
egrep -i 'found:' indent.log >> switches10.txt

latexindent.pl command1 -l switches11.yaml -o=+-mod11 
egrep -i 'INFO:  Switch activated via YAML:' indent.log > switches11.txt
egrep -i 'found:' indent.log >> switches11.txt

set +x 
wrapuptasks
