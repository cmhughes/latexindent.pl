#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
set -x 

# if else fi code blocks, simple no line breaks
latexindent.pl -w -s -t ifelsefi-first.tex
latexindent.pl -w -s -t ifelsefi-simple-nested.tex
latexindent.pl -w -s -t ifelsefi-multiple-nested.tex
# modify line breaks
latexindent.pl ifelsefi-first.tex -s -t -m -l=ifelsefi-mod-lines1.yaml -o=ifelsefi-first-mod1.tex
latexindent.pl ifelsefi-first.tex -s -t -m -l=ifelsefi-mod-lines2.yaml -o=ifelsefi-first-mod2.tex
latexindent.pl ifelsefi-first.tex -s -t -m -l=ifelsefi-mod-lines3.yaml -o=ifelsefi-first-mod3.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -t -m -l=ifelsefi-mod-lines1.yaml -o=ifelsefi-first-mod-A-mod1.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -t -m -l=ifelsefi-mod-lines2.yaml -o=ifelsefi-first-mod-A-mod2.tex
latexindent.pl ifelsefi-first-mod-A.tex -s -t -m -l=ifelsefi-mod-lines3.yaml -o=ifelsefi-first-mod-A-mod3.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -t -m -l=ifelsefi-mod-lines4.yaml -o=ifelsefi-first-mod-B-mod4.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -t -m -l=ifelsefi-mod-lines5.yaml -o=ifelsefi-first-mod-B-mod5.tex
latexindent.pl ifelsefi-first-mod-B.tex -s -t -m -l=ifelsefi-mod-lines6.yaml -o=ifelsefi-first-mod-B-mod6.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -t -m -l=ifelsefi-mod-lines7.yaml -o=ifelsefi-first-mod-C-mod7.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -t -m -l=ifelsefi-mod-lines8.yaml -o=ifelsefi-first-mod-C-mod8.tex
latexindent.pl ifelsefi-first-mod-C.tex -s -t -m -l=ifelsefi-mod-lines9.yaml -o=ifelsefi-first-mod-C-mod9.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -t -m -l=ifelsefi-mod-lines10.yaml -o=ifelsefi-first-mod-D-mod10.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -t -m -l=ifelsefi-mod-lines11.yaml -o=ifelsefi-first-mod-D-mod11.tex
latexindent.pl ifelsefi-first-mod-D.tex -s -t -m -l=ifelsefi-mod-lines12.yaml -o=ifelsefi-first-mod-D-mod12.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines12.yaml -o=ifelsefi-first-mod-E-mod12.tex
# else line break experiments
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines13.yaml -o=ifelsefi-first-mod-E-mod13.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines14.yaml -o=ifelsefi-first-mod-E-mod14.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines15.yaml -o=ifelsefi-first-mod-E-mod15.tex
latexindent.pl ifelsefi-first-mod-F.tex -s -t -m -l=ifelsefi-mod-lines13.yaml -o=ifelsefi-first-mod-F-mod13.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines16.yaml -o=ifelsefi-first-mod-E-mod16.tex
latexindent.pl ifelsefi-first-mod-E.tex -s -t -m -l=ifelsefi-mod-lines17.yaml -o=ifelsefi-first-mod-E-mod17.tex
# removing line breaks
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -l=ifelsefi-mod-lines18.yaml -o=ifelsefi-nested-blank-lines-mod18.tex
# testing a nested, one-line example
latexindent.pl ifelsefi-one-line.tex -s -t -m -o=ifelsefi-one-line-mod1.tex
# first mixed example
latexindent.pl env-ifelsefi-mixed.tex -s -t -m -o=env-ifelsefi-mixed-out1.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod1.yaml -o=env-ifelsefi-mixed-mod1.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod2.yaml -o=env-ifelsefi-mixed-mod2.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod3.yaml -o=env-ifelsefi-mixed-mod3.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod4.yaml -o=env-ifelsefi-mixed-mod4.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod5.yaml -o=env-ifelsefi-mixed-mod5.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod6.yaml -o=env-ifelsefi-mixed-mod6.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod7.yaml -o=env-ifelsefi-mixed-mod7.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod8.yaml -o=env-ifelsefi-mixed-mod8.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod9.yaml -o=env-ifelsefi-mixed-mod9.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod10.yaml -o=env-ifelsefi-mixed-mod10.tex
latexindent.pl env-ifelsefi-mixed.tex -s -t  -m -l=env-ifelsefi-mixed-mod11.yaml -o=env-ifelsefi-mixed-mod11.tex
# recursive object examples
latexindent.pl env-ifelsefi-mixed-recursive.tex -s -t -m -o=env-ifelsefi-mixed-recursive-mod1.tex
latexindent.pl env-ifelsefi-mixed-recursive.tex -s -t -m -o=env-ifelsefi-mixed-recursive-mod2.tex -l=env-conflicts-mod2.yaml
latexindent.pl ifelsefi-env-mixed-recursive.tex  -m -tt -l=if-env-recursive-conflicts.yaml -s -o=ifelsefi-env-mixed-recursive-mod1.tex
# condense/protect line breaks
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense.tex
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense-mod1.tex -l=ifelsefi-condense-mod1.yaml
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense-mod2.tex -l=ifelsefi-condense-mod2.yaml
exit
