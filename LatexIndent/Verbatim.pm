# Verbatim.pm
#   creates a class for the Verbatim objects
#   which are a subclass of the Document object.
package LatexIndent::Verbatim;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/put_verbatim_back_in find_verbatim_environments find_noindent_block/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321

sub indent{
    my $self = shift;
    my $previousIndent = shift;
    $self->logger("in verbatim environment ${$self}{name}, not indenting body");
    ${$self}{end} =~ s/(^\h*)/$previousIndent/mg;  # add indentation
    return;
}

sub find_noindent_block{
    my $self = shift;

    # noindent block
    # noindent block
    # noindent block
    $self->logger('looking for NOINDENTBLOCk environments (see noIndentBlock)','heading');
    $self->logger(Dumper(\%{%{%{$self}{settings}}{noIndentBlock}}),'trace');
    while( my ($noIndentBlock,$yesno)= each %{%{%{$self}{settings}}{noIndentBlock}}){
        if($yesno){
            $self->logger("looking for $noIndentBlock:$yesno environments");

            while( ${$self}{body} =~ m/
                            (
                                %
                                (?: \h*)?               # possible horizontal spaces
                                \\begin\{
                                        $noIndentBlock  # environment name captured into $2
                                       \}               # %* \begin{noindentblock} statement
                            )
                            (
                                .*?
                            )                           # non-greedy match (body)
                            (\R*)?                      # possible line breaks
                            (
                                (\h*)?                  # possible horizontal spaces
                                %                       # %
                                (?: \h*)?               # possible horizontal spaces
                                \\end\{$noIndentBlock\} # \end{noindentblock}
                            )                           # %* \end{<something>} statement
                        /sx){

              # create a new Environment object
              my $env = LatexIndent::Verbatim->new( begin=>$1,
                                                    name=>$noIndentBlock,
                                                    body=>$2.($3?$3:q()),
                                                    end=>($5?$5:q()).$4,
                                                    );
            
              # give unique id
              $env->create_unique_id;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$env}{id}}=$env;

              # log file output
              $self->logger("NOINDENTBLOCK environment found: $noIndentBlock");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/
                                %
                                (?: \h*)?
                                \\begin\{
                                    ($noIndentBlock)    # environment name captured into $2
                                   \}                   # %* \begin{<something>} statement
                                .*?                     # non-greedy match up until
                                (?:\h*)                 # possibly having horizontal space before
                                %                       # %
                                (?: \h*)?               # possibly followed by horizontal space
                                \\end\{$noIndentBlock\} # %* \end{<something>} statement
                        /${$env}{id}/sx;

              $self->logger("replaced with ID: ${$env}{id}");
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
    # verbatim environments
    # verbatim environments
    $self->logger('looking for VERBATIM environments (see verbatimEnvironments)','heading');
    $self->logger(Dumper(\%{%{%{$self}{settings}}{verbatimEnvironments}}),'trace');
    while( my ($verbEnv,$yesno)= each %{%{%{$self}{settings}}{verbatimEnvironments}}){
        if($yesno){
            $self->logger("looking for $verbEnv:$yesno environments");

            while( ${$self}{body} =~ m/
                            (
                            \\begin\{
                                    $verbEnv     # environment name captured into $1
                                   \}            # \begin{<something>} statement
                            )
                            (
                                .*?
                            )                    # any character, but not \\begin
                            (\R*)?               # possible line breaks
                            (
                                (\h*)?           # possible horizontal spaces
                                \\end\{$verbEnv\}# \end{<something>} statement
                            )                    
                        /sx){

              # create a new Environment object
              my $env = LatexIndent::Verbatim->new( begin=>$1,
                                                    name=>$verbEnv,
                                                    body=>$2.($3?$3:q()),
                                                    end=>($5?$5:q()).$4,
                                                    );
              # give unique id
              $env->create_unique_id;

              # verbatim children go in special hash
              ${$self}{verbatim}{${$env}{id}}=$env;

              # log file output
              $self->logger("VERBATIM environment found: $verbEnv");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/
                            \\begin\{
                                    ($verbEnv)   # environment name captured into $2
                                   \}            # \begin{<something>} statement
                                .*?
                                \\end\{$verbEnv\}# \end{<something>} statement
                        /${$env}{id}/sx;

              $self->logger("replaced with ID: ${$env}{id}");
            } 
      } else {
            $self->logger("*not* looking for $verbEnv as $verbEnv:$yesno");
      }
    }
    return;
}

sub  put_verbatim_back_in {
    my $self = shift;

    # if there are no verbatim children, return
    return unless(%{$self}{verbatim});

    # search for environments
    $self->logger('Putting verbatim back in, here is the pre-processed body:','heading.trace');
    $self->logger(${$self}{body},'trace');

    # loop through document children hash
    while( (scalar keys %{%{$self}{verbatim}})>0 ){
          while( my ($key,$child)= each %{%{$self}{verbatim}}){
            if(${$self}{body} =~ m/
                        (   
                            ^           # beginning of the line
                            \h*         # with 0 or more horizontal spaces
                        )?              # possibly
                                        #
                        ${$child}{id}   # the ID
                        /mx){

                my $indentation = $1?$1:q();

                # log file info
                $self->logger("Indentation info",'heading');
                $self->logger("current indentation: '$indentation'");
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # perform indentation
                $child->indent($indentation);

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','heading.trace');
                $self->logger(${$self}{body},'trace');

                # delete the hash so it won't be operated upon again
                delete ${$self}{verbatim}{${$child}{id}};
                $self->logger("deleted key");
              }
            }
    }

    # logfile info
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{verbatim}});
    $self->logger('Post-processed body:','heading.trace');
    $self->logger(${$self}{body},'trace');
    return;
}

1;
