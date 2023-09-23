%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    latexindent.pl, version 3.23.2, 2023-09-23

    PERL script to indent code within environments, and align delimited 
    environments in .tex files.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    See http://www.gnu.org/licenses/

    C. M. Hughes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+

FOR COMPLETE DETAILS, PLEASE SEE documentation/latexindent.pdf

Note: The standalone executable files (in the bin directory) are created using commands
      such as the following:

      pp 
      --addfile="defaultSettings.yaml;lib/LatexIndent/defaultSettings.yaml"
      --cachedeps=scancache
      --output latexindent-linux
      latexindent.pl

      using the Par::Packer perl module.

*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+

USAGE
    You'll need

        latexindent.pl
        LatexIndent/*.pm
        defaultSettings.yaml

    in the same directory. Windows users might prefer to grab latexindent.exe

* IMPORTANT *

This script may not work for your style of formatting; I highly
recommend that when you first use the script you use the `-o` switch
to output to a separate file; something like

    latexindent.pl myfile.tex -o myfile-output.tex

and then check `myfile-output.tex` carefully to make sure that
nothing has been changed (or removed) in a way that will damage
your file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
