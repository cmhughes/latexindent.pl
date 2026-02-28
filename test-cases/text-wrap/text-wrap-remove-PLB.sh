#!/bin/bash
loopmax=5
. ../common.sh

openingtasks

# proof of concept
latexindent.pl -s long-lines1 -o=+-default
latexindent.pl -s long-lines2 -o=+-default

# the issue that motivated this pursuit  https://github.com/cmhughes/latexindent.pl/issues/33
latexindent.pl -s jowens-short -o=+-mod-4 -l=text-wrap-4 -m -r
latexindent.pl -s jowens-long -o=+-mod-4 -l=text-wrap-4 -m 

set +x
# long lines test cases
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    # basic tests
    keepappendinglogfile
    latexindent.pl -s long-lines1 -o=+-mod-$i -l=text-wrap-$i -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines2 -o=+-mod-$i -l=text-wrap-$i -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines3 -o=+-mod-$i -l=text-wrap-$i -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    set +x
done
keepappendinglogfile

# not stopping at comment block
latexindent.pl -s long-lines1 -o=+-mod-6 -l=text-wrap-4,not-stop-comment-block -m

# following comment on previous line
latexindent.pl -s long-lines4 -o=+-mod-6 -l=text-wrap-6 -m
latexindent.pl -s long-lines4 -o=+-mod-7 -l=text-wrap-6 -m -y="modifyLineBreaks:textWrapOptions:blocksFollow:commentOnPreviousLine:0"

# verbatim
latexindent.pl -s -m verbatim-long-lines -o verbatim-long-lines-mod1 -l=text-wrap-1 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -s -m verbatim2 -o=+-mod1 -l=verbatim1
latexindent.pl -s -m verbatim2 -o=+-mod2 -l=verbatim2
latexindent.pl -s -m verbatim2 -o=+-mod3 -l=verbatim3

# remove paragraph line breaks
latexindent.pl -m -s jowens-short-multi-line -l removeParaLineBreaks0 -o=+0
latexindent.pl -m -s jowens-short-multi-line -l removeParaLineBreaks1 -o=+1
latexindent.pl -m -s jowens-short-multi-line -l removeParaLineBreaks2 -o=+2
latexindent.pl -m -s jowens-short-multi-line -l removeParaLineBreaks3 -o=+3
latexindent.pl -m -s jowens-short-multi-line -l removeParaLineBreaks4 -o=+4

# remove paragraph line breaks, multiple objects
latexindent.pl -m -s multi-object -l removeParaLineBreaks0 -o=+0
latexindent.pl -m -s multi-object -l removeParaLineBreaks5 -o=+5
latexindent.pl -m -s multi-object -l removeParaLineBreaks7 -o=+7
latexindent.pl -m -s multi-object -l removeParaLineBreaks9 -o=+9

# trailing comments
latexindent.pl -m -s trailingComments -l removeParaLineBreaks0 -o=+0
latexindent.pl -m -s trailingComments -l removeParaLineBreaks0,unprotect-blank-lines -o=+-unprotect0

# chapter file
latexindent.pl -m -s chapter-file -l removeParaLineBreaks0 -o=+0
latexindent.pl -m -s chapter-file -l removeParaLineBreaks0,unprotect-blank-lines -o=+unprotect0

# chapter file with \par
latexindent.pl -m -s chapter-file-par -l removeParaLineBreaks0 -o chapter-file-par0

# key equals value
latexindent.pl -m -s key-equals-value -l key-equals-value -o=+0

# unnamed grouping braces
latexindent.pl -m -s unnamed-group-braces -l removeParaLineBreaks0,unnamed-braces -o=+0

# test paragraph stop routine
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0 -o=+-mod0
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,stopParaAtCommands -o=+-mod1
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,noStopParaAtEnvironments -o=+-mod2

# headings
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,../headings/levels1 -o=+-mod7
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,../headings/levels1-o jowens-short-multi-line-stop-mod8
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,../headings/levels1,removeParaLineBreaks17 -o=+-mod9

# file contents
latexindent.pl -m -s jowens-short-multi-line-stop -l removeParaLineBreaks0,stopParaAtFileContents -o=+-mod10
cp indent.log file-contents-warn1.txt
perl -p0i -e 's/.*?(WARN:\s*Obsolete)/$1/s' file-contents-warn1.txt
perl -p0i -e 's/INFO:.*//s' file-contents-warn1.txt

# heading
latexindent.pl -m -s jowens-follow-ups -l removeParaLineBreaks0,jowens-follow-up -o=+-mod0
latexindent.pl -m -s jowens-follow-ups -l removeParaLineBreaks0,jowens-follow-up,description -o=+-mod1

# bug reported at https://github.com/cmhughes/latexindent.pl/issues/90
latexindent.pl -m -s bug1 -o=+-mod0 -l lower-alph

# everything below is to do with the
# improvement to text wrap routine, requested at https://github.com/cmhughes/latexindent.pl/issues/103
latexindent.pl -m -s zoehneto -l=zoehneto1 -o=+-mod1
latexindent.pl -m -s zoehneto -l=zoehneto4 -o=+-mod4
latexindent.pl -m -s zoehneto -l=zoehneto9 -o=+-mod9 -y="modifyLineBreaks:textWrapOptions:huge:wrap"

latexindent.pl -m -s zoehneto1 -l=zoehneto1 -o=+-mod1
latexindent.pl -m -s zoehneto2 -l=zoehneto3 -o=+-mod3
latexindent.pl -m -s zoehneto1 -l=zoehneto4 -o=+-mod4
latexindent.pl -m -s zoehneto1 -l=zoehneto7 -o=+-mod7

latexindent.pl -m -s environments-nested-fourth -l=env1 -o=+-mod1
latexindent.pl -m -s dbmrq -l=dbmrq1 -o=+-mod1
latexindent.pl -m -s zoehneto3 -l=zoehneto-config1 -o=+-mod1
latexindent.pl -m -s zoehneto4 -l=zoehneto11 -o=+-mod11 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto3 -l=zoehneto17 -o=+-mod17

# preamble
latexindent.pl -m -s zoehneto5 -l=zoehneto21 -o=+-mod21
latexindent.pl -m -s zoehneto5 -l=zoehneto22 -o=+-mod22
latexindent.pl -m -s zoehneto5 -l=zoehneto23 -o=+-mod23

# https://github.com/cmhughes/latexindent.pl/issues/172, adds fields for break, huge for textwrap
latexindent.pl waschk -s -m -l waschk -o=+-mod -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl waschk -s -m -l waschk0 -o=+-mod0
latexindent.pl waschk -s -m -l waschk1 -o=+-mod1

# https://github.com/cmhughes/latexindent.pl/issues/183
latexindent.pl -s -m -l issue-183-mod1 issue-183 -o=+-mod1
latexindent.pl -s -m -l issue-183-mod2 issue-183 -o=+-mod2

# https://github.com/cmhughes/latexindent.pl/issues/279
latexindent.pl -s -l issue-279 -m issue-279 -o=+-mod1

# text wrap enhancement: 
#   https://github.com/cmhughes/latexindent.pl/issues/158
#   https://github.com/cmhughes/latexindent.pl/issues/228
latexindent.pl -s -l textwrap-most-useful -m issue-158 -o=+-mod1
latexindent.pl -s -l issue-158-mod4 -m issue-158 -o=+-mod4
latexindent.pl -s -l issue-158-mod5 -m issue-158 -o=+-mod5

latexindent.pl -s -l textwrap-most-useful,document -m issue-228 -o=+-mod1
latexindent.pl -s -y "modifyLineBreaks:textWrapOptions:columns:-1" -m issue-228 -o=+-mod3
latexindent.pl -s -l textwrap-most-useful -m headings1 -o=+-mod1
latexindent.pl -s -l textwrap-most-useful -m headings2 -o=+-mod1
latexindent.pl -s -l textwrap-most-useful,headings2 -m headings1 -o=+-mod2

latexindent.pl -s -l textwrap-most-useful,verbatim -m verbatim3 -o=+-mod1

latexindent.pl -s -l textwrap-most-useful,test1,addruler1 -m -r textwrap-bfccb -o=+-mod1
latexindent.pl -s -l textwrap-most-useful,addruler1,test2 -m -r textwrap-bfccb -o=+-mod2
latexindent.pl -s -l textwrap-most-useful,test1,addruler1 -m -r textwrap-bfccb1 -o=+-mod1
latexindent.pl -s -l textwrap-most-useful,test2,addruler1 -m -r textwrap-bfccb1 -o=+-mod2
latexindent.pl -s -l textwrap-most-useful,test3,addruler1 -m -r textwrap-bfccb1 -o=+-mod3
latexindent.pl -s -l textwrap-most-useful-preamble,addruler2 -m -r textwrap-bfccb2 -o=+-mod1

latexindent.pl -s -m -l commandshell1 verbatim4 -o=+-mod1
latexindent.pl -s -m -l commandshell2 verbatim4 -o=+-mod2
latexindent.pl -s -m -l commandshell3 verbatim4 -o=+-mod3

latexindent.pl -s -m -l commandshell2 verbatim5 -o=+-mod2
latexindent.pl -s -m -l commandshell1 verbatim6 -o=+-mod1

# flurry of text wrap issues, early 2022, which motivated text wrap overhaul
latexindent.pl -s issue-337 -m -l issue-337 -o=+-mod1
latexindent.pl -s issue-337 -m -l issue-337a -o=+-mod2
latexindent.pl -s issue-344 -m -l issue-344 -o=+-mod1
latexindent.pl -s issue-341 -m -l issue-341 -o=+-mod1
latexindent.pl -s issue-341-mod1 -m -l issue-341 -w

# warning to log file if m switch not active; check issue-362-warn.log for warning 
latexindent.pl -s issue-362 -l issue-362 -g issue-362-warn.log

latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367  -o=+-mod1
latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367a -o=+-mod1
latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367b -o=+-mod1

set +x
for i in {1..7}; 
  do 
    keepappendinglogfile
    latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' tw-tc$i -o=+-mod1
    set +x
  done
keepappendinglogfile

# before/after
latexindent.pl -s -r -m -l issue-359a issue-306 -y 'modifyLineBreaks:textWrapOptions:columns:80' -o=+-mod1

latexindent.pl -s -r -m -l issue-359 issue-359 -o=+-mod1
latexindent.pl -s -r -m -l issue-359a issue-359 -o=+-mod2

latexindent.pl -s -r -m -l issue-359a issue-359a -o=+-mod1
latexindent.pl -s -r -m -l issue-359a issue-359b -o=+-mod1
latexindent.pl -s -r -m -l issue-359a issue-359c -o=+-mod1

latexindent.pl -s -r -m -l issue-359a issue-359a -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2
latexindent.pl -s -r -m -l issue-359a issue-359b -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2
latexindent.pl -s -r -m -l issue-359a issue-359c -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2

latexindent.pl -s -r -m -l issue-359a issue-359a -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3
latexindent.pl -s -r -m -l issue-359a issue-359b -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3
latexindent.pl -s -r -m -l issue-359a issue-359c -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3

latexindent.pl -s -r -m -l issue-359d issue-359a -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod5
latexindent.pl -s -r -m -l issue-359e issue-359a -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod6

# sentence text wrapping
latexindent.pl -s -r -m -l issue-359b issue-359 -o=+-mod3
latexindent.pl -s -r -m -l issue-359b issue-359a -o=+-mod4

latexindent.pl -s -r -m -l issue-359b issue-359d -o=+-mod1
latexindent.pl -s -r -m -l issue-359b issue-359d -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2

latexindent.pl -s -r -m -l issue-359b issue-359e -o=+-mod1
latexindent.pl -s -r -m -l issue-359c issue-359e -o=+-mod2

latexindent.pl -s -r -m -l issue-356,addruler3 issue-356 -o=+-mod1
latexindent.pl -s -r -m -l issue-356a,addruler3 issue-356 -o=+-mod2

# wrap comments
latexindent.pl -s -r -m -l wrap-comments,addruler1 issue-389a -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments,addruler1 issue-389b -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments,addruler1 issue-389c -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments2,addruler1 issue-389c -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments,addruler1 issue-389d -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments,addruler1 issue-389e -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments2,addruler1 issue-389e -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments3,addruler1 issue-389f -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments2,addruler1 issue-389g -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2,addruler1 issue-389h -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2,addruler1 issue-389i -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2,addruler1,inherit-leading-space issue-389j -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2,addruler1,inherit-leading-space issue-389k -o=+-mod2

# sentences with trailing comments
latexindent.pl -s -r -m -l wrap-comments4,addruler1 issue-389l -o=+-mod2
latexindent.pl -s -r -m -l wrap-comments5,addruler1 issue-389l -o=+-mod3

latexindent.pl -s -m -l issue-412 issue-412 -o=+-mod1

# issue 444: text wrap after
latexindent.pl -s -m -r -l issue-444  issue-444 -o=+-mod1
latexindent.pl -s -m -r -l issue-444a issue-444 -o=+-mod2
latexindent.pl -s -m -r -l issue-444b issue-444 -o=+-mod3

latexindent.pl -s -m -r -l issue-444  issue-444a -o=+-mod1

latexindent.pl -s -m -r -l issue-444  issue-444b  -o=+-mod1
latexindent.pl -s -m -r -l issue-444c  issue-444b -o=+-mod2
latexindent.pl -s -m -r -l issue-444d  issue-444b -o=+-mod3
latexindent.pl -s -m -r -l issue-444e  issue-444b -o=+-mod4
latexindent.pl -s -m -r -l issue-444f  issue-444b -o=+-mod5

latexindent.pl -s -m -r -l issue-444g  issue-444c -o=+-mod1

latexindent.pl -s -m -r -l issue-450  issue-450 -o=+-mod1
latexindent.pl -s -m -r -l issue-450  issue-450a -o=+-mod1
latexindent.pl -s -m -r -l issue-450  issue-450b -o=+-mod1

latexindent.pl -s -m -r -l issue-450a  issue-450c -o=+-mod1

latexindent.pl -s -m -r -l issue-450a  issue-450d -o=+-mod1 -y 'modifyLineBreaks:textWrapOptions:columns:89'

latexindent.pl -s -m -r -l issue-450  issue-450e -o=+-mod1

latexindent.pl -s -m -r -l issue-450  issue-450f -o=+-mod1

latexindent.pl -s -m -l issue-471  issue-471 -o=+-mod1

latexindent.pl -s -m -l issue-487 issue-487 -o=+-mod1

latexindent.pl -s -m -l issue-495 issue-495 -o=+-mod1

latexindent.pl -s -m -l issue-499,addruler2 -r issue-499 -o=+-mod1
latexindent.pl -s -m -l issue-499a,addruler2 -r issue-499 -o=+-mod2

latexindent.pl -s -m -r -l issue-502,addruler2 issue-502 -o=+-mod1
latexindent.pl -s -m -r -l issue-502a,addruler2 issue-502a -o=+-mod1

latexindent.pl -s -l issue-506 -m issue-506 -o=+-mod1

latexindent.pl -l issue-552 -m issue-552 -s

latexindent.pl -s -l issue-553 -m issue-553 -o=+-mod1

latexindent.pl -s -l issue-556 -m issue-556 -o=+-mod1
latexindent.pl -s -l issue-556a -m -r issue-556 -o=+-mod2

latexindent.pl -s -l issue-562 -m issue-562 -o=+-mod1
latexindent.pl -s -l issue-608.yaml -m issue-608.tex -o=+-mod1
latexindent.pl -s -r -l issue-608a.yaml -m issue-608.tex -o=+-mod2
latexindent.pl -s -l sec-intro -m sec-intro -o=+-mod1

set +x 
wrapuptasks
