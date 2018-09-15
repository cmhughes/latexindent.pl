#!/bin/bash

generatePDFmode=0
minorVersion=0
while getopts "mp" OPTION
do
 case $OPTION in 
  p)    
   echo "re-generating pdf..."
   generatePDFmode=1
   ;;
  m)    
   echo "minor version, not removing most recently updated stars from documentation..."
   minorVersion=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

oldVersion='3.5'
newVersion='3.5.1'
oldDate='2018-08-13'
newDate='2018-09-15'

cd ../
if [ $minorVersion = 0 ]
then
    cd documentation
    find -name "a*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\*\{/announce\{/gi"
    find -name "s*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\*\{/announce\{/gi"
    find -name "a*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\{NEW\}/announce\*\{$newDate\}/gi"
    find -name "s*.tex" -print0|xargs -0 sed -i.bak -E "s/announce\{NEW\}/announce\*\{$newDate\}/gi"
    cd ../
fi
sed -i.bak "s/version = u'$oldVersion'/version = u'$newVersion'/" documentation/conf.py
sed -i.bak "s/release = u'$oldVersion'/release = u'$newVersion'/" documentation/conf.py
sed -i.bak "s/\$versionNumber = '$oldVersion'/\$versionNumber = '$newVersion'/" LatexIndent/Version.pm
sed -i.bak "s/\$versionDate = '$oldDate'/\$versionDate = '$newDate'/" LatexIndent/Version.pm
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" latexindent.pl
sed -i.bak "s/version $oldVersion, $oldDate/version $newVersion, $newDate/" defaultSettings.yaml
sed -i.bak "s/version $oldVersion/version $newVersion/" readme.md
sed -i.bak "s/$oldDate/$newDate/" readme.md
sed -i.bak "s/version $oldVersion/version $newVersion/" documentation/readme.txt
sed -i.bak "s/version $oldVersion/version $newVersion/g" documentation/conf.py
sed -i.bak "s/$oldDate/$newDate/" documentation/readme.txt
sed -i.bak "s/Version $oldVersion/Version $newVersion/" documentation/title.tex
sed -i.bak "s/\\documentclass\[10pt,draft\]/\\documentclass\[10pt\]/" documentation/latexindent.tex
cd documentation
perl documentation-default-settings-update.pl -r
cd ../
# possibly generate the pdf
[[ $generatePDFmode == 1 ]] && cd documentation && arara latexindent
exit
