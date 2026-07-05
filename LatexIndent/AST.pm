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
our @AST;
our $ASTCounter;
our $ASTLevel = -1;
our @ISA =
  "LatexIndent::Document";    # class inheritance, Programming Perl, pg 321
our @EXPORT_OK =
  qw/@AST $ASTCounter $ASTLevel _ast_store_block _ast_final_work /;

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
                type  => $input{type}
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
                type  => $input{type}
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
            while ( my ( $key, $value ) = each %{$entryInLevel} ) {
                $value =~ s/^\s*//s;
                $value =~ s/\s*$//s;
                ${$entryInLevel}{$key} = $value;
            }
        }
    }

    foreach my $levelArray (reverse @AST) {
        foreach my $entryInLevel ( @{$levelArray} ) {
            print "current level: ${$entryInLevel}{level}\n";
            if (index(${$entryInLevel}{body}, $tokens{ast}) != -1) {
                print "--------\nnested child found\n-----------\n";
                my @bodySplit = split(/($tokens{ast}\d+$tokens{endOfToken})/,${$entryInLevel}{body});

                # first child
                ${$entryInLevel}{children}[0]{text} = shift(@bodySplit);
                foreach (@bodySplit){
                    print "thing: $_\n";
                }
            }
        }
    }

    print Dumper( \@AST );
}
1;
