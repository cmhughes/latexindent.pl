#!/usr/bin/perl
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
#	See <http://www.gnu.org/licenses/>.

use strict;
use warnings;

# if you don't want to indent an environment
# put it in this hash table
my %noindent=("pccexample"=>1,
                  "pccdefinition"=>1,
                  "problem"=>1,
                  "exercises"=>1,
                  "pccsolution"=>1,
                  "widepage"=>1,
                  "comment"=>1,
                  "document"=>1,
                  "\\\["=>0,
                  "\\\]"=>0,
                  );

# if you have indent rules for particular environments
# put them in here; for example, you might just want 
# to use a space " " or maybe a double tab "\t\t"
my %indentrules=("axis"=>"   ");

# environments that have tab delimeters, add more 
# as needed
my %lookforaligndelims=("tabular"=>1,
                        "align"=>1,
                        "align*"=>1,
                        "cases"=>1,
                        "dcases"=>1,
                        "aligned"=>1);

# commands that might split {} across lines
# such as \parbox, \marginpar, etc
my %checkunmatched=("parbox"=>1,
                    "vbox"=>1,
                    "marginpar"=>1,
                    "foreach"=>1);

# scalar variables
my $defaultindent="\t";     # $defaultindent: Default value of indentation
my $line='';                # $line: takes the $line of the file
my $inpreamble=1;           # $inpreamble: switch to determine if in
                            #               preamble or not
my $delimeters=0;           # $delimeters: switch that governs if
                            #              we need to check for & or not
my $matchedbraces=0;        # $matchedbraces: counter to see if { }
                            #               are matched; it will be 
                            #               positive if too many { 
                            #               negative if too many }
                            #               0 if matched
my $commandname='';         # $commandname: either \parbox, \marginpar,
                            #               or anything else from %checkunmatched

# array variables
my @indent=();              # @indent: stores indentation
my @lines=();               # @lines: stores the newly indented lines
my @block=();               # @block: stores blocks that have & delimeters
my @commandstore=();        # @commandstore: stores commands that 
                            #           have split {} across lines
my @matchbracestore=();     # @matchbracestore: stores the counters used
                            #           to match { and }, for e.g \parbox
my @mainfile=();            # @mainfile: stores input file; used to 
                            #            grep for \documentclass



# check to see if the current file has \documentclass, if so, then 
# it's the main file, if not, then it doesn't have preamble
open(MAINFILE, $ARGV[0]) or die "Could not open input file";
    @mainfile=<MAINFILE>;
close(MAINFILE);
if(scalar(@{[grep(m/^\s*\\documentclass/, @mainfile)]})==0)
{
    $inpreamble=0;
}

# loop through the lines in the INPUT file
while(<>)
{
    # check to see if we're still in the preamble
    if(!$inpreamble)
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
    # and make sure we're not working with %\end{something}
    # which is commented
    if( ($_ =~ m/^\s*\\end{(.*?)}/ or $_=~ m/(\\\])/)
         and $_ !~ m/^%/)
    {

       # check to see if we need to turn off alignment
       # delimeters and output the current block
       if($lookforaligndelims{$1})
       {
           $delimeters=0;

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

       # DECREASE the indentation by 1 level
       if(!$noindent{$1})
       {
            pop(@indent);
        }
    }

    # check to see if we're at the end of a \parbox, \marginpar
    # or other split-across-lines command and check that
    # we're not starting another command that has split braces (nesting)
    if(scalar(@matchbracestore) 
        and !($_ =~ m/^\s*\\(.*?)(\[|{|\s)/ and scalar($checkunmatched{$1}))
       )
    {
       # get the most recent value of $matchedbraces
       # and $commandname
       $matchedbraces = pop(@matchbracestore);
       $commandname = pop(@commandstore);

       # match { but don't match \{
       $matchedbraces++ while ($_ =~ /(?<!\\){/g);
       # match } but don't match \}
       $matchedbraces-- while ($_ =~ /(?<!\\)}/g);

       # if we've matched up the braces then
       # we can decrease the indent by 1 level
       if($matchedbraces == 0 and !$noindent{$commandname})
       {
            pop(@indent);
       }
       else
       {
           # otherwise we need to enter the new value
           # of $matchedbraces and the value of $command
           # back into storage
           push(@commandstore,$commandname);
           push(@matchbracestore,$matchedbraces);
       }
     }

    # ADD CURRENT LEVEL OF INDENTATION
    # (unless we're in a delimeter-aligned block)
    if(!$delimeters)
    {
        # add current value of indentation to the current line
        # and output it
        $_ = join("",@indent).$_;
        push(@lines,$_);
    }
    else
    {
        # output to block
        push(@block,$_);
    }

    # check to see if we have \begin{something} or \[ 
    # and make sure we're not working with %\begin{something}
    # which is commented
    if( ($_ =~ m/^\s*\\begin{(.*?)}/ or $_=~ m/^\s*(\\\[)/) 
        and $_ !~ m/^%/)
    {
       # INCREASE the indentation unless the environment 
       # is one that we don't want to indent
       if(!$noindent{$1})
       {
         if(scalar($indentrules{$1}))
         {
            # if there's a rule for indentation for this environment
            push(@indent, $indentrules{$1});
          }
          else
          {
            # default indentation
            push(@indent, $defaultindent);
          }
       }

       # check to see if we need to look for alignment
       # delimeters
       if($lookforaligndelims{$1})
       {
           $delimeters=1;
       }
    }

    # check to see if we have \parbox, \marginpar, or
    # something similar that might split braces {} across lines,
    # specified in %checkunmatched hash table
    #
    # this matches \parbox{...
    #              \parbox[...
    # etc
    #
    # How to read: ^\s*\\(.*?)(\[|{|\s)
    #
    #       ^ line begins with
    #       \s* any (or no)spaces
    #       \\ matches a \
    #       (.*?) non-greedy character match and store the result
    #       (\[|}|\s) either [ or { or a space
    #
    if ($_ =~ m/^\s*\\(.*?)(\[|{|\s)/ and scalar($checkunmatched{$1}))
        {
            # store the command name, because $1
            # will not exist after the next match
            $commandname = $1;
            $matchedbraces=0;

            # match { but don't match \{
            $matchedbraces++ while ($_ =~ /(?<!\\){/g);
            # match } but don't match \}
            $matchedbraces-- while ($_ =~ /(?<!\\)}/g);

            # set the indentation
            if($matchedbraces != 0 and !$noindent{$commandname})
            {
                  # store the command name
                  # and the value of $matchedbraces
                  push(@commandstore,$commandname);
                  push(@matchbracestore,$matchedbraces);

                  if(scalar($indentrules{$commandname}))
                  {
                     # if there's a rule for indentation for this environment
                     push(@indent, $indentrules{$commandname});
                   }
                   else
                   {
                     # default indentation
                     push(@indent, $defaultindent);
                   }
            }
        }
}

# output the formatted lines!
print @lines;


sub format_block{
	# SUBROUTINE
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

        # separate the row at each &
        @tmprow = split("&",$row);
    
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
            $tmpstring = sprintf($fmtstring,split("&",$row)).$linebreak."\n";
        }
        push(@formattedblock,$tmpstring);
    }

    # return the formatted block
	@formattedblock;
}
