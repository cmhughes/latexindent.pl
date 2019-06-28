package LatexIndent::Replacement;
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
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active $is_rr_switch_active/;
use LatexIndent::LogFile qw/$logger/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/regexp_body_substitutions make_replacements/;

sub make_replacements{
    my $self = shift;
    my %input = @_;
    if ($is_t_switch_active and !$is_rr_switch_active){
        $logger->trace("*Replacement mode *$input{when}* indentation: -r") ;
    } elsif ($is_t_switch_active and $is_rr_switch_active) {
      $logger->trace("*Replacement mode, -rr switch is active") if $is_t_switch_active ;
    }

	my @replacements = @{$masterSettings{replacements}};

	foreach ( @replacements ){
        next if(!${$_}{this} or !${$_}{that});
        # default value of "when" is before
        ${$_}{when} = "before" if( !(defined ${$_}{when}) or $is_rr_switch_active); 
        ${$_}{type} = "string" if( !(defined ${$_}{type})); 
        ${$_}{lookForThis} = 1 if( !(defined ${$_}{lookForThis})); 

        # move on if this one shouldn't be looked for
        next if(!${$_}{lookForThis});

        if(${$_}{when} eq $input{when}){
	        my $this = qq{${$_}{this}};
	        my $that = qq{${$_}{that}};
	        my $index_match = index(${$self}{body}, $this);
	        while ( $index_match != -1 ) {
	              substr (${$self}{body}, $index_match, length($this), $that ); 
	        	     $index_match = index(${$self}{body}, $this);
	        }
        }
    }
}

sub regexp_body_substitutions{
    my $self = shift;
	my @regExpSubs = @{$masterSettings{regExpBodySubs}};

	foreach ( @regExpSubs ){
 	   ${$self}{body} =~ s/${$_}{before}/${$_}{after}/sg;
	}
}

1;
