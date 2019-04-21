#!/bin/bash
loopmax=3
verbatimTest=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# starred environments
latexindent.pl -s  verbatim-starred1 -l=verb-equation-star.yaml -o=+-mod1
latexindent.pl -s  verbatim-starred2 -l=no-indent-star.yaml -o=+-mod1

# m switch tests:
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
    #   verbatim environment
    latexindent.pl -s  -m verbatim1 -l=verb-env$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-env$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-env$i.yaml -o=+-mod$i

    #   verbatim special
    latexindent.pl -s  -m verbatim-special1 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-special2 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-special3 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i
done

# checking a named version of polyswitch
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml -o=+-mod-1-named
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml,verb-env-1 -o=+-mod-1-named-mk2
latexindent.pl -s  -m verbatim-special3 -l=verb-special.yaml,verb-spec2-named.yaml -o=+-mod2-named

# make sure that trailing comments work
latexindent.pl -s  -m verbatim-trailing-comments -l=verb-env2.yaml -o=+-mod2


#   verbatim command
#   verbatim noindent block -- no need to test this one...?
git status
verbatimTest=0
