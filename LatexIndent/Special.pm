# Special.pm
#   creates a class for the Special object
#   which are a subclass of the Document object.
package LatexIndent::Special;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_special construct_special_begin/;
our $specialCounter;
our $specialBegins = q();
our $specialAllMatchesRegExp = q();

sub construct_special_begin{
    my $self = shift;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # put together a list of the begin terms in special
    while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){

      # only append the regexps if lookForThis is 1
      if(${$BeginEnd}{lookForThis}){
        # the beginning parts
        $specialBegins .= ($specialBegins eq ""?q():"|").${$BeginEnd}{begin};

        # the overall regexp
        $specialAllMatchesRegExp .= ($specialAllMatchesRegExp eq ""?q():"|")
                                    .qr/
                                    ${$BeginEnd}{begin}
                                    (?:                        # cluster-only (), don't capture 
                                        (?!             
                                            (?:$specialBegins) # cluster-only (), don't capture
                                        ).                     # any character, but not anything in $specialBegins
                                    )*?                 
                                    ${$BeginEnd}{end}
                             /sx;
        } else {
            $self->logger("The special regexps won't include anything from $specialName (see lookForThis)",'heading');
        }
    }

    # move $$ to the beginning
    if($specialBegins =~ m/\|\\\$\\\$/){
      $specialBegins =~ s/\|(\\\$\\\$)//;
      $specialBegins = $1."|".$specialBegins; 
    }

    # info to the log file
    $self->logger("The special beginnings regexp is: $specialBegins (see specialBeginEnd)",'heading.trace');

    # overall special regexp
    $self->logger("The overall special regexp is: $specialAllMatchesRegExp(see specialBeginEnd)",'heading.trace');

  }

sub find_special{
    my $self = shift;

    # no point carrying on if the list of specials is empty
    return if($specialBegins eq "");

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # otherwise loop through the special begin/end
    $self->logger("Searching for special begin/end (see specialBeginEnd)");
    $self->logger(Dumper(\%{$masterSettings{specialBeginEnd}}));

    # get the blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # keep looping as long as there is a special match of some kind
    while(${$self}{body} =~ m/$specialAllMatchesRegExp/sx){

        # loop through each special match
        while( my ($specialName,$BeginEnd)= each %{$masterSettings{specialBeginEnd}}){

            # log file
            if(${$BeginEnd}{lookForThis}){
                $self->logger("Looking for $specialName",'heading');
            } else {
                $self->logger("Not looking for $specialName (see lookForThis)",'heading');
                next;
            }

            # the regexp
            my $specialRegExp = qr/
                                  (
                                      ${$BeginEnd}{begin}
                                      \h*
                                      (\R*)?
                                  )
                                  (
                                      (?:                        # cluster-only (), don't capture 
                                          (?!             
                                              (?:$specialBegins) # cluster-only (), don't capture
                                          ).                     # any character, but not anything in $specialBegins
                                      )*?                 
                                     (\R*)?
                                  )                       
                                  (
                                    ${$BeginEnd}{end}
                                    \h*
                                  )
                                  (\R)?
                               /sx;
            
            while(${$self}{body} =~ m/$specialRegExp\h*($trailingCommentRegExp)?/){

                # log file output
                $self->logger("special found: $specialName",'heading');

                # create a new special object
                my $specialObject = LatexIndent::Special->new(begin=>$1,
                                                        body=>$3,
                                                        end=>$5,
                                                        name=>$specialName,
                                                        linebreaksAtEnd=>{
                                                          begin=>$2?1:0,
                                                          body=>$4?1:0,
                                                          end=>$6?1:0,
                                                        },
                                                        aliases=>{
                                                          # begin statements
                                                          BeginStartsOnOwnLine=>"SpecialBeginStartsOnOwnLine",
                                                          # body statements
                                                          BodyStartsOnOwnLine=>"SpecialBodyStartsOnOwnLine",
                                                          # end statements
                                                          EndStartsOnOwnLine=>"SpecialEndStartsOnOwnLine",
                                                          # after end statements
                                                          EndFinishesWithLineBreak=>"SpecialEndFinishesWithLineBreak",
                                                        },
                                                        modifyLineBreaksYamlName=>"specialBeginEnd",
                                                        regexp=>$specialRegExp,
                                                        endImmediatelyFollowedByComment=>$6?0:($7?1:0),
                                                      );

                # the settings and storage of most objects has a lot in common
                $self->get_settings_and_store_new_object($specialObject);
            }
         }
     }
}


sub create_unique_id{
    my $self = shift;

    $specialCounter++;

    ${$self}{id} = "${$self->get_tokens}{special}$specialCounter";
    return;
}

1;
