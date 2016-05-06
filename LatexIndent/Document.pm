package LatexIndent::Document;
use strict;
use warnings;
use Data::Dumper;
use Data::UUID;

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

sub process_body_of_text{
    my $self = shift;
    $self->find_environments;
    #print "\n\n ++++++++++++++++\n";
    print Dumper(\%{$self});
    print "Pre-processed body: \n";
    print ${$self}{body};
    ## loop recursively through the children
    #foreach my $child (@{${$self}{children}}){
    #  $child->process_body_of_text;
    #}
    print $self,"\n";

    # loop through document children hash
    print "number of childs:",scalar keys %{%{$self}{children}},"\n";
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
                print "current indentation: '$indent'\n";
                $child->indent($indent);
                ${$self}{body} =~ s/${$child}{id}/${$child}{begin}${$child}{body}${$child}{end}/;
                delete ${$self}{children}{${$child}{id}};
                print "deleted key\n";
              }
            }
    }
    print "number of childs:",scalar keys %{%{$self}{children}},"\n";
    #$self->indent_objects;
    #$self->replace_ids_with_body;
    print "\n\nPost-processed body: \n";
    print ${$self}{body};
    print "\n\n====================\n";
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
      print "environment found: $2\n";

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/
                (\\begin\{(.*?)\}   # the \begin{<something>} statement
                (\R*)?)             # possible line breaks
                (((?!(\\begin)).)*?)
                (\\end\{\2\})       # the \end{<something>} statement
                /$uuid1/sx;

      # print "replaced with ID: ${$self}{body}\n";
    } 
    return;
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
