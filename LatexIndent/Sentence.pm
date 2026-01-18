package LatexIndent::Sentence;

#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	Chris Hughes, 2017-2025
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use LatexIndent::Tokens           qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings  qw/%mainSettings/;
use LatexIndent::Switches         qw/$is_t_switch_active $is_tt_switch_active $is_m_switch_active/;
use LatexIndent::LogFile          qw/$logger/;
use LatexIndent::Blocks           qw/_find_all_code_blocks/;
use LatexIndent::Environment      qw/$environmentBasicRegExp/;
use LatexIndent::IfElseFi         qw/$ifElseFiBasicRegExp/;
use LatexIndent::Heading          qw/$allHeadingsRegexp/;
use LatexIndent::Special          qw/$specialBeginAndBracesBracketsBasicRegExp/;
use Exporter                      qw/import/;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/one_sentence_per_line mlb_one_sentence_per_line_indent/;
our $sentenceCounter;
our @sentenceStorage;

sub one_sentence_per_line {
    my $self = shift;

    $logger->trace("*one sentence per line info:") if $is_t_switch_active;
    $logger->trace("\ttext-wrap sentences: ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences}")
        if $is_t_switch_active;
    $logger->trace("\tindent sentences: 0") if $is_t_switch_active;
    $logger->trace(
        "one sentence per line regular expression construction: (see oneSentencePerLine: manipulateSentences)")
        if $is_t_switch_active;

    #
    # sentences FOLLOW
    #
    my $sentencesFollow = q();

    while ( my ( $sentencesFollowEachPart, $yesNo )
        = each %{ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesFollow} } )
    {
        if ($yesNo) {
            if ( $sentencesFollowEachPart eq "par" ) {
                $sentencesFollowEachPart = qr/\R?\\par(?![a-zA-Z])/s;
            }
            elsif ( $sentencesFollowEachPart eq "blankLine" ) {
                $sentencesFollowEachPart = qr/
                        (?:\A(?:$tokens{blanklines}\R)+)     # the order of each of these 
                                |                            # is important, as (like always) the first
                        (?:\G(?:$tokens{blanklines}\R)+)     # thing to be matched will 
                                |                            # be accepted
                        (?:(?:$tokens{blanklines}\h*\R)+)
                                |
                                \R{2,}
                                |
                                \G
                        /sx;
            }
            elsif ( $sentencesFollowEachPart eq "fullStop" ) {
                $sentencesFollowEachPart = qr/\./s;
            }
            elsif ( $sentencesFollowEachPart eq "exclamationMark" ) {
                $sentencesFollowEachPart = qr/\!/s;
            }
            elsif ( $sentencesFollowEachPart eq "questionMark" ) {
                $sentencesFollowEachPart = qr/\?/s;
            }
            elsif ( $sentencesFollowEachPart eq "rightBrace" ) {
                $sentencesFollowEachPart = qr/\}/s;
            }
            elsif ( $sentencesFollowEachPart eq "commentOnPreviousLine" ) {
                $sentencesFollowEachPart = qr/$trailingCommentRegExp\h*\R/s;
            }
            elsif ( $sentencesFollowEachPart eq "other" ) {
                $sentencesFollowEachPart = qr/$yesNo/;
            }
            $sentencesFollow .= ( $sentencesFollow eq '' ? q() : "|" ) . qr/$sentencesFollowEachPart/sx;
        }
    }

    # if blankLine is not active from sentencesFollow then we need to set up the
    # beginning of the string, but make sure that it is *not* followed by a
    # blank line token, or a blank line
    if ( !${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesFollow} }{blankLine} ) {
        $sentencesFollow .= ( $sentencesFollow eq '' ? q() : "|" ) . qr/
                                        \G
                                        (?!$tokens{blanklines})
                                    /sx;
    }

    if ( ${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesFollow} }{blankLine} ) {
        $sentencesFollow = ( $sentencesFollow eq '' ? q() : qr/(?:$sentencesFollow)(?:\h|\R)*/sx );
    }
    else {
        $sentencesFollow = ( $sentencesFollow eq '' ? q() : qr/(?:$sentencesFollow)(?:\h*\R?)/sx );
    }

    $logger->trace("Sentences follow regexp:") if $is_tt_switch_active;
    $logger->trace($sentencesFollow)           if $is_tt_switch_active;

    #
    # sentences BEGIN with
    #
    my $sentencesBeginWith = q();

    while ( my ( $sentencesBeginWithEachPart, $yesNo )
        = each %{ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesBeginWith} } )
    {
        if ($yesNo) {
            if ( $sentencesBeginWithEachPart eq "A-Z" ) {
                $logger->trace("sentence BEGINS with capital letters (see oneSentencePerLine:sentencesBeginWith:A-Z)")
                    if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/(?!(?:$tokens{blanklines}|$tokens{verbatim}|$tokens{preamble}))[A-Z]/;
            }
            elsif ( $sentencesBeginWithEachPart eq "a-z" ) {
                $logger->trace(
                    "sentence BEGINS with lower-case letters (see oneSentencePerLine:sentencesBeginWith:a-z)")
                    if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/[a-z]/;
            }
            elsif ( $sentencesBeginWithEachPart eq "other" ) {
                $logger->trace(
                    "sentence BEGINS with other $yesNo (reg exp) (see oneSentencePerLine:sentencesBeginWith:other)")
                    if $is_t_switch_active;
                $sentencesBeginWithEachPart = qr/$yesNo/;
            }
            $sentencesBeginWith .= ( $sentencesBeginWith eq "" ? q() : "|" ) . $sentencesBeginWithEachPart;
        }
    }
    $sentencesBeginWith = qr/$sentencesBeginWith/;

    #
    # sentences END with
    #
    ${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesEndWith} }{basicFullStop} = 0
        if ${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesEndWith} }{betterFullStop};
    my $sentencesEndWith = q();

    while ( my ( $sentencesEndWithEachPart, $yesNo )
        = each %{ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesEndWith} } )
    {
        if ($yesNo) {
            if ( $sentencesEndWithEachPart eq "basicFullStop" ) {
                $logger->trace("sentence ENDS with full stop (see oneSentencePerLine:sentencesEndWith:basicFullStop")
                    if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/\./;
            }
            elsif ( $sentencesEndWithEachPart eq "betterFullStop" ) {
                $logger->trace(
                    "sentence ENDS with *better* full stop (see oneSentencePerLine:sentencesEndWith:betterFullStop")
                    if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/${${$mainSettings{fineTuning}}{modifyLineBreaks}}{betterFullStop}/;
            }
            elsif ( $sentencesEndWithEachPart eq "exclamationMark" ) {
                $logger->trace(
                    "sentence ENDS with exclamation mark (see oneSentencePerLine:sentencesEndWith:exclamationMark)")
                    if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/!/;
            }
            elsif ( $sentencesEndWithEachPart eq "questionMark" ) {
                $logger->trace(
                    "sentence ENDS with question mark (see oneSentencePerLine:sentencesEndWith:questionMark)")
                    if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/\?/;
            }
            elsif ( $sentencesEndWithEachPart eq "other" ) {
                $logger->trace(
                    "sentence ENDS with other $yesNo (reg exp) (see oneSentencePerLine:sentencesEndWith:other)")
                    if $is_t_switch_active;
                $sentencesEndWithEachPart = qr/$yesNo/;
            }
            $sentencesEndWith .= ( $sentencesEndWith eq "" ? q() : "|" ) . $sentencesEndWithEachPart;
        }
    }
    $sentencesEndWith = qr/$sentencesEndWith/;

    #
    # the OVERALL sentence regexp
    #
    $logger->trace("Overall sentences end with regexp:") if $is_tt_switch_active;
    $logger->trace($sentencesEndWith)                    if $is_tt_switch_active;

    $logger->trace("Finding sentences...") if $is_t_switch_active;

    my $notWithinSentence = qr/$trailingCommentRegExp/s;

    # if
    #
    #   modifyLineBreaks
    #       oneSentencePerLine
    #           sentencesFollow
    #               blankLine
    #
    # is set to 0 then we need to *exclude* the $tokens{blanklines} from the sentence routine,
    # otherwise we could begin a sentence with $tokens{blanklines}.
    if ( !${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesFollow} }{blankLine} ) {
        $notWithinSentence .= "|" . qr/(?:\h*\R?$tokens{blanklines})/s;
    }

    # similarly for \par
    if ( ${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesFollow} }{par} ) {
        $notWithinSentence .= "|" . qr/(?:\R?\\par(?![a-zA-Z]))/s;
    }

    my $sentenceRegEx = qr/
                        ((?:$sentencesFollow))
                            (\h*)
                            (?!$notWithinSentence) 
                            ((?:$sentencesBeginWith).*?)
                            ($sentencesEndWith)
                            (\h*)?                        # possibly followed by horizontal space
                            (\R)?                         # possibly followed by a line break 
                            ($trailingCommentRegExp)?     # possibly followed by trailing comments
                        /sx;

    if ( ref ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesDoNOTcontain} eq 'HASH'
        and defined ${ ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesDoNOTcontain} }{other} )
    {
        my $sentencesDoNOTcontain
            = qr/${${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentencesDoNOTcontain}}{other}/;

        $sentenceRegEx = qr/
                        ((?:$sentencesFollow))
                            (\h*)
                            (?!$notWithinSentence) 
                            (
                               (?:$sentencesBeginWith)
                               (?:
                                  (?!
                                    $sentencesDoNOTcontain 
                                  ).
                               )
                               *?
                            )
                            ($sentencesEndWith)
                            (\h*)?                        # possibly followed by horizontal space
                            (\R)?                         # possibly followed by a line break 
                            ($trailingCommentRegExp)?     # possibly followed by trailing comments
                        /sx;
    }

    # ------------------------------------------
    # one sentence per line routine (finally)
    # ------------------------------------------
    my $sentenceWorkAfterIndentation = 0;
    $sentenceWorkAfterIndentation = 1
        if (
        (       ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences}
            and ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{when} eq 'after'
        )
        or ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} =~ m/\h+/
        );
    ${$self}{body} =~ s/$sentenceRegEx/
                            my $beginning = $1;
                            my $h_space   = ($2?$2:q());
                            my $middle    = $3;
                            my $end       = $4;
                            my $trailing  = ($5?$5:q()).($6?$6:q()).($7?$7:q());
                            my $lineBreaksAtEnd = ($6? 1 : ($7?1:0) );
                            my $trailingComments = q();
                            if (${$mainSettings{modifyLineBreaks}{oneSentencePerLine}}{removeSentenceLineBreaks}){
                                # remove trailing comments from within the body of the sentence
                                while($middle =~ m|$trailingCommentRegExp|){
                                    $middle =~ s|\h*($trailingCommentRegExp)||s;
                                    # trailing comments can be wrapped
                                    if (${ ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{comments} }{wrap}){
                                       $trailingComments .= ( $trailingComments eq q() ? q(): "\n").$1;
                                    } else {
                                       $trailingComments .= $1;
                                    }
                                }
                                # remove line breaks from within a sentence
                                $middle =~ s|
                                                (?!\A)      # not at the *beginning* of a match
                                                (\h*)\R     # possible horizontal space, then line break
                                            |$1?$1:" ";|esgx;
                            }
                            $middle =~ s|\h{2,}| |sg if ${$mainSettings{modifyLineBreaks}{oneSentencePerLine}}{multipleSpacesToSingle};
                            $middle =~ s|$tokens{blanklines}\h*\R?|$tokens{blanklines}\n|sg;
                            $logger->trace("follows: $beginning") if $is_tt_switch_active;
                            $logger->trace("sentence: $middle") if $is_tt_switch_active;
                            $logger->trace("ends with: $end") if $is_tt_switch_active;
                            # if indentation is specified for sentences, then we treat sentences as objects
                            my $replacementText = q();
                            my $sentenceBody = $middle.$end;
                            if($sentenceWorkAfterIndentation){
                                my $sentenceObj = LatexIndent::Sentence->new(
                                                            name=>"sentence",
                                                            begin=>q(),
                                                            body=>$middle.$end,
                                                            end=>q(),
                                                            indentation=>${$mainSettings{modifyLineBreaks}{oneSentencePerLine}}{sentenceIndent},
                                                            modifyLineBreaksYamlName=>"sentence",
                                                            BeginStartsOnOwnLine=>1,
                                                            follows=>$beginning,
                                                          );
                                # log file output
                                $logger->trace("*sentence found: $middle.$end") if $is_tt_switch_active;

                                # the settings and storage of most objects has a lot in common
                                $self->get_settings_and_store_new_object($sentenceObj);
                                ${@{${$self}{children}}[-1]}{replacementText} = $beginning.$h_space.$tokens{sentence}.$sentenceCounter.$tokens{endOfToken}.$trailingComments.$trailing.($lineBreaksAtEnd ? q() : "\n");
                                $replacementText = ${@{${$self}{children}}[-1]}{replacementText};
                            } else {
                                $sentenceCounter++;
                                push(@sentenceStorage,{id=>$tokens{sentence}.$sentenceCounter.$tokens{endOfToken},
                                                       value=>$middle.$end,leadingHorizontalSpace=>$h_space,
                                                       follows=>$beginning});
                                $replacementText = $beginning.$h_space.$tokens{sentence}.$sentenceCounter.$tokens{endOfToken}.$trailingComments.$trailing.($lineBreaksAtEnd ? q() : "\n");
                            };
                            $replacementText;
                            /xsge;

    #
    # remove spaces between trailing comments
    #
    #
    # from:
    #
    #   % first comment %second comment
    #                  ^
    # into:
    #
    #   % first comment%second comment
    #
    ${$self}{body} =~ s/($trailingCommentRegExp)\h($trailingCommentRegExp)/$1$2/sg
        unless ${ ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{comments} }{wrap};

    #
    # before:
    #   \item LTXIN-TK-SENTENCE-117-END
    # after
    #   \item
    #   LTXIN-TK-SENTENCE-117-END
    ${$self}{body} =~ s/(\S)\h*($tokens{sentence}\d+$tokens{endOfToken})/$1\n$2/sg;

    #
    # before:
    #    LTXIN-TK-SENTENCE-117-END %tc-13
    # after:
    #    LTXIN-TK-SENTENCE-117-END
    #    %tc-13
    if ( ${ ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{comments} }{wrap} ) {
        ${$self}{body} =~ s/($tokens{sentence}\d+$tokens{endOfToken})\h*($trailingCommentRegExp)/$1\n$2/sg;
    }

    # sentence indent means we do the sentence replacement later
    return if $sentenceWorkAfterIndentation;

    foreach my $sentence (@sentenceStorage) {
        my $sentenceStorageID    = ${$sentence}{id};
        my $sentenceStorageValue = ${$sentence}{value};

        # possibly text wrap
        if (    ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences}
            and ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{columns} != 0 )
        {
            ${$sentence}{follows} =~ s/.*?\R(\h*)$/$1/s;
            my $sentenceObj = LatexIndent::Sentence->new(
                name                     => "sentence",
                begin                    => q(),
                body                     => $sentenceStorageValue,
                end                      => q(),
                follows                  => ${$sentence}{follows},
                indentation              => q(),
                modifyLineBreaksYamlName => "sentence",
                BeginStartsOnOwnLine     => 1,
            );
            $sentenceObj->text_wrap;
            $sentenceStorageValue = ${$sentenceObj}{body};
        }

        # sentence at the very END
        ${$self}{body} =~ s/\h*$sentenceStorageID\h*$/$sentenceStorageValue/s;

        # sentence at the very BEGINNING
        ${$self}{body} =~ s/^$sentenceStorageID\h*\R?/$sentenceStorageValue\n/s;

        # all other sentences
        ${$self}{body} =~ s/\R?\h*$sentenceStorageID\h*\R?/\n$sentenceStorageValue\n/s;
    }
}

sub mlb_one_sentence_per_line_indent {
    my $self = shift;
    return
        unless (
        ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{manipulateSentences}
        and (
            (       ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences}
                and ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{when} eq 'after'
            )
            or ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} =~ m/\h+/
        )
        );

    $logger->trace("*one sentence per line: sentence INDENTATION active, finding code blocks");

    # loop back through the sentenceStorage and replace with the sentence, adjusting line breaks
    # before and after appropriately
    foreach my $sentenceObj ( @{ ${$self}{children} } ) {
        next unless ${$sentenceObj}{modifyLineBreaksYamlName} eq "sentence";
        my $sentenceStorageID    = ${$sentenceObj}{id};
        my $sentenceStorageValue = ${$sentenceObj}{value};

        ${$sentenceObj}{follows} =~ s/(.*?\R)//s;

        ${$self}{body} =~ m/^(\h*)$sentenceStorageID/m;
        my $surroundingIndentation = ( $1 ? $1 : q() );

        ${$sentenceObj}{follows} = $surroundingIndentation;

        # option to text wrap (and option to indent) sentences
        if ( ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences} ) {

            # text wrapping
            if ( ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{columns} == 0 ) {
                $logger->warn("*Sentence text wrap warning:");
                $logger->info("You have specified oneSentencePerLine:textWrapSentences, but columns is set to 0");
                $logger->info("You might wish to specify, for example: modifyLineBreaks: textWrapOptions: columns: 80");
                $logger->info(
                    "The value of oneSentencePerLine:textWrapSentences will now be set to 0, so you won't see this message again"
                );
                ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences} = 0;
            }
            else {
                $sentenceObj->text_wrap if ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences};
                $surroundingIndentation = q()
                    unless ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} =~ m/\h+/;
            }
        }

        ${$sentenceObj}{body} = _find_all_code_blocks( ${$sentenceObj}{body}, "" );

        # indentation of sentences
        if (${$sentenceObj}{body} =~ m/
                                           (.*?)      # content of first line
                                           \R         # first line break
                                           (.*$)      # rest of body
                                           /sx
            )
        {
            my $bodyFirstLine = $1;
            my $remainingBody = $2;
            my $indentation
                = ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} . $surroundingIndentation;
            $bodyFirstLine =~ s/^\h*//s;
            $logger->trace("first line of sentence:  $bodyFirstLine")                if $is_tt_switch_active;
            $logger->trace("remaining body (before indentation):\n'$remainingBody'") if ($is_tt_switch_active);

            # add the indentation to all the body except first line
            $remainingBody =~ s/^/$indentation/mg unless ( $remainingBody eq '' );    # add indentation
            $logger->trace("remaining body (after indentation):\n$remainingBody'") if ($is_tt_switch_active);

            # put the body back together
            ${$sentenceObj}{body} = $bodyFirstLine . "\n" . $remainingBody;
        }

        $sentenceStorageValue = ${$sentenceObj}{body};

        # indented sentences
        ${$self}{body} =~ s/^(\h*)$sentenceStorageID/$1$sentenceStorageValue/m;

    }
}

sub create_unique_id {
    my $self = shift;

    $sentenceCounter++;
    ${$self}{id} = "$tokens{sentence}$sentenceCounter";
    return;
}

sub tasks_particular_to_each_object {
    my $self = shift;

    # option to text wrap (and option to indent) sentences
    if (    ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{textWrapSentences}
        and ${ $mainSettings{modifyLineBreaks}{textWrapOptions} }{columns} != 0 )
    {
        $self->text_wrap;
    }

    return;
}

sub indent_body {
    return unless ${ $mainSettings{modifyLineBreaks}{oneSentencePerLine} }{sentenceIndent} =~ m/\h+/;

    my $self = shift;

    # indentation of sentences
    if (${$self}{body} =~ m/
                          (.*?)      # content of first line
                          \R         # first line break
                          (.*$)      # rest of body
                          /sx
        )
    {
        my $bodyFirstLine = $1;
        my $remainingBody = $2;
        my $indentation   = ${$self}{indentation};
        $logger->trace("first line of sentence  $bodyFirstLine")                 if $is_tt_switch_active;
        $logger->trace("remaining body (before indentation):\n'$remainingBody'") if ($is_tt_switch_active);

        # add the indentation to all the body except first line
        $remainingBody =~ s/^/$indentation/mg unless ( $remainingBody eq '' );    # add indentation
        $logger->trace("remaining body (after indentation):\n$remainingBody'") if ($is_tt_switch_active);

        # put the body back together
        ${$self}{body} = $bodyFirstLine . "\n" . $remainingBody;
    }
}

sub yaml_get_indentation_settings_for_this_object {
    return;
}

sub add_surrounding_indentation_to_begin_statement {

    # specific method for sentences
    my $self = shift;

    my $surroundingIndentation = ${$self}{surroundingIndentation};
    ${$self}{body} =~ s/^(\h*)?/$surroundingIndentation/s;    # add indentation

}

1;
