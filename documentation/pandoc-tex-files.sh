#!/bin/bash

# argument check
ERROR="Too few arguments : no file name specified"
[[ $# -eq 0 ]] && echo $ERROR && exit  # no args? ... print error and exit

# name of MAINFILE
mainFile=$1

mainFile=${mainFile/%.tex/}

echo "Processing ${mainFile}.tex"
pandoc --filter pandoc-citeproc cmhlistings.tex ${mainFile}.tex -o ${mainFile}.rst --bibliography latex-indent.bib --bibliography contributors.bib --columns=500
perl -pi -e 's|:((?:num)?ref):``(.*?)``|:$1:`$2`|g' ${mainFile}.rst 

# re-align tables, if necessary
perl -p0i -e 's/^(\|.*\|)/my $table_row = $1; my @cells = split(m!\|!,$table_row); foreach (@cells){ my $matches =0; $matches = () = ($_ =~ m@\:numref\:@g);$_ .= ("  " x $matches); };join("|",@cells)."\|";/mgxe' ${mainFile}.rst

# label follows
perl -pi -e 's|^\h*\.\. \\\_|\.\. \_|mg' ${mainFile}.rst
perl -pi -e 's|^(\h*\.\. _)|.. label follows\n\n$1|mg' ${mainFile}.rst

# some code blocks need special treatment
perl -p0i -e 's/^::(?:\R|\h)*\{(.*?)\}\{((?:(?!(?:\{)).)*?)\}$/\.\. code-block:: latex\n   :caption: $1\n   :name: $2\n/msg' ${mainFile}.rst

# commandshell code blocks
perl -p0i -e 's/^(\h*)::(?:\R|\h)*style:commandshell\h*$/$1\.\. code-block:: latex\n$1   :class: .commandshell\n/msg' ${mainFile}.rst

# and this can lead to \\texttt still being present in .rst
perl -p0i -e 's/\\texttt\{(.*?)\}/``$1``/sg' ${mainFile}.rst

# remove line breaks from :alt: text
perl -p0i -e 's/(:alt:.*?)\R{2}(\h*)/\n\n$2/gs' ${mainFile}.rst

# remove line breaks from :caption: text
perl -p0i -e 's/(:caption:.*?)(^\h+:name:)/my $caption=$1; my $name=$2; $caption=~ s|\h*\R| |sg; $caption."\n".$name;/emgs' ${mainFile}.rst

# some literalincludes can have spurious line breaks
perl -p0i -e 's/^\h*(\.\. literalinclude::)\h*\R/$1 /gsm' ${mainFile}.rst
perl -p0i -e 's/^\h*(\.\. literalinclude::)/$1/gsm' ${mainFile}.rst

# caption and number the tables
perl -p0i -e 's|(\.\. _tab.*?$)(.*?)^Table:(.*?)$|my $label=$1; my $body=$2; my $caption=$3; $body=~s/^/\t/mg; $label."\n\n.. table:: ".$caption."\n\n".$body;|msge' ${mainFile}.rst
perl -p0i -e 's/^\h*\|\h*$//mg' ${mainFile}.rst

# warnings
perl -p0i -e 's|\.\.\h*warning::(.*?)\.\.\h*endwarning::|my $body=$1; $body=~s/^/\t/mg; "\.\. warning::$body";|sge' ${mainFile}.rst

# examples
perl -p0i -e 's|\.\.\h*proof:example::(.*?)\.\.\h*endproof:example::|my $body=$1; $body=~s/^/\t/mg; "\.\. proof:example::$body";|sge' ${mainFile}.rst

# multiple label follows to single
perl -p0i -e 's|(\.\.\h*label\hfollows)(\s*\.\.\h*label\hfollows)+|$1|sg' ${mainFile}.rst

# reset the .tex file
git checkout ${mainFile}.tex
