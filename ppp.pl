# a file to help create latexindent.exe, for reference, see
# http://stackoverflow.com/questions/43549240/perl-par-packer-executable-with-unicodegcstring-cant-locate-object-method/43690984#43690984
#
# perl ppp.pl -u -o latexindent.exe latexindent.pl
$ENV{PAR_VERBATIM}=1;
system 'pp', @ARGV;
