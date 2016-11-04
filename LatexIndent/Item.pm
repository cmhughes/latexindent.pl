# Items.pm
#   creates a class for the Item object
#   which are a subclass of the Document object.
package LatexIndent::Item;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_items/;
our $itemCounter;

sub find_items{
    my $self = shift;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    return unless ${$masterSettings{indentAfterItems}}{${$self}{name}};

    # otherwise loop through the item names
    $self->logger("Searching for items (see itemNames) in ${$self}{name} (see indentAfterItems)");
    $self->logger(Dumper(\%{$masterSettings{itemNames}}));

    # put together a list of the items
    my $listOfItems = q();
    while( my ($item,$lookForThisItem)= each %{$masterSettings{itemNames}}){
        $listOfItems .= ($listOfItems eq "")?"$item":"|$item" if($lookForThisItem);
    }

    # detail items in the log
    $self->logger("List of items: $listOfItems");

    # no point carrying on if the list of items is empty
    return if($listOfItems eq "");

    # get the blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    my $itemRegExp = qr/
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
    
    while(${$self}{body} =~ m/$itemRegExp\h*($trailingCommentRegExp)?/){

        # log file output
        $self->logger("Item found: $2",'heading');

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

        # the item body could hoover up line breaks; we do an additional check
        ${${$itemObject}{linebreaksAtEnd}}{body}=1 if(${$itemObject}{body} =~ m/\R+$/s );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($itemObject);
    }
}


sub create_unique_id{
    my $self = shift;

    $itemCounter++;

    ${$self}{id} = "${$self->get_tokens}{item}$itemCounter";
    return;
}

1;
