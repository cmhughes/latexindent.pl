#!/usr/bin/env perl
use strict;
use warnings;
use Regexp::Grammars;
use Data::Dumper 'Dumper';
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
    #   <logfile: - >

    # https://metacpan.org/pod/Regexp::Grammars#Subrule-results
    <nocontext:>

    <File>

    <objrule: Latex::file=File>          <[Element]>*

    <objrule: Latex::element=Element>    <Command> | <Literal>

    <objrule: Latex::command=Command>    
        <begin=(\\)>
        <Literal>  
        (?:<[Options]>|<[MandatoryArgs]>|<[Between]>)*

    <objrule: Latex::mandatoryargs=MandatoryArgs> 
        <lbrace> <linebreaksAtEndBegin=(\R*)> <[Element]>* <rbrace>

    # miscellaneous tokens
    <token: lbrace> \{
    <token: rbrace> \}

    <objrule: Latex::literal=Literal>    <body=([^][\$&%#_{}~^\s]+)>

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
}{ second
}
};
#my $test_string = 'text';
$test_string =~ $parser;
print Dumper \%/;

$/{File}->explain(0);

my $master_body = $/{File}->unpack(0);
print "master body: $master_body\n";

exit(0);
