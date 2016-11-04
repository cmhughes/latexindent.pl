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
                            (
                             (?:               # cluster-only (), don't capture 
                                 (?!           # don't include \begin in the body
                                   (?:\\begin) # cluster-only (), don't capture
                                 ).            # any character, but not \\begin
                             )
                             *?
                            )                  # environment name captured into $2
                           \}                  # \begin{<something>} statement
                           \h*                 # horizontal space
                           (\R*)?              # possible line breaks (into $3)
                )                              # begin statement captured into $1
                (
                    (?:                        # cluster-only (), don't capture 
                        (?!                    # don't include \begin in the body
                            (?:\\begin)        # cluster-only (), don't capture
                        ).                     # any character, but not \\begin
                    )*?                        # non-greedy
                            (\R*)?             # possible line breaks (into $5)
                )                              # environment body captured into $4
                (
                    \\end\{\2\}                # \end{<something>} statement
                    (\h*)?                     # possibly followed by horizontal space
                )                              # captured into $6
                (\R)?                          # possibly followed by a line break 
                /sx;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    while( ${$self}{body} =~ m/$environmentRegExp\h*($trailingCommentRegExp)?/){
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
                                              endImmediatelyFollowedByComment=>$8?0:($9?1:0),
                                            );

      # the settings and storage of most objects has a lot in common
      $self->get_settings_and_store_new_object($env);
    } 
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for arguments
    $self->find_opt_mand_arguments;

    # search for items
    $self->find_items;
}

sub create_unique_id{
    my $self = shift;

    $environmentCounter++;
    ${$self}{id} = "${$self->get_tokens}{environment}$environmentCounter";
    return;
}


1;