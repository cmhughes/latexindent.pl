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
use LatexIndent::Switches qw/%switch/;
our @AST;
our $ASTCounter;
our $ASTLevel = -1;
our @ISA =
  "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK =
  qw/@AST $ASTCounter $ASTLevel _ast_store_block _ast_final_work/;

sub _ast_store_block {
    my %input = @_;

    $ASTCounter++;
    my $id = $tokens{ast} . $ASTCounter . $tokens{endOfToken};
    if ( defined $AST[ $input{level} ] ) {
        # AST at $input{level} defined
        push(
            @{ @AST[ $input{level} ] },
            {
                begin => $input{begin},
                body  => $input{body},
                end   => $input{end},
                id    => $id,
                level => $input{level},
                name => $input{name},
                type  => $input{type},
                arguments => (defined $input{arguments}?\@{$input{arguments}}:0 ),
            }
        );
    }
    else {
        # AST at $input{level} NOT defined
        $AST[ $input{level} ] = [
            {
                begin => $input{begin},
                body  => $input{body},
                end   => $input{end},
                id    => $id,
                level => $input{level},
                name => $input{name},
                type  => $input{type},
                arguments => (defined $input{arguments}?\@{$input{arguments}}:0 ),
            }
        ];
    }

    my $body  = " " . $id;
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
            delete ${$entryInLevel}{begin} if ${$entryInLevel}{type} eq "arguments";
            delete ${$entryInLevel}{body} if ${$entryInLevel}{type} eq "arguments";
            delete ${$entryInLevel}{end} if ${$entryInLevel}{type} eq "arguments";
            # commands
            delete ${$entryInLevel}{body} if ${$entryInLevel}{type} eq "commands";
            delete ${$entryInLevel}{end} if ${$entryInLevel}{type} eq "commands";
            while ( my ( $key, $value ) = each %{$entryInLevel} ) {
                next if ref($value) eq "ARRAY";
                $value =~ s/^\s*//s;
                $value =~ s/\s*$//s;
                ${$entryInLevel}{$key} = $value;
            }
        }
    }

    # 
    # argument work
    #
    foreach my $levelArray (@AST) {
        foreach my $index (0 .. $#{$levelArray}) {
            if (${$levelArray}[$index]{type} eq "arguments" ){
                foreach (@{${$levelArray}[$index]{arguments}}){
                     push( @{${$levelArray}[$index+1]{arguments}}, $_);
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
    foreach my $levelArray (reverse @AST) {
        foreach my $entryInLevel ( @{$levelArray} ) {
            next unless defined ${$entryInLevel}{body};
            if (index(${$entryInLevel}{body}, $tokens{ast}) != -1) {
                my @bodySplit = split(/($tokens{ast}\d+$tokens{endOfToken})/,${$entryInLevel}{body});

                delete ${$entryInLevel}{body};

                # first child
                ${$entryInLevel}{body}[0]{text} = shift(@bodySplit);

                # subsequent children
                while (scalar @bodySplit > 0){
                    my $id_to_look_for = shift(@bodySplit);
                    my $text_after_id  = shift(@bodySplit);
                    foreach (@{$AST[${$entryInLevel}{level}+1]}){
                        if (defined ${$_}{id} and $id_to_look_for eq ${$_}{id}){
                            delete ${$_}{id};
                            push(@{${$entryInLevel}{body}},$_);
                            push(@{${$entryInLevel}{body}},{text=>$text_after_id}) if defined $text_after_id;
                        } 
                    }
                }
            }
        }
    }

    @AST = @{$AST[0]};
    delete ${$AST[0]}{id};

    # remove empty HASHES 
    my @ASTemptyHashRemove;
    foreach my $index ( 0 .. $#AST ) {
        if (!keys %{$AST[$index]}) { 
            push(@ASTemptyHashRemove,$index);
        }
    }
    foreach ( reverse @ASTemptyHashRemove ) {
        splice( @AST, $_ ,1);
    }

    # remove any id: ast-token-
    foreach ( @AST ) {
      %{$_} = &_ast_iterate_through_hash(%{$_});
    }
}

sub _ast_iterate_through_hash{
    my %input = @_;

    delete $input{id} if defined $input{id};
    while ( my ( $key, $value ) = each %input ) {
        if (ref($value) eq "ARRAY"){
            foreach (@{$value}){
                %{$_} = &_ast_iterate_through_hash(%{$_});
            }
        }
    }

    return %input;
}
1;
