%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    latexindent.pl, version 3.1, 2017-05-27

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

Note: latexindent.exe was created using 

      perl ppp.pl -u -o latexindent.exe latexindent.pl

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
recommend comparing the outputfile.tex to make sure that 
nothing has been changed (or removed) in a way that will damage
your file.

I recommend both using the following:
    - a visual check, at the very least, make sure that 
      each file has the same number of lines
    - a check using latexdiff inputfile.tex outputfile.tex
    - git status myfile.tex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
