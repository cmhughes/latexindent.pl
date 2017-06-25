`PERL` script to indent code within environments, and align delimited 
environments in `.tex`files.

    latexindent.pl, version 3.2.1, 2017-06-25

Author: Chris Hughes (cmhughes)

---
---

For complete details, please see documentation/latexindent.pdf

Note: `latexindent.exe` was created using 

      perl ppp.pl -u -o latexindent.exe latexindent.pl

using the `Par::Packer` perl module.

ppp.pl is located in the helper-scripts directory.

---

### USAGE

You'll need

        latexindent.pl
        LatexIndent/*.pm
        defaultSettings.yaml

in the same directory. Windows users might prefer to grab latexindent.exe

### Testing

A nice way to test the script is to navigate to the test-cases 
directory, and then run the command (on Linux/Mac -- sorry, not created a Windows test-case version):

        ./test-cases.sh

## *IMPORTANT*

This script may not work for your style of formatting; I highly 
recommend comparing the outputfile.tex to make sure that 
nothing has been changed (or removed) in a way that will damage
your file.

I recommend using both of the following:
* a visual check, at the very least, make sure that 
      each file has the same number of lines
* a check using `latexdiff inputfile.tex outputfile.tex`
* git status myfile.tex
