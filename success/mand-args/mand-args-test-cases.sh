#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
#
# hugely useful, for example:
#       vim mand-args-test-cases.sh && ./mand-args-test-cases.sh && vim -p environments-second-mand-args.tex environments-second-mand-args-mod2.tex

loopmax=16
[[ $# -eq 1 ]] &&  loopmax=$1  # mand-args-test-cases.sh <maxloop>
echo "mand-args-test-cases.sh will run with loopmax = $loopmax"

set -x 
# mandatory arguments in environments
latexindent.pl environments-first-mand-args.tex -m  -tt -s -w
# loop through mand-args-mod<i>.yaml, from i=1...16
set +x
for (( i=1 ; i <= $loopmax ; i++ )) 
do 
   set -x
   # one mand arg
   latexindent.pl environments-first-mand-args.tex -m  -tt -s -o=environments-first-mand-args-mod$i.tex -l=mand-args-mod$i.yaml 
   latexindent.pl environments-first-mand-args.tex -m  -tt -s -o=environments-first-mand-args-mod-supp$i.tex -l=mand-args-mod$i.yaml,mand-args-supp.yaml 
   latexindent.pl environments-first-mand-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-mand-args-remove-linebreaks1-mod$i.tex -l=mand-args-mod$i.yaml 
   latexindent.pl environments-first-mand-args-remove-linebreaks1.tex -m  -tt -s -o=environments-first-mand-args-remove-linebreaks1-mod-supp$i.tex -l=mand-args-mod$i.yaml,mand-args-supp.yaml
   latexindent.pl environments-first-mand-args-remove-linebreaks2.tex -m  -tt -s -o=environments-first-mand-args-remove-linebreaks2-mod-supp$i.tex -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml
   # two mand args
   latexindent.pl environments-second-mand-args.tex -m -l=mand-args-mod$i.yaml -tt -s -o=environments-second-mand-args-mod$i.tex 
   latexindent.pl environments-second-mand-args-remove-linebreaks1.tex -m -l=mand-args-mod$i.yaml -tt -s -o=environments-second-mand-args-remove-linebreaks1-mod$i.tex 
   latexindent.pl environments-second-mand-args-remove-linebreaks1.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml -tt -s -o=environments-second-mand-args-remove-linebreaks1-mod-unprotect$i.tex 
   latexindent.pl environments-second-mand-args-remove-linebreaks1.tex -m -l=mand-args-mod$i.yaml,unprotect-blank-lines.yaml,condense-blank-lines.yaml -tt -s -o=environments-second-mand-args-remove-linebreaks1-mod-unprotect-condense$i.tex 
   # three, ah ah ah
   latexindent.pl environments-third-mand-args-remove-linebreaks1-trailing-comments.tex -m -l=mand-args-mod$i.yaml -s -tt -o=environments-third-mand-args-remove-linebreaks1-trailing-comments-mod$i.tex
   latexindent.pl environments-third-mand-args.tex -m -l=mand-args-mod$i.yaml,addPercentAfterBegin.yaml -tt -s -o=environments-third-mand-args-mod$i.tex -g=other.log
   set +x
done
git status
exit
