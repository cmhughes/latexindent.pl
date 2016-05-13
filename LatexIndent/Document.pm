package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;
use Data::UUID;

# gain access to subroutines in the following modules
use LatexIndent::Logfile qw/logger output_logfile/;
use LatexIndent::GetYamlSettings qw/masterYamlSettings readSettings/;

sub new{
    # Create new objects, with optional key/value pairs
    # passed as initializers.
    #
    # See Programming Perl, pg 319
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {@_};
    bless ($self,$class);
    return $self;
}

sub find_verbatim_environments{
    my $self = shift;

    # get user settings
    $self->masterYamlSettings;

    # noindent block
    # noindent block
    # noindent block
    $self->logger('looking for NOINDENTBLOCk environments (see noIndentBlock)','heading');
    $self->logger(Dumper(\%{%{%{$self}{settings}}{noIndentBlock}}),'verbose');
    while( my ($noIndentBlock,$yesno)= each %{%{%{$self}{settings}}{noIndentBlock}}){
        if($yesno){
            $self->logger("looking for $noIndentBlock:$yesno environments");

            while( ${$self}{body} =~ m/
                            (
                                %\*
                                (?: \s*)?
                                \\begin\{
                                        $noIndentBlock  # environment name captured into $2
                                       \}               # %* \begin{noindentblock} statement
                            )
                            (
                                .*?
                            )                           # non-greedy match (body)
                            (\R*)?                      # possible line breaks
                            (
                                (\s*)?                  # possible spaces
                                %\*                     # %*
                                (?: \s*)?               # possible spaces
                                \\end\{$noIndentBlock\} # \end{noindentblock}
                            )                           # %* \end{<something>} statement
                        /sx){

              # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
              my $uuid1 = Data::UUID->new->create_str();

              # create a new Environment object
              my $env = LatexIndent::Verbatim->new(id=>$uuid1,
                                                      begin=>$1,
                                                      name=>$noIndentBlock,
                                                      body=>$2.($3?$3:q()),
                                                      end=>($5?$5:q()).$4,
                                                    );
              ${$self}{verbatim}{$uuid1}=$env;

              # log file output
              $self->logger("NOINDENTBLOCK environment found: $noIndentBlock");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/
                            (
                                %\*
                                (?: \s*)?
                                \\begin\{
                                    ($noIndentBlock)    # environment name captured into $2
                                   \}                   # %* \begin{<something>} statement
                            )
                            (
                                .*
                            )?                          # non-greedy match up until
                            (
                                (?:\s*)                 # possibly having space before
                                %\*                     # %*
                                (?: \s*)?               # possibly followed by space
                                \\end\{$noIndentBlock\}
                            )                           # %* \end{<something>} statement
                        /$uuid1/sx;

              $self->logger("replaced with ID: ${$env}{id}");
            } 
      } else {
            $self->logger("*not* looking for $noIndentBlock as $noIndentBlock:$yesno");
      }
    }

    # verbatim environments
    # verbatim environments
    # verbatim environments
    $self->logger('looking for VERBATIM environments (see verbatimEnvironments)','heading');
    $self->logger(Dumper(\%{%{%{$self}{settings}}{verbatimEnvironments}}),'verbose');
    while( my ($verbEnv,$yesno)= each %{%{%{$self}{settings}}{verbatimEnvironments}}){
        if($yesno){
            $self->logger("looking for $verbEnv:$yesno environments");

            while( ${$self}{body} =~ m/
                            (
                            \\begin\{
                                    $verbEnv    # environment name captured into $2
                                   \}           # \begin{<something>} statement
                            )
                            (
                                .*
                            )?                  # any character, but not \\begin
                            (
                                \\end\{$verbEnv\}
                            )                   # \end{<something>} statement
                        /sx){

              # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
              my $uuid1 = Data::UUID->new->create_str();

              # create a new Environment object
              my $env = LatexIndent::Verbatim->new(id=>$uuid1,
                                                      begin=>$1,
                                                      name=>$verbEnv,
                                                      body=>$2,
                                                      end=>$3,
                                                    );
              ${$self}{verbatim}{$uuid1}=$env;

              # log file output
              $self->logger("VERBATIM environment found: $verbEnv");

              # remove the environment block, and replace with unique ID
              ${$self}{body} =~ s/
                            (
                            \\begin\{
                                    ($verbEnv)  # environment name captured into $2
                                   \}           # \begin{<something>} statement
                            )
                            (
                                .*
                            )?                  # any character, but not \\begin
                            (
                                \\end\{$verbEnv\}
                            )                   # \end{<something>} statement
                        /$uuid1/sx;

              $self->logger("replaced with ID: ${$env}{id}");
            } 
      } else {
            $self->logger("*not* looking for $verbEnv as $verbEnv:$yesno");
      }
    }
    return;
}

sub remove_leading_space{
    my $self = shift;
    $self->logger("Removing leading space from entire document (verbatim/noindentblock already accounted for)",'heading');
    ${$self}{body} =~ s/
                        (   
                            ^           # beginning of the line
                            \s*|\t*     # with 0 or more spaces
                        )?              # possibly
                        //mxg;
    return;
}

sub operate_on_file{
    my $self = shift;
    $self->find_verbatim_environments;
    $self->remove_leading_space;
    $self->process_body_of_text;
    $self->put_verbatim_back_in;
    $self->output_logfile;
    print ${$self}{body};
    return
}

sub process_body_of_text{
    my $self = shift;

    # search for environments
    $self->logger('looking for ENVIRONMENTS','heading');
    $self->find_environments;

    # logfile information
    $self->logger(Dumper(\%{$self}),'verbose');
    $self->logger("Operating on: $self",'heading');
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{children}});
    $self->logger('Pre-processed body:','heading');
    $self->logger(${$self}{body});
    $self->logger("Indenting children objects:",'heading');

    # loop through document children hash
    while( (scalar keys %{%{$self}{children}})>0 ){
          while( my ($key,$child)= each %{%{$self}{children}}){
            if(${$self}{body} =~ m/
                        (   
                            ^           # beginning of the line
                            \s*         # with 0 or more spaces
                        )?              # possibly
                                        #
                        ${$child}{id}   # the ID
                        /mx){
                my $indent = $1?$1:q();

                # log file info
                $self->logger("current indentation: '$indent'");
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # perform indentation
                $child->indent($indent);

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','verbose');
                $self->logger(${$self}{body},'verbose');

                # delete the hash so it won't be operated upon again
                delete ${$self}{children}{${$child}{id}};
                $self->logger("  deleted key");
              }
            }
    }

    # logfile info
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{children}});
    $self->logger('Post-processed body:','verbose');
    $self->logger(${$self}{body},'verbose');
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
                )                       # captured into $6
                /sx){

      # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
      my $uuid1 = Data::UUID->new->create_str();

      # create a new Environment object
      my $env = LatexIndent::Environment->new(id=>$uuid1,
                                              begin=>$1,
                                              name=>$2,
                                              body=>$4,
                                              end=>$6,
                                              linebreaksAtEnd=>{
                                                begin=> ($3)?1:0,
                                                body=> ($5)?1:0,
                                                end=> ($7)?1:0,
                                              },
                                              indent=>"     ",
                                            );
      ${$self}{children}{$uuid1}=$env;

      # log file output
      $self->logger("environment found: $2");

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/
                (\\begin\{(.*?)\}   # the \begin{<something>} statement
                (\R*)?)             # possible line breaks
                (((?!(\\begin)).)*?)
                (\\end\{\2\})       # the \end{<something>} statement
                /$uuid1/sx;

      $self->logger("replaced with ID: ${$env}{id}");
    } 
    return;
  }

sub  put_verbatim_back_in {
    my $self = shift;
    # search for environments
    $self->logger('Putting verbatim back in, pre-processed body:','heading');
    $self->logger(${$self}{body});

    # loop through document children hash
    while( (scalar keys %{%{$self}{verbatim}})>0 ){
          while( my ($key,$child)= each %{%{$self}{verbatim}}){
            if(${$self}{body} =~ m/
                        (   
                            ^           # beginning of the line
                            \s*         # with 0 or more spaces
                        )?              # possibly
                                        #
                        ${$child}{id}   # the ID
                        /mx){

                my $indent = $1?$1:q();

                # log file info
                $self->logger("current indentation: '$indent'");
                $self->logger("looking up indentation scheme for ${$child}{name}");

                # perform indentation
                $child->indent($indent);

                # replace ids with body
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;

                # log file info
                $self->logger('Body now looks like:','verbose');
                $self->logger(${$self}{body},'verbose');

                # delete the hash so it won't be operated upon again
                delete ${$self}{verbatim}{${$child}{id}};
                $self->logger("  deleted key");
              }
            }
    }

    # logfile info
    $self->logger("Number of children:",'heading');
    $self->logger(scalar keys %{%{$self}{verbatim}});
    $self->logger('Post-processed body:','verbose');
    $self->logger(${$self}{body},'verbose');
    return;
}

1;
