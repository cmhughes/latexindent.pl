# KeyEqualsValuesBraces.pm
#   creates a class for the KeyEqualsValuesBraces objects
#   which are a subclass of the Document object.
package LatexIndent::KeyEqualsValuesBraces;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::Switches qw/$is_m_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Command"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/construct_key_equals_values_regexp $key_equals_values_bracesRegExp $key_equals_values_bracesRegExpTrailingComment/;
our $key_equals_values_braces_Counter;
our $key_equals_values_bracesRegExp; 
our $key_equals_values_bracesRegExpTrailingComment; 

sub construct_key_equals_values_regexp{
    my $self = shift;

    # grab the arguments regexp
    my $optAndMandRegExp = $self->get_arguments_regexp;

    # blank line token
    my $blankLineToken = $tokens{blanklines};

    # store the regular expresssion for matching and replacing 
    $key_equals_values_bracesRegExp = qr/
                  (
                    (?:
                       (?:(?<!\\)\{)
                           |
                           ,
                           |
                       (?:(?<!\\)\[)
                     )
                     (?:\h|\R|$blankLineToken|$trailingCommentRegExp)*
                  )                                                     # $1 pre-key bit: could be { OR , OR [                                 
                  (\\)?                                                 # $2 possible backslash
                  (
                   [a-zA-Z@\*0-9_\/.\h\{\}:\#]+?                               # lowercase|uppercase letters, @, *, numbers, forward slash, dots
                  )                                                     # $3 name
                  (
                    (?:\h|\R|$blankLineToken|$trailingCommentRegExp)*
                    =\h*
                  )                                                     # $4 = symbol
                  (\R*)?                                                # $5 linebreak after =
                  ($optAndMandRegExp)                                   # $6 opt|mand arguments
                  (\R)?                                                 # $9 linebreak at end
                /sx;

    $key_equals_values_bracesRegExpTrailingComment = qr/$key_equals_values_bracesRegExp\h*((?:$trailingCommentRegExp\h*)*)?/;
}

sub indent_begin{
    my $self = shift;

    # blank line token
    my $blankLineToken = $tokens{blanklines};

    if(${$self}{begin} =~ /\R=/s or ${$self}{begin} =~ /$blankLineToken\h*=/s ){
        $self->logger("= found on own line in ${$self}{name}, adding indentation");
        ${$self}{begin} =~ s/=/${$self}{indentation}=/s;
    }
}

sub check_linebreaks_before_equals{
    # check if -m switch is active
    return unless $is_m_switch_active;
    
    my $self = shift;

    # linebreaks *infront* of = symbol
    if(${$self}{begin} =~ /\R\h*=/s){
          if(defined ${$self}{EqualsStartsOnOwnLine} and ${$self}{EqualsStartsOnOwnLine}==-1){
            $self->logger("Removing linebreak before = symbol in ${$self}{name} (see EqualsStartsOnOwnLine)");
            ${$self}{begin} =~ s/(\R|\h)*=/=/s;
          }
    } else {
      if(defined ${$self}{EqualsStartsOnOwnLine} and ${$self}{EqualsStartsOnOwnLine}==1){
            $self->logger("Adding a linebreak before = symbol for ${$self}{name} (see EqualsStartsOnOwnLine)");
            ${$self}{begin} =~ s/=/\n=/s;
      } elsif(defined ${$self}{EqualsStartsOnOwnLine} and ${$self}{EqualsStartsOnOwnLine}==2){
            $self->logger("Adding a % linebreak immediately before = symbol for ${$self}{name} (see EqualsStartsOnOwnLine)");
            ${$self}{begin} =~ s/\h*=/%\n=/s;
      }
    }
    return;
}

sub create_unique_id{
    my $self = shift;

    $key_equals_values_braces_Counter++;
    ${$self}{id} = "$tokens{key_equals_values_braces}$key_equals_values_braces_Counter";
    return;
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for a key = {value} needes to accomodate the leading [ OR { OR % OR , OR any combination thereof
    $self->logger("Custom replacement text routine for ${$self}{name}");
    ${$self}{replacementText} = ${$self}{beginningbit}.${$self}{id};
    delete ${$self}{beginningbit};
}

1;
