#!/bin/bash
# A little script to help me prepare the bundle for ctan

mkdir latexindent
mkdir latexindent/documentation
mkdir latexindent/success
cp latexindent.pl latexindent
cp latexindent.exe latexindent
cp defaultSettings.yaml latexindent
cp indent.yaml latexindent
cp readme.txt latexindent
cp documentation/manual.tex latexindent/documentation
cp documentation/manual.pdf latexindent/documentation
cp success/*.tex latexindent/success
zip -r latexindent.zip latexindent
mv latexindent.zip ~/Desktop
trash-put latexindent
exit
