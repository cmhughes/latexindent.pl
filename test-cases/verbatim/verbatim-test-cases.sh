#!/bin/bash
loopmax=3
verbatimTest=1
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -w -s verbatim-preamble.tex
latexindent.pl -m -s verbatim-preamble.tex -o=+-mod2 -l=verb-begin2.yaml
latexindent.pl -w -s verbatim-preamble1.tex
# starred environments
latexindent.pl -s  verbatim-starred1 -l=verb-equation-star.yaml -o=+-mod1
latexindent.pl -s  verbatim-starred2 -l=no-indent-star.yaml -o=+-mod1

# m switch tests:
[[ $silentMode == 0 ]] && set +x 
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
   [[ $showCounter == 1 ]] && echo $i of $loopmax
   [[ $silentMode == 0 ]] && set -x 
    #   verbatim environment
    latexindent.pl -s  -m verbatim1 -l=verb-begin$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-begin$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-begin$i.yaml -o=+-mod$i

    latexindent.pl -s  -m verbatim1 -l=verb-end$i.yaml -o=+-end-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-end$i.yaml -o=+-end-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-end$i.yaml -o=+-end-mod$i

    #   verbatim special
    latexindent.pl -s  -m verbatim-special1 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-special2 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-special3 -l=verb-special.yaml,verb-spec$i.yaml -o=+-mod$i

    latexindent.pl -s  -m verbatim-special1 -l=verb-special.yaml,verb-end-spec$i.yaml -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-special4 -l=verb-special.yaml,verb-end-spec$i.yaml -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-special5 -l=verb-special.yaml,verb-end-spec$i.yaml -o=+-end-mod$i

    # verbatim commands
    latexindent.pl -s  -m verbatim-commands1 -l=verb-begin$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands2 -l=verb-begin$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands3 -l=verb-begin$i.yaml -o=+-mod$i

    latexindent.pl -s  -m verbatim-commands1 -l=verb-end$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands4 -l=verb-end$i.yaml -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands5 -l=verb-end$i.yaml -o=+-mod$i
   [[ $silentMode == 0 ]] && set +x 
done

latexindent.pl -s  -m verbatim6 -l=verb-env-1-named.yaml -o=+-mod-1

# checking a named version of polyswitch
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml -o=+-mod-1-named
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml,verb-begin-1 -o=+-mod-1-named-mk2
latexindent.pl -s  -m verbatim-special3 -l=verb-special.yaml,verb-spec2-named.yaml -o=+-mod2-named

# make sure that trailing comments work
latexindent.pl -s  -m verbatim-trailing-comments -l=verb-begin2.yaml -o=+-mod2

# verbatim command
latexindent.pl -s -w verbatim-commands.tex
latexindent.pl -s verbatim-trailing-comments1.tex -o=+-default

#   verbatim noindent block -- no need to test this one...?
[[ $noisyMode == 1 ]] && makenoise
git status
verbatimTest=0
