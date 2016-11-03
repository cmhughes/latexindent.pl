#!/bin/bash
# set verbose mode, 
# see http://stackoverflow.com/questions/2853803/in-a-shell-script-echo-shell-commands-as-they-are-executed
#
# hugely useful, for example:
#       vim mand-args-test-cases.sh && ./mand-args-test-cases.sh && vim -p environments-second-mand-args.tex environments-second-mand-args-mod2.tex
silentMode=0
# check flags, and change defaults appropriately
while getopts 's' OPTION
do
 case $OPTION in 
  s)    
   echo "Silent mode on...next thing you'll see is git status."
   silentMode=1
   ;;
  ?)    printf "Usage: %s: [-s]  args\n" $(basename $0) >&2
        exit 2
        ;;
 # end case
 esac 
done

loopmax=16
#[[ $# -eq 1 ]] &&  loopmax=$1  # mand-args-test-cases.sh <maxloop>
#echo "mand-args-test-cases.sh will run with loopmax = $loopmax"

# if silentMode is not active, verbose
[[ $silentMode == 0 ]] && set -x 

# mandatory arguments in environments
latexindent.pl environments-first-mand-args.tex -m  -tt -s -w
# loop through mand-args-mod<i>.yaml, from i=1...16
[[ $silentMode == 0 ]] && set +x 
for (( i=1 ; i <= $loopmax ; i++ )) 
do 
   [[ $silentMode == 0 ]] && set -x 
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
   [[ $silentMode == 0 ]] && set +x 
done
# multi switches set to 2
latexindent.pl environments-third-mand-args-remove-linebreaks1-trailing-comments.tex -m -l=mand-args-mod1.yaml,addPercentAfterBegin.yaml -s -tt -o=environments-third-mand-args-remove-linebreaks1-trailing-comments-mod1-addPercentAfterBegin.tex
latexindent.pl environments-third-mand-args.tex -l=mand-args-mod1.yaml,addPercentBeforeBegin.yaml -m -s -o=environments-third-mand-args-percent-before-begin.tex
latexindent.pl environments-third-mand-args.tex -l=addPercentAfterEnd.yaml -m -s -o=environments-third-mand-args-percent-after-end.tex
latexindent.pl environments-third-mand-args.tex -l=addPercentAfterBody.yaml -m -s -o=environments-third-mand-args-percent-after-body.tex
latexindent.pl -s -tt -m -w environments-first-mand-args-mod-supp1.tex -l=addPercentAfterBody.yaml -o=environments-first-mand-args-mod-supp1-mod1.tex 
latexindent.pl -s environments-first-mand-args-more-comments.tex -m -l=addPercentAfterBegin.yaml  -tt -o=environments-first-mand-args-more-comments-addPercentAfterBegin.tex
latexindent.pl environments-third-mand-args.tex -l=addPercentAll.yaml -m -s -o=environments-third-mand-args-percent-after-all.tex
# noAdditionalIndent experiments   
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent.yaml -m -s -o=environments-third-mand-args-noAddtionalIndentScalar.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-mod1.yaml -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod1.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-mod2.yaml -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod2.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-mod3.yaml -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod3.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-mod4.yaml -m -s -o=environments-third-mand-args-noAddtionalIndentHash-mod4.tex
# indent rules
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-indent-rules1.yaml -m -s -o=environments-third-mand-args-indent-rules1.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-indent-rules2.yaml -m -s -o=environments-third-mand-args-indent-rules2.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-indent-rules3.yaml -m -s -o=environments-third-mand-args-indent-rules3.tex
latexindent.pl environments-third-mand-args.tex -l=addPercent-noAdditionalIndent-mand-args-indent-rules4.yaml -m -s -o=environments-third-mand-args-indent-rules4.tex
# noAdditionalIndent
latexindent.pl environments-third-mand-args-mod1.tex -l=noAdditionalIndentGlobal.yaml -s -o=environments-third-mand-args-mod1-global.tex -tt
[[ $silentMode == 0 ]] && set -x 
git status
exit
