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

    # line break checks *after* \end{statement}
    if (defined ${$self}{EndFinishesWithLineBreak}
        and ${$self}{EndFinishesWithLineBreak}==0 
        ) {
        # add a single horizontal space after the child id, otherwise we can end up 
        # with things like
        #       before: 
        #               \fi
        #                   text
        #       after:
        #               \fitext
        $self->logger("Adding a single space after \\fi statement (otherwise \\fi can be comined with next line of text in an unwanted way)",'heading.trace');
        ${$self}{end} =${$self}{end}." ";
    }

    return $self;
}

sub find_ifelsefi{
    my $self = shift;

    # store the regular expresssion for matching and replacing the \if...\else...\fi statements
    # note: we search for \else separately in an attempt to keep this regexp a little more managable
    my $ifElseFiRegExp = qr/
                    (
                        \\
                            (@?if[a-zA-Z@]*?)
                        (\R*)
                    )                            # begin statement, e.g \ifnum, \ifodd
                    (
                        (?:
                            \\(?!if)|\R|\s|\#|!-!   # up until a \\, linebreak # or !-!, which is 
                        )                        # part of the tokens used for latexindent
                        (?: 
                            (?!\\if).
                        )*?                      # body, which can't include another \if
                    )
                    (\R*)                        # linebreaks after body
                    (
                        \\fi                     # \fi statement 
                        \h*                      # 0 or more horizontal spaces
                    )
                    (\R*)                        # linebreaks after \fi
    /sx;

    while( ${$self}{body} =~ m/$ifElseFiRegExp/){
      # log file output
      $self->logger("IfElseFi found: $2");

      # create a new Environment object
      my $ifElseFi = LatexIndent::IfElseFi->new(begin=>$1,
                                              name=>$2,
                                              body=>$4.$5,
                                              end=>"$6",
                                              linebreaksAtEnd=>{
                                                begin=> ($3)?1:0,
                                                body=> ($5)?1:0,
                                                end=> ($7)?1:0,
                                              },
                                              aliases=>{
                                                # begin statements
                                                everyBeginStartsOnOwnLine=>"everyIfStartsOnOwnLine",
                                                BeginStartsOnOwnLine=>"IfStartsOnOwnLine",
                                                # body statements
                                                everyBodyStartsOnOwnLine=>"everyBodyStartsOnOwnLine",
                                                BodyStartsOnOwnLine=>"BodyStartsOnOwnLine",
                                                # end statements
                                                everyEndStartsOnOwnLine=>"everyFiStartsOnOwnLine",
                                                EndStartsOnOwnLine=>"FiStartsOnOwnLine",
                                                # after end statements
                                                everyEndFinishesWithLineBreak=>"everyFiFinishesWithLineBreak",
                                                EndFinishesWithLineBreak=>"FiFinishesWithLineBreak",
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
    ${$self}{id} = "!-!LATEX-INDENT-IFELSEFI$ifElseFiCounter";
    return;
}

sub check_for_else_statement{
    my $self = shift;
    $self->logger("Looking for \\else statement (${$self}{name})",'heading.trace');
    if(${$self}{body} =~ m/
                            (\R*)   # possible line breaks before \else statement
                            \\else  
                            \h*     # possible horizontal space
                            (\R*)   # possible line breaks after \else statement
                            /x){
      $self->logger("found \\else statement, storing line break information:",'trace');

      # linebreaks *before* \else statement
      ${$self}{linebreaksAtEnd}{ifbody} = $1?1:0;
      $self->logger("linebreaksAtEnd of ifbody: ${$self}{linebreaksAtEnd}{ifbody}",'trace');

      # linebreaks *after* \else statement
      ${$self}{linebreaksAtEnd}{else} = $2?1:0;
      $self->logger("linebreaksAtEnd of else: ${$self}{linebreaksAtEnd}{else}",'trace');
      ${$self}{elsePresent}=1;

      # default modifylinebreak values undefined
      ${$self}{ElseStartsOnOwnLine}=undef;

      # check if -m switch is active
      $self->get_switches;

      # return with undefined values unless the -m switch is active
      return  unless(${${$self}{switches}}{modifyLineBreaks});

      # master settings
      $self->masterYamlSettings;
      my %masterSettings = %{${$self}{settings}};

      # name of the object
      my $name = ${$self}{name};

      # name of the object in the modifyLineBreaks yaml (e.g environments, ifElseFi, etc)
      my $modifyLineBreaksYamlName = ${$self}{modifyLineBreaksYamlName};

      # ElseStartsOnOwnLine 
      # ElseStartsOnOwnLine 
      # ElseStartsOnOwnLine 
      my %ElseStartsOnOwnLine= (
                                finalvalue=>undef,
                                every=>{name=>"everyElseStartsOnOwnLine"},
                                custom=>{name=>"ElseStartsOnOwnLine"}
                              );
      $ElseStartsOnOwnLine{every}{value}  = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$ElseStartsOnOwnLine{every}{name}};
      $ElseStartsOnOwnLine{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$ElseStartsOnOwnLine{custom}{name}};
      
      # check for the *every* value
      if (defined $ElseStartsOnOwnLine{every}{value} and $ElseStartsOnOwnLine{every}{value} >= 0){
          $self->logger("$ElseStartsOnOwnLine{every}{name}=$ElseStartsOnOwnLine{every}{value}, (*every* value) adjusting ElseStartsOnOwnLine",'trace');
          $ElseStartsOnOwnLine{finalvalue} = $ElseStartsOnOwnLine{every}{value};
      }
      
      # check for the *custom* value
      if (defined $ElseStartsOnOwnLine{custom}{value}){
          $self->logger("$name: $ElseStartsOnOwnLine{custom}{name}=$ElseStartsOnOwnLine{custom}{value}, (*custom* value) adjusting ElseStartsOnOwnLine",'trace');
          $ElseStartsOnOwnLine{finalvalue} = $ElseStartsOnOwnLine{custom}{value} >=0 ? $ElseStartsOnOwnLine{custom}{value} : undef;
      }

      # update the final value
      ${$self}{ElseStartsOnOwnLine}=$ElseStartsOnOwnLine{finalvalue};

      # possibly modify line break *before* \else statement
      if(defined ${$self}{ElseStartsOnOwnLine}){
          if(${$self}{ElseStartsOnOwnLine}==1 and !${$self}{linebreaksAtEnd}{ifbody}){
              # add a line break after ifbody, if appropriate
              $self->logger("Adding a linebreak before the \\else statement (see ElseStartsOnOwnLine)");
              ${$self}{body} =~ s/\\else/\n\\else/s;
              ${$self}{linebreaksAtEnd}{ifbody} = 1;
          } elsif (${$self}{ElseStartsOnOwnLine}==0 and ${$self}{linebreaksAtEnd}{ifbody}){
              # remove line break *after* ifbody, if appropriate
              $self->logger("Removing linebreak before \\else statement (see ElseStartsOnOwnLine)");
              ${$self}{body} =~ s/\R*(\h*)\\else/$1\\else/sx;
              ${$self}{linebreaksAtEnd}{ifbody} = 0;
          }
      }


      # ElseFinishesWithLineBreak
      # ElseFinishesWithLineBreak
      # ElseFinishesWithLineBreak
      my %ElseFinishesWithLineBreak= (
                                finalvalue=>undef,
                                every=>{name=>"everyElseFinishesWithLineBreak"},
                                custom=>{name=>"ElseFinishesWithLineBreak"}
                              );
      $ElseFinishesWithLineBreak{every}{value}  = ${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$ElseFinishesWithLineBreak{every}{name}};
      $ElseFinishesWithLineBreak{custom}{value} = ${${${$masterSettings{modifyLineBreaks}}{$modifyLineBreaksYamlName}}{$name}}{$ElseFinishesWithLineBreak{custom}{name}};

      # check for the *every* value
      if (defined $ElseFinishesWithLineBreak{every}{value} and $ElseFinishesWithLineBreak{every}{value} >= 0){
          $self->logger("$ElseFinishesWithLineBreak{every}{name}=$ElseFinishesWithLineBreak{every}{value}, (*every* value) adjusting ElseFinishesWithLineBreak",'trace');
          $ElseFinishesWithLineBreak{finalvalue} = $ElseFinishesWithLineBreak{every}{value};
      }
      
      # check for the *custom* value
      if (defined $ElseFinishesWithLineBreak{custom}{value}){
          $self->logger("$name: $ElseFinishesWithLineBreak{custom}{name}=$ElseFinishesWithLineBreak{custom}{value}, (*custom* value) adjusting ElseFinishesWithLineBreak",'trace');
          $ElseFinishesWithLineBreak{finalvalue} = $ElseFinishesWithLineBreak{custom}{value} >=0 ? $ElseFinishesWithLineBreak{custom}{value} : undef;
      }

      # update the final value
      ${$self}{ElseFinishesWithLineBreak}=$ElseFinishesWithLineBreak{finalvalue};

      # possibly modify line break *before* \else statement
      if(defined ${$self}{ElseFinishesWithLineBreak}){
          if(${$self}{ElseFinishesWithLineBreak}==1 and !${$self}{linebreaksAtEnd}{else}){
              # add a line break after else, if appropriate
              $self->logger("Adding a linebreak after the \\else statement (see ElseFinishesWithLineBreak)");
              ${$self}{body} =~ s/\\else\h*/\\else\n/s;
              ${$self}{linebreaksAtEnd}{else} = 1;
          } elsif (${$self}{ElseFinishesWithLineBreak}==0 and ${$self}{linebreaksAtEnd}{else}){
              # remove line break *after* else, if appropriate
              $self->logger("Removing linebreak after \\else statement (see ElseFinishesWithLineBreak)");
              ${$self}{body} =~ s/\\else\h*\R*/\\else/sx;
              ${$self}{linebreaksAtEnd}{else} = 0;
          }
      }


      # there's no need for the current object to keep all of the settings
      delete ${$self}{settings};
      delete ${$self}{switches};
      return;
    } else {
      $self->logger("\\else statement not found",'trace');
    }
}

1;
