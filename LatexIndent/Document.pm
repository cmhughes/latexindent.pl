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
    # print Dumper(\%{$self});
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
            if(${$self}{body} =~ m/(^\s*)?${$child}{id}/m){
                my $indent = ($1?$1:q());
                print "current indentation: '$1'\n";
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
                (.*?)                   # anything before \begin
                (\\begin\{(.*?)\}       # the \begin{<something>} statement
                             (\R*)?)    # possible line breaks
                (((?!(\\begin)).)*?)    # don't include \begin in the body
                (\\end\{\3\})           # the \end{<something>} statement
                (.*)                    # anything after \end
                /sx){

      # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
      my $uuid1 = Data::UUID->new->create_str();

      # create a new Environment object
      my $env = LatexIndent::Environment->new(id=>$uuid1,
                                              begin=>$2,
                                              name=>$3,
                                              body=>$5,
                                              end=>$8,
                                              indent=>"     ",
                                            );
      ${$self}{children}{$uuid1}=$env;

      # log file output
      print "environment found: $3\n";

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
