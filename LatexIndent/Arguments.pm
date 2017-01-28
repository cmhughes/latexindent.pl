# Arguments.pm
#   creates a class for the Argument objects
#   which are a subclass of the Document object.
package LatexIndent::Arguments;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/get_arguments_regexp find_opt_mand_arguments get_numbered_arg_regexp construct_arguments_regexp $optAndMandRegExp/;
our $ArgumentCounter;
our $optAndMandRegExp; 
our $optAndMandRegExpWithLineBreaks; 

sub construct_arguments_regexp{
    my $self = shift;

    $optAndMandRegExp = $self->get_arguments_regexp;

    $optAndMandRegExpWithLineBreaks = $self->get_arguments_regexp(mode=>"lineBreaksAtEnd");
}

sub indent{
    my $self = shift;
    $self->logger("Arguments object doesn't receive any direct indentation, but its children will...",'heading') if $is_t_switch_active;
    return;
}

sub find_opt_mand_arguments{
    my $self = shift;

    $self->logger("Searching ${$self}{name} for optional and mandatory arguments",'heading') if $is_t_switch_active;

    # blank line token
    my $blankLineToken = $tokens{blanklines};

    if(${$self}{body} =~ m/^$optAndMandRegExpWithLineBreaks\h*($trailingCommentRegExp)?/){
        $self->logger("Optional/Mandatory arguments found in ${$self}{name}: $1",'heading') if $is_t_switch_active;

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
                                                regexp=>$optAndMandRegExpWithLineBreaks,
                                                endImmediatelyFollowedByComment=>$2?0:($3?1:0),
                                              );

        # give unique id
        $arguments->create_unique_id;

        # determine which comes first, optional or mandatory
        ${$arguments}{body} =~ m/.*?((?<!\\)\{|\[)/s;

        if($1 eq "\["){
            $self->logger("Searching for optional arguments, and then mandatory (optional found first)") if $is_t_switch_active;
            # look for optional arguments
            $arguments->find_optional_arguments;

            # look for mandatory arguments
            $arguments->find_mandatory_arguments;
        } else {
            $self->logger("Searching for mandatory arguments, and then optional (mandatory found first)") if $is_t_switch_active;
            # look for mandatory arguments
            $arguments->find_mandatory_arguments;

            # look for optional arguments
            $arguments->find_optional_arguments;
        }

        # examine *first* child
        #   situation: parent BodyStartsOnOwnLine >= 1, but first child has BeginStartsOnOwnLine == 0 || BeginStartsOnOwnLine == undef
        #   problem: the *body* of parent actually starts after the arguments
        #   solution: remove the linebreak at the end of the begin statement of the parent
        if(defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}>=1){
            if( !(defined ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine} and ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}>=1) 
                    and ${$self}{body} !~ m/^$blankLineToken/){
                my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
                my $BeginStringLogFile = ${${${$arguments}{children}}[0]}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                $self->logger("$BodyStringLogFile = 1 (in ${$self}{name}), but first argument should not begin on its own line (see $BeginStringLogFile)") if $is_t_switch_active;
                $self->logger("Removing line breaks at the end of ${$self}{begin}") if $is_t_switch_active;
                ${$self}{begin} =~ s/\R*$//s;
                ${$self}{linebreaksAtEnd}{begin} = 0;
            }
        }

        # situation: preserveBlankLines is active, so the body may well begin with a blank line token
        #            which means that ${$self}{linebreaksAtEnd}{begin} *should be* 1
        if(${${${$arguments}{children}}[0]}{body} =~ m/^($blankLineToken)/){
            $self->logger("Updating {linebreaksAtEnd}{begin} for ${$self}{name} as $blankLineToken or blank line found at beginning of argument child") if $is_t_switch_active;
            ${$self}{linebreaksAtEnd}{begin} = 1 
          }

        # examine *first* child
        #   situation: parent BodyStartsOnOwnLine == -1, but first child has BeginStartsOnOwnLine == 1
        #   problem: the *body* of parent actually starts after the arguments
        #   solution: add a linebreak at the end of the begin statement of the parent so that
        #              the child settings are obeyed.
        #              BodyStartsOnOwnLine == 0 will actually be controlled by the last arguments' 
        #              settings of EndFinishesWithLineBreak
        if( ${$self}{linebreaksAtEnd}{begin} == 0
           and ((defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}==-1) 
                    or !(defined ${$self}{BodyStartsOnOwnLine})) 
              ){
            if(defined ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine} and ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}>=1){
                my $BodyStringLogFile = ${$self}{aliases}{BodyStartsOnOwnLine}||"BodyStartsOnOwnLine";
                my $BeginStringLogFile = ${${${$arguments}{children}}[0]}{aliases}{BeginStartsOnOwnLine}||"BeginStartsOnOwnLine";
                my $BodyValue = (defined ${$self}{BodyStartsOnOwnLine}) ? ${$self}{BodyStartsOnOwnLine} : "0";
                $self->logger("$BodyStringLogFile = $BodyValue (in ${$self}{name}), but first argument *should* begin on its own line (see $BeginStringLogFile)") if $is_t_switch_active;

                # possibly add a comment at the end of the begin statement
                my $trailingCommentToken = q();
                if(${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}==1){
                    $self->logger("Adding line breaks at the end of ${$self}{begin} (first argument, see $BeginStringLogFile == ${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine})") if $is_t_switch_active;
                } elsif(${${${$arguments}{children}}[0]}{BeginStartsOnOwnLine}==2){
                    $self->logger("Adding a % at the end of begin, ${$self}{begin} followed by a linebreak ($BeginStringLogFile == 2)") if $is_t_switch_active;
                    $trailingCommentToken = "%".$self->add_comment_symbol;
                    $self->logger("Removing trailing space on ${$self}{begin}") if $is_t_switch_active;
                    ${$self}{begin} =~ s/\h*$//s;
                }

                # modification
                ${$self}{begin} .= "$trailingCommentToken\n";
                ${$self}{linebreaksAtEnd}{begin} = 1;
            }
        }

        # the replacement text can be just the ID, but the ID might have a line break at the end of it
        ${$arguments}{replacementText} = ${$arguments}{id};

        # children need to receive ancestor information, see test-cases/commands/commands-triple-nested.tex
        foreach (@{${$arguments}{children}}){
            $self->logger("Updating argument children of ${$self}{name} to include ${$self}{id} in ancestors") if $is_t_switch_active;
            push(@{${$_}{ancestors}},{ancestorID=>${$self}{id},ancestorIndentation=>${$self}{indentation},type=>"natural"});
        }

        # the argument object only needs a trailing line break if the *last* child
        # did not add one at the end, and if BodyStartsOnOwnLine >= 1
        if( (defined ${${${$arguments}{children}}[-1]}{EndFinishesWithLineBreak} and ${${${$arguments}{children}}[-1]}{EndFinishesWithLineBreak}<1)
            and (defined ${$self}{BodyStartsOnOwnLine} and ${$self}{BodyStartsOnOwnLine}>=1) ){
            $self->logger("Updating replacementtext to include a linebreak for arguments in ${$self}{name}") if $is_t_switch_active;
            ${$arguments}{replacementText} .= "\n" if(${$arguments}{linebreaksAtEnd}{end});
        }

        # store children in special hash
        push(@{${$self}{children}},$arguments);

        # remove the environment block, and replace with unique ID
        ${$self}{body} =~ s/${$arguments}{regexp}/${$arguments}{replacementText}/;

        # delete the regexp, as there's no need for it
        delete ${${${$self}{children}}[-1]}{regexp};

        $self->logger(Dumper(\%{$arguments}),'ttrace') if($is_tt_switch_active);
        $self->logger("replaced with ID: ${$arguments}{id}") if $is_t_switch_active;
    } else {
        $self->logger("... no arguments found") if $is_t_switch_active;
    }

}


sub create_unique_id{
    my $self = shift;

    $ArgumentCounter++;
    ${$self}{id} = "$tokens{arguments}$ArgumentCounter$tokens{endOfToken}";
    return;
}

sub get_numbered_arg_regexp{

    # for example #1 #2, etc
    my $numberedArgRegExp = qr/(?:#\d\h*;?)+/;
    return $numberedArgRegExp;
}

sub get_arguments_regexp{

    my $self = shift;
    my %input = @_;

    # blank line token
    my $blankLineToken = $tokens{blanklines};

    # some calls to this routine need to account for the linebreaks at the end, some do not
    my $lineBreaksAtEnd = (defined ${input}{mode} and ${input}{mode} eq 'lineBreaksAtEnd')?'\R*':q();

    # for example #1 #2, etc
    my $numberedArgRegExp = $self->get_numbered_arg_regexp;

    # beamer special
    my $beamerRegExp = qr/\<.*?\>/;

    # arguments regexp
    return qr/
                          (                          # capture into $1
                             (?:                  
                                (?:\h|\R|$blankLineToken|$trailingCommentRegExp|$numberedArgRegExp|$beamerRegExp)* 
                                (?:
                                     (?:
                                         \h*         # 0 or more spaces
                                         (?<!\\)     # not immediately pre-ceeded by \
                                         \[
                                             (?:
                                                 (?!
                                                     (?:(?<!\\)\[|(?<!\\)\{) 
                                                 ).
                                             )*?     # not including [, but \[ ok
                                         (?<!\\)     # not immediately pre-ceeded by \
                                         \]          # [optional arguments]
                                     )
                                     |               # OR
                                     (?:
                                         \h*         # 0 or more spaces
                                         (?<!\\)     # not immediately pre-ceeded by \
                                         \{
                                             (?:
                                                 (?!
                                                     (?:(?<!\\)\{|(?<!\\)\[) 
                                                 ).
                                             )*?     # not including {, but \{ ok
                                         (?<!\\)     # not immediately pre-ceeded by \
                                         \}          # {mandatory arguments}
                                     )
                                )
                             )
                             +                       # at least one of the above
                             # NOT followed by
                             (?!
                               (?:
                                   (?:\h|\R|$blankLineToken|$trailingCommentRegExp|$numberedArgRegExp|$beamerRegExp)*  # 0 or more h-space, blanklines, trailing comments
                                   (?:
                                     (?:(?<!\\)\[)
                                     |
                                     (?:(?<!\\)\{)
                                     |
                                     =
                                   )
                               )
                             )
                             \h*
                             ($lineBreaksAtEnd)
                          )                  
                          /sx;
}

1;
