Perl script to indent code within environments, and align delimited 
environments in .tex files.

For example, it converts this:

\begin{align*}
	F(-x) & =-(-x)^2 &   G(-x) & =-(-x)^4 & H(-x) & =-(-x)^6 \\ 
	    & =-x^2    & & =-x^4    &       & =-x^6\\    
	      &  =F(x)  &      & =G(x)    &       & =H(x)    
\end{align*}

into this:

\begin{align*}
	F(-x) & =-(-x)^2 & G(-x) & =-(-x)^4 & H(-x) & =-(-x)^6 \\ 
	      & =-x^2    &       & =-x^4    &       & =-x^6    \\    
	      & =F(x)    &       & =G(x)    &       & =H(x)    
\end{align*}

This file does not (or rather, should not) remove any lines
from your .tex file.

Usage:

    perl indent.plx inputfile.tex

will output to the terminal and 

    perl indent.plx inputfile.tex > outputfile.tex

will output to outputfile.tex

For more examples, see the sampleBEFORE.tex and sampleAFTER.tex 
which was obtained by running

    perl indent.plx sampleBEFORE.tex > sampleAFTER.tex

* IMPORTANT *

This script may not work for your style of formatting; I highly 
recommend comparing the outputfile.tex to make sure that 
nothing has been changed (or removed) in a way that will damage
your file.

I recommend both using the following:
    - a visual check, at the very least, make sure that 
      each file has the same number of lines
    - a check using latexdiff inputfile.tex outputfile.tex
