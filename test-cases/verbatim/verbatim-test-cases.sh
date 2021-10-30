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

[[ $silentMode == 0 ]] && set -x 

latexindent.pl -s  -m verbatim6 -l=verb-env-1-named.yaml -o=+-mod-1
latexindent.pl -s  -m verbatim7 -o=+-mod-1-default
latexindent.pl -s  -m verbatim7 -l=nameAsRegex.yaml -o=+-mod-1
latexindent.pl -s  -m verbatim7 -l=nameAsRegex2.yaml -o=+-mod-2
latexindent.pl -s  -m verbatim7a -l=nameAsRegex.yaml -o=+-mod-1

# checking a named version of polyswitch
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml -o=+-mod-1-named
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named.yaml,verb-begin-1 -o=+-mod-1-named-mk2
latexindent.pl -s  -m verbatim-special3 -l=verb-special.yaml,verb-spec2-named.yaml -o=+-mod2-named

# make sure that trailing comments work
latexindent.pl -s  -m verbatim-trailing-comments -l=verb-begin2.yaml -o=+-mod2

# verbatim command
latexindent.pl -s -w verbatim-commands.tex -l=nameAsRegex.yaml
latexindent.pl -s verbatim-trailing-comments1.tex -o=+-default

#   verbatim noindent block 
latexindent.pl -s issue-266.tex -o=+-default
latexindent.pl -s issue-266a.tex -o=+-default
latexindent.pl -s issue-266b.tex -o=+-default

# noindentblock
latexindent.pl -s noindentblock1.tex -o=+-default
latexindent.pl -s noindentblock1.tex -l noindent1 -o=+-mod1

# noindentblock with begin, body, end: https://github.com/cmhughes/latexindent.pl/issues/274
latexindent.pl -s -m href.tex -l href1.yaml -o=+-mod1
latexindent.pl -s -m href.tex -l href2.yaml -o=+-mod2

# the following will *not* work, as they are missing end and begin statements (check the log files)
latexindent.pl -s -m href.tex -l href3.yaml -o=+-mod3 -g=one.log
latexindent.pl -s -m href.tex -l href4.yaml -o=+-mod4 -g=two.log

latexindent.pl -s -m href.tex -l href5.yaml -o=+-mod5
latexindent.pl -s -m href.tex -l href6.yaml -o=+-mod6

[[ $noisyMode == 1 ]] && makenoise
git status
verbatimTest=0
