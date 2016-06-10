# Environment.pm
#   creates a class for the Environment objects
#   which are a subclass of the Document object.
package LatexIndent::Environment;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_environments/;
our %previouslyFoundSettings;

sub indent{
    my $self = shift;
    my $surroundingIndentation = ${$self}{surroundingIndentation}?${${$self}{surroundingIndentation}}:q();

    $self->logger("indenting ENVIRONMENT ${$self}{name}");
    $self->logger("indentation *surrounding* object: '$surroundingIndentation'");
    $self->logger("indentation *of* object: '${$self}{indentation}'");
    $self->logger("*total* indentation to be added: '$surroundingIndentation${$self}{indentation}'");
    my $indentation = $surroundingIndentation.${$self}{indentation};
    ${$self}{indentation} = $indentation;

    # line break stuff
    # line break stuff
    # line break stuff

    # ${$self}{body} =~ s/\R*$//;        # remove line break(s) at end of body

    # remove line break(s) before body
    #${$self}{begin} =~ s/\R*$// if(${$self}{BodyStartsOnOwnLine}==0);       

    # adjust indendation
    ${$self}{body} =~ s/^\h*/$indentation/mg unless(!${$self}{linebreaksAtEnd}{begin});  # add indentation
    ${$self}{end} =~ s/^\h*/$surroundingIndentation/mg unless(!${$self}{linebreaksAtEnd}{body});  # add indentation

    # ${$self}{body} =~ s/\R*//mg;       # remove line break(s) from body
    return $self;
}

sub get_indentation_settings_for_this_object{
    my $self = shift;

    # check for storage of repeated environments
    if ($previouslyFoundSettings{${$self}{name}}){
        $self->logger("Using stored settings for ${$self}{name}",'trace');
    } else {
        my $name = ${$self}{name};
        $self->logger("Storing settings for $name",'trace');

        # get master settings
        $self->masterYamlSettings;

        # check for noAdditionalIndent and indentRules
        # otherwise use defaultIndent
        my $indentation = (${${$self}{settings}{noAdditionalIndent}}{$name})
                                ?
                                q()
                                :
                     (${${$self}{settings}{indentRules}}{$name}
                                ||
                     ${$self}{settings}{defaultIndent});

        # check if the -m switch is active
        $self->get_switches;
        my $modLineBreaksSwitch = ${${$self}{switches}}{modifyLineBreaks}?${${$self}{switches}}{modifyLineBreaks}:0;

        # settings for modifying line breaks, off by default
        my $BeginStartsOnOwnLine = undef;
        my $BodyStartsOnOwnLine = undef;
        my $EndStartsOnOwnLine = undef;
        my $EndFinishesWithLineBreak = undef;

        # if the -m switch is active, update these settings
        if($modLineBreaksSwitch){
                $BeginStartsOnOwnLine = (${${$self}{settings}{modifyLineBreaks}}{everyBeginStartsOnOwnLine}
                                                             or
                                        ${${${$self}{settings}{modifyLineBreaks}}{$name}}{BeginStartsOnOwnLine})
                                            ?  1 : 0;
                $BodyStartsOnOwnLine = (${${$self}{settings}{modifyLineBreaks}}{everyBodyStartsOnOwnLine}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{BodyStartsOnOwnLine})
                                            ?  1 : 0;
                $EndStartsOnOwnLine =  (${${$self}{settings}{modifyLineBreaks}}{everyEndStartsOnOwnLine}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{EndStartsOnOwnLine})
                                            ?  1 : 0;
                $EndFinishesWithLineBreak =  (${${$self}{settings}{modifyLineBreaks}}{everyEndFinishesWithLineBreak}
                                                             or
                                           ${${${$self}{settings}{modifyLineBreaks}}{$name}}{EndFinishesWithLineBreak})
                                            ?  1 : 0;
        }

        # store the settings
        %{${previouslyFoundSettings}{$name}} = (
                        indentation=>$indentation,
                        modLineBreaksSwitch=>$modLineBreaksSwitch,
                        BeginStartsOnOwnLine=>$BeginStartsOnOwnLine,
                        BodyStartsOnOwnLine=>$BodyStartsOnOwnLine,
                        EndStartsOnOwnLine=>$EndStartsOnOwnLine,
                        EndFinishesWithLineBreak=>$EndFinishesWithLineBreak,
                      );

        # there's no need for the current object to keep all of the settings
        delete ${$self}{settings};
        delete ${$self}{switches};
    }


    # append indentation settings to the ENVIRONMENT object
    while( my ($key,$value)= each %{${previouslyFoundSettings}{${$self}{name}}}){
            ${$self}{$key} = $value;
    }

    return;
}

sub find_environments{
    my $self = shift;
    while( ${$self}{body} =~ m/
                (
                    \\begin\{
                            (.*?)       # environment name captured into $2
                           \}           # \begin{<something>} statement
                            (\R*)?      # possible line breaks (into $3)
                )                       # begin statement captured into $1
                (
                    (?:                 # cluster-only (), don't capture 
                        (?!             # don't include \begin in the body
                            (?:\\begin) # cluster-only (), don't capture
                        ).              # any character, but not \\begin
                    )*?                 # non-greedy
                            (\R*)?      # possible line breaks (into $5)
                )                       # environment body captured into $4
                (
                    \\end\{\2\}         # \end{<something>} statement
                    (\h*)?              # possibly followed by horizontal space
                )                       # captured into $6
                (\R)?                   # possibly followed by a line break 
                /sx){

      # create a new Environment object
      my $env = LatexIndent::Environment->new(begin=>$1,
                                              name=>$2,
                                              body=>$4,
                                              end=>$6,
                                              linebreaksAtEnd=>{
                                                begin=> ($3)?1:0,
                                                body=> ($5)?1:0,
                                                end=> ($8)?1:0,
                                              },
                                            );

      # get settings for this object
      $env->get_indentation_settings_for_this_object;

      $self->logger(Dumper(\%{$env}),'trace');

      # give unique id
      $env->create_unique_id;

      # log file output
      $self->logger("environment found: $2");

      # the replacement text can be just the ID, but the ID might have a line break at the end of it
      my $replacementText = ${$env}{id};

      # add a line break after \begin{statement} if appropriate
      if(${$env}{BodyStartsOnOwnLine} and !${$env}{linebreaksAtEnd}{begin}){
          $self->logger("Adding a linebreak at the end of begin, ${$env}{begin} (see BodyStartsOnOwnLine)");
          ${$env}{begin} .= "\n";       
          ${$env}{linebreaksAtEnd}{begin} = 1;
       }

      # add a line break after body, if appropriate
      if(${$env}{EndStartsOnOwnLine} and !${$env}{linebreaksAtEnd}{body}){
          $self->logger("Adding a linebreak at the end of body, ${$env}{body} (see EndStartsOnOwnLine)");
          ${$env}{body} .= "\n";
          ${$env}{linebreaksAtEnd}{body} = 1;
      }

      # line break checks after \end{statement} if appripriate
      if(${$env}{EndFinishesWithLineBreak} and !${$env}{linebreaksAtEnd}{end}){
          $self->logger("Adding a linebreak at the end of ${$env}{end} (see EndFinishesWithLineBreak)");
          ${$env}{end} =~ s/\h*//g;
          ${$env}{linebreaksAtEnd}{end} = 1;
          $replacementText .= "\n";
      }

      # store children in special hash
      ${$self}{children}{${$env}{id}}=$env;

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/
                (\\begin\{(.*?)\}   # the \begin{<something>} statement
                (\R*)?)             # possible line breaks
                (((?!(\\begin)).)*?)
                (\\end\{\2\}(\h*)?)       # the \end{<something>} statement
                /$replacementText/sx;

      $self->logger("replaced with ID: ${$env}{id}");
    } 
    return;
}

1;
