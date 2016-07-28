# IfElseFi.pm
#   creates a class for the IfElseFi objects
#   which are a subclass of the Document object.
package LatexIndent::IfElseFi;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_ifelsefi/;
our %previouslyFoundSettings;
our $ifElseFiCounter;

sub indent{
    my $self = shift;

    # determine the surrounding and current indentation
    $self->determine_total_indentation;

    # indent the body
    $self->indent_body;

    # \else statement adjustment
    my $surroundingIndentation = ${$self}{surroundingIndentation}?${${$self}{surroundingIndentation}}:q();
    if(${$self}{elsePresent} and ${$self}{linebreaksAtEnd}{ifbody}){
            $self->logger("Adding surrounding indentation to \\else statement ('$surroundingIndentation')");
            ${$self}{body} =~ s/\h*\\else/$surroundingIndentation\\else/; 
    }

    # indent the end statement
    $self->indent_end_statement;

    # wrap-up statement
    $self->wrap_up_statement;
    return $self;
}

sub find_ifelsefi{
    my $self = shift;

    # store the regular expresssion for matching and replacing the \if...\else...\fi statements
    # note: we search for \else separately in an attempt to keep this regexp a little more managable
    my $ifElseFiRegExp = qr/
                (
                    \\(
                        if.*?           # ifelsefi name captured into $2
                       )                
                )                       # begin statement is $1
                (
                    \s|\\|\#            # space OR backslash OR #
                )              
                (\R*)?                  # possible line break into $4
                (                       
                    (?:                 
                        (?!             
                            (?:\\if)    
                        ).              # any character, but not \\if                                   
                    )*?                 # non-greedy
                    (\R*)?              # possible line breaks (into $6)    
                )                       # ifelsefi body captured into $5
                (                       
                    \\fi                # \fi statement
                    (?:\h*)?            # possibly followed by horizontal space
                )                       # captured into $7
                (\R)?                   # possibly followed by a line break 
    
    /sx;

    while( ${$self}{body} =~ m/$ifElseFiRegExp/){
      # log file output
      $self->logger("IfElseFi found: $2");

      # create a new Environment object
      my $ifElseFi = LatexIndent::IfElseFi->new(begin=>$1,
                                              name=>$2,
                                              body=>$3.$5,
                                              end=>$7,
                                              linebreaksAtEnd=>{
                                                begin=> ($4)?1:0,
                                                body=> ($6)?1:0,
                                                end=> ($8)?1:0,
                                              },
                                              elsePresent=>0,
                                              modifyLineBreaksYamlName=>"ifElseFi",
                                            );

      # there are a number of tasks common to each object
      $ifElseFi->tasks_common_to_each_object;

      # check for existence of \else statement, and associated line break information
      $ifElseFi->check_for_else_statement;

      # store children in special hash
      ${$self}{children}{${$ifElseFi}{id}}=$ifElseFi;

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/$ifElseFiRegExp/${$ifElseFi}{replacementText}/;

      $self->logger(Dumper(\%{$ifElseFi}),'trace');
      $self->logger("replaced with ID: ${$ifElseFi}{id}");
    } 
    return;
}

sub create_unique_id{
    my $self = shift;

    $ifElseFiCounter++;
    ${$self}{id} = "LATEX-INDENT-IFELSEFI$ifElseFiCounter";
    return;
}

sub check_for_else_statement{
    my $self = shift;
    $self->logger("Looking for \\else statement",'heading.trace');
    if(${$self}{body} =~ m/
                            (\R*)?  # possible line breaks before \else statement
                            \\else  
                            (?:
                                \h*
                            )?     # possible (uncaptured) horizontal space
                            (\R*)? # possible line breaks after \else statement
                            /x){
      $self->logger("found \\else statement, storing line break information:",'trace');
      ${$self}{linebreaksAtEnd}{ifbody} = $1?1:0;
      $self->logger("linebreaksAtEnd of ifbody: ${$self}{linebreaksAtEnd}{ifbody}",'trace');
      ${$self}{linebreaksAtEnd}{else} = $2?1:0;
      $self->logger("linebreaksAtEnd of else: ${$self}{linebreaksAtEnd}{else}",'trace');
      ${$self}{elsePresent}=1;
    }
}

1;
