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

sub indent{
    my $self = shift;
    my $surroundingIndentation = ${$self}{surroundingIndentation}?${${$self}{surroundingIndentation}}:q();

    $self->logger("indenting ENVIRONMENT ${$self}{name}");
    $self->logger("indentation *surrounding* object: '$surroundingIndentation'");
    $self->logger("indentation *of* object: '${$self}{indentation}'");
    $self->logger("*total* indentation to be added: '$surroundingIndentation${$self}{indentation}'");
    my $indentation = $surroundingIndentation.${$self}{indentation};
    ${$self}{indentation} = $indentation;
    $self->logger(Dumper(\%{$self}),'ttrace');

    # body indendation
    if(${$self}{linebreaksAtEnd}{begin}==1){
        ${$self}{body} =~ s/^\h*/$indentation/mg;  # add indentation
    } elsif(${$self}{linebreaksAtEnd}{begin}==0 and ${$self}{bodyLineBreaks}>0) {
        if(${$self}{body} =~ m/
                            (.*?)      # content of first line
                            \R         # first line break
                            (.*$)      # rest of body
                            /sx){
            my $bodyFirstLine = $1;
            my $remainingBody = $2;
            $self->logger("first line of body: $bodyFirstLine");
            $self->logger("remaining body (before indentation): '$remainingBody'");
    
            # add the indentation to all the body except first line
            $remainingBody =~ s/^/$indentation/mg unless($remainingBody eq '');  # add indentation
            $self->logger("remaining body (after indentation): '$remainingBody'");
    
            # put the body back together
            ${$self}{body} = $bodyFirstLine."\n".$remainingBody; 
        }
    }

    # \end{statement} indentation
    if(${$self}{linebreaksAtEnd}{body}){
        ${$self}{end} =~ s/^\h*/$surroundingIndentation/mg;  # add indentation
        $self->logger("Adding surrounding indentation to ${$self}{end} ('$surroundingIndentation')");
     }

    $self->logger("Finished indenting ${$self}{name}",'heading');
    return $self;
}

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
      $self->logger("environment found: $2");

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
                                              modifyLineBreaksYamlName=>"environments",
                                            );

      # there are a number of tasks common to each object
      $env->tasks_common_to_each_object;

      # store children in special hash
      ${$self}{children}{${$env}{id}}=$env;

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/$environmentRegExp/${$env}{replacementText}/;

      # log file information
      $self->logger(Dumper(\%{$env}),'trace');
      $self->logger("replaced with ID: ${$env}{id}");
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
