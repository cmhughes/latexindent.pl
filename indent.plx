#!/usr/bin/perl -w
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	For details of how to use this file, please see readme.txt

# Check the number of input arguments- if it is 0 then simply 
# display the list of options (like a manual)
if(scalar(@ARGV) < 1)
{
    print "usage: indent.plx [options] [file][.tex]\n\n";
    print " -o \t output to another file\n";
    print " -w \t overwrite the current file- a backup will be made, but still be careful\n";
    print " -s \t silent mode- no output will be given\n";
    exit(2);
}

# load packages/modules
use strict;
use warnings;           
use FindBin;            # help find defaultSettings.yaml 
use YAML::Tiny;         # interpret defaultSettings.yaml
use File::Copy;         # to copy the original file to backup (if overwrite option set)
use Getopt::Std;        # to get the switches/options/flags

# get the options
my %options=();
getopts("ows", \%options);

# a quick options check
if($options{o} and $options{w})
{
    print "You can't call indent.plx with both -o and -w\n\n";
    print "-o will overwrite the current file\n";
    print "-w will output to another file\n\n";
    print "No indentation done :(\n\n";
    exit(2);
}

# don't call the script with 2 files unless the -o flag is active
if(!$options{o} and scalar(@ARGV)==2)
{
    print "You're calling indent.plx with two file names, but not the -o flag.\n";
    print "Did you mean to use the -o flag ?\n";
    print "Note that this will OVERWRITE the second file\n";
    print "No indentation done :(\n\n";
    exit(2);
}

# if the script is called with the -o switch, then check that 
# a second file is present in the call, e.g
#           indent.plx -o myfile.tex output.tex
if($options{o} and scalar(@ARGV)==1)
{
    print "indent.plx -o",$ARGV[0],"[needs another name here] \n";
    print "No indentation done :(\n\n";
    exit(2);
}

# Create a YAML file
my $defaultSettings = YAML::Tiny->new;

# Open defaultSettings.yaml
$defaultSettings = YAML::Tiny->read( "$FindBin::Bin/defaultSettings.yaml" );

# setup the variables and hashes from the YAML file
my $defaultindent = $defaultSettings->[0]->{defaultindent};
my $alwaysLookforSplitBraces = $defaultSettings->[0]->{alwaysLookforSplitBraces};
my $alwaysLookforSplitBrackets = $defaultSettings->[0]->{alwaysLookforSplitBrackets};
my %lookforaligndelims= %{$defaultSettings->[0]->{lookforaligndelims}};
my %indentrules= %{$defaultSettings->[0]->{indentrules}};
my %verbatimEnvironments= %{$defaultSettings->[0]->{verbatimEnvironments}};
my %noindentblock= %{$defaultSettings->[0]->{noindentblock}};
my %checkunmatched= %{$defaultSettings->[0]->{checkunmatched}};
my %checkunmatchedELSE= %{$defaultSettings->[0]->{checkunmatchedELSE}};
my %checkunmatchedbracket= %{$defaultSettings->[0]->{checkunmatchedbracket}};
my %noAdditionalIndent= %{$defaultSettings->[0]->{noAdditionalIndent}};
my $backupExtension = $defaultSettings->[0]->{backupExtension};

# if we want to over write the current file
# create a backup first
if ($options{w})
{
    my $filename = $ARGV[0];
    my $backupFile = $filename;
    $backupFile =~ s/\.tex/$backupExtension/;
    # need to output these lines to a log file
    #print "Original file: ", $filename,"\n" if (!$options{s});
    #print "Backup file:",$backupFile,"\n" if (!$options{s});
    copy($filename,$backupFile);
}

# scalar variables
my $line='';                # $line: takes the $line of the file
my $inpreamble=1;           # $inpreamble: switch to determine if in
                            #               preamble or not
my $inverbatim=0;           # $inverbatim: switch to determine if in
                            #               a verbatim environment or not
my $delimiters=0;           # $delimiters: switch that governs if
                            #              we need to check for & or not
my $matchedbraces=0;        # $matchedbraces: counter to see if { }
                            #               are matched; it will be 
                            #               positive if too many { 
                            #               negative if too many }
                            #               0 if matched
my $matchedBRACKETS=0;      # $matchedBRACKETS: counter to see if [ ]
                            #               are matched; it will be 
                            #               positive if too many { 
                            #               negative if too many }
                            #               0 if matched
my $commandname='';         # $commandname: either \parbox, \marginpar,
                            #               or anything else from %checkunmatched
my $commanddetails = '';    # $command details: a scalar that stores
                            #               details about the command 
                            #               that splits {} across lines
my $countzeros = '';        # $countzeros:  a counter that helps 
                            #               when determining if we're in
                            #               an else construct
my $lookforelse=0;          # $lookforelse: a boolean to help determine 
                            #               if we need to look for an 
                            #               else construct

# array variables
my @indent=();              # @indent: stores current level of indentation
my @lines=();               # @lines: stores the newly indented lines
my @block=();               # @block: stores blocks that have & delimiters
my @commandstore=();        # @commandstore: stores commands that 
                            #           have split {} across lines
my @commandstorebrackets=();# @commandstorebrackets: stores commands that 
                            #           have split [] across lines
my @mainfile=();            # @mainfile: stores input file; used to 
                            #            grep for \documentclass
my $trailingcomments='';    # $trailingcomments stores the comments at the end of 
                            #           a line 

# check to see if the current file has \documentclass, if so, then 
# it's the main file, if not, then it doesn't have preamble
open(MAINFILE, $ARGV[0]) or die "Could not open input file";
    @mainfile=<MAINFILE>;
close(MAINFILE);

if(scalar(@{[grep(m/^\s*\\documentclass/, @mainfile)]})==0)
{
    $inpreamble=0;
}

# the previous OPEN command puts us at the END of the file
open(MAINFILE, $ARGV[0]) or die "Could not open input file";

# loop through the lines in the INPUT file
while(<MAINFILE>)
{
    # check to see if we're still in the preamble
    # or in a verbatim environment
    if(!($inpreamble or $inverbatim))
    {
        # if not, remove all leading spaces and tabs
        # from the current line
        s/^\ *//; 
        s/^\t*//; 
    }
    else
    {
        # otherwise check to see if we've reached the main
        # part of the document
        if(m/^\s*\\begin{document}/)
        {
            $inpreamble = 0;
        }
    }

    # check to see if we have \end{something} or \]
    &at_end_of_env_or_eq();

    # check to see if we're at the end of a noindent 
    # block %\end{noindent}
    &at_end_noindent();

    # only check for unmatched braces if we're not in
    # a verbatim-like environment
    if(!$inverbatim)
    {
        # The check for closing } and ] relies on counting, so 
        # we have to remove trailing comments so that any {, }, [, ]
        # that are found after % are not counted
        #
        # note that these lines are NOT in @lines, so we
        # have to store the $trailingcomments to put
        # back on after the counting
        #
        # note the use of (?<!\\)% so that we don't match \%
        if ( $_=~ m/(?<!\\)%.*/)
        {
            s/((?<!\\)%.*)//;
            $trailingcomments=$1;
        }

        # check to see if we're at the end of a \parbox, \marginpar
        # or other split-across-lines command and check that
        # we're not starting another command that has split braces (nesting)
        &end_command_or_key_unmatched_braces();

        # check to see if we're at the end of a command that splits 
        # [ ] across lines
        &end_command_or_key_unmatched_brackets();

        # add the trailing comments back to the end of the line
        if(scalar($trailingcomments))
        {
            # some line break magic, http://stackoverflow.com/questions/881779/neatest-way-to-remove-linebreaks-in-perl
            s/\R//;
            $_ = $_ . $trailingcomments."\n" ;
            # empty the trailingcomments
            $trailingcomments='';
        }
    }

    # ADD CURRENT LEVEL OF INDENTATION
    # (unless we're in a delimiter-aligned block)
    if(!$delimiters)
    {
        # make sure we're not in a verbatim block
        if($inverbatim)
        {
           # just push the current line as is
           push(@lines,$_);
        }
        else
        {
            # add current value of indentation to the current line
            # and output it
            $_ = join("",@indent).$_;
            push(@lines,$_);
        }
    }
    else
    {
        # output to @block if we're in a delimiter block
        push(@block,$_);
    }

    # only check for new environments or commands if we're 
    # not in a verbatim-like environment
    if(!$inverbatim)
    {

        # check if we are in a 
        #   % \begin{noindent}
        # block; this is similar to a verbatim block, the user
        # may not want some blocks of code to be touched 
        #
        # IMPORTANT: this needs to go before the trailing comments
        # are removed!
        &at_beg_noindent();

        # remove trailing comments so that any {, }, [, ]
        # that are found after % are not counted
        #
        # note that these lines are already in @lines, so we
        # can remove the trailing comments WITHOUT having
        # to put them back in
        #
        # Note that this won't match \%
        s/(?<!\\)%.*// if( $_=~ m/(?<!\\)%.*/);

        # check to see if we have \begin{something} or \[ 
        &at_beg_of_env_or_eq();

        # check to see if we have \parbox, \marginpar, or
        # something similar that might split braces {} across lines,
        # specified in %checkunmatched hash table
        &start_command_or_key_unmatched_braces();

        # check for an else statement
        &check_for_else();

        # check for a command that splits [] across lines
        &start_command_or_key_unmatched_brackets();
    }
}

# close the main file
close(MAINFILE);

# output the formatted lines to the terminal!
print @lines if(!$options{s});

# if -w is active then output to $ARGV[0]
if($options{w})
{
    open(OUTPUTFILE,">",$ARGV[0]);
    print OUTPUTFILE @lines;
    close(OUTPUTFILE);
}

# if -o is active then output to $ARGV[1]
if($options{o})
{
    open(OUTPUTFILE,">",$ARGV[1]);
    print OUTPUTFILE @lines;
    close(OUTPUTFILE);
}

exit;

sub at_end_noindent{
    # PURPOSE: This matches
    #           % \end{noindent}
    #          the comment symbol IS indended!
    #
    #          This is for blocks of code that the user wants
    #          to leave untouched- similar to verbatim blocks

    if( $_ =~ m/^%\s*\\end{(.*?)}/ and $noindentblock{$1}) 
    {
           $inverbatim = 0;
    }
}

sub at_beg_noindent{
    # PURPOSE: This matches
    #           % \begin{noindent}
    #          the comment symbol IS indended!
    #
    #          This is for blocks of code that the user wants
    #          to leave untouched- similar to verbatim blocks

    if( $_ =~ m/^%\s*\\begin{(.*?)}/ and $noindentblock{$1}) 
    {
           $inverbatim = 1;
    }
}

sub start_command_or_key_unmatched_brackets{
    # PURPOSE: This matches 
    #              \pgfplotstablecreatecol[...
    #
    #              or any other command/key that has brackets [ ] 
    #              split across lines specified in the 
    #              hash tables, %checkunmatchedbracket
    #
    # How to read: ^\s*(\\)?(.*?)(\[\s*)
    #
    #       ^       line begins with
    #       \s*     any (or no)spaces
    #       (\\)?   matches a \ backslash but not necessarily
    #       (.*?)   non-greedy character match and store the result
    #       (\[\s*) match [ possibly leading with spaces

    if ($_ =~ m/^\s*(\\)?(.*?)(\s*\[)/ 
        and (scalar($checkunmatchedbracket{$2})
             or $alwaysLookforSplitBrackets)
        )
        {
            # store the command name, because $2
            # will not exist after the next match
            $commandname = $2;
            $matchedBRACKETS=0;

            # match [ but don't match \[
            $matchedBRACKETS++ while ($_ =~ /(?<!\\)\[/g);
            # match ] but don't match \]
            $matchedBRACKETS-- while ($_ =~ /(?<!\\)\]/g);

            # set the indentation
            if($matchedBRACKETS != 0 )
            {
                  &increase_indent($commandname);

                  # store the command name
                  # and the value of $matchedBRACKETS
                  push(@commandstorebrackets,{commandname=>$commandname,
                                      matchedBRACKETS=>$matchedBRACKETS});

            }
        }
}

sub end_command_or_key_unmatched_brackets{
    # PURPOSE:  Check for the closing BRACKET of a command that 
    #           splits its BRACKETS across lines, such as
    #
    #               \pgfplotstablecreatecol[ ...
    #
    #           It works by checking if we have any entries
    #           in the array @commandstorebrackets, and making 
    #           sure that we're not starting another command/key
    #           that has split BRACKETS (nesting).
    #
    #           It also checks that the line is not commented.
    #
    #           We count the number of [ and ADD to the counter
    #                                  ] and SUBTRACT to the counter
    if(scalar(@commandstorebrackets) 
        and  !($_ =~ m/^\s*(\\)?(.*?)(\s*\[)/ 
                    and (scalar($checkunmatchedbracket{$2})
                         or $alwaysLookforSplitBrackets))
        and $_ !~ m/^\s*%/
       )
    {
       # get the details of the most recent command name
       $commanddetails = pop(@commandstorebrackets);
       $commandname = $commanddetails->{'commandname'};
       $matchedBRACKETS = $commanddetails->{'matchedBRACKETS'};

       # match [ but don't match \[
       $matchedBRACKETS++ while ($_ =~ m/(?<!\\)\[/g);

       # match ] but don't match \]
       $matchedBRACKETS-- while ($_ =~ m/(?<!\\)\]/g);

       # if we've matched up the BRACKETS then
       # we can decrease the indent by 1 level
       if($matchedBRACKETS == 0)
       {
            # decrease the indentation (if appropriate)
            &decrease_indent($commandname);
       }
       else
       {
           # otherwise we need to enter the new value
           # of $matchedBRACKETS and the value of $command
           # back into storage
           push(@commandstorebrackets,{commandname=>$commandname,
                                       matchedBRACKETS=>$matchedBRACKETS});
       }
     }
}

sub start_command_or_key_unmatched_braces{
    # PURPOSE: This matches 
    #              \parbox{...
    #              \parbox[..]..{
    #              empty header/.style={
    #              \foreach \something
    #              etc
    #
    #              or any other command/key that has BRACES
    #              split across lines specified in the 
    #              hash tables, %checkunmatched, %checkunmatchedELSE
    #
    # How to read: ^\s*(\\)?(.*?)(\[|{|\s)
    #
    #       ^                  line begins with
    #       \s*                any (or no) spaces
    #       (\\)?              matches a \ backslash but not necessarily
    #       (.*?)              non-greedy character match and store the result
    #       (\[|}|=|(\s*\\))   either [ or { or = or space \

    if ($_ =~ m/^\s*(\\)?(.*?)(\[|{|=|(\s*\\))/ 
            and (scalar($checkunmatched{$2}) 
                 or scalar($checkunmatchedELSE{$2})
                 or $alwaysLookforSplitBraces)
        )
        {
            # store the command name, because $1
            # will not exist after the next match
            $commandname = $2;
            $matchedbraces=0;

            # by default, don't look for an else construct
            $lookforelse=0;
            if(scalar($checkunmatchedELSE{$2}))
            {
                $lookforelse=1;
            }

            # match { but don't match \{
            $matchedbraces++ while ($_ =~ /(?<!\\){/g);

            # match } but don't match \}
            $matchedbraces-- while ($_ =~ /(?<!\\)}/g);

            # set the indentation
            if($matchedbraces != 0 )
            {
                  &increase_indent($commandname);

                  # store the command name
                  # and the value of $matchedbraces
                  push(@commandstore,{commandname=>$commandname,
                                      matchedbraces=>$matchedbraces,
                                      lookforelse=>$lookforelse,
                                      countzeros=>0});

            }
        }
}

sub end_command_or_key_unmatched_braces{
    # PURPOSE:  Check for the closing BRACE of a command that 
    #           splits its BRACES across lines, such as
    #
    #               \parbox{ ...
    #
    #           or one of the tikz keys, such as
    #           
    #              empty header/.style={
    #
    #           It works by checking if we have any entries
    #           in the array @commandstore, and making 
    #           sure that we're not starting another command/key
    #           that has split BRACES (nesting).
    #
    #           It also checks that the line is not commented.
    #
    #           We count the number of { and ADD to the counter
    #                                  } and SUBTRACT to the counter
    if(scalar(@commandstore) 
        and  !($_ =~ m/^\s*(\\)?(.*?)(\[|{|=|(\s*\\))/ 
                    and (scalar($checkunmatched{$2}) 
                         or scalar($checkunmatchedELSE{$2})
                         or $alwaysLookforSplitBraces))
        and $_ !~ m/^\s*%/
       )
    {
       # get the details of the most recent command name
       $commanddetails = pop(@commandstore);
       $commandname = $commanddetails->{'commandname'};
       $matchedbraces = $commanddetails->{'matchedbraces'};
       $countzeros = $commanddetails->{'countzeros'};
       $lookforelse= $commanddetails->{'lookforelse'};

       # match { but don't match \{
       $matchedbraces++ while ($_ =~ m/(?<!\\){/g);

       # match } but don't match \}
       $matchedbraces-- while ($_ =~ m/(?<!\\)}/g);

       # if we've matched up the braces then
       # we can decrease the indent by 1 level
       if($matchedbraces == 0)
       {
            $countzeros++ if $lookforelse;

            # decrease the indentation (if appropriate)
            &decrease_indent($commandname);

           if($countzeros==1)
           {
                push(@commandstore,{commandname=>$commandname,
                                    matchedbraces=>$matchedbraces,
                                    lookforelse=>$lookforelse,
                                    countzeros=>$countzeros});
           }
       }
       else
       {
           # otherwise we need to enter the new value
           # of $matchedbraces and the value of $command
           # back into storage
           push(@commandstore,{commandname=>$commandname,
                               matchedbraces=>$matchedbraces,
                               lookforelse=>$lookforelse,
                               countzeros=>$countzeros});
       }
     }
}

sub check_for_else{
    # PURPOSE: Check for an else clause
    #
    #          Some commands have the form
    #
    #               \mycommand{
    #                   if this
    #               }
    #               {
    #                   else this
    #               }
    #
    #          so we need to look for the else bit, and set 
    #          the indentation appropriately.
    #
    #          We only perform this check if there's something
    #          in the array @commandstore, and if 
    #          the line itself is not a command, or comment, 
    #          and if it begins with {

    if(scalar(@commandstore) 
        and  !($_ =~ m/^\s*(\\)?(.*?)(\[|{|=)/ 
                    and (scalar($checkunmatched{$2}) 
                         or scalar($checkunmatchedELSE{$2})
                         or $alwaysLookforSplitBraces))
        and $_ =~ m/^\s*{/
        and $_ !~ m/^\s*%/
       )
    {
       # get the details of the most recent command name
       $commanddetails = pop(@commandstore);
       $commandname = $commanddetails->{'commandname'};
       $matchedbraces = $commanddetails->{'matchedbraces'};
       $countzeros = $commanddetails->{'countzeros'};
       $lookforelse= $commanddetails->{'lookforelse'};

       # increase indentation
       if($lookforelse and $countzeros==1)
       {
         &increase_indent($commandname);
       }

       # put the array back together
       push(@commandstore,{commandname=>$commandname,
                           matchedbraces=>$matchedbraces,
                           lookforelse=>$lookforelse,
                           countzeros=>$countzeros});
    }
}

sub at_beg_of_env_or_eq{
    # PURPOSE: Check if we're at the BEGINning of an environment
    #          or at the BEGINning of a displayed equation \[
    #
    #          This subroutine checks for matches of the form
    #
    #               \begin{environmentname}
    #          or
    #               \[
    #
    #          It also checks to see if the current environment
    #          should have alignment delimiters; if so, we need to turn 
    #          ON the $delimiter switch 

    # How to read
    #  m/^\s*(\$)?\\begin{(.*?)}/ 
    #
    #   ^               beginning of a line
    #   \s*             any white spaces (possibly none)
    #   (\$)?           possibly a $ symbol, but not required
    #   \\begin{(.*)?}  \begin{environmentname}
    #
    # How to read
    #  m/^\s*()(\\\[)/
    #
    #  ^        beginning of a line
    #  \s*      any white spaces (possibly none)
    #  ()       empty just so that $1 and $2 are defined
    #  (\\\[)   \[  there are lots of \ because both \ and [ need escaping 

    if( ($_ =~ m/^\s*(\$)?\\begin{(.*?)}/ or $_=~ m/^\s*()(\\\[)/) 
        and $_ !~ m/^\s*%/)
    {
       # increase the indentation 
       &increase_indent($2);

       # check to see if we need to look for alignment
       # delimiters
       if($lookforaligndelims{$2})
       {
           $delimiters=1;
       }

       # check for verbatim-like environments
       if($verbatimEnvironments{$2})
       {
           $inverbatim = 1;
       }
    }
}

sub at_end_of_env_or_eq{
    # PURPOSE: Check if we're at the END of an environment
    #          or at the END of a displayed equation \]
    #
    #          This subroutine checks for matches of the form
    #
    #               \end{environmentname}
    #          or
    #               \]
    #
    #          It also checks to see if the current environment
    #          had alignment delimiters; if so, we need to turn 
    #          OFF the $delimiter switch 
    
    if( ($_ =~ m/^\s*\\end{(.*?)}/ or $_=~ m/(\\\])/)
         and $_ !~ m/\s*^%/)
    {

       # check if we're at the end of a verbatim-like environment
       if($verbatimEnvironments{$1})
       {
           $inverbatim = 0;
       }

       # check to see if we need to turn off alignment
       # delimiters and output the current block
       if($lookforaligndelims{$1})
       {
           $delimiters=0;

           # print the current FORMATTED block
           @block = &format_block(@block);
           foreach $line (@block)
           {
                # add the indentation and add the 
                # each line of the formatted block
                # to the output
                push(@lines,join("",@indent).$line);
           }
           # empty the @block, very important!
           @block=();
       }

       # decrease the indentation (if appropriate)
       &decrease_indent($1);
    }
}

sub format_block{
    #   PURPOSE: Format a delimited environment such as the 
    #            tabular or align environment that contains &
    #
    #   INPUT: @block               array containing unformatted block
    #                               from, for example, align, or tabular
    #   OUTPUT: @formattedblock     array containing FORMATTED block

    # @block is the input
    my @block=@_;

    # local array variables
    my @formattedblock;
    my @tmprow=();
    my @tmpblock=();
    my @maxmstringsize=();

    # local scalar variables
    my $alignrowcounter=-1;
    my $aligncolcounter=-1;
    my $tmpstring='';
    my $row='';
    my $column='';
    my $maxmcolstrlength='';
    my $i='';
    my $j='';
    my $fmtstring='';
    my $linebreak='';

    # local hash table
    my %stringsize=();
    
    # loop through the lines in the @block
    foreach $row (@block)
    {
        # increment row counter
        $alignrowcounter++;

        # clear the $linebreak variable
        $linebreak='';

        # check for line break \\
        # and don't mess with a line that has multicolumn
        if($row =~ m/\\\\/ and $row !~ m/multicolumn/)
        {
          # remove \\ and all characters that follow
          # and put it back in later, once the measurement
          # has been done
          $row =~ s/(\\\\.*)//;
          $linebreak = $1;
        }

        # separate the row at each &, but not at \&
        @tmprow = split(/(?<!\\)&/,$row);
    
        if(scalar(@tmprow)>1 and ($row !~ m/multicolumn/))
        {
            # reset column counter
            $aligncolcounter=-1;

            # loop through each column element
            # removing leading and trailing space
            foreach $column (@tmprow)
            {
               # increment column counter
               $aligncolcounter++;
    
               # remove leading and trailing space from element
    	       $column =~ s/^\s+//;
               $column =~ s/\s+$//;
    
               # assign string size to the array
               $stringsize{$alignrowcounter.$aligncolcounter}=length($column);
               if(length($column)==0)
               {
                 $column=" ";
               }

               # put the row back together
               if ($aligncolcounter ==0)
               {
                 $tmpstring = $column;
               }
               else
               {
                 $tmpstring .= "&".$column;
               }
            }
            
            # put $linebreak back on the string, now that
            # the measurement has been done
            $tmpstring .= $linebreak;
            push(@tmpblock,$tmpstring);
        }
        else
        {
               # if there are no & then use the 
               # NOFORMATTING token
               # remove leading space
    	       s/^\s+//;
               push(@tmpblock,$row."NOFORMATTING");
        }
    }

    # calculate the maximum string size of each column
    for($j=0;$j<=$aligncolcounter;$j++)
    {
        $maxmcolstrlength=0;
        for($i=0; $i<=$alignrowcounter;$i++)
        {
            # make sure the stringsize is defined
            if(defined $stringsize{$i.$j})
            {
                if ($stringsize{$i.$j}>$maxmcolstrlength)
                {
                    $maxmcolstrlength = $stringsize{$i.$j};
                }
            }
        }
        push(@maxmstringsize,$maxmcolstrlength);
    }

    # README: printf( formatting, expression)
    #
    #   formatting has the form %-50s & %-20s & %-19s
    #   (the numbers have been made up for example)
    #       the - symbols mean that each column should be left-aligned
    #       the numbers represent how wide each column is
    #       the s represents string
    #       the & needs to be inserted
    
    # join up the maximum string lengths using "s %-"
    $fmtstring = join("s & %-",@maxmstringsize);
    
    # add an s to the end, and a newline
    $fmtstring .= "s ";
    
    # add %- to the beginning
    $fmtstring = "%-".$fmtstring;
    
    # process the @tmpblock of aligned material
    foreach $row (@tmpblock)
    {
        $linebreak='';
        # check for line break \\
        if($row =~ m/\\\\/)
        {
          # remove \\ and all characters that follow
          # and put it back in later
          $row =~ s/(\\\\.*$)//;
          $linebreak = $1;
        }

        if($row =~ m/NOFORMATTING/)
        {
            $row =~ s/NOFORMATTING//;
            $tmpstring=$row;
        }
        else
        {
          $tmpstring = sprintf($fmtstring,split(/(?<!\\)&/,$row)).$linebreak."\n";
        }
        push(@formattedblock,$tmpstring);
    }

    # return the formatted block
	@formattedblock;
}

sub increase_indent{
       # PURPOSE: Adjust the indentation
       #          of the current environment;
       #          check that it's not an environment
       #          that doesn't want indentation.

       my $command = pop(@_);

       if(scalar($indentrules{$command}))
       {
          # if there's a rule for indentation for this environment
          push(@indent, $indentrules{$command});
       }
       else
       {
          # default indentation
          if(!($noAdditionalIndent{$command} or $verbatimEnvironments{$command} or $inverbatim))
          {
            push(@indent, $defaultindent);
          }
       }
}

sub decrease_indent{
       # PURPOSE: Adjust the indentation
       #          of the current environment;
       #          check that it's not an environment
       #          that doesn't want indentation.

       my $command = pop(@_);

       if(!($noAdditionalIndent{$command} or $verbatimEnvironments{$command} or $inverbatim))
       {
            pop(@indent);
       }
}
