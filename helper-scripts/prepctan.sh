#!/bin/bash
# A little script to help me prepare the bundle for ctan

# script
git checkout master
cd ../documentation
arara latexindent
cd ../
mkdir latexindent
cp latexindent.pl latexindent
cp latexindent.exe latexindent
cp defaultSettings.yaml latexindent
# modules
mkdir latexindent/LatexIndent
cp LatexIndent/*.pm latexindent/LatexIndent
# readme
cp readme.txt latexindent/README
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
