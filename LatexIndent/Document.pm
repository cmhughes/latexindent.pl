package LatexIndent::Document;
use strict;
use warnings;
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
    print "\n\n ++++++++++++++++\n";
    print "Pre-processed body: \n";
    print ${$self}{body};
    # loop recursively through the children
    foreach my $child (@{${$self}{children}}){
      $child->process_body_of_text;
    }
    $self->indent_objects;
    $self->replace_ids_with_body;
    print "\n\nPost-processed body: \n";
    print ${$self}{body};
    print "\n\n====================\n";
    return;
}

sub find_environments{
    my $self = shift;
    while( ${$self}{body} =~ m/(.*?)(\\begin\{(.*?)\}(\R*)?)(.*)(\\end\{\3\})(.*)/s){
      # generate a unique ID (http://stackoverflow.com/questions/18628244/how-we-can-create-a-unique-id-in-perl)
      my $uuid1 = Data::UUID->new->create_str();

      # create a new Environment object
      my $env = LatexIndent::Environment->new(id=>$uuid1,name=>$3,body=>$5,begin=>$2,end=>$6);
      push( @{${$self}{children}},$env);

      # remove the environment block, and replace with unique ID
      ${$self}{body} =~ s/(\\begin\{(.*?)\}(\R*)?)(.*)(\\end\{\2\})/$uuid1/s;
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
