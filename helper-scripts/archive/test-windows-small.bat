latexindent.exe unicode-multicol.tex -o=++ -l multiColumnGrouping.yaml 
latexindent.exe unicode-multicol.tex -o=++ -g=one.log
latexindent.exe unicode-multicol.tex -o ++ -g=two.log
latexindent.exe unicode-multicol.tex -o=+cmh -g=three.log
latexindent.exe unicode-multicol.tex -o=+cmh1 -yaml="defaultIndent: ' '" -g=four.log
pause
