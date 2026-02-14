#!/bin/bash
loopmax=0
. ../common.sh

openingtasks

latexindent.pl -w -s  myfile.tex
latexindent.pl -w -s  myfile.cmh

# *should* work as .cmh is in fileExtensionPreference in fileExtension1.yaml
latexindent.pl -w -s  myfile.cmh -l=fileExtension1.yaml

# should work, as it will pick up myfile.tex
latexindent.pl -w -s  myfile -g=myfile.log

# should pick up myfile.sty first
latexindent.pl -w -s  myfile -l=style-file-first.yaml -g=myfile-sty.log

# won't work, as it will look for another.tex, another.cls, another.bib, another.sty
latexindent.pl -w -s  another
cp indent.log fatal-info1.txt
set +x
for infofile in fatal-info*.txt 
do 
    keepappendinglogfile
    perl -p0i -e 's/.*?(FATAL:)/$1/s' $infofile
    perl -p0i -e 's/INFO:\s+Please.*//s' $infofile
    set +x
done

# the -l switch can accept a + symbol:
latexindent.pl  tabular-karl -l=+../alignment/multiColumnGrouping.yaml -s -o=tabular-karl1.tex 
cp indent.log yaml-info1.txt
latexindent.pl  tabular-karl -l="   +../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl2.tex 
cp indent.log yaml-info2.txt
latexindent.pl  tabular-karl -l="   +   ../alignment/multiColumnGrouping.yaml" -s -o=tabular-karl3.tex 
cp indent.log yaml-info3.txt
latexindent.pl  tabular-karl -l=../alignment/multiColumnGrouping.yaml+ -s -o=tabular-karl4.tex 
cp indent.log yaml-info4.txt
latexindent.pl  tabular-karl -l="../alignment/multiColumnGrouping.yaml    +" -s -o=tabular-karl5.tex -g=one.log
cp indent.log yaml-info5.txt
latexindent.pl  tabular-karl -l=+../alignment/multiColumnGrouping -s -o=tabular-karl6.tex 
cp indent.log yaml-info6.txt

set +x
for infofile in yaml-info*.txt 
do 
    keepappendinglogfile
    perl -p0i -e 's/.*?(INFO:\s+YAML\s+settings\s+read:\s+-l)/$1/s' $infofile
    perl -p0i -e 's/INFO:\s+File.*//s' $infofile
    set +x
done

# no extension for output file
latexindent.pl -s cmh.tex -o one
latexindent.pl -s cmh -o two
cp indent.log ext-info1.txt
latexindent.pl -s cmh -o three. 
cp indent.log ext-info2.txt
latexindent.pl -s cmh.bib -o one 
cp indent.log ext-info3.txt
perl -p0i -e 's/.*?(INFO:\s+-o)/$1/s' ext-info3.txt
latexindent.pl -s cmh.bib -o two. 
cp indent.log ext-info4.txt
perl -p0i -e 's/.*?(INFO:\s+-o)/$1/s' ext-info4.txt

set +x
for infofile in ext-info*.txt 
do 
    keepappendinglogfile
    perl -p0i -e 's/.*?(File\hextension\hwork)/$1/s' $infofile
    perl -p0i -e 's/INFO:\s+Please.*//s' $infofile
    set +x
done

# the output file can be called with a + sign, e.g
#       latexindent.pl cmh.tex -o=+one.tex
#       latexindent.pl cmh.tex -o=+one
# both of which are equivalent to
#       latexindent.pl cmh.tex -o=cmhone.tex
latexindent.pl -s cmh.tex -o +one -g=six.log
latexindent.pl -s cmh.tex -o +two.tex -g=seven.log

# test the ++ routine:
#       latexindent.pl myfile.tex -o=++
# says that latexindent should output to myfile0.tex; if myfile0.tex exists, it should use myfile1.tex, and so on.
#       latexindent.pl myfile.tex -o=output++
# says that latexindent should output to output0.tex; if output0.tex exists, it should use output1.tex, and so on.
#       latexindent.pl myfile.tex -o=+output++
# says that latexindent should myfileoutput to myfileoutput0.tex; if myfileoutput0.tex exists, it should use myfileoutput1.tex, and so on.
latexindent.pl cmh.tex -o=++ -s
cp indent.log cmh-info1.txt
latexindent.pl cmh.tex -o=output++ -s
cp indent.log cmh-info2.txt
latexindent.pl cmh.tex -o +output++ -s
cp indent.log cmh-info3.txt
latexindent.pl cmh.tex -o +myfile++.tex -s
cp indent.log cmh-info4.txt
latexindent.pl cmh.tex -o myfile++.tex -s
cp indent.log cmh-info5.txt
set +x
for infofile in cmh-info*.txt 
do 
    keepappendinglogfile
    perl -p0i -e 's/.*?(output\hfile\hcheck)/$1/s' $infofile
    perl -p0i -e 's/INFO:.*//s' $infofile
    set +x
done

for outputfile in *0.tex; do mv $outputfile tmp.log; done

# update for https://github.com/cmhughes/latexindent.pl/issues/154
# latexindent can now be called to act on any file, regardless of it is 
# part of fileExtensionPreference
latexindent.pl -w cmh.txt -s
latexindent.pl -w cmh.jab -s

set +x 
wrapuptasks
