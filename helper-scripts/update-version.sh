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

oldVersion='3.2.1'
newVersion='3.2.2'
oldDate='2017-06-25'
newDate='2017-06-28'

cd ../
cd documentation
find -name "*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\*\{/announce\{/g"
find -name "*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\{NEW\}/announce\*\{$newDate\}/g"
cd ../
sed -i.bak "s/\$versionNumber = '$oldVersion'/\$versionNumber = '$newVersion'/" LatexIndent/Version.pm
sed -i.bak "s/\$versionDate = '$oldDate'/\$versionDate = '$newDate'/" LatexIndent/Version.pm
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" latexindent.pl
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" defaultSettings.yaml
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.md
sed -i.bak "s/version $oldVersion/version $newVersion/" documentation/readme.txt
sed -i.bak "s/$oldDate/$newDate/" documentation/readme.txt
sed -i.bak "s/Version $oldVersion/Version $newVersion/" documentation/title.tex
sed -i.bak "s/\\documentclass\[10pt,draft\]/\\documentclass\[10pt\]/" documentation/latexindent.tex
# possibly generate the pdf
[[ $generatePDFmode == 1 ]] && cd documentation && arara latexindent
exit
