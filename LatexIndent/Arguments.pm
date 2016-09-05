# Arguments.pm
#   creates a class for the Argument objects
#   which are a subclass of the Document object.
package LatexIndent::Arguments;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_opt_mand_arguments/;
our $ArgumentCounter;

sub indent{
    my $self = shift;
    $self->logger("Arguments object doesn't receive any direct indentation, but its children will...",'heading');
    return;
}

sub find_opt_mand_arguments{
    my $self = shift;

    my $optAndMandRegExp = qr/
                            ^                      # begins with
                             (                     # capture into $1
                                (                  
                                   (
                                       \h*         # 0 or more spaces
                                       \R*         # 0 or more line breaks
                                       (?<!\\)     # not immediately pre-ceeded by \
                                       \[
                                           .*?
                                       (?<!\\)     # not immediately pre-ceeded by \
                                       \]          # [optional arguments]
                                   )
                                   |               # OR
                                   (
                                       \h*         # 0 or more spaces
                                       \R*         # 0 or more line breaks
                                       (?<!\\)     # not immediately pre-ceeded by \
                                       \{
                                           .*?
                                       (?<!\\)     # not immediately pre-ceeded by \
                                       \}          # {mandatory arguments}
                                   )
                                )
                                +                  # at least one of the above
                                (\R*)
                             )                  
                             /sx;

        if(${$self}{body} =~ m/$optAndMandRegExp/){
            $self->logger("Optional/Mandatory arguments found in ${$self}{name}: $1",'heading');

            # create a new Arguments object
            # The arguments object is a little different to most
            # other objects, as it is created purely for its children,
            # so some of the properties common to other objects, such 
            # as environment, ifelsefi, etc do not exist for Arguments;
            # they will, however, exist for its children: OptionalArgument, MandatoryArgument
            my $arguments = LatexIndent::Arguments->new(begin=>"",
                                                    name=>${$self}{name}.":arguments",
                                                    body=>$1,
                                                    linebreaksAtEnd=>{
                                                      end=>$5?1:0,
                                                    },
                                                    end=>"",
                                                    regexp=>$optAndMandRegExp,
                                                  );

            # give unique id
            $arguments->create_unique_id;

            # look for optional arguments
            $arguments->find_optional_arguments;

            # examine *first* child
            if(${$self}{BodyStartsOnOwnLine}==1){
                if(${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}==0){
                    my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
                    my $BeginStringLogFile = ${${${$arguments}{children}}[0]}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                    $self->logger("$BodyStringLogFile = 1, but first argument should not begin on its own line (see $BeginStringLogFile)");
                    $self->logger("Removing line breaks at the end of ${$self}{begin}");
                    ${$self}{begin} =~ s/\R$//s;
                    ${$self}{linebreaksAtEnd}{begin} = 0;
                }
            }

            # the replacement text can be just the ID, but the ID might have a line break at the end of it
            ${$arguments}{replacementText} = ${$arguments}{id};

            # the argument object only needs a trailing line break if the *last* child
            # did not add one at the end, and if BodyStartsOnOwnLine == 1
            if(${${${$arguments}{children}}[-1]}{EndFinishesWithLineBreak}!=1 and ${$self}{BodyStartsOnOwnLine}==1){
                $self->logger("Updating replacementtext to include a linebreak for arguments in ${$self}{name}");
                ${$arguments}{replacementText} .= "\n" if(${$arguments}{linebreaksAtEnd}{end});
            }

            # store children in special hash
            push(@{${$self}{children}},$arguments);

            # remove the environment block, and replace with unique ID
            ${$self}{body} =~ s/${$arguments}{regexp}/${$arguments}{replacementText}/;

            $self->logger(Dumper(\%{$arguments}),'trace');
            $self->logger("replaced with ID: ${$arguments}{id}");
        }

}


sub create_unique_id{
    my $self = shift;

    $ArgumentCounter++;
    ${$self}{id} = "LATEX-INDENT-ARGUMENTS$ArgumentCounter";
    return;
}

1;
