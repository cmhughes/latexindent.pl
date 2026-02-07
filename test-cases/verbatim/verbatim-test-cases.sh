#!/bin/bash
loopmax=4
verbatimTest=1
. ../common.sh

openingtasks

latexindent.pl -w -s verbatim-preamble
latexindent.pl -m -s verbatim-preamble -o=+-mod2 -l=verb-begin2
latexindent.pl -s verbatim-preamble1 -o=+-mod1
# starred environments
latexindent.pl -s  verbatim-starred1 -l=verb-equation-star -o=+-mod1
latexindent.pl -s  verbatim-starred2 -l=no-indent-star -o=+-mod1

# m switch tests:
set +x
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do
    keepappendinglogfile
    #   verbatim environment
    latexindent.pl -s  -m verbatim1 -l=verb-begin$i -o=+-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-begin$i -o=+-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-begin$i -o=+-mod$i
    latexindent.pl -s  -m verbatim1 -l=verb-end$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim2 -l=verb-end$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim3 -l=verb-end$i -o=+-end-mod$i

    #   verbatim special
    latexindent.pl -s  -m verbatim-special1 -l=verb-special,verb-spec$i -o=+-mod$i
    latexindent.pl -s  -m verbatim-special2 -l=verb-special,verb-spec$i -o=+-mod$i
    latexindent.pl -s  -m verbatim-special3 -l=verb-special,verb-spec$i -o=+-mod$i
    latexindent.pl -s  -m verbatim-special1 -l=verb-special,verb-end-spec$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-special4 -l=verb-special,verb-end-spec$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-special5 -l=verb-special,verb-end-spec$i -o=+-end-mod$i

    # verbatim commands
    latexindent.pl -s  -m verbatim-commands1 -l=verb-begin$i -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands2 -l=verb-begin$i -o=+-mod$i
    latexindent.pl -s  -m verbatim-commands3 -l=verb-begin$i -o=+-mod$i

    latexindent.pl -s  -m verbatim-commands1 -l=verb-end$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-commands4 -l=verb-end$i -o=+-end-mod$i
    latexindent.pl -s  -m verbatim-commands5 -l=verb-end$i -o=+-end-mod$i
    set +x
done
keepappendinglogfile

latexindent.pl -s  -m verbatim6 -l=verb-env-1-named -o=+-mod-1
latexindent.pl -s  -m verbatim7 -o=+-mod-1-default
latexindent.pl -s  -m verbatim7 -l=nameAsRegex -o=+-mod-1
latexindent.pl -s  -m verbatim7 -l=nameAsRegex2 -o=+-mod-2
latexindent.pl -s  -m verbatim7a -l=nameAsRegex -o=+-mod-1

# checking a named version of polyswitch
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named -o=+-mod-1-named
latexindent.pl -s  -m verbatim5 -l=verb-env-1-named,verb-begin-1 -o=+-mod-1-named-mk2
latexindent.pl -s  -m verbatim-special3 -l=verb-special,verb-spec2-named -o=+-mod2-named

# make sure that trailing comments work
latexindent.pl -s  -m verbatim-trailing-comments -l=verb-begin2 -o=+-mod2

# verbatim command
latexindent.pl -s verbatim-commands -l=nameAsRegex -o=+-mod1
latexindent.pl -s verbatim-trailing-comments1 -o=+-default

# verbatim noindent block 
latexindent.pl -s issue-266 -o=+-default
latexindent.pl -s issue-266a -o=+-default
latexindent.pl -s issue-266b -o=+-default

# noindentblock
latexindent.pl -s noindentblock1 -o=+-default
latexindent.pl -s noindentblock1 -l noindent1 -o=+-mod1

# noindentblock with begin, body, end: https://github.com/cmhughes/latexindent.pl/issues/274
latexindent.pl -s -m href -l href1 -o=+-mod1

# the following will *not* work, as they are missing end and begin statements (check the log files)
latexindent.pl -s -m href -l href3 -o=+-mod3 -g=one.log
latexindent.pl -s -m href -l href4 -o=+-mod4 -g=two.log

latexindent.pl -s -m href -l href5 -o=+-mod5
latexindent.pl -s -m href -l href6 -o=+-mod6

latexindent.pl -s -r -l issue-616.yaml issue-616.tex -o=+-mod1

verbatimTest=0
set +x 
wrapuptasks
