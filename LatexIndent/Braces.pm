# Braces.pm
#   contains the function that looks for 
#   either COMMANDS or KEYEQUALSVALUESBRACES
package LatexIndent::Braces;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_commands_or_key_equals_values_braces/;
our $commandCounter;

sub find_commands_or_key_equals_values_braces{

    my $self = shift;

    $self->logger("Searching for commands with optional and/or mandatory arguments AND key = {value}",'heading');

    # store the regular expresssion for matching and replacing 
    my $commandRegExp = $self->get_command_regexp;

    # key = {value} regexp
    my $key_equals_values_bracesRegExp = $self->get_key_equals_values_regexp;

    # something {value} regexp
    my $grouping_braces_regexp = $self->get_grouping_braces_brackets_regexp;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # command regexp with trailing comment
    my $commandRegExpTrailingComment = qr/$commandRegExp\h*((?:$trailingCommentRegExp\h*)*)/;

    # key ={value} regexp with trailing comment
    my $key_equals_values_bracesRegExpTrailingComment = qr/$key_equals_values_bracesRegExp\h*((?:$trailingCommentRegExp\h*)*)?/;

    # something {value} grouping braces with trailing comment
    my $grouping_braces_regexpTrailingComment = qr/$grouping_braces_regexp\h*((?:$trailingCommentRegExp\h*)*)?/;

    # match either a \\command or key={value}
    while( ${$self}{body} =~ m/$commandRegExpTrailingComment/
                            or  
           ${$self}{body} =~ m/$key_equals_values_bracesRegExpTrailingComment/
                            or
           ${$self}{body} =~ m/$grouping_braces_regexpTrailingComment/ ){
      if(${$self}{body} =~ m/$commandRegExpTrailingComment/){ 
        # log file output
        $self->logger("command found: $2",'heading');

        # create a new command object
        my $command = LatexIndent::Command->new(begin=>$1.$2.($3?$3:q()),
                                                name=>$2,
                                                body=>$4.($7?$7:($8?$8:q())),    # $7 is linebreak, $8 is trailing comment
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>$3?1:0,
                                                  end=>$7?1:0,            # $7 is linebreak before comment check, $9 is after
                                                },
                                                modifyLineBreaksYamlName=>"commands",
                                                regexp=>($7?$commandRegExp:$commandRegExpTrailingComment),
                                                endImmediatelyFollowedByComment=>$7?0:($8?1:0),
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"CommandStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"CommandNameFinishesWithLineBreak",
                                                },
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($command);
      } elsif (${$self}{body} =~ m/$key_equals_values_bracesRegExpTrailingComment/){

        # log file output
        $self->logger("key_equals_values_braces found: $3",'heading');

        # create a new key_equals_values_braces object
        my $key_equals_values_braces = LatexIndent::KeyEqualsValuesBraces->new(
                                                begin=>($2?$2:q()).$3.$4.($5?$5:q()),
                                                name=>$3,
                                                body=>$6.($9?$9:($10?$10:q())),     # $9 is linebreak before comment check, $10 is trailing comment
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>$5?1:0,
                                                  end=>$9?1:0,                # $9 is linebreak before comment check
                                                },
                                                modifyLineBreaksYamlName=>"keyEqualsValuesBraces",
                                                regexp=>($9?$key_equals_values_bracesRegExp:$key_equals_values_bracesRegExpTrailingComment),
                                                beginningbit=>$1,
                                                endImmediatelyFollowedByComment=>$9?0:($10?1:0),
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"KeyStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"EqualsFinishesWithLineBreak",
                                                },
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($key_equals_values_braces);

      } elsif (${$self}{body} =~ m/$grouping_braces_regexpTrailingComment/){

        # log file output
        $self->logger("grouping braces found: $1",'heading');

        # create a new key_equals_values_braces object
        my $grouping_braces = LatexIndent::GroupingBracesBrackets->new(
                                                begin=>$1.($2?$2:q()).($3?$3:q()),
                                                name=>$1,
                                                body=>$4.($7?$7:($8?$8:q())),    
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>0,
                                                  end=>$7?1:0,
                                                },
                                                modifyLineBreaksYamlName=>"keyEqualsValuesBraces",
                                                regexp=>($7?$grouping_braces_regexp:$grouping_braces_regexpTrailingComment),
                                                endImmediatelyFollowedByComment=>$7?0:($8?1:0),
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"KeyStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"EqualsFinishesWithLineBreak",
                                                },
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($grouping_braces);
    } 
  }
    return;
}

1;
