#!/usr/bin/env perl
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	See http://www.gnu.org/licenses/.
#
#	Chris Hughes, 2017
#
#	For all communication, please visit: https://github.com/cmhughes/latexindent.pl

use strict;
use warnings;

print ("============\nlatexindent.pl module installer\n============\n");
print ("Would you like to run the following commands?\n");
my @modulesToInstall = ("cpanm YAML::Tiny","cpanm File::HomeDir","cpanm Unicode::GCString");
foreach (@modulesToInstall) {
    print $_,"\n";
}
if (prompt_yn("Press Y to run the above commands")){
    foreach (@modulesToInstall) {
        system($_);
    }
} else {
  print "Not installing modules\n";
}
exit;

# reference: https://stackoverflow.com/questions/18103501/prompting-multiple-questions-to-user-yes-no-file-name-input
sub prompt {
  my ($query) = @_; # take a prompt string as argument
  local $| = 1; # activate autoflush to immediately show the prompt
  print $query;
  chomp(my $answer = <STDIN>);
  return $answer;
}

sub prompt_yn {
  my ($query) = @_;
  my $answer = prompt("$query (Y/N): ");
  return lc($answer) eq 'y';
}
