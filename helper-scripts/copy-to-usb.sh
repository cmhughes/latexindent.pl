#!/bin/bash

destinationDir="/media/D8B4-3FFC/latexindent/"

cd ../
cp latexindent.pl ${destinationDir}
cp defaultSettings.yaml ${destinationDir}
cp LatexIndent/*.pm ${destinationDir}/LatexIndent/
exit
