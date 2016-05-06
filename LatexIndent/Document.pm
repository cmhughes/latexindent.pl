package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;
use Data::UUID;
our @logFileNotes;

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

sub operate_on_file{
  my $self = shift;
  $self->logger('latexindent.pl version 3.0','heading');
  $self->process_body_of_text;
  $self->output_logfile;
  print ${$self}{body};
  return
}

sub process_body_of_text{
    my $self = shift;
    $self->logger('looking for environments','heading');
    $self->find_environments;
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
                $self->logger("indenting ${$child}{name}");
                $self->logger("current indentation: '$indent'");

                # perform indentation
                $child->indent($indent);
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

sub logger{
    shift;
    my $line = shift;
    my $infoLevel = shift;
    push(@logFileNotes,{line=>$line,level=>$infoLevel?$infoLevel:'default'});
    return
}

sub output_logfile{
  my $logfile;
  open($logfile,">","indent.log") or die "Can't open indent.log";
  foreach my $line (@logFileNotes){
        if(${$line}{level} eq 'heading'){
            print $logfile ${$line}{line},"\n";
          } elsif(${$line}{level} eq 'default') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            print $logfile ${$line}{line},"\n";
          } elsif(${$line}{level} eq 'verbose') {
            # add tabs to the beginning of lines 
            # for default logfile lines
            ${$line}{line} =~ s/^/\t/mg;
            #print $logfile ${$line}{line},"\n";
          }
  }
  close($logfile);
}

sub indent_objects{
    my $self = shift;
    foreach my $child (@{${$self}{children}}){
      $child->indent;
    }
    return;
}

sub replace_ids_with_body{
    my $self = shift;
    foreach my $child (@{${$self}{children}}){
        ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;
    }
    return;
}

1;
