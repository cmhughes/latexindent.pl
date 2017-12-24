#!/bin/bash
# A little script to help me prepare the bundle for ctan

# make sure to be on the master branch
git checkout master
# re-compile the documentation
cd ../documentation
arara latexindent
egrep 'undefined' latexindent.log && read -p "Does the above look ok?"
egrep 'multiply-defined' latexindent.log && read -p "Does the above look ok?"
egrep -i 'fixthis' latexindent.log && read -p "Does the above look ok?"
nohup evince latexindent.pdf
cd ../
# create a folder
mkdir latexindent
cp latexindent.pl latexindent
cp helper-scripts/latexindent-module-installer.pl latexindent
cp latexindent.exe latexindent
cp defaultSettings.yaml latexindent
# modules
mkdir latexindent/LatexIndent
cp LatexIndent/*.pm latexindent/LatexIndent
# readme
cp documentation/readme.txt latexindent/README
# documentation
mkdir latexindent/documentation
cp documentation/*.tex latexindent/documentation
cp documentation/latexindent.pdf latexindent/documentation
# zip it
zip -r latexindent.zip latexindent
mv latexindent.zip ~/Desktop
echo ""
echo "~/Desktop contains latexindent.zip"
echo ""
trash-put latexindent
exit
