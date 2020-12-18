package LatexIndent::Special;
use strict;
use warnings;
use feature qw(say);
use LatexIndent::LogFile qw/$grammarLeadingSpace/;

# TO DO: these hashes will need to read from the YAML
# TO DO: these hashes will need to read from the YAML
our $special_begin_reg_ex = qr/\$|\\\[/s;
our %special_look_up_hash = (displayMath=>({
                                            begin=>qr/\\\[/s,
                                            middle=>qr/\\(Middle|ElsIf)(?:(\h|\R)*)/s,
                                            end=>qr/\\\]/s
                                          }),
                            inlineMath=>({
                                            begin=>qr/\$/s,
                                            end=>qr/\$/s
                                         }),
                 );

our %special_middle_look_up_hash;
our %special_end_look_up_hash;


sub explain {
    my ($self, $level) = @_;
    say $grammarLeadingSpace x $level, "Special";
    say $grammarLeadingSpace x ($level+1), "Begin: $self->{begin}";
    say $grammarLeadingSpace x ($level+1), "End:   $self->{end}";
    say $grammarLeadingSpace x $level, $self->{GroupOfItems}->explain($level+2);
    return;
}

sub indent {
    my $self = shift;
    my $body = q();
    $body .= $self->{GroupOfItems}->indent;

    if (!$self->{GroupOfItems}->{itemHeading}){
        # indentation of the body
        $body =~ s/^/\t/mg;

        # remove the first line of indentation, if appropriate
        $body =~ s/^\t//s if !$self->{linebreaksAtEndBegin};
    }

    # assemble the body
    $body =  $self->{begin}                 # begin
            .$self->{leadingHorizontalSpace}
            .$self->{linebreaksAtEndBegin}
            .$body                          # body
            .$self->{end}                   # end
            .$self->{horizontalTrailingSpace}
            .$self->{linebreaksAtEndEnd};   
    return $body;
}
1;

# my $test_begin = '$';
# while( my ($key,$value)= each %special_look_up_hash){
#     if ($test_begin =~ ${$value}{begin} ){
#         print "match found: ",$key,"\n";
#         print "corresponding end: ",${$value}{end},"\n";
#     }
# }
# 
# print "================\n";
# 
# print Dumper \%special_look_up_hash; 
