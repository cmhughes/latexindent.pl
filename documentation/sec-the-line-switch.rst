.. label follows

.. _sec:line-switch:

The –lines switch
=================

``latexindent.pl`` can operate on a *selection* of lines of the file using the ``–lines`` or ``-n`` switch.

.. index:: switches;-lines demonstration

The basic syntax is ``–lines MIN-MAX``, so for example

.. code-block:: latex
   :class: .commandshell

   latexindent.pl --lines 3-7 myfile.tex
   latexindent.pl -n 3-7 myfile.tex

will only operate upon lines 3 to 7 in ``myfile.tex``. All of the other lines will *not* be operated upon by ``latexindent.pl``.

The options for the ``lines`` switch are:

-  line range, as in ``–lines 3-7``

-  single line, as in ``–lines 5``

-  multiple line ranges separated by commas, as in ``–lines 3-5,8-10``

-  negated line ranges, as in ``–lines !3-5`` which translates to ``–lines 1-2,6-N``, where N is the number of lines in your file.

We demonstrate this feature, and the available variations in what follows. We will use the file in :numref:`lst:myfile`.

.. literalinclude:: demonstrations/myfile.tex
 	:class: .tex
 	:caption: ``myfile.tex`` 
 	:name: lst:myfile
 	:linenos:

.. proof:example::	
	
	We demonstrate the basic usage using the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 3-7 myfile.tex -o=+-mod1
	
	which instructs ``latexindent.pl`` to only operate on lines 3 to 7; the output is given in :numref:`lst:myfile-mod1`.
	
	.. literalinclude:: demonstrations/myfile-mod1.tex
	 	:class: .tex
	 	:caption: ``myfile-mod1.tex`` 
	 	:name: lst:myfile-mod1
	 	:linenos:
	
	The following two calls to ``latexindent.pl`` are equivalent
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 3-7 myfile.tex -o=+-mod1
	   latexindent.pl --lines 7-3 myfile.tex -o=+-mod1
	
	as ``latexindent.pl`` performs a check to put the lowest number first.
	 

.. proof:example::	
	
	You can call the ``lines`` switch with only *one number* and in which case only that line will be operated upon. For example
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 5 myfile.tex -o=+-mod2
	
	instructs ``latexindent.pl`` to only operate on line 5; the output is given in :numref:`lst:myfile-mod2`.
	
	.. literalinclude:: demonstrations/myfile-mod2.tex
	 	:class: .tex
	 	:caption: ``myfile-mod2.tex`` 
	 	:name: lst:myfile-mod2
	 	:linenos:
	
	The following two calls are equivalent:
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 5 myfile.tex
	   latexindent.pl --lines 5-5 myfile.tex
	
	
	 

.. proof:example::	
	
	If you specify a value outside of the line range of the file then ``latexindent.pl`` will ignore the ``lines`` argument, detail as such in the log file, and proceed to operate on the entire file.
	
	For example, in the following call
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 11-13 myfile.tex
	
	``latexindent.pl`` will ignore the ``lines`` argument, and *operate on the entire file* because :numref:`lst:myfile` only has 12 lines.
	
	Similarly, in the call
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines -1-3 myfile.tex
	
	``latexindent.pl`` will ignore the ``lines`` argument, and *operate on the entire file* because we assume that negatively numbered lines in a file do not exist.
	 

.. proof:example::	
	
	You can specify *multiple line ranges* as in the following
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 3-5,8-10 myfile.tex -o=+-mod3
	
	which instructs ``latexindent.pl`` to operate upon lines 3 to 5 and lines 8 to 10; the output is given in :numref:`lst:myfile-mod3`.
	
	.. literalinclude:: demonstrations/myfile-mod3.tex
	 	:class: .tex
	 	:caption: ``myfile-mod3.tex`` 
	 	:name: lst:myfile-mod3
	 	:linenos:
	
	The following calls to ``latexindent.pl`` are all equivalent
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 3-5,8-10 myfile.tex
	   latexindent.pl --lines 8-10,3-5 myfile.tex
	   latexindent.pl --lines 10-8,3-5 myfile.tex
	   latexindent.pl --lines 10-8,5-3 myfile.tex
	
	as ``latexindent.pl`` performs a check to put the lowest line ranges first, and within each line range, it puts the lowest number first.
	 

.. proof:example::	
	
	There’s no limit to the number of line ranges that you can specify, they just need to be separated by commas. For example
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 1-2,4-5,9-10,12 myfile.tex -o=+-mod4
	
	has four line ranges: lines 1 to 2, lines 4 to 5, lines 9 to 10 and line 12. The output is given in :numref:`lst:myfile-mod4`.
	
	.. literalinclude:: demonstrations/myfile-mod4.tex
	 	:class: .tex
	 	:caption: ``myfile-mod4.tex`` 
	 	:name: lst:myfile-mod4
	 	:linenos:
	
	As previously, the ordering does not matter, and the following calls to ``latexindent.pl`` are all equivalent
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 1-2,4-5,9-10,12 myfile.tex
	   latexindent.pl --lines 2-1,4-5,9-10,12 myfile.tex
	   latexindent.pl --lines 4-5,1-2,9-10,12 myfile.tex
	   latexindent.pl --lines 12,4-5,1-2,9-10 myfile.tex
	
	as ``latexindent.pl`` performs a check to put the lowest line ranges first, and within each line range, it puts the lowest number first.
	 

.. proof:example::	
	
	.. index:: switches;-lines demonstration, negation
	
	You can specify *negated line ranges* by using ``!`` as in
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines !5-7 myfile.tex -o=+-mod5
	
	which instructs ``latexindent.pl`` to operate upon all of the lines *except* lines 5 to 7.
	
	In other words, ``latexindent.pl`` *will* operate on lines 1 to 4, and 8 to 12, so the following two calls are equivalent:
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines !5-7 myfile.tex 
	   latexindent.pl --lines 1-4,8-12 myfile.tex 
	
	The output is given in :numref:`lst:myfile-mod5`.
	
	.. literalinclude:: demonstrations/myfile-mod5.tex
	 	:class: .tex
	 	:caption: ``myfile-mod5.tex`` 
	 	:name: lst:myfile-mod5
	 	:linenos:
	
	
	 

.. proof:example::	
	
	.. index:: switches;-lines demonstration, negation
	
	You can specify *multiple negated line ranges* such as
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines !5-7,!9-10 myfile.tex -o=+-mod6
	
	which is equivalent to:
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 1-4,8,11-12 myfile.tex -o=+-mod6
	
	The output is given in :numref:`lst:myfile-mod6`.
	
	.. literalinclude:: demonstrations/myfile-mod6.tex
	 	:class: .tex
	 	:caption: ``myfile-mod6.tex`` 
	 	:name: lst:myfile-mod6
	 	:linenos:
	
	
	 

.. proof:example::	
	
	If you specify a line range with anything other than an integer, then ``latexindent.pl`` will ignore the ``lines`` argument, and *operate on the entire file*.
	
	Sample calls that result in the ``lines`` argument being ignored include the following:
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 1-x myfile.tex 
	   latexindent.pl --lines !y-3 myfile.tex 
	
	
	 

.. proof:example::	
	
	We can, of course, use the ``lines`` switch in combination with other switches.
	
	For example, let’s use with the file in :numref:`lst:myfile1`.
	
	.. literalinclude:: demonstrations/myfile1.tex
	 	:class: .tex
	 	:caption: ``myfile1.tex`` 
	 	:name: lst:myfile1
	 	:linenos:
	
	We can demonstrate interaction with the ``-m`` switch (see :numref:`sec:modifylinebreaks`); in particular, if we use :numref:`lst:mlb2`, :numref:`lst:env-mlb7` and :numref:`lst:env-mlb8` and run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl --lines 6 myfile1.tex -o=+-mod1 -m -l env-mlb2,env-mlb7,env-mlb8 -o=+-mod1
	
	then we receive the output in :numref:`lst:myfile1-mod1`.
	
	.. literalinclude:: demonstrations/myfile1-mod1.tex
	 	:class: .tex
	 	:caption: ``myfile1-mod1.tex`` 
	 	:name: lst:myfile1-mod1
	 	:linenos:
	
	
	 

