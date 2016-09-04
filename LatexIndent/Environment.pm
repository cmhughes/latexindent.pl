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
our $environmentCounter;

sub find_environments{
    my $self = shift;

    # store the regular expresssion for matching and replacing the \begin{}...\end{} statements
    my $environmentRegExp = qr/
                (
                    \\begin\{
                            (.*?)       # environment name captured into $2
                           \}           # \begin{<something>} statement
                           (?:          # cluster-only (), don't capture
                            \h*         # horizontal space
                           )?           # possibly
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
                /sx;

    while( ${$self}{body} =~ m/$environmentRegExp/){
      # log file output
      $self->logger("environment found: $2",'heading');

      # create a new Environment object
      my $env = LatexIndent::Environment->new(begin=>$1,
                                              name=>$2,
                                              body=>$4,
                                              end=>$6,
                                              linebreaksAtEnd=>{
                                                begin=>$3?1:0,
                                                body=>$5?1:0,
                                                end=>$8?1:0,
                                              },
                                              modifyLineBreaksYamlName=>"environments",
                                              regexp=>$environmentRegExp,
                                            );

      # there are a number of tasks common to each object
      $env->tasks_common_to_each_object;

      # search for arguments
      $env->find_opt_mand_arguments;

      # store children in special hash
      push(@{${$self}{children}},$env);

      # wrap_up_tasks
      $self->wrap_up_tasks;
    } 
    return;
}

sub create_unique_id{
    my $self = shift;

    $environmentCounter++;
    ${$self}{id} = "LATEX-INDENT-ENVIRONMENT$environmentCounter";
    return;
}


1;
