#!/bin/bash

# argument check
ERROR="Too few arguments : no file name specified"
[[ $# -eq 0 ]] && echo $ERROR && exit  # no args? ... print error and exit

# name of MAINFILE
mainFile=$1

mainFile=${mainFile/%.tex/}

echo "Processing ${mainFile}.tex"
pandoc --filter pandoc-citeproc cmhlistings.tex ${mainFile}.tex -o ${mainFile}.rst --bibliography latex-indent.bib --bibliography contributors.bib --columns=200
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

### ARCHIVE BELOW, need to ditch
###
### perl -p0i -E 's&(\.\.\h*table::.*?)\R(.*?)=\R\h*\R&
###                 my $beginning = $1; 
###                 my $table_body = $2;
###                 my @table_rows = split(/\R/, $table_body);
###                 my @ampersandPosition;
###                 # lines containing
###                 #    ========== =============
###                 # detail the position of |
###                 foreach (@table_rows){
###                   if ($_ =~ m/^\h*(\h|=)+?$/){
###                     @ampersandPosition = split(" ",$_);
###                     last;
###                   }
###                 };
###                 my $hrule = "  +";
###                 foreach(@ampersandPosition){
###                     $_ = length($_);
###                     $hrule .= ("-" x $_);
###                     $hrule .="-+";
###                 } 
###                 # remove ========== =============
###                 # remove =======================
###                 $table_body =~ s/^\h*(\h|=)+?$//mg;
###                 # remove blank lines
###                 $table_body =~ s/\R{2,}/\n/sg;
###                 @table_rows = split(/\R/, $table_body);
###                 # get maximum row length
###                 my $maximumRowLength = 0;
###                 foreach (@table_rows){
###                   $maximumRowLength = length($_) if (length($_)>$maximumRowLength);
###                 }
###                 foreach (@table_rows){
###                   #next if $_ !~ m/^\h*$/s;
###                   my $originalRow = $_;
###                   my $startIndex = 1;
###                   my $finalIndex = (scalar @ampersandPosition>0 ? $ampersandPosition[0]: length($originalRow))+$startIndex;
###                   $finalIndex++;
###                   $_ = substr($originalRow,$startIndex,$finalIndex)."|";
###                   for(my $index=1; $index <= $#ampersandPosition; $index++){
###                     $startIndex = $finalIndex+1;
###                     $finalIndex = $ampersandPosition[$index];
###                     $finalIndex++;
###                     $_ .= substr($originalRow,$startIndex,$finalIndex)."|";
###                   }
###                   $_ .= substr($originalRow,$startIndex+$finalIndex).(" "x($maximumRowLength-length($originalRow)))." |";
###                   $_ =~ s/^(\h*)(.)/$1| $2/m;
###                 };
###                 $table_rows[0] = q();
###                 $hrule .= ("-" x ($maximumRowLength - length($hrule)+2*(scalar @ampersandPosition)))."+";
###                 $beginning."\n"."\n".$hrule.join("\n",@table_rows)."\n".$hrule."\n\n";&sgex' ${mainFile}.rst

#### perl -p0i -E 's&(\.\.\h*table::.*?)\R(.*?)=\R\h*\R&
####                 my $beginning = $1; 
####                 my $table_body = $2;
####                 # remove =======================
####                 #$table_body =~ s/^\h*=+?$//mg;
####                 $beginning."\n"."\n".$table_body."\n\n";&sgex' ${mainFile}.rst
