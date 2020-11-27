#!/usr/bin/env perl
use strict;
use warnings;
use Regexp::Grammars;
use Data::Dumper;           # reference: https://stackoverflow.com/questions/7466825/how-do-you-sort-the-output-of-datadumper
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;
$Data::Dumper::Deparse = 1;
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Sortkeys = 1;

use FindBin;                   
#use YAML;                # interpret defaultSettings.yaml and other potential settings files
use lib $FindBin::RealBin;
use Latex;

my $parser = qr{
    # starting point:
    #   https://perl-begin.org/uses/text-parsing/
    #   https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    
    # helpful
    #   https://stackoverflow.com/questions/1352657/regex-for-matching-custom-syntax
    
    # https://metacpan.org/pod/Regexp::Grammars#Debugging1
    # <logfile: indent.log >

    # https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    <nocontext:>

    <File>

    <objrule: Latex::file=File>          
        <[Element]>*

    <objrule: Latex::element=Element>    
        <Command> | <Literal>

    <objrule: Latex::command=Command>    
        <begin=(\\)>
        <name=([^][\$&%#_{}~^\s]+)>
        (?:<[Options]>|<[MandatoryArgs]>|<[Between]>)*
        <linebreaksAtEndEnd=(\R*)> 

    <objrule: Latex::mandatoryargs=MandatoryArgs> 
        <begin=(\{)> 
        <leadingHorizontalSpace=(\h*)>
        <linebreaksAtEndBegin=(\R*)> 
        <[Element]>* 
        <linebreaksAtEndBody=(\R*)> 
        <end=(\})> 

    <objrule: Latex::literal=Literal>    
        <body=([^][\$&%#_{}~^]+)>

    # to fix
    # to fix
    # to fix
    <rule: Options>                      \[  <[Option]>+ % (,)  \]

    <rule: Option>                       [^][\$&%#_{}~^\s,]+

    <rule: Between>                      [*_]
}xms;

my $test_string = q{
\cmh{
first
}{ second \again{ \another{nested }
1234 \other{ asas
text 
goes
here}}
}{  third another 
word goes here}
};
#my $test_string = 'text';
$test_string =~ $parser;

print Dumper \%/;

$/{File}->explain(0);

my $master_body = $/{File}->unpack(0);
print "master body: $master_body\n";

exit(0);
