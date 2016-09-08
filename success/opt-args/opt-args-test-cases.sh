#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
set -x 

# optional arguments in environments
latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod0.tex
latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod0.tex
# loop through -opt-args-mod<i>.yaml, from i=1...16
set +x
for (( i=1 ; i < 17 ; i++ )) 
do 
   set -x
   latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod$i.tex -l=opt-args-mod$i.yaml 
   latexindent.pl environments-first-opt-args.tex -m  -tt -s -o=environments-first-opt-args-mod-supp$i.tex -l=opt-args-mod$i.yaml,opt-args-supp.yaml 
   latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod$i.tex -l=opt-args-mod$i.yaml 
   latexindent.pl environments-first-opt-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks1-mod-supp$i.tex -l=opt-args-mod$i.yaml,opt-args-supp.yaml
   latexindent.pl environments-first-opt-args-remove-linebreaks2.tex -m  -tt -s -o=environments-first-opt-args-remove-linebreaks2-mod-supp$i.tex -l=opt-args-mod$i.yaml,unprotect-blank-lines.yaml
   set +x
done
set -x
# fixthis- need to return to this file
# fixthis- need to return to this file
# fixthis- need to return to this file
latexindent.pl environments-simple-opt-args.tex -m  -tt -s -o=environments-simple-opt-args-out.tex
latexindent.pl environments-more-opt-mand-args.tex -s
git status
exit
