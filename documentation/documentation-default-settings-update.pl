#!/usr/bin/env perl
# a helper script to make the subsitutions for line numbers 
# from defaultSettings.yaml in documentation/latexindent.tex
use strict;
use warnings;
use Getopt::Long;

my $readTheDocsMode = 0;

GetOptions (
    "readthedocs|r"=>\$readTheDocsMode,
);

# store the names of each field
my @namesAndOffsets = (
                        {name=>"fileExtensionPreference",numberOfLines=>4},
                        {name=>"logFilePreferences",numberOfLines=>10},
                        {name=>"verbatimEnvironments",numberOfLines=>3},
                        {name=>"verbatimCommands",numberOfLines=>2},
                        {name=>"noIndentBlock",numberOfLines=>2},
                        {name=>"removeTrailingWhitespace",numberOfLines=>2},
                        {name=>"fileContentsEnvironments",numberOfLines=>2},
                        {name=>"lookForPreamble",numberOfLines=>4},
                        {name=>"indentAfterItems",numberOfLines=>4},
                        {name=>"itemNames",numberOfLines=>2},
                        {name=>"specialBeginEnd",numberOfLines=>13,mustBeAtBeginning=>1},
                        {name=>"indentAfterHeadings",numberOfLines=>9},
                        {name=>"noAdditionalIndentGlobalEnv",numberOfLines=>1,special=>"noAdditionalIndentGlobal"},
                        {name=>"noAdditionalIndentGlobal",numberOfLines=>12},
                        {name=>"indentRulesGlobalEnv",numberOfLines=>1,special=>"indentRulesGlobal"},
                        {name=>"indentRulesGlobal",numberOfLines=>12},
                        {name=>"commandCodeBlocks",numberOfLines=>14},
                        {name=>"modifylinebreaks",numberOfLines=>2,special=>"modifyLineBreaks",mustBeAtBeginning=>1},
                        {name=>"textWrapOptions",numberOfLines=>1},
                        {name=>"textWrapOptionsAll",numberOfLines=>16,special=>"textWrapOptions"},
                        {name=>"removeParagraphLineBreaks",numberOfLines=>14},
                        {name=>"paragraphsStopAt",numberOfLines=>9},
                        {name=>"oneSentencePerLine",numberOfLines=>23},
                        {name=>"sentencesFollow",numberOfLines=>8},
                        {name=>"sentencesBeginWith",numberOfLines=>3},
                        {name=>"sentencesEndWith",numberOfLines=>5},
                        {name=>"modifylinebreaksEnv",numberOfLines=>9,special=>"environments",within=>"modifyLineBreaks"},
                        {name=>"fineTuning",numberOfLines=>21},
                        {name=>"replacements",numberOfLines=>8},
                      );

# loop through defaultSettings.yaml and count the lines as we go through
my $lineCounter = 1;
my $within = q();
open(MAINFILE,"../defaultSettings.yaml");
while(<MAINFILE>){
    $within = $_ if($_=~m/^[a-zA-Z]/);
    # loop through the names and search for a match
    foreach my $thing (@namesAndOffsets){
      my $name = (defined ${$thing}{special} ? ${$thing}{special} : ${$thing}{name} ); 
      my $beginning = (${$thing}{mustBeAtBeginning}? qr/^/ : qr/\h*/);
      if(defined ${$thing}{within}){
        ${$thing}{firstLine} = $lineCounter if ($_=~m/$beginning$name:/ and $within =~ m/${$thing}{within}/);
      } else {
        ${$thing}{firstLine} = $lineCounter if ($_=~m/$beginning$name:/);
      }
    }
    $lineCounter++;
  }
close(MAINFILE);

# store the file
my @lines;
if(!$readTheDocsMode){
    open(MAINFILE,"../documentation/latexindent.tex");
    push(@lines,$_) while(<MAINFILE>);
    close(MAINFILE);
    my $documentationFile = join("",@lines);
    
    # make the substitutions
    for (@namesAndOffsets){
        my $firstLine = ${$_}{firstLine}; 
        my $lastLine = $firstLine + ${$_}{numberOfLines}; 
        $documentationFile =~ s/\h*\\lstdefinestyle\{${$_}{name}\}\{\h*\R*
                                	\h*style=yaml-LST,\h*\R*
                                	\h*firstnumber=\d+,linerange=\{\d+-\d+\},\h*\R*
                                	\h*numbers=left,?\h*\R*
                                \h*\}
                              /\\lstdefinestyle\{${$_}{name}\}\{
                                	style=yaml-LST,
                                	firstnumber=$firstLine,linerange=\{$firstLine-$lastLine\},
                                	numbers=left,
                                \}/xs;
    }
    
    # overwrite the original file
    open(OUTPUTFILE,">","../documentation/latexindent.tex");
    print OUTPUTFILE $documentationFile;
    close(OUTPUTFILE);
    
    # and operate upon it with latexindent.pl
    system('latexindent.pl -w -s -m -l ../documentation/latexindent.tex');
} else {

    # read informatino from latexindent.aux
    open(MAINFILE, "latexindent.aux") or die "Could not open input file, latexindent.aux";
    push(@lines,$_) while(<MAINFILE>);
    close(MAINFILE);

    my %crossReferences;
    foreach (@lines){
        if($_ =~ m/\\newlabel\{(.*?)\}(.*?)$/s){
            my $name = $1;
            my $value = $2;
            if($name !~ m/\@/s){
                $value =~ s/\}\{\}\}//s;
                $value =~ s/.*\{//s;
                if($value =~ m/lstlisting\.(\d+)/){
                    $value = "Listing ".$1;
                } elsif ($value =~ m/appendix\.([a-zA-Z]+)/){
                    $value = "Appendix ".$1;
                } elsif ($value =~ m/section\.(.+)/){
                    $value = "Section ".$1;
                } elsif ($value =~ m/subsection\.(.+)/){
                    $value = "Subsection ".$1;
                } elsif ($value =~ m/table\.(.+)/){
                    $value = "Table ".$1;
                }
                $crossReferences{$name} = $value;
            }
        } elsif ($_ =~ m/\\totalcount\@set\{lstlisting\}\{(\d+)\}/ ) {
            $crossReferences{totalListings} = $1;
        }
    }

    # combine the subsec files
    foreach("subsec-noAdditionalIndent-indentRules.tex",
            "subsubsec-environments-and-their-arguments.tex",
            "subsubsec-environments-with-items.tex",
            "subsubsec-commands-with-arguments.tex",
            "subsubsec-ifelsefi.tex",
            "subsubsec-special.tex",
            "subsubsec-headings.tex",
            "subsubsec-no-add-remaining-code-blocks.tex",
            "subsec-commands-and-their-options.tex",
          ){
       system("cat $_ >> sec-default-user-local.tex");
    }

    foreach("subsec-partnering-poly-switches.tex",
            "subsec-conflicting-poly-switches.tex",
          ){
       system("cat $_ >> sec-the-m-switch.tex");
    }
    
    # appendix
    system("perl -p0i -e 's/\\\\subsection/\\\\subsubsection/sg' appendices.tex");
    system("perl -p0i -e 's/\\\\section/\\\\subsection/sg' appendices.tex");
    system("perl -p0i -e 's/\\\\appendix/\\\\section\{Appendices\}/sg' appendices.tex");

    # loop through the .tex files
    foreach my $fileName ("sec-introduction.tex", 
                          "sec-demonstration.tex", 
                          "sec-how-to-use.tex", 
                          "sec-indent-config-and-settings.tex",
                          "sec-default-user-local.tex",
                          "sec-the-m-switch.tex",
                          "sec-replacements.tex",
                          "sec-fine-tuning.tex",
                          "sec-conclusions-know-limitations.tex",
                          "references.tex",
                          "appendices.tex",
                          , ){
        @lines = q();
        # read the file
        open(MAINFILE, $fileName) or die "Could not open input file, $fileName";
        push(@lines,$_) while(<MAINFILE>);
        close(MAINFILE);
        my $body = join("",@lines);

        # remove latex only block
        $body =~ s/%\h*\\begin\{latexonly\}.*?%\h*\\end\{latexonly\}/\n\n/sg;

        # references
        $body =~ s/(\\section\{References\})(.*)(\\label\{.*?\})/$1$3$2/s;
        $body =~ s/\\printbibliography\[.*?\]/\\printbibliography/sg;
        $body =~ s/\\printbibliography.*\\printbibliography/\\printbibliography/sg;

        # make the substitutions
        $body =~ s/\\begin\{cmhtcbraster\}\h*(\[.*?\])?//sg;
        $body =~ s/\\end\{cmhtcbraster\}.*$//mg;
        $body =~ s/\\begin\{minipage\}\{.*?\}//sg;
        $body =~ s/\\end\{minipage\}.*$//mg;
        $body =~ s/\\hfill.*$//mg;
        $body =~ s/\\cmhlistingsfromfile(.*)\h*$/
                    my $listingsbody = $1;
                    $listingsbody =~ s|\*||sg;
                    my $rst_class = "tex";
                    if($listingsbody =~ m|replace-TCB|s ){
                        $rst_class = "replaceyaml";
                    } elsif($listingsbody =~ m|MLB-TCB|s ){
                        $rst_class = "mlbyaml";
                    } elsif ($listingsbody =~ m|yaml-TCB|s or $listingsbody =~ m|defaultSettings\.yaml|s or $listingsbody =~ m|yaml-LST|s) {
                        $rst_class = "baseyaml";
                    } elsif ($listingsbody =~ m|yaml-obsolete|s) {
                        $rst_class = "obsolete";
                    }
                    $listingsbody =~ s|\}\h*\[.*?\]|\}|s;
                    $listingsbody =~ s|\[style=yaml-LST\]\*?||sg;
                    $listingsbody =~ s"\[(columns=fixed)?,?(show(spaces|tabs)=true)?,?(show(spaces|tabs)=true)?\]""sg;
                    $listingsbody .= "\{".$rst_class."\}";
                    my $listingname = ($listingsbody =~ m|^\h*\[|s ? "cmhlistingsfromfilefour": "cmhlistingsfromfile");
                    "\n\n\\$listingname".$listingsbody."\n\n";/mgex;
        $body =~ s|\}\h*\[\h*width=.*?\]\h*\{|\}\{|sg;
        
        # get rid of wrapfigure stuff
        $body =~ s/\\begin\{adjustwidth\}\{.*?\}\{.*?\}//sg;
        $body =~ s/\\end\{adjustwidth\}//sg;

        # get rid of \announce command
        $body =~ s/\\announce\*?\{.*?\}\*?\{.*?\}\R*//sg;

        # get rid of wrapfigure stuff
        $body =~ s/\\begin\{wrapfigure\}.*$//mg;
        $body =~ s/\\end\{wrapfigure\}.*$//mg;

        # defaultIndent: "" can cause problems for rst
        $body =~ s/\\texttt\{defaultIndent: ""\}/\\verb!defaultIndent: ""!/sg;

        $body =~ s/\\lstinline\[breaklines=true\]/\\verb/sg;

        # total listings
        $body =~ s/\\totallstlistings/$crossReferences{totalListings}/s;

        # cpageref for page references
        $body =~ s/\\[cC]pageref\{(.*?)\}/:ref:\\texttt\{page $1 <$1>\}/sg;

        # warning
        $body =~ s/\\begin\{warning}(.*?)\\end\{warning\}/\\warning\{$1\}\n/sg;

        # example
        $body =~ s/\\begin\{example}(.*?)\\end\{example\}/\\example\{$1\}\n/sg;

        # cross references
        $body =~ s/\\[vVcC]?ref\{(.*?)\}/
                # check for ,
                my $internal = $1;
                my $returnValue = q();
                if($internal =~ m|,|s){
                    my @refs = split(',',$internal);
                    foreach my $reference (@refs){
                        $returnValue .= ($returnValue eq ''?q():' and ').":numref:\\texttt\{$reference\}";
                    }
                } else {
                    $returnValue = ":numref:\\texttt\{$internal\}";
                };
                $returnValue;
                /exsg;
        $body =~ s/\\crefrange\{(.*?)\}\{(.*?)\}/:numref:\\texttt\{$1\} -- :numref:\\texttt\{$2\}/sg;

        # verbatim-like environments
        $body =~ s/(\\begin\{commandshell\}(?:                       # cluster-only (), don't capture 
                    (?!                   # don't include \begin in the body
                        (?:\\begin)       # cluster-only (), don't capture
                    ).                    # any character, but not \\begin
                )*?\\end\{commandshell\})(?:\R|\h)*(\\label\{.*?\})/$2\n\n$1/xsg;
        $body =~ s/\\begin\{commandshell\}/\\begin\{verbatim\}style:commandshell/sg;
        $body =~ s/\\end\{commandshell\}/\\end\{verbatim\}/sg;
        $body =~ s/\\begin\{cmhlistings\}\*?/\\begin\{verbatim\}/sg;
        $body =~ s/\\end\{cmhlistings\}(\[.*?\])?/\\end\{verbatim\}/sg;
        $body =~ s/\\begin\{yaml\}(\[.*?\])?(\{.*?\})(\[.*?\])?/\\begin\{verbatim\}$2/sg;
        $body =~ s/\\end\{yaml\}/\\end\{verbatim\}/sg;
        $body =~ s/\\lstinline/\\verb/sg;
        $body =~ s/\$\\langle\$\\itshape\{arguments\}\$\\rangle\$/<arguments>/sg;
        $body =~ s/\$\\langle\$\\itshape\{braces\/brackets\}\$\\rangle\$/<braces\/brackets>/sg;
        $body =~ s/\$\\langle\$(.*?)\$\\rangle\$/<$1>/sg;

        # flagbox switch
        $body =~ s/\\flagbox\{(.*?)\}/\n.. describe:: $1\n\n/sg;

        # yaml title
        $body =~ s/\\yamltitle\{(.*?)\}\*?\{(.*?)\}/.. describe:: $1:$2\n\n/sg;

        # labels
        #
        # move the labels ahead of section, subsection, subsubsection
        $body =~ s/(\\section\{.*?\}\h*)(\\label\{.*?\})/$2$1/mg;
        $body =~ s/(\\subsection\{.*?\}\h*)(\\label\{.*?\})/$2$1/mg;
        $body =~ s/(\\subsubsection\{.*?\}\h*)(\\label\{.*?\})/$2$1/mg;

        # move figure label before \\begin{figure}
        $body =~ s/(\\begin\{figure.*?)(\\label\{.*?\})/$2\n\n$1/s;

        # figure
        $body =~ s/\\input\{figure-schematic\}/\\includegraphics\{figure-schematic.png\}/s;
        
        # longtable
        $body =~ s/\\begin\{longtable\}/\\begin\{table\}\n\\begin\{tabular\}/sg;
        $body =~ s/\\end\{longtable\}/\\end\{tabular\}\n\\end\{table\}\n\n/sg;

        # tables can not contain listings 
        $body =~ s/(?!\\lstinline!)(\\begin\{tabular\})((?:(?!(?:\\begin\{tabular)).)*?)(\\end\{tabular\})/
                    my $tabular_begin = $1;
                    my $tabular_body = $2;
                    my $tabular_end = $3;
                    $tabular_body =~ s|\{m\{.3\\linewidth\}@\{\\hspace\{.25cm\}\}m\{.4\\linewidth\}@\{\\hspace\{.25cm\}\}m\{.2\\linewidth\}\}|\{lll\}|s;
                    $tabular_body =~ s|\\begin\{lstlisting\}(.*?)\\end\{lstlisting\}|
                                        my $verb_body=$1;
                                        $verb_body=~s@\R*@@sg;
                                        $verb_body=~s@^\[.*?\]@@s;
                                        $verb_body=~s@\h*$@@sg;
                                        "\\verb!".$verb_body."!";|sgex;
                    $tabular_body =~ s|\\\\\\cmidrule|\n\\\\\\cmidrule|sg;
                    my $caption = q();
                    if ($tabular_body =~ m|\\caption.*$|m){
                        $tabular_body =~ s|(\\caption.*)$||m;
                        $caption = $1;
                    }
                    $caption.$tabular_begin.$tabular_body.$tabular_end; /xesg;
        
        # 
        $body =~ s/(\\label\{.*?\})/\n\n$1\n\n/sg;
        $body =~ s/\\label/\\cmhlabel/sg;

        # line numbers for defaulSettings
        for (@namesAndOffsets){
            my $firstLine = ${$_}{firstLine}; 
            my $lastLine = $firstLine + ${$_}{numberOfLines}; 
            $body =~ s/\*?\[style\h*=\h*${$_}{name}\h*,?\]\*?/\{$firstLine\}\{$lastLine\}/sg;
        }

        # can't have back to back verbatim
        $body =~ s/(\\end\{verbatim\}(?:\h|\R)*)(\\cmhlistings.*?)$((?:\h|\R)*[a-zA-Z]+\h)/$1\n\n$3\n\n$2\n\n/smg; 

        # the spade, heart, diamonds and club issues
        $body =~ s|\(\*@\$\\BeginStartsOnOwnLine\$@\*\)|♠|gs;
        $body =~ s|\$\\BeginStartsOnOwnLine\$|♠|gs;

        $body =~ s|\(\*@\$\\BodyStartsOnOwnLine\$@\*\)|♥|gs;
        $body =~ s|\$\\BodyStartsOnOwnLine\$|♥|gs;

        $body =~ s|\(\*@\$\\EndStartsOnOwnLine\$@\*\)|◆|gs;
        $body =~ s|\$\\EndStartsOnOwnLine\$|◆|gs;

        $body =~ s|\(\*@\$\\EndFinishesWithLineBreak\$@\*\)|♣|gs;
        $body =~ s|\$\\EndFinishesWithLineBreak\$|♣|gs;

        $body =~ s|\(\*@\$\\ElseStartsOnOwnLine\$@\*\)|★|gs;
        $body =~ s|\$\\ElseStartsOnOwnLine\$|★|gs;

        $body =~ s|\(\*@\$\\ElseFinishesWithLineBreak\$@\*\)|□|gs;
        $body =~ s|\$\\ElseFinishesWithLineBreak\$|□|gs;

        $body =~ s|\(\*@\$\\OrStartsOnOwnLine\$@\*\)|▲|gs;
        $body =~ s|\$\\OrStartsOnOwnLine\$|▲|gs;

        $body =~ s|\(\*@\$\\OrFinishesWithLineBreak\$@\*\)|▼|gs;
        $body =~ s|\$\\OrFinishesWithLineBreak\$|▼|gs;

        $body =~ s|\(\*@\$\\EqualsStartsOnOwnLine\$@\*\)|●|gs;
        $body =~ s|\$\\EqualsStartsOnOwnLine\$|●|gs;

        $body =~ s|\\faCheck|yes|gs;
        $body =~ s|\\faClose|no|gs;

        # output the file
        open(OUTPUTFILE,">",$fileName);
        print OUTPUTFILE $body;
        close(OUTPUTFILE);

        system("./pandoc-tex-files.sh $fileName");
    }
    
    # convert the images, if necessary
    system("./convert-figures-to-png.sh");


}
exit; 
