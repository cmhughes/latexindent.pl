# Verbatim.pm
#   creates a class for the Verbatim objects
#   which are a subclass of the Document object.
package LatexIndent::Verbatim;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/put_verbatim_back_in find_verbatim_environments find_noindent_block find_verbatim_commands/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our $verbatimCounter;

sub find_noindent_block{
    my $self = shift;

    # noindent block
    $self->logger('looking for NOINDENTBLOCk environments (see noIndentBlock)','heading');
    $self->logger(Dumper(\%{$masterSettings{noIndentBlock}})) if($is_t_switch_active);
    while( my ($noIndentBlock,$yesno)= each %{$masterSettings{noIndentBlock}}){
        if($yesno){
            $self->logger("looking for $noIndentBlock:$yesno environments");

            my $noIndentRegExp = qr/
                            (
                                (?!<\\)
                                %
                                \h*                     # possible horizontal spaces
                                \\begin\{
                                        $noIndentBlock  # environment name captured into $2
                                       \}               # %* \begin{noindentblock} statement
                            )
                            (
                                .*?
                            )                           # non-greedy match (body)
                            (
                                (?!<\\)
                                %                       # %
                                \h*                     # possible horizontal spaces
                                \\end\{$noIndentBlock\} # \end{noindentblock}
                            )                           # %* \end{<something>} statement
                        /sx;

            while( ${$self}{body} =~ m/$noIndentRegExp/sx){

              # create a new Environment object
              my $noIndentBlock = LatexIndent::Verbatim->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$noIndentBlock,
                                                    );
            
              # give unique id
              $noIndentBlock->create_unique_id;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$noIndentBlock}{id}}=$noIndentBlock;

              # log file output
              $self->logger("NOINDENTBLOCK environment found: $noIndentBlock");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$noIndentRegExp/${$noIndentBlock}{id}/sx;

              $self->logger("replaced with ID: ${$noIndentBlock}{id}");
            } 
      } else {
            $self->logger("*not* looking for $noIndentBlock as $noIndentBlock:$yesno");
      }
    }
    return;
}

sub find_verbatim_environments{
    my $self = shift;

    # verbatim environments
    $self->logger('looking for VERBATIM environments (see verbatimEnvironments)','heading');
    $self->logger(Dumper(\%{$masterSettings{verbatimEnvironments}})) if($is_t_switch_active);
    while( my ($verbEnv,$yesno)= each %{$masterSettings{verbatimEnvironments}}){
        if($yesno){
            $self->logger("looking for $verbEnv:$yesno environments");

            my $verbatimRegExp = qr/
                            (
                            \\begin\{
                                    $verbEnv     # environment name captured into $1
                                   \}            # \begin{<something>} statement
                            )
                            (
                                .*?
                            )                    # any character, but not \\begin
                            (
                                \\end\{$verbEnv\}# \end{<something>} statement
                            )                    
                        /sx;

            while( ${$self}{body} =~ m/$verbatimRegExp/sx){

              # create a new Environment object
              my $verbatimBlock = LatexIndent::Verbatim->new( begin=>$1,
                                                    body=>$2,
                                                    end=>$3,
                                                    name=>$verbEnv,
                                                    );
              # give unique id
              $verbatimBlock->create_unique_id;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$verbatimBlock}{id}}=$verbatimBlock;

              # log file output
              $self->logger("VERBATIM environment found: $verbEnv");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$verbatimRegExp/${$verbatimBlock}{id}/sx;

              $self->logger("replaced with ID: ${$verbatimBlock}{id}");
            } 
      } else {
            $self->logger("*not* looking for $verbEnv as $verbEnv:$yesno");
      }
    }
    return;
}

sub find_verbatim_commands{
    my $self = shift;

    # verbatim commands
    $self->logger('looking for VERBATIM commands (see verbatimCommands)','heading');
    $self->logger(Dumper(\%{$masterSettings{verbatimCommands}})) if($is_t_switch_active);
    while( my ($verbCommand,$yesno)= each %{$masterSettings{verbatimCommands}}){
        if($yesno){
            $self->logger("looking for $verbCommand:$yesno Commands");

            my $verbatimCommandRegExp = qr/
                            (
                                \\$verbCommand     
                                \h*                                             
                            )                                                   # name of command into $1
                            (
                                \[
                                    (?:
                                        (?!
                                            (?:(?<!\\)\[) 
                                        ).
                                    )*?     # not including [, but \[ ok
                                (?<!\\)     # not immediately pre-ceeded by \
                                \]          # [optional arguments]
                                \h*
                            )?                                                  # opt arg into $2
                            (
                              .
                            )                                                   # delimiter into $3
                            (
                              .*?
                            )                                                   # body into $4
                            \3
                        /sx;

            while( ${$self}{body} =~ m/$verbatimCommandRegExp/sx){

              # create a new Environment object
              my $verbatimCommand = LatexIndent::Verbatim->new( begin=>$1.($2?$2:q()).$3,
                                                    body=>$4,
                                                    end=>$3,
                                                    name=>$verbCommand,
                                                    optArg=>$2?$2:q(),
                                                    );
              # give unique id
              $verbatimCommand->create_unique_id;

              # output, if desired
              $self->logger(Dumper($verbatimCommand),'ttrace') if($is_tt_switch_active);

              # verbatim children go in special hash
              ${$self}{verbatim}{${$verbatimCommand}{id}}=$verbatimCommand;

              # log file output
              $self->logger("VERBATIM command found: $verbCommand");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/$verbatimCommandRegExp/${$verbatimCommand}{id}/sx;

              $self->logger("replaced with ID: ${$verbatimCommand}{id}");
            } 
      } else {
            $self->logger("*not* looking for $verbCommand as $verbCommand:$yesno");
      }
    }
    return;

}

sub  put_verbatim_back_in {
    my $self = shift;

    # if there are no verbatim children, return
    return unless(%{$self}{verbatim});

    # search for environments/commands
    $self->logger('Putting verbatim back in, here is the pre-processed body:','heading') if $is_t_switch_active;
    $self->logger(${$self}{body}) if($is_t_switch_active);

    # loop through document children hash
    while( (scalar keys %{%{$self}{verbatim}})>0 ){
          while( my ($key,$child)= each %{%{$self}{verbatim}}){
            if(${$self}{body} =~ m/${$child}{id}/mx){

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','heading') if $is_tt_switch_active;
                $self->logger(${$self}{body},'ttrace') if($is_tt_switch_active);

                # delete the hash so it won't be operated upon again
                delete ${$self}{verbatim}{${$child}{id}};
                $self->logger("deleted key");
              }
            }
    }

    # logfile info
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{verbatim}});
    $self->logger('Post-processed body:','heading') if $is_t_switch_active;
    $self->logger(${$self}{body}) if($is_t_switch_active);
    return;
}

sub create_unique_id{
    my $self = shift;

    $verbatimCounter++;
    ${$self}{id} = "$tokens{verbatim}$verbatimCounter$tokens{endOfToken}";
    return;
}

1;
