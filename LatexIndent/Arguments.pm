# Arguments.pm
#   creates a class for the Argument objects
#   which are a subclass of the Document object.
package LatexIndent::Arguments;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_opt_mand_arguments get_arguments_regexp/;
our $ArgumentCounter;

sub indent{
    my $self = shift;
    $self->logger("Arguments object doesn't receive any direct indentation, but its children will...",'heading');
    return;
}

sub find_opt_mand_arguments{
    my $self = shift;

    $self->logger("Searching ${$self}{name} for optional and mandatory arguments",'heading');

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    if(${$self}{body} =~ m/^$optAndMandRegExp\h*($trailingCommentRegExp)?/){
        $self->logger("Optional/Mandatory arguments found in ${$self}{name}: $1",'heading');

        # create a new Arguments object
        # The arguments object is a little different to most
        # other objects, as it is created purely for its children,
        # so some of the properties common to other objects, such 
        # as environment, ifelsefi, etc do not exist for Arguments;
        # they will, however, exist for its children: OptionalArgument, MandatoryArgument
        my $arguments = LatexIndent::Arguments->new(begin=>"",
                                                name=>${$self}{name}.":arguments",
                                                parent=>${$self}{name},
                                                body=>$1,
                                                linebreaksAtEnd=>{
                                                  end=>$2?1:0,
                                                },
                                                end=>"",
                                                regexp=>$optAndMandRegExp,
                                                endImmediatelyFollowedByComment=>$2?0:($3?1:0),
                                              );

        # give unique id
        $arguments->create_unique_id;

        # look for optional arguments
        $arguments->find_optional_arguments;

        # look for mandatory arguments
        $arguments->find_mandatory_arguments;

        # examine *first* child
        #   situation: parent BodyStartsOnOwnLine >= 1, but first child has BeginStartsOnOwnLine == 0 || BeginStartsOnOwnLine == undef
        #   problem: the *body* of parent actually starts after the arguments
        #   solution: remove the linebreak at the end of the begin statement of the parent
        if(defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}>=1){
            if( !(defined ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine} and ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}>=1) 
                    and ${$self}{body} !~ m/^$blankLineToken/){
                my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
                my $BeginStringLogFile = ${${${$arguments}{children}}[0]}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                $self->logger("$BodyStringLogFile = 1 (in ${$self}{name}), but first argument should not begin on its own line (see $BeginStringLogFile)");
                $self->logger("Removing line breaks at the end of ${$self}{begin}");
                ${$self}{begin} =~ s/\R*$//s;
                ${$self}{linebreaksAtEnd}{begin} = 0;
            }
        }

        # examine *first* child
        #   situation: parent BodyStartsOnOwnLine == 0, but first child has BeginStartsOnOwnLine == 1
        #   problem: the *body* of parent actually starts after the arguments
        #   solution: add a linebreak at the end of the begin statement of the parent so that
        #              the child settings are obeyed.
        #              BodyStartsOnOwnLine == 0 will actually be controlled by the last arguments' 
        #              settings of EndFinishesWithLineBreak
        if( (defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}==0) 
            or !(defined ${$self}{BodyStartsOnOwnLine})){
            if(defined ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine} and ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}>=1){
                my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
                my $BeginStringLogFile = ${${${$arguments}{children}}[0]}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                my $BodyValue = ${$self}{BodyStartsOnOwnLine} ? ${$self}{BodyStartsOnOwnLine} : "-1";
                $self->logger("$BodyStringLogFile = $BodyValue (in ${$self}{name}), but first argument *should* begin on its own line (see $BeginStringLogFile)");

                # possibly add a comment at the end of the begin statement
                my $trailingCommentToken = q();
                if(${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}==1){
                    $self->logger("Adding line breaks at the end of ${$self}{begin} (first argument, see $BeginStringLogFile == ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine})");
                } elsif(${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}==2){
                    $self->logger("Adding a % at the end of begin, ${$self}{begin} followed by a linebreak ($BeginStringLogFile == 2)");
                    $trailingCommentToken = "%".$self->add_comment_symbol;
                    $self->logger("Removing trailing space on ${$self}{begin}");
                    ${$self}{begin} =~ s/\h*$//s;
                }

                # modification
                ${$self}{begin} .= "$trailingCommentToken\n";
                ${$self}{linebreaksAtEnd}{begin} = 1;
            }
        }

        # the replacement text can be just the ID, but the ID might have a line break at the end of it
        ${$arguments}{replacementText} = ${$arguments}{id};

        # the argument object only needs a trailing line break if the *last* child
        # did not add one at the end, and if BodyStartsOnOwnLine >= 1
        if( (defined ${${${$arguments}{children}}[-1]}{EndFinishesWithLineBreak} and ${${${$arguments}{children}}[-1]}{EndFinishesWithLineBreak}<1)
            and (defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}>=1) ){
            $self->logger("Updating replacementtext to include a linebreak for arguments in ${$self}{name}");
            ${$arguments}{replacementText} .= "\n" if(${$arguments}{linebreaksAtEnd}{end});
        }

        # store children in special hash
        push(@{${$self}{children}},$arguments);

        # remove the environment block, and replace with unique ID
        ${$self}{body} =~ s/${$arguments}{regexp}/${$arguments}{replacementText}/;

        $self->logger(Dumper(\%{$arguments}),'trace');
        $self->logger("replaced with ID: ${$arguments}{id}");
    } else {
        $self->logger("... no arguments found");
    }

}


sub create_unique_id{
    my $self = shift;

    $ArgumentCounter++;
    ${$self}{id} = "${$self->get_tokens}{arguments}$ArgumentCounter";
    return;
}

sub get_arguments_regexp{

    my $self = shift;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # arguments regexp
    my $optAndMandRegExp = 
                        qr/
                             (                     # capture into $1
                                (?:                  
                                   (?:\h|\R|$blankLineToken|$trailingCommentRegExp)* 
                                   (?:
                                        (?:
                                            \h*         # 0 or more spaces
                                            (?<!\\)     # not immediately pre-ceeded by \
                                            \[
                                                .*?
                                            (?<!\\)     # not immediately pre-ceeded by \
                                            \]          # [optional arguments]
                                        )
                                        |               # OR
                                        (?:
                                            \h*         # 0 or more spaces
                                            (?<!\\)     # not immediately pre-ceeded by \
                                            \{
                                                .*? # not including {
                                            (?<!\\)     # not immediately pre-ceeded by \
                                            \}          # {mandatory arguments}
                                        )
                                   )
                                )
                                +                  # at least one of the above
                                (\R*)
                             )                  
                             /sx;
    return $optAndMandRegExp; 
}

1;
