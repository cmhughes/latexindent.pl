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

    # something {value} or something [value] regexp
    my $grouping_braces_regexp = $self->get_grouping_braces_brackets_regexp;

    # {something} or [something] regexp (unnamed grouping braces)
    my $un_named_grouping_braces_RegExp = $self->get_unnamed_grouping_braces_brackets_regexp; 

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # command regexp with trailing comment
    my $commandRegExpTrailingComment = qr/$commandRegExp\h*((?:$trailingCommentRegExp\h*)*)/;

    # key ={value} regexp with trailing comment
    my $key_equals_values_bracesRegExpTrailingComment = qr/$key_equals_values_bracesRegExp\h*((?:$trailingCommentRegExp\h*)*)?/;

    # something {value} grouping braces with trailing comment
    my $grouping_braces_regexpTrailingComment = qr/$grouping_braces_regexp\h*((?:$trailingCommentRegExp\h*)*)?/;

    # {something} or [something] with trailing comment
    my $un_named_grouping_braces_RegExp_trailing_comment = qr/$un_named_grouping_braces_RegExp\h*((?:$trailingCommentRegExp\h*)*)?/; 

    # match either a \\command or key={value}
    while( ${$self}{body} =~ m/$commandRegExpTrailingComment/
                            or  
           ${$self}{body} =~ m/$key_equals_values_bracesRegExpTrailingComment/
                            or
           ${$self}{body} =~ m/$grouping_braces_regexpTrailingComment/ 
                            or
           ${$self}{body} =~ m/$un_named_grouping_braces_RegExp_trailing_comment/
         ){
      if(${$self}{body} =~ m/$commandRegExpTrailingComment/){ 
        # log file output
        $self->logger("command found: $2",'heading');

        # create a new command object
        my $command = LatexIndent::Command->new(begin=>$1.$2.($3?$3:q()).($4?$4:q()),
                                                name=>$2,
                                                body=>$5.($8?$8:($9?$9:q())),    # $8 is linebreak, $9 is trailing comment
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>$4?1:0,
                                                  end=>$8?1:0,            # $8 is linebreak before comment check, $9 is after
                                                },
                                                modifyLineBreaksYamlName=>"commands",
                                                regexp=>($8?$commandRegExp:$commandRegExpTrailingComment),
                                                endImmediatelyFollowedByComment=>$8?0:($9?1:0),
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
                                                additionalAssignments=>["EqualsStartsOnOwnLine"],
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($key_equals_values_braces);

      } elsif (${$self}{body} =~ m/$grouping_braces_regexpTrailingComment/){

        # log file output
        $self->logger("named grouping braces found: $2",'heading');

        # create a new key_equals_values_braces object
        my $grouping_braces = LatexIndent::NamedGroupingBracesBrackets->new(
                                                begin=>$2.($3?$3:q()).($4?$4:q()),
                                                name=>$2,
                                                body=>$5.($8?$8:($9?$9:q())),    
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>$4?1:0,
                                                  end=>$8?1:0,
                                                },
                                                modifyLineBreaksYamlName=>"namedGroupingBracesBrackets",
                                                regexp=>($8?$grouping_braces_regexp:$grouping_braces_regexpTrailingComment),
                                                beginningbit=>$1,
                                                endImmediatelyFollowedByComment=>$8?0:($9?1:0),
                                                aliases=>{
                                                  # begin statements
                                                  BeginStartsOnOwnLine=>"NameStartsOnOwnLine",
                                                  # body statements
                                                  BodyStartsOnOwnLine=>"NameFinishesWithLineBreak",
                                                },
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($grouping_braces);
    } elsif (${$self}{body} =~ m/$un_named_grouping_braces_RegExp_trailing_comment/) {
        # log file output
        $self->logger("UNnamed grouping braces found (no name, by definition!)",'heading');

        # create a new Un-named-grouping-braces-brackets object
        my $un_named_grouping_braces = LatexIndent::UnNamedGroupingBracesBrackets->new(
                                                begin=>q(),
                                                name=>"always-un-named",
                                                body=>$3.($6?$6:($7?$7:q())),    
                                                end=>q(),
                                                linebreaksAtEnd=>{
                                                  begin=>$2?1:0,
                                                  end=>$6?1:0,
                                                },
                                                modifyLineBreaksYamlName=>"UnNamedGroupingBracesBrackets",
                                                regexp=>($6?$un_named_grouping_braces_RegExp:$un_named_grouping_braces_RegExp_trailing_comment),
                                                beginningbit=>$1,
                                                endImmediatelyFollowedByComment=>$6?0:($7?1:0),
                                              );

        # the settings and storage of most objects has a lot in common
        $self->get_settings_and_store_new_object($un_named_grouping_braces);

    }
  }
    return;
}

1;
