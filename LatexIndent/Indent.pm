# Indent.pm
#   contains subroutines for indentation (can be overwritten for each object, if necessary)
package LatexIndent::Indent;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @EXPORT_OK = qw/indent wrap_up_statement determine_total_indentation indent_body indent_end_statement/;

sub indent{
    my $self = shift;

    # determine the surrounding and current indentation
    $self->determine_total_indentation;

    # indent the body
    $self->indent_body;

    # indent the end statement
    $self->indent_end_statement;

    # wrap-up statement
    $self->wrap_up_statement;
    return $self;
}

sub wrap_up_statement{
    my $self = shift;
    $self->logger("Finished indenting ${$self}{name}",'heading');
    return $self;
  }

sub determine_total_indentation{
    my $self = shift;
    my $surroundingIndentation = ${$self}{surroundingIndentation}?${${$self}{surroundingIndentation}}:q();

    $self->logger("indenting object ${$self}{name}");
    $self->logger("indentation *surrounding* object: '$surroundingIndentation'");
    $self->logger("indentation *of* object: '${$self}{indentation}'");
    $self->logger("*total* indentation to be added: '$surroundingIndentation${$self}{indentation}'");

    ${$self}{indentation} = $surroundingIndentation.${$self}{indentation};
    $self->logger(Dumper(\%{$self}),'ttrace');
    return $self;
}

sub indent_body{
    my $self = shift;

    # grab the indentation of the object
    my $indentation = ${$self}{indentation};

    # output to the logfile
    $self->logger("Body (${$self}{name}) before indentation:\n${$self}{body}","trace");

    # body indendation
    if(${$self}{linebreaksAtEnd}{begin}==1){
        ${$self}{body} =~ s/^(\h*)/$1$indentation/mg;  # add indentation
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

    # output to the logfile
    $self->logger("Body (${$self}{name}) after indentation:\n${$self}{body}","trace");
    return $self;
}

sub indent_end_statement{
    my $self = shift;
    my $surroundingIndentation = ${$self}{surroundingIndentation}?${${$self}{surroundingIndentation}}:q();

    # end{statement} indentation, e.g \end{environment}, \fi, }, etc
    if(${$self}{linebreaksAtEnd}{body}){
        ${$self}{end} =~ s/^\h*/$surroundingIndentation/mg;  # add indentation
        $self->logger("Adding surrounding indentation to ${$self}{end} ('$surroundingIndentation')");
     }
    return $self;
}


1;
