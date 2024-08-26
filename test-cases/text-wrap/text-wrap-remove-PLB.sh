#!/bin/bash
loopmax=5
. ../common.sh

[[ $silentMode == 0 ]] && set -x 

# proof of concept
latexindent.pl -s long-lines1.tex -o=+-default.tex
latexindent.pl -s long-lines2.tex -o=+-default.tex

# the issue that motivated this pursuit  https://github.com/cmhughes/latexindent.pl/issues/33
latexindent.pl -s jowens-short.tex -o=+-mod-4.tex -l=text-wrap-4.yaml -m -r
latexindent.pl -s jowens-long.tex -o=+-mod-4.tex -l=text-wrap-4.yaml -m 

set +x
# long lines test cases
for (( i=$loopmin ; i <= $loopmax ; i++ )) 
do 
    # basic tests
    [[ $showCounter == 1 ]] && echo $i of $loopmax
    [[ $silentMode == 0 ]] && set -x 
    latexindent.pl -s long-lines1.tex -o=+-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines2.tex -o=+-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    latexindent.pl -s long-lines3.tex -o=+-mod-$i.tex -l=text-wrap-$i.yaml -m -y="modifyLineBreaks:textWrapOptions:huge:wrap"
    set +x
done

set +x
[[ $silentMode == 0 ]] && set -x 

# not stopping at comment block
latexindent.pl -s long-lines1.tex -o=+-mod-6.tex -l=text-wrap-4.yaml,not-stop-comment-block.yaml -m

# following comment on previous line
latexindent.pl -s long-lines4.tex -o=+-mod-6.tex -l=text-wrap-6.yaml -m
latexindent.pl -s long-lines4.tex -o=+-mod-7.tex -l=text-wrap-6.yaml -m -y="modifyLineBreaks:textWrapOptions:blocksFollow:commentOnPreviousLine:0"

# verbatim
latexindent.pl -s -m verbatim-long-lines.tex -o verbatim-long-lines-mod1.tex -l=text-wrap-1.yaml -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -s -m verbatim2 -o=+-mod1 -l=verbatim1.yaml
latexindent.pl -s -m verbatim2 -o=+-mod2 -l=verbatim2.yaml
latexindent.pl -s -m verbatim2 -o=+-mod3 -l=verbatim3.yaml

# remove paragraph line breaks
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks0.yaml -o=+0.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks1.yaml -o=+1
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks2.yaml -o=+2.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks3.yaml -o=+3.tex
latexindent.pl -m -s jowens-short-multi-line.tex -l removeParaLineBreaks4.yaml -o=+4.tex

# remove paragraph line breaks, multiple objects
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks0.yaml -o=+0.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks5.yaml -o=+5.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks7.yaml -o=+7.tex
latexindent.pl -m -s multi-object.tex -l removeParaLineBreaks9.yaml -o=+9.tex

# trailing comments
latexindent.pl -m -s trailingComments.tex -l removeParaLineBreaks0.yaml -o=+0.tex
latexindent.pl -m -s trailingComments.tex -l removeParaLineBreaks0.yaml,unprotect-blank-lines.yaml -o=+-unprotect0.tex

# chapter file
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks0.yaml -o=+0.tex
latexindent.pl -m -s chapter-file.tex -l removeParaLineBreaks0.yaml,unprotect-blank-lines.yaml -o=+unprotect0.tex

# chapter file with \par
latexindent.pl -m -s chapter-file-par.tex -l removeParaLineBreaks0.yaml -o chapter-file-par0.tex

# key equals value
latexindent.pl -m -s key-equals-value.tex -l key-equals-value.yaml -o=+0.tex

# unnamed grouping braces
latexindent.pl -m -s unnamed-group-braces.tex -l removeParaLineBreaks0.yaml,unnamed-braces.yaml -o=+0.tex

# test paragraph stop routine
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml -o=+-mod0.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtCommands.yaml -o=+-mod1.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,noStopParaAtEnvironments.yaml -o=+-mod2.tex

# headings
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml -o=+-mod7.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml-o jowens-short-multi-line-stop-mod8.tex
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,../headings/levels1.yaml,removeParaLineBreaks17.yaml -o=+-mod9.tex

# file contents
latexindent.pl -m -s jowens-short-multi-line-stop.tex -l removeParaLineBreaks0.yaml,stopParaAtFileContents.yaml -o=+-mod10.tex

# heading
latexindent.pl -m -s jowens-follow-ups.tex -l removeParaLineBreaks0,jowens-follow-up -o=+-mod0.tex
latexindent.pl -m -s jowens-follow-ups.tex -l removeParaLineBreaks0,jowens-follow-up,description -o=+-mod1.tex

# bug reported at https://github.com/cmhughes/latexindent.pl/issues/90
latexindent.pl -m -s bug1 -o=+-mod0 -l lower-alph

# everything below is to do with the
# improvement to text wrap routine, requested at https://github.com/cmhughes/latexindent.pl/issues/103
latexindent.pl -m -s zoehneto.tex -l=zoehneto1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto.tex -l=zoehneto4.yaml -o=+-mod4
latexindent.pl -m -s zoehneto.tex -l=zoehneto9.yaml -o=+-mod9 -y="modifyLineBreaks:textWrapOptions:huge:wrap"

latexindent.pl -m -s zoehneto1.tex -l=zoehneto1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto2.tex -l=zoehneto3.yaml -o=+-mod3
latexindent.pl -m -s zoehneto1.tex -l=zoehneto4.yaml -o=+-mod4
latexindent.pl -m -s zoehneto1.tex -l=zoehneto7.yaml -o=+-mod7

latexindent.pl -m -s environments-nested-fourth.tex -l=env1 -o=+-mod1
latexindent.pl -m -s dbmrq -l=dbmrq1 -o=+-mod1
latexindent.pl -m -s zoehneto3.tex -l=zoehneto-config1.yaml -o=+-mod1
latexindent.pl -m -s zoehneto4.tex -l=zoehneto11.yaml -o=+-mod11 -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl -m -s zoehneto3.tex -l=zoehneto17.yaml -o=+-mod17

# preamble
latexindent.pl -m -s zoehneto5.tex -l=zoehneto21.yaml -o=+-mod21
latexindent.pl -m -s zoehneto5.tex -l=zoehneto22.yaml -o=+-mod22
latexindent.pl -m -s zoehneto5.tex -l=zoehneto23.yaml -o=+-mod23

# https://github.com/cmhughes/latexindent.pl/issues/172, adds fields for break, huge for textwrap
latexindent.pl waschk.tex -s -m -l waschk.yaml -o=+-mod -y="modifyLineBreaks:textWrapOptions:huge:wrap"
latexindent.pl waschk.tex -s -m -l waschk0.yaml -o=+-mod0
latexindent.pl waschk.tex -s -m -l waschk1.yaml -o=+-mod1

# https://github.com/cmhughes/latexindent.pl/issues/183
latexindent.pl -s -m -l issue-183-mod1.yaml issue-183.tex -o=+-mod1
latexindent.pl -s -m -l issue-183-mod2.yaml issue-183.tex -o=+-mod2

# https://github.com/cmhughes/latexindent.pl/issues/279
latexindent.pl -s -l issue-279.yaml -m issue-279.tex -o=+-mod1

# text wrap enhancement: 
#   https://github.com/cmhughes/latexindent.pl/issues/158
#   https://github.com/cmhughes/latexindent.pl/issues/228
latexindent.pl -s -l textwrap-most-useful.yaml -m issue-158.tex -o=+-mod1
latexindent.pl -s -l issue-158-mod4.yaml -m issue-158.tex -o=+-mod4
latexindent.pl -s -l issue-158-mod5.yaml -m issue-158.tex -o=+-mod5

latexindent.pl -s -l textwrap-most-useful.yaml,document.yaml -m issue-228.tex -o=+-mod1
latexindent.pl -s -y "modifyLineBreaks:textWrapOptions:columns:-1" -m issue-228.tex -o=+-mod3
latexindent.pl -s -l textwrap-most-useful.yaml -m headings1.tex -o=+-mod1
latexindent.pl -s -l textwrap-most-useful.yaml -m headings2.tex -o=+-mod1
latexindent.pl -s -l textwrap-most-useful.yaml,headings2.yaml -m headings1.tex -o=+-mod2

latexindent.pl -s -l textwrap-most-useful.yaml,verbatim.yaml -m verbatim3.tex -o=+-mod1

latexindent.pl -s -l textwrap-most-useful,test1,addruler1 -m -r textwrap-bfccb.tex -o=+-mod1
latexindent.pl -s -l textwrap-most-useful,addruler1,test2 -m -r textwrap-bfccb.tex -o=+-mod2
latexindent.pl -s -l textwrap-most-useful,test1,addruler1 -m -r textwrap-bfccb1.tex -o=+-mod1
latexindent.pl -s -l textwrap-most-useful,test2,addruler1 -m -r textwrap-bfccb1.tex -o=+-mod2
latexindent.pl -s -l textwrap-most-useful,test3,addruler1 -m -r textwrap-bfccb1.tex -o=+-mod3
latexindent.pl -s -l textwrap-most-useful-preamble.yaml,addruler2 -m -r textwrap-bfccb2.tex -o=+-mod1

latexindent.pl -s -m -l commandshell1.yaml verbatim4.tex -o=+-mod1
latexindent.pl -s -m -l commandshell2.yaml verbatim4.tex -o=+-mod2
latexindent.pl -s -m -l commandshell3.yaml verbatim4.tex -o=+-mod3

latexindent.pl -s -m -l commandshell2.yaml verbatim5.tex -o=+-mod2

latexindent.pl -s -m -l commandshell1.yaml verbatim6.tex -o=+-mod1

# flurry of text wrap issues, early 2022, which motivated text wrap overhaul
latexindent.pl -s issue-337.tex -m -l issue-337.yaml -o=+-mod1
latexindent.pl -s issue-337.tex -m -l issue-337a.yaml -o=+-mod2
latexindent.pl -s issue-344.tex -m -l issue-344.yaml -o=+-mod1
latexindent.pl -s issue-341.tex -m -l issue-341.yaml -o=+-mod1
latexindent.pl -s issue-341-mod1.tex -m -l issue-341.yaml -w

# warning to log file if m switch not active; check issue-362-warn.log for warning 
latexindent.pl -s issue-362.tex -l issue-362.yaml -g issue-362-warn.log

latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367  -o=+-mod1
latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367a -o=+-mod1
latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' issue-367b -o=+-mod1

set +x
for i in {1..7}; 
  do 
    [[ $silentMode == 0 ]] && set -x 
    latexindent.pl -s -m -y 'modifyLineBreaks:textWrapOptions:columns:-1' tw-tc$i.tex -o=+-mod1
    set +x
  done

# before/after
latexindent.pl -s -r -m -l issue-359a.yaml issue-306.tex -y 'modifyLineBreaks:textWrapOptions:columns:80' -o=+-mod1

latexindent.pl -s -r -m -l issue-359.yaml issue-359.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-359a.yaml issue-359.tex -o=+-mod2

latexindent.pl -s -r -m -l issue-359a.yaml issue-359a.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-359a.yaml issue-359b.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-359a.yaml issue-359c.tex -o=+-mod1

latexindent.pl -s -r -m -l issue-359a.yaml issue-359a.tex -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2
latexindent.pl -s -r -m -l issue-359a.yaml issue-359b.tex -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2
latexindent.pl -s -r -m -l issue-359a.yaml issue-359c.tex -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2

latexindent.pl -s -r -m -l issue-359a.yaml issue-359a.tex -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3
latexindent.pl -s -r -m -l issue-359a.yaml issue-359b.tex -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3
latexindent.pl -s -r -m -l issue-359a.yaml issue-359c.tex -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod3

latexindent.pl -s -r -m -l issue-359d.yaml issue-359a.tex -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod5
latexindent.pl -s -r -m -l issue-359e.yaml issue-359a.tex -y 'modifyLineBreaks:textWrapOptions:columns:60' -o=+-mod6

# sentence text wrapping
latexindent.pl -s -r -m -l issue-359b.yaml issue-359.tex -o=+-mod3
latexindent.pl -s -r -m -l issue-359b.yaml issue-359a.tex -o=+-mod4

latexindent.pl -s -r -m -l issue-359b.yaml issue-359d.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-359b.yaml issue-359d.tex -y 'modifyLineBreaks:textWrapOptions:columns:40' -o=+-mod2

latexindent.pl -s -r -m -l issue-359b.yaml issue-359e.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-359c.yaml issue-359e.tex -o=+-mod2

latexindent.pl -s -r -m -l issue-356.yaml,addruler3.yaml issue-356.tex -o=+-mod1
latexindent.pl -s -r -m -l issue-356a.yaml,addruler3.yaml issue-356.tex -o=+-mod2

# wrap comments
latexindent.pl -s -r -m -l wrap-comments.yaml,addruler1.yaml issue-389a.tex -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments.yaml,addruler1.yaml issue-389b.tex -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments.yaml,addruler1.yaml issue-389c.tex -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml issue-389c.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments.yaml,addruler1.yaml issue-389d.tex -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments.yaml,addruler1.yaml issue-389e.tex -o=+-mod1
latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml issue-389e.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments3.yaml,addruler1.yaml issue-389f.tex -o=+-mod1

latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml issue-389g.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml issue-389h.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml issue-389i.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml,inherit-leading-space.yaml issue-389j.tex -o=+-mod2

latexindent.pl -s -r -m -l wrap-comments2.yaml,addruler1.yaml,inherit-leading-space.yaml issue-389k.tex -o=+-mod2

# sentences with trailing comments
latexindent.pl -s -r -m -l wrap-comments4.yaml,addruler1.yaml issue-389l.tex -o=+-mod2
latexindent.pl -s -r -m -l wrap-comments5.yaml,addruler1.yaml issue-389l.tex -o=+-mod3

latexindent.pl -s -m -l issue-412.yaml issue-412.tex -o=+-mod1

# issue 444: text wrap after
latexindent.pl -s -m -r -l issue-444.yaml  issue-444.tex -o=+-mod1
latexindent.pl -s -m -r -l issue-444a.yaml issue-444.tex -o=+-mod2
latexindent.pl -s -m -r -l issue-444b.yaml issue-444.tex -o=+-mod3

latexindent.pl -s -m -r -l issue-444.yaml  issue-444a.tex -o=+-mod1

latexindent.pl -s -m -r -l issue-444.yaml  issue-444b.tex  -o=+-mod1
latexindent.pl -s -m -r -l issue-444c.yaml  issue-444b.tex -o=+-mod2
latexindent.pl -s -m -r -l issue-444d.yaml  issue-444b.tex -o=+-mod3
latexindent.pl -s -m -r -l issue-444e.yaml  issue-444b.tex -o=+-mod4
latexindent.pl -s -m -r -l issue-444f.yaml  issue-444b.tex -o=+-mod5

latexindent.pl -s -m -r -l issue-444g.yaml  issue-444c.tex -o=+-mod1

latexindent.pl -s -m -r -l issue-450.yaml  issue-450.tex -o=+-mod1
latexindent.pl -s -m -r -l issue-450.yaml  issue-450a.tex -o=+-mod1
latexindent.pl -s -m -r -l issue-450.yaml  issue-450b.tex -o=+-mod1

latexindent.pl -s -m -r -l issue-450a.yaml  issue-450c.tex -o=+-mod1

latexindent.pl -s -m -r -l issue-450a.yaml  issue-450d.tex -o=+-mod1 -y 'modifyLineBreaks:textWrapOptions:columns:89'

latexindent.pl -s -m -r -l issue-450.yaml  issue-450e.tex -o=+-mod1

latexindent.pl -s -m -r -l issue-450.yaml  issue-450f.tex -o=+-mod1

latexindent.pl -s -m -l issue-471.yaml  issue-471.tex -o=+-mod1

latexindent.pl -s -m -l issue-487.yaml issue-487.tex -o=+-mod1

latexindent.pl -s -m -l issue-495.yaml issue-495.tex -o=+-mod1

latexindent.pl -s -m -l issue-499.yaml,addruler2.yaml -r issue-499.tex -o=+-mod1
latexindent.pl -s -m -l issue-499a.yaml,addruler2.yaml -r issue-499.tex -o=+-mod2

latexindent.pl -s -m -r -l issue-502.yaml,addruler2.yaml issue-502.tex -o=+-mod1
latexindent.pl -s -m -r -l issue-502a.yaml,addruler2.yaml issue-502a.tex -o=+-mod1

latexindent.pl -s -l issue-506.yaml -m issue-506.tex -o=+-mod1

latexindent.pl -l issue-552.yaml -m issue-552.tex -s
cp indent.log issue-552.txt
perl -p0i -e 's/.*?(WARN)/$1/s' issue-552.txt
perl -p0i -e 's/INFO:.*//s' issue-552.txt

latexindent.pl -s -l issue-553.yaml -m issue-553.tex -o=+-mod1

latexindent.pl -s -l issue-556.yaml -m issue-556.tex -o=+-mod1
latexindent.pl -s -l issue-556a.yaml -m -r issue-556.tex -o=+-mod2
set +x
[[ $gitStatus == 1 ]] && git status
[[ $noisyMode == 1 ]] && makenoise

exit 0
