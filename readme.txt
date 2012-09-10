%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    Dr. C. M. Hughes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
USAGE

    This file does not (or rather, should not) remove any lines
    from your .tex file.
    
        perl indent.plx inputfile.tex
    
    will output to the terminal and 
    
        perl indent.plx inputfile.tex > outputfile.tex
    
    will output to outputfile.tex

    You can make this file executable using
        
        chmod +x indent.plx

    and then put it with your other executable files, for example

        /usr/local/bin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 1: delimiter tabs; populate %lookforaligndelims with 
    a list of environments that have alignment tabs, the default is:

    my %lookforaligndelims=("tabular"=>1,
                            "align"=>1,
                            "align*"=>1,
                            "alignat"=>1,
                            "alignat*"=>1,
                            "cases"=>1,
                            "dcases"=>1,
                            "aligned"=>1);

    Include any environment name you like in here. If you change 
    your mind, just change 1 to a 0 (or remove them completely).

    Before:
    
    \begin{align*}
    	F(-x) & =-(-x)^2 &   G(-x) & =-(-x)^4 & H(-x) & =-(-x)^6 \\ 
    	    & =-x^2    & & =-x^4    &       & =-x^6\\    
    	      &  =F(x)  &      & =G(x)    &       & =H(x)    
    \end{align*}
    
    After:
    
    \begin{align*}
    	F(-x) & =-(-x)^2 & G(-x) & =-(-x)^4 & H(-x) & =-(-x)^6 \\ 
    	      & =-x^2    &       & =-x^4    &       & =-x^6    \\    
    	      & =F(x)    &       & =G(x)    &       & =H(x)    
    \end{align*}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 2: nested environments; by default every time the script comes 
    across \begin{something} it will increase the indentation- this 
    can be customized as detailed in the next examples.

    Before:
    
    \begin{figure}[!htb]
     \centering
    \begin{tikzpicture}
        \begin{axis}[
            framed,
            width=\figurewidth,
            xmin=-5,xmax=5,
            ymin=-1,ymax=5,
            xtick={-6},
            ytick={-6},
         ]
          \addplot expression[domain=-4.5:2.2]{2^x};
        \end{axis}
    \end{tikzpicture}
    \end{figure}
    
    After:
    
    \begin{figure}[!htb]
    	\centering
    	\begin{tikzpicture}
    		\begin{axis}[
    		   framed,
    		   width=\figurewidth,
    		   xmin=-5,xmax=5,
    		   ymin=-1,ymax=5,
    		   xtick={-6},
    		   ytick={-6},
    		   ]
    		   \addplot expression[domain=-4.5:2.2]{2^x};
    		\end{axis}
    	\end{tikzpicture}
    \end{figure}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 3: custom indentation

    If you want to customize the indentation for an environment, 
    then use %indentrules, for example

    my %indentrules=("axis"=>"\t\t\t");

    will indent the axis environment using 3 tabs.

    Include any environment name you like in here with 
    the special rule that you choose.

    Before:

    \begin{figure}[!htb]
     \centering
    \begin{tikzpicture}
        \begin{axis}[
            framed,
            width=\figurewidth,
            xmin=-5,xmax=5,
            ymin=-1,ymax=5,
            xtick={-6},
            ytick={-6},
         ]
          \addplot expression[domain=-4.5:2.2]{2^x};
        \end{axis}
    \end{tikzpicture}
    \end{figure}

    After:

    \begin{figure}[!htb]
    	\centering
    	\begin{tikzpicture}
    		\begin{axis}[
    					framed,
    					width=\figurewidth,
    					xmin=-5,xmax=5,
    					ymin=-1,ymax=5,
    					xtick={-6},
    					ytick={-6},
    					]
    					\addplot expression[domain=-4.5:2.2]{2^x};
    		\end{axis}
    	\end{tikzpicture}
    \end{figure}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 4: no additional indentation for an environment; if you want
    an environment to not have additional indentation, then populate
    %noindent, for example
        
    my %noindent=("tikzpicture"=>1,
                      );

    Include any environment name you like in here. If you change 
    your mind, just change 1 to a 0, or remove it from %noindent 
    completely.

    Before:

    \begin{figure}[!htb]
     \centering
    \begin{tikzpicture}
        \begin{axis}[
            framed,
            width=\figurewidth,
            xmin=-5,xmax=5,
            ymin=-1,ymax=5,
            xtick={-6},
            ytick={-6},
         ]
          \addplot expression[domain=-4.5:2.2]{2^x};
        \end{axis}
    \end{tikzpicture}
    \end{figure}

    After (notice that tikzpicture content is not indented):

    \begin{figure}[!htb]
    	\centering
    	\begin{tikzpicture}
    	\begin{axis}[
    		framed,
    		width=\figurewidth,
    		xmin=-5,xmax=5,
    		ymin=-1,ymax=5,
    		xtick={-6},
    		ytick={-6},
    		]
    		\addplot expression[domain=-4.5:2.2]{2^x};
    	\end{axis}
    	\end{tikzpicture}
    \end{figure}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 5: commands that split {} across lines, e.g \parbox; populate
    %checkunmatched, 
     
    my %checkunmatched=("parbox"=>1,);

    Include any command name you wish; you can put 
    TikZ key names in here too- they don't have to begin with \, 
    for example

    my %checkunmatched=("parbox"=>1,
                        "vbox"=>1,
                        "marginpar"=>1,
                        "pgfplotstableset"=>1,
                        "empty header/.style"=>1,
                        "typeset cell/.append code"=>1,
                        "create col/assign/.code"=>1,
                        "foreach"=>1);
    
    You can specify particular indentation rules in %indentrules, 
    as in Example 3.

    Before:

    \parbox{
    some text
    some text
    some text
    some text
    some text
    }

    After:

    \parbox{
    	some text
    	some text
    	some text
    	some text
    	some text
    }

    Note: you can nest these commands, e.g

    Before:

    \parbox{
    some text
    some text
    some text
    some text
    some text
    \parbox{
    some text
    some text
    some text
    some text
    some text
    }
    }

    After:

    \parbox{
    	some text
    	some text
    	some text
    	some text
    	some text
    	\parbox{
    		some text
    		some text
    		some text
    		some text
    		some text
    	}
    }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 6: commands that have an else clause using {} and can split the
    {} across lines; populate %checkunmatchedELSE, for example

    my %checkunmatchedELSE=("mycommand"=>1);

    Include any command name you wish; you can put 
    TikZ key names in here too- they don't have to begin with \ 
    as in Example 5.

    You can specify particular indentation rules in %indentrules, 
    as in Example 3.

    Before:
    
    \mycommand{
    if clause
    }
    {
    else clause
    }

    After:
    
    \mycommand{
    	if clause
    }
    {
    	else clause
    }

    Note that these can be nested as in Example 5.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 7: commands that split [] across lines; populate 
    %checkunmatchedbracket, for example

    my %checkunmatchedbracket=("mycommand"=>1);

    Include any command name you wish that may split [] across 
    lines; it doesn't have to begin with a \ as in Examples
    5 and 6. 

    You can specify particular indentation rules in %indentrules, 
    as in Example 3.
    
    Before:

    \mycommand[
    some text
    some text
    some text
    some text
    some text
    some text
    ]

    After:
    
    \mycommand[
    	some text
    	some text
    	some text
    	some text
    	some text
    	some text
    ]

    Note that these can be nested as in Example 5.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EXAMPLE 8: verbatim environments; if you don't want the script to 
    modify a code block at all, then populate %verbatim, for example

    my %verbatim=("verbatim"=>1);

    Include any environment name you wish to behave like 
    a verbatim environment.

    Before:

    \begin{verbatim}
    this text won't change
        at all
            promise!
                        hopefully\ldots
    \end{verbatim}

    After:

    \begin{verbatim}
    this text won't change
        at all
            promise!
                        hopefully\ldots
    \end{verbatim}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
