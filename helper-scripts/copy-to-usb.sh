#!/bin/bash

destinationDir="/media/D8B4-3FFC/latexindent/"

# from this directory
cp create-windows-executable.bat ${destinationDir}
cp test-windows-small.bat ${destinationDir}
cp ppp.pl ${destinationDir}
cp latexindent-module-installer.pl ${destinationDir}

# from the one above
cd ../
cp latexindent.pl ${destinationDir}
cp defaultSettings.yaml ${destinationDir}
mkdir ${destinationDir}/LatexIndent/
cp LatexIndent/*.pm ${destinationDir}/LatexIndent/

# a very few small test case
cp test-cases/alignment/unicode-multicol.tex ${destinationDir}
cp test-cases/alignment/multiColumnGrouping.yaml ${destinationDir}
exit
