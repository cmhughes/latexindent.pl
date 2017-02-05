# Items.pm
#   creates a class for the Item object
#   which are a subclass of the Document object.
package LatexIndent::Item;
use strict;
use warnings;
use LatexIndent::Tokens qw/%tokens/;
use LatexIndent::TrailingComments qw/$trailingCommentRegExp/;
use LatexIndent::GetYamlSettings qw/%masterSettings/;
use LatexIndent::Switches qw/$is_t_switch_active $is_tt_switch_active/;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_items construct_list_of_items/;
our $itemCounter;
our $listOfItems = q();
our $itemRegExp; 

sub construct_list_of_items{
    my $self = shift;

    # put together a list of the items
    while( my ($item,$lookForThisItem)= each %{$masterSettings{itemNames}}){
        $listOfItems .= ($listOfItems eq "")?"$item":"|$item" if($lookForThisItem);
    }

    # detail items in the log
    $self->logger("List of items: $listOfItems (see itemNames)",'heading');

    $itemRegExp = qr/
                          (
                              \\($listOfItems)
                              \h*
                              (\R*)?
                          )
                          (
                              (?:                 # cluster-only (), don't capture 
                                  (?!             
                                      (?:\\(?:$listOfItems)) # cluster-only (), don't capture
                                  ).              # any character, but not \\$item
                              )*                 
                          )                       
                          (\R)?
                       /sx;
    

    return;
}

sub find_items{
    # no point carrying on if the list of items is empty
    return if($listOfItems eq "");

    my $self = shift;

    return unless ${$masterSettings{indentAfterItems}}{${$self}{name}};

    # otherwise loop through the item names
    $self->logger("Searching for items (see itemNames) in ${$self}{name} (see indentAfterItems)") if $is_t_switch_active;
    $self->logger(Dumper(\%{$masterSettings{itemNames}})) if $is_t_switch_active;

    while(${$self}{body} =~ m/$itemRegExp\h*($trailingCommentRegExp)?/){

        # log file output
        $self->logger("Item found: $2",'heading') if $is_t_switch_active;

        # create a new Item object
        my $itemObject = LatexIndent::Item->new(begin=>$1,
                                                body=>$4,
                                                end=>q(),
                                                name=>$2,
                                                linebreaksAtEnd=>{
                                                  begin=>$3?1:0,
                                                  body=>$5?1:0,
                                                },
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"ItemStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"ItemFinishesWithLineBreak",
                                                },
                                                modifyLineBreaksYamlName=>"items",
                                                regexp=>$itemRegExp,
                                                endImmediatelyFollowedByComment=>$5?0:($6?1:0),
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($itemObject);
    }
}


sub create_unique_id{
    my $self = shift;

    $itemCounter++;

    ${$self}{id} = "$tokens{item}$itemCounter";
    return;
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # the item body could hoover up line breaks; we do an additional check
    ${${$self}{linebreaksAtEnd}}{body}=1 if(${$self}{body} =~ m/\R+$/s );

    # search for ifElseFi blocks
    $self->find_ifelsefi;

    # search for headings (part, chapter, section, setc)
    $self->find_heading;
    
    # search for commands with arguments
    $self->find_commands_or_key_equals_values_braces;

    # search for special begin/end
    $self->find_special;

}
1;
