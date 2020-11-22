#!/usr/bin/env perl
use Regexp::Grammars;
use Data::Dumper 'Dumper';
my $parser = qr{
    <File>

    <rule: File>       <[Element]>*

    <rule: Element>    <Command> | <Literal>

    <rule: Command>    \\  <Literal>  (?:<[Options]>|<[Args]>|<[Between]>)*

    <rule: Options>    \[  <[Option]>+ % (,)  \]

    <rule: Args>       \{  <[Element]>*  \}

    <rule: Option>     [^][\$&%#_{}~^\s,]+

    <rule: Literal>    [^][\$&%#_{}~^\s]+

    <rule: Between>    [*_]
}xms;

#my $test_string = '\cmh[first]_{second\drh{ONE}}[third]{fourth}*{fifth}';
my $test_string = '\cmh{first}';
$test_string =~ $parser;
print Dumper \%/;
exit(0);
