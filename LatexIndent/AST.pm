package LatexIndent::AST;

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
#	Chris Hughes, 2017
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl
use strict;
use warnings;
use Data::Dumper;
use Exporter                     qw/import/;
use LatexIndent::GetYamlSettings qw/%mainSetting/;
use LatexIndent::Tokens          qw/%tokens/;
use LatexIndent::Switches        qw/%switch/;
use LatexIndent::Verbatim        qw/%verbatimStorage/;
our @AST;
our $ASTCounter;
our $ASTLevel  = -1;
our @ISA       = "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/@AST $ASTCounter $ASTLevel _ast_store_block _ast_final_work/;

sub _ast_store_block {
    my %input = @_;

    $ASTCounter++;
    my $id = $tokens{ast} . $ASTCounter . $tokens{endOfToken};
    if ( defined $AST[ $input{level} ] ) {

        # AST at $input{level} defined
        push(
            @{ @AST[ $input{level} ] },
            {   begin     => $input{begin},
                body      => $input{body},
                end       => $input{end},
                id        => $id,
                level     => $input{level},
                name      => $input{name},
                type      => $input{type},
                arguments => ( defined $input{arguments} ? \@{ $input{arguments} } : 0 ),
            }
        );
    }
    else {
        # AST at $input{level} NOT defined
        $AST[ $input{level} ] = [
            {   begin     => $input{begin},
                body      => $input{body},
                end       => $input{end},
                id        => $id,
                level     => $input{level},
                name      => $input{name},
                type      => $input{type},
                arguments => ( defined $input{arguments} ? \@{ $input{arguments} } : 0 ),
            }
        ];
    }

    my $body  = $id;
    my $begin = q();
    my $end   = q();
    return ( $begin, $body, $end );
}

sub _ast_final_work {

    # remove leading and trailing space
    foreach my $levelArray (@AST) {
        foreach my $entryInLevel ( @{$levelArray} ) {

            # arguments
            delete ${$entryInLevel}{arguments} if !${$entryInLevel}{arguments};
            delete ${$entryInLevel}{begin}     if ${$entryInLevel}{type} eq "arguments";
            delete ${$entryInLevel}{body}      if ${$entryInLevel}{type} eq "arguments";
            delete ${$entryInLevel}{end}       if ${$entryInLevel}{type} eq "arguments";

            # commands
            delete ${$entryInLevel}{body} if ${$entryInLevel}{type} eq "commands";
            delete ${$entryInLevel}{end}  if ${$entryInLevel}{type} eq "commands";

            # environments
            ${$entryInLevel}{begin} =~ s/\s*//sg           if ${$entryInLevel}{type} eq "environments";
            ${$entryInLevel}{body}  =~ s/^\s*(?:\n|\t)+//s if ${$entryInLevel}{type} eq "environments";
            ${$entryInLevel}{body}  =~ s/\n/ /sg           if ${$entryInLevel}{type} eq "environments";
            ${$entryInLevel}{body}  =~ s/^\s*//sg          if ${$entryInLevel}{type} eq "environments";
            ${$entryInLevel}{body}  =~ s/\s*$//s           if ${$entryInLevel}{type} eq "environments";
            ${$entryInLevel}{end}   =~ s/\s*$//sg          if ${$entryInLevel}{type} eq "environments";
        }
    }

    #
    # argument work
    #
    foreach my $levelArray (@AST) {
        foreach my $index ( 0 .. $#{$levelArray} ) {
            if ( ${$levelArray}[$index]{type} eq "arguments" ) {
                foreach ( @{ ${$levelArray}[$index]{arguments} } ) {
                    push( @{ ${$levelArray}[ $index + 1 ]{arguments} }, $_ );
                }
                delete ${$levelArray}[$index];
            }
        }
    }

    #
    # check if body contains "ast-token-" and if it does, then
    #
    #   1. split body
    #   2. reorganise levels
    #
    foreach my $levelArray ( reverse @AST ) {
        foreach my $entryInLevel ( @{$levelArray} ) {
            next unless ( defined ${$entryInLevel}{body} or defined ${$entryInLevel}{arguments} );
            if ( defined ${$entryInLevel}{body} ) {
                $entryInLevel = &_ast_body_find_child( %{$entryInLevel} );
            }

            if ( defined ${$entryInLevel}{arguments} ) {
                foreach my $argument ( @{ ${$entryInLevel}{arguments} } ) {
                    $argument = &_ast_body_find_child( %{$argument} );
                }
            }
        }
    }

    @AST = @{ $AST[0] };
    delete ${ $AST[0] }{id};

    # remove empty HASHES
    my @ASTemptyHashRemove;
    foreach my $index ( 0 .. $#AST ) {
        if ( !keys %{ $AST[$index] } ) {
            push( @ASTemptyHashRemove, $index );
        }
    }
    foreach ( reverse @ASTemptyHashRemove ) {
        splice( @AST, $_, 1 );
    }

    # remove any id: ast-token-
    foreach (@AST) {
        %{$_} = &_ast_iterate_through_hash( %{$_} );
    }
}

sub _ast_iterate_through_hash {
    my %input = @_;

    delete $input{id} if defined $input{id};
    while ( my ( $key, $value ) = each %input ) {
        if ( ref($value) eq "ARRAY" ) {
            foreach ( @{$value} ) {
                %{$_} = &_ast_iterate_through_hash( %{$_} );
            }
        }
    }

    return %input;
}

sub _ast_body_find_child {
    my %entryInLevel = @_;

    if ( index( $entryInLevel{body}, $tokens{ast} ) != -1 or index( $entryInLevel{body}, $tokens{verbatim}) != -1 ) {
        my @bodySplit = split( /((?:$tokens{ast}\d+$tokens{endOfToken})|(?:$tokens{verbatim}\d+$tokens{endOfToken}))/, $entryInLevel{body} );

        delete $entryInLevel{body};

        # first child
        $entryInLevel{body}[0]{text} = shift(@bodySplit);

        # subsequent children
        while ( scalar @bodySplit > 0 ) {
            my $id_to_look_for = shift(@bodySplit);
            my $text_after_id  = shift(@bodySplit);
            if ($id_to_look_for =~m /$tokens{verbatim}/s){
                    ${$verbatimStorage{$id_to_look_for}}{type} = ${$verbatimStorage{$id_to_look_for}}{modifyLineBreaksYamlName};
                    my %verbatim;
                    $verbatim{name} = ${$verbatimStorage{$id_to_look_for}}{name};
                    $verbatim{begin} = ${$verbatimStorage{$id_to_look_for}}{begin};
                    $verbatim{body} = ${$verbatimStorage{$id_to_look_for}}{body};
                    $verbatim{end} = ${$verbatimStorage{$id_to_look_for}}{end};
                    $verbatim{type} = ${$verbatimStorage{$id_to_look_for}}{modifyLineBreaksYamlName};
                    delete $verbatimStorage{$id_to_look_for};
                    push( @{ $entryInLevel{body} },\%verbatim);
                    push( @{ $entryInLevel{body} }, { text => $text_after_id } ) if defined $text_after_id;
            } else {
            foreach ( @{ $AST[ $entryInLevel{level} + 1 ] } ) {
                if ( defined ${$_}{id} and $id_to_look_for eq ${$_}{id} ) {
                    delete ${$_}{id};

                    # move leading space from specialBeginEnd to the end of previous "text"
                    if (    ${$_}{type} eq "specialBeginEnd"
                        and ${$_}{begin} =~ m/^(\s+)/s
                        and defined ${ $entryInLevel{body} }[-1]{text} )
                    {
                        ${$_}{begin} =~ s/^(\s+)//s;
                        ${ $entryInLevel{body} }[-1]{text} .= $1;
                    }

                    # move leading space from commands to the end of previous "text"
                    if (    ${$_}{type} eq "commands"
                        and ${$_}{begin} =~ m/^(\s+)/s
                        and defined ${ $entryInLevel{body} }[-1]{text} )
                    {
                        ${$_}{begin} =~ s/^(\s+)//s;
                        ${ $entryInLevel{body} }[-1]{text} .= $1;
                    }
                    push( @{ $entryInLevel{body} }, $_ );
                    push( @{ $entryInLevel{body} }, { text => $text_after_id } ) if defined $text_after_id;
                }
            }
            }
        }
    }

    # remove empty "text" elements
    if ( ref( $entryInLevel{body} ) eq "ARRAY" ) {
        my @ASTemptyTextRemove;
        foreach my $index ( 0 .. $#{ $entryInLevel{body} } ) {
            if ( defined ${ $entryInLevel{body} }[$index]{text} and ${ $entryInLevel{body} }[$index]{text} eq '' ) {
                push( @ASTemptyTextRemove, $index );
            }
            elsif ( defined ${ $entryInLevel{body} }[$index]{text} ) {

                # condense multiple leading spaces
                ${ $entryInLevel{body} }[$index]{text} =~ s/^\s+/ /s;
            }
        }
        foreach ( reverse @ASTemptyTextRemove ) {
            splice( @{ $entryInLevel{body} }, $_, 1 );
        }
    }

    return \%entryInLevel;
}
1;
