#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
set -x 

# A little script to help me run through test cases

#find . -type f \( -name "*.tex" -or -name "*.cls" -or -name "*.sty" -or -name "*.bib" \) | while read file; do echo $file; latexindent.pl -w -s -l "$file";done
#
#echo latexindent.pl -w -t -l=table5.yaml -s table5
#latexindent.pl -w -t -l=table5.yaml -s table5
#
#echo latexindent.pl  -w -l=items3.yaml -s --ttrace items3
#latexindent.pl  -w -l=items3.yaml -s --ttrace items3
#
#echo latexindent.pl  -w -l=items4.yaml -s --ttrace items4
#latexindent.pl  -w -l=items4.yaml -s --ttrace items4

latexindent.pl -w -s -t environments-simple.tex
latexindent.pl -w -s -t environments-simple-nested.tex
latexindent.pl -w -s -t environments-nested-nested.tex
latexindent.pl -w -s -t environments-one-line.tex
latexindent.pl -w -s -t environments-challenging.tex
latexindent.pl -w -s -t environments-verbatim-simple.tex
latexindent.pl -w -s -t environments-verbatim-harder.tex
latexindent.pl -w -s -t environments-noindent-block.tex
latexindent.pl -w -s -t no-environments.tex
latexindent.pl -w -s -t environments-repeated.tex
latexindent.pl -w -s -t environments-trailing-comments.tex
latexindent.pl -w -s -t -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l=env-chall.yaml -s -t -o=environments-challenging-output.tex environments-challenging.tex
latexindent.pl -w -l env-chall.yaml -s -t -o environments-challenging-output.tex environments-challenging.tex
# go from one line to multi-line environments
latexindent.pl -s -l=env-mod-lines1.yaml -t -m -o=environments-one-line-mod-lines1.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines2.yaml -t -m -o=environments-one-line-mod-lines2.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines3.yaml -t -m -o=environments-one-line-mod-lines3.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines4.yaml -t -m -o=environments-one-line-mod-lines4.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines5.yaml -t -m -o=environments-one-line-mod-lines5.tex environments-one-line.tex
latexindent.pl -s -l env-mod-lines5.yaml -t -m -o=environments-one-line-simple-mod1.tex environments-one-line-simple.tex
latexindent.pl -s -w -o environments-nested-fourth-mod1.tex -m environments-nested-fourth.tex
# change log file name
latexindent.pl -s -l=testlogfile.yaml environments-nested-fourth.tex
# go from multiline to non-multi line
latexindent.pl  -s -m -tt -l=env-mod-lines6.yaml -o env-remove-line-breaks-mod1.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o env-remove-line-breaks-mod2.tex environments-remove-line-breaks.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o env-remove-line-breaks-mk1-mod1.tex environments-remove-line-breaks-mk1.tex
latexindent.pl  -s -m -tt -l=env-mod-lines7.yaml -o environments-remove-line-breaks-trailing-comments-mod1.tex environments-remove-line-breaks-trailing-comments.tex
latexindent.pl  -s -m -l=env-mod-lines8.yaml -o=environments-remove-line-breaks-trailing-comments-mk1-mod1.tex environments-remove-line-breaks-trailing-comments-mk1.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod1.tex -m -tt -l=env-mod-lines9.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod2.tex -m -tt -l=env-mod-lines10.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod3.tex -m -tt -l=env-mod-lines11.yaml environments-modify-multiple-line-breaks.tex
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
# conflicting line breaks
latexindent.pl environments-line-break-conflict.tex -s -t -m -o environments-line-break-conflict-mod1.tex -l=env-conflicts-mod1.yaml
latexindent.pl environments-line-break-conflict.tex -s -t -m -o environments-line-break-conflict-mod4.tex -l=env-conflicts-mod4.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -t -m -o environments-line-break-conflict-nested-mod-2.tex -l=env-conflicts-mod2.yaml
latexindent.pl environments-line-break-conflict-nested.tex -s -t -m -o environments-line-break-conflict-nested-mod-3.tex -l=env-conflicts-mod3.yaml
# condense/protect line breaks
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod4.tex -m -tt -l=env-mod-lines12.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod5.tex -m -tt -l=env-mod-lines13.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl -s -o=environments-modify-multiple-line-breaks-mod6.tex -m -tt -l=env-mod-lines14.yaml environments-modify-multiple-line-breaks.tex
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense.tex
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense-mod1.tex -l=ifelsefi-condense-mod1.yaml
latexindent.pl ifelsefi-nested-blank-lines.tex -s -t -m -o=ifelsefi-nested-blank-lines-condense-mod2.tex -l=ifelsefi-condense-mod2.yaml
latexindent.pl environments-modify-multiple-line-breaks-verbatim.tex -s -t -m -o=environments-modify-multiple-line-breaks-verbatim-mod1.tex -l=env-mod-lines12.yaml 
# optional arguments in environments
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod0.tex
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod0.tex
# mod1
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod1.tex -l=opt-args-mod1.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod1.tex -l=opt-args-mod1.yaml 
# mod2
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod2.tex -l=opt-args-mod2.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod2.tex -l=opt-args-mod2.yaml 
# mod3
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod3.tex -l=opt-args-mod3.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod3.tex -l=opt-args-mod3.yaml 
# mod4
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod4.tex -l=opt-args-mod4.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod4.tex -l=opt-args-mod4.yaml 
# mod5
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod5.tex -l=opt-args-mod5.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod5.tex -l=opt-args-mod5.yaml 
# mod6
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod6.tex -l=opt-args-mod6.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod6.tex -l=opt-args-mod6.yaml 
# mod7
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod7.tex -l=opt-args-mod7.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod7.tex -l=opt-args-mod7.yaml 
# mod8
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod8.tex -l=opt-args-mod8.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod8.tex -l=opt-args-mod8.yaml 
# mod9
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod9.tex -l=opt-args-mod9.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod9.tex -l=opt-args-mod9.yaml 
# mod10
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod10.tex -l=opt-args-mod10.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod10.tex -l=opt-args-mod10.yaml 
# mod11
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod11.tex -l=opt-args-mod11.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod11.tex -l=opt-args-mod11.yaml 
# mod12
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod12.tex -l=opt-args-mod12.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod12.tex -l=opt-args-mod12.yaml 
# mod13
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod13.tex -l=opt-args-mod13.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod13.tex -l=opt-args-mod13.yaml 
# mod14
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod14.tex -l=opt-args-mod14.yaml 
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod14.tex -l=opt-args-mod14.yaml 
# fixthis- need to return to this file
# fixthis- need to return to this file
# fixthis- need to return to this file
latexindent.pl environments-simple-opt-args.tex -m  -tt -s -o=environments-simple-opt-args-out.tex
git status
exit
