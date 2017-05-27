#!/bin/bash

generatePDFmode=0
while getopts "p" OPTION
do
 case $OPTION in 
  p)    
   echo "re-generating pdf..."
   generatePDFmode=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

oldVersion='3.0.2'
newVersion='3.1'
oldDate='2017-05-12'
newDate='2017-05-27'

cd ../
sed -i.bak "s/version $oldVersion/version $newVersion/" LatexIndent/LogFile.pm
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" latexindent.pl
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" defaultSettings.yaml
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.txt
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.txt
sed -i.bak "s/Version $oldVersion/Version $newVersion/" documentation/latexindent.tex
cd documentation
[[ $generatePDFmode == 1 ]] && arara latexindent
exit
