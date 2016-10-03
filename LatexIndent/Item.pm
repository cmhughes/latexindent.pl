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
    while( my ($item,$lookForThisItem)= each %{$masterSettings{itemNames}}){
        if($lookForThisItem){
            # get the blank line token
            my $blankLineToken = $self->get_blank_line_token;

            # trailing comment regexp
            my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

            my $itemRegExp = qr/
                                  (
                                      \\$item
                                      \h*
                                  )
                                  (\R*)?
                                  (
                                      (?:                 # cluster-only (), don't capture 
                                          (?!             
                                              (?:\\$item) # cluster-only (), don't capture
                                          ).              # any character, but not \\$item
                                      )*                 
                                  )                       
                                  (\R)?
                               /sx;
            
            while(${$self}{body} =~ m/$itemRegExp\h*($trailingCommentRegExp)?/){

                # log file output
                $self->logger("Item found: $item",'heading');

                # create a new Item object
                my $itemObject = LatexIndent::Item->new(begin=>$1,
                                                        name=>$item,
                                                        body=>$3,
                                                        end=>"",
                                                        linebreaksAtEnd=>{
                                                          begin=>$2?1:0,
                                                          body=>$4?1:0,
                                                        },
                                                        aliases=>{
                                                          # begin statements
                                                          BeginStartsOnOwnLine=>"ItemStartsOnOwnLine",
                                                          # body statements
                                                          BodyStartsOnOwnLine=>"ItemBodyStartsOnOwnLine",
                                                          # after end statements
                                                          EndFinishesWithLineBreak=>"ItemBodyFinishesWithLineBreak",
                                                        },
                                                        modifyLineBreaksYamlName=>"items",
                                                        regexp=>$itemRegExp,
                                                        endImmediatelyFollowedByComment=>$4?0:($5?1:0),
                                                      );
                # there are a number of tasks common to each object
                $itemObject->tasks_common_to_each_object(%{$self});

                # store children in special hash
                push(@{${$self}{children}},$itemObject);

                # wrap_up_tasks
                $self->wrap_up_tasks;
            }
        } else {
            $self->logger("Not searching for $item, as $item: $lookForThisItem");
        }
    }
  }


sub create_unique_id{
    my $self = shift;

    $itemCounter++;
    ${$self}{id} = "LATEX-INDENT-ITEMS$itemCounter";
    return;
}

1;
