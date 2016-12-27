# Heading.pm
#   creates a class for the Heading object
#   which are a subclass of the Document object.
package LatexIndent::Heading;
use strict;
use warnings;
use Data::Dumper;
use Exporter qw/import/;
our @ISA = "LatexIndent::Document"; # class inheritance, Programming Perl, pg 321
our @EXPORT_OK = qw/find_heading construct_headings_levels/;
our $headingCounter;
our @headingsRegexpArray;
our $allHeadingsRegexp = q();

sub construct_headings_levels{
    my $self = shift;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # grab the heading levels
    my %headingsLevels = %{$masterSettings{indentAfterHeadings}};

    # delete the values that have indentAfterThisHeading set to 0
    while( my ($headingName,$headingInfo)= each %headingsLevels){
        if(!${$headingsLevels{$headingName}}{indentAfterThisHeading}){
            $self->logger("Not indenting after $headingName (see indentAfterThisHeading)",'heading');
            delete $headingsLevels{$headingName};
        } else {
            # *all heading* regexp
            $allHeadingsRegexp .= ($allHeadingsRegexp eq '' ?q():"|").$headingName;
        }
    }

    # sort the file extensions by preference 
    my @sortedByLevels = sort { ${$headingsLevels{$a}}{level} <=> $headingsLevels{$b}{level} } keys(%headingsLevels);

    # it could be that @sortedByLevels is empty;
    return if !@sortedByLevels;

    $self->logger("All headings regexp: $allHeadingsRegexp",'heading'); 

    # loop through the levels, and create a regexp for each (min and max values are the first and last values respectively from sortedByLevels)
    for(my $i = ${$headingsLevels{$sortedByLevels[0]}}{level}; $i <= ${$headingsLevels{$sortedByLevels[-1]}}{level}; $i++ ){
        # level regexp
        my @tmp = grep { ${$headingsLevels{$_}}{level} == $i } keys %headingsLevels;
        push(@headingsRegexpArray,join("|",@tmp)) if @tmp;
        $self->logger("Heading level regexp for level $i will contain: @tmp",'heading') if @tmp;
    }
  }

sub find_heading{

    # if there are no headings regexps, there's no point going any further
    return if!@headingsRegexpArray;

    my $self = shift;

    # grab the settings
    my %masterSettings = %{$self->get_master_settings};

    # otherwise loop through the headings regexp
    $self->logger("Searching for special begin/end (see specialBeginEnd)");

    # get the blank line token
    my $blankLineToken = $self->get_blank_line_token;

    # trailing comment regexp
    my $trailingCommentRegExp = $self->get_trailing_comment_regexp;

    # loop through each headings match; note that we need to 
    # do it in *reverse* so as to ensure that the lower level headings get matched first of all
    foreach(reverse(@headingsRegexpArray)){
        
        # the regexp
        my $headingRegExp = qr/
                              (
                                  \\($_)        # name stored into $2
                              )                 # beginning bit into $1
                              (
                                  .*?                 
                              )                 # body into $3      
                              (\R*)?            # linebreaks at end of body into $4
                              ((?:\\(?:$allHeadingsRegexp))|$)  # up to another heading, or else the end of the file
                           /sx;
        
        while(${$self}{body} =~ m/$headingRegExp/){

            # log file output
            $self->logger("heading found: $2",'heading');

            # create a new heading object
            my $headingObject = LatexIndent::Heading->new(begin=>q(),
                                                    body=>$1.$3,
                                                    end=>q(),
                                                    afterbit=>($4?$4:q()).($5?$5:q()),
                                                    name=>$2.":heading",
                                                    parent=>$2,
                                                    nameForIndentationSettings=>$2,
                                                    linebreaksAtEnd=>{
                                                      begin=>0,
                                                      body=>0,
                                                      end=>0,
                                                    },
                                                    modifyLineBreaksYamlName=>"afterHeading",
                                                    regexp=>$headingRegExp,
                                                    endImmediatelyFollowedByComment=>0,
                                                  );

            # the settings and storage of most objects has a lot in common
            $self->get_settings_and_store_new_object($headingObject);
        }
     }
}

sub get_replacement_text{
    my $self = shift;

    # the replacement text for a heading (chapter, section, etc) needs to put the trailing part back in
    $self->logger("Custom replacement text routine for heading ${$self}{name}");
    ${$self}{replacementText} = ${$self}{id}.${$self}{afterbit};
    delete ${$self}{afterbit};
}

sub create_unique_id{
    my $self = shift;

    $headingCounter++;

    ${$self}{id} = "${$self->get_tokens}{heading}$headingCounter";
    return;
}

sub adjust_replacement_text_line_breaks_at_end{
    return;
}

sub get_object_attribute_for_indentation_settings{
    # when looking for noAdditionalIndent or indentRules, we may need to determine
    # which thing we're looking for, e.g
    #
    #   chapter:
    #       body: 0
    #       optionalArguments: 1
    #       mandatoryArguments: 1
    #       afterHeading: 0
    #
    # this method returns 'body' by default, but the other objects (optionalArgument, mandatoryArgument, afterHeading)
    # return their appropriate identifier.
    my $self = shift;
    
    return ${$self}{modifyLineBreaksYamlName};
}

sub tasks_particular_to_each_object{
    my $self = shift;

    # search for commands, keys, named grouping braces
    $self->find_commands_or_key_equals_values_braces;

    return;
}

1;
