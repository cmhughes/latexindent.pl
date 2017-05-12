#!/bin/bash

oldVersion='3.0.1'
newVersion='3.0.2'
oldDate='2017-05-12'
newDate='2017-05-12'

cd ../
sed -i.bak "s/version $oldVersion/version $newVersion/" LatexIndent/LogFile.pm
sed -i.bak "s/version $oldVersion/version $newVersion/" latexindent.pl
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.txt
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.txt
sed -i.bak "s/Version $oldVersion/Version $newVersion/" documentation/latexindent.tex
cd documentation
arara latexindent
exit
