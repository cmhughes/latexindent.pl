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
    $self->logger('looking for VERBATIM environments','heading');
    $self->masterYamlSettings;
    print %{%{$self}{settings}}{verbatimEnvironments};
    while( my ($verbEnv,$yesno)= each %{%{$self}{settings}}{verbatimEnvironments}){
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
              ${$self}{children}{$uuid1}=$env;

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
    return
}

sub remove_leading_space{
    my $self = shift;
    $self->logger("removing leading space",'heading');
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
  $self->process_body_of_text;
  $self->output_logfile;
  print ${$self}{body};
  return
}

sub process_body_of_text{
    my $self = shift;
    # search for environments
    $self->logger('looking for environments','heading');
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

1;
