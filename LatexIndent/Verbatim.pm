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
our $verbatimCounter;

sub find_noindent_block{
    my $self = shift;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # noindent block
    # noindent block
    # noindent block
    $self->logger('looking for NOINDENTBLOCk environments (see noIndentBlock)','heading');
    $self->logger(Dumper(\%{$masterSettings{noIndentBlock}}),'trace');
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

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # verbatim environments
    # verbatim environments
    # verbatim environments
    $self->logger('looking for VERBATIM environments (see verbatimEnvironments)','heading');
    $self->logger(Dumper(\%{$masterSettings{verbatimEnvironments}}),'trace');
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
            if(${$self}{body} =~ m/${$child}{id}/mx){

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','heading.ttrace');
                $self->logger(${$self}{body},'ttrace');

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

sub create_unique_id{
    my $self = shift;

    $verbatimCounter++;
    ${$self}{id} = "${$self->get_tokens}{verbatim}$verbatimCounter${$self->get_tokens}{endOfToken}";
    return;
}

1;
