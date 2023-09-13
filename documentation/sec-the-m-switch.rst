.. label follows

.. _sec:modifylinebreaks:

The -m (modifylinebreaks) switch
================================

All features described in this section will only be relevant if the ``-m`` switch is used.

.. describe:: modifylinebreaks:fields

As of Version 3.0, ``latexindent.pl`` has the ``-m`` switch, which permits ``latexindent.pl`` to modify line breaks, according to the specifications in the ``modifyLineBreaks`` field. *The settings in this field will only be considered if the ``-m`` switch has been used*. A snippet of the default settings of this field is shown in :numref:`lst:modifylinebreaks`.

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``modifyLineBreaks`` 
	:name: lst:modifylinebreaks
	:lines: 500-502
	:linenos:
	:lineno-start: 500

Having read the previous paragraph, it should sound reasonable that, if you call ``latexindent.pl`` using the ``-m`` switch, then you give it permission to modify line breaks in your file, but let’s be clear:

.. index:: warning;the m switch

.. warning::	
	
	If you call ``latexindent.pl`` with the ``-m`` switch, then you are giving it permission to modify line breaks. By default, the only thing that will happen is that multiple blank lines will be condensed into one blank line; many other settings are possible, discussed next.


.. describe:: preserveBlankLines:0|1

This field is directly related to *poly-switches*, discussed in :numref:`sec:poly-switches`. By default, it is set to ``1``, which means that blank lines will be *protected* from removal; however, regardless of this setting, multiple blank lines can be condensed if ``condenseMultipleBlankLinesInto`` is greater than ``0``, discussed next.

.. describe:: condenseMultipleBlankLinesInto:positive integer

Assuming that this switch takes an integer value greater than ``0``, ``latexindent.pl`` will condense multiple blank lines into the number of blank lines illustrated by this switch.

.. proof:example::	
	
	As an example, :numref:`lst:mlb-bl` shows a sample file with blank lines; upon running
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl myfile.tex -m -o=+-mod1 
	
	the output is shown in :numref:`lst:mlb-bl-out`; note that the multiple blank lines have been condensed into one blank line, and note also that we have used the ``-m`` switch!
	
	.. literalinclude:: demonstrations/mlb1.tex
		:class: .tex
		:caption: ``mlb1.tex`` 
		:name: lst:mlb-bl
	
	.. literalinclude:: demonstrations/mlb1-out.tex
		:class: .tex
		:caption: ``mlb1-mod1.tex`` 
		:name: lst:mlb-bl-out
	


.. label follows

.. _subsec:textwrapping:

Text Wrapping
-------------

*The text wrapping routine has been over-hauled as of V3.16; I hope that the interface is simpler, and most importantly, the results are better*.

The complete settings for this feature are given in :numref:`lst:textWrapOptionsAll`.

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``textWrapOptions`` 
	:name: lst:textWrapOptionsAll
	:lines: 530-557
	:linenos:
	:lineno-start: 530

Text wrap: overview
~~~~~~~~~~~~~~~~~~~

An overview of how the text wrapping feature works:

#. the default value of ``columns`` is 0, which means that text wrapping will *not* happen by default;

#. it happens *after* verbatim blocks have been found;

#. it happens *after* the oneSentencePerLine routine (see :numref:`sec:onesentenceperline`);

#. it can happen *before* or *after* all of the other code blocks are found and does *not* operate on a per-code-block basis; when using ``before`` this means that, including indentation, you may receive a column width wider than that which you specify in ``columns``, and in which case you probably wish to explore ``after`` in :numref:`subsubsec:tw:before:after`;

#. code blocks to be text wrapped will:

   #. *follow* the fields specified in ``blocksFollow``

   #. *begin* with the fields specified in ``blocksBeginWith``

   #. *end* before the fields specified in ``blocksEndBefore``

#. setting ``columns`` to a value :math:`>0` will text wrap blocks by first removing line breaks, and then wrapping according to the specified value of ``columns``;

#. setting ``columns`` to :math:`-1` will *only* remove line breaks within the text wrap block;

#. by default, the text wrapping routine will remove line breaks within text blocks because ``removeBlockLineBreaks`` is set to 1; switch it to 0 if you wish to change this;

#. about trailing comments within text wrap blocks:

   #. trailing comments that do *not* have leading space instruct the text wrap routine to connect the lines *without* space (see :numref:`lst:tw-tc2`);

   #. multiple trailing comments will be connected at the end of the text wrap block (see :numref:`lst:tw-tc4`);

   #. the number of spaces between the end of the text wrap block and the (possibly combined) trailing comments is determined by the spaces (if any) at the end of the text wrap block (see :numref:`lst:tw-tc5`);

#. trailing comments can receive text wrapping ; examples are shown in :numref:`subsubsec:tw:comments` and :numref:`subsubsec:ospl:tw:comments`.

We demonstrate this feature using a series of examples.

.. label follows

.. _subsec:textwrapping-quick-start:

Text wrap: simple examples
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:textwrap1`.
	
	.. index:: text wrap;quick start
	
	.. literalinclude:: demonstrations/textwrap1.tex
		:class: .tex
		:caption: ``textwrap1.tex`` 
		:name: lst:textwrap1
	
	We will change the value of ``columns`` in :numref:`lst:textwrap1-yaml` and then run the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml textwrap1.tex
	
	then we receive the output given in :numref:`lst:textwrap1-mod1`.
	
	.. literalinclude:: demonstrations/textwrap1-mod1.tex
		:class: .tex
		:caption: ``textwrap1-mod1.tex`` 
		:name: lst:textwrap1-mod1
	
	.. literalinclude:: demonstrations/textwrap1.yaml
		:class: .mlbyaml
		:caption: ``textwrap1.yaml`` 
		:name: lst:textwrap1-yaml
	


.. proof:example::	
	
	If we set ``columns`` to :math:`-1` then ``latexindent.pl`` remove line breaks within the text wrap block, and will *not* perform text wrapping. We can use this to undo text wrapping.
	
	.. index:: text wrap;setting columns to -1
	
	Starting from the file in :numref:`lst:textwrap1-mod1` and using the settings in :numref:`lst:textwrap1A-yaml`
	
	.. literalinclude:: demonstrations/textwrap1A.yaml
		:class: .mlbyaml
		:caption: ``textwrap1A.yaml`` 
		:name: lst:textwrap1A-yaml
	
	and running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1A.yaml textwrap1-mod1.tex
	
	gives the output in :numref:`lst:textwrap1-mod1A`.
	
	.. literalinclude:: demonstrations/textwrap1-mod1A.tex
		:class: .tex
		:caption: ``textwrap1-mod1A.tex`` 
		:name: lst:textwrap1-mod1A
	


.. proof:example::	
	
	By default, the text wrapping routine will convert multiple spaces into single spaces. You can change this behaviour by flicking the switch ``multipleSpacesToSingle`` which we have done in :numref:`lst:textwrap1B-yaml`
	
	Using the settings in :numref:`lst:textwrap1B-yaml` and running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1B.yaml textwrap1-mod1.tex
	
	gives the output in :numref:`lst:textwrap1-mod1B`.
	
	.. literalinclude:: demonstrations/textwrap1-mod1B.tex
		:class: .tex
		:caption: ``textwrap1-mod1B.tex`` 
		:name: lst:textwrap1-mod1B
	
	.. literalinclude:: demonstrations/textwrap1B.yaml
		:class: .mlbyaml
		:caption: ``textwrap1B.yaml`` 
		:name: lst:textwrap1B-yaml
	
	We note that in :numref:`lst:textwrap1-mod1B` the multiple spaces have *not* been condensed into single spaces.


Text wrap: ``blocksFollow`` examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We examine the ``blocksFollow`` field of :numref:`lst:textWrapOptionsAll`.

.. index:: text wrap;blocksFollow

.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:tw-headings1`.
	
	.. index:: text wrap;blocksFollow!headings
	
	.. literalinclude:: demonstrations/tw-headings1.tex
		:class: .tex
		:caption: ``tw-headings1.tex`` 
		:name: lst:tw-headings1
	
	We note that :numref:`lst:tw-headings1` contains the heading commands ``section`` and ``subsection``. Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-headings1.tex
	
	then we receive the output given in :numref:`lst:tw-headings1-mod1`.
	
	.. literalinclude:: demonstrations/tw-headings1-mod1.tex
		:class: .tex
		:caption: ``tw-headings1-mod1.tex`` 
		:name: lst:tw-headings1-mod1
	
	We reference :numref:`lst:textWrapOptionsAll` and also :numref:`lst:indentAfterHeadings`:
	
	-  in :numref:`lst:textWrapOptionsAll` the ``headings`` field is set to ``1``, which instructs ``latexindent.pl`` to read the fields from :numref:`lst:indentAfterHeadings`, *regardless of the value of indentAfterThisHeading or level*;
	
	-  the default is to assume that the heading command can, optionally, be followed by a ``label`` command.
	
	If you find scenarios in which the default value of ``headings`` does not work, then you can explore the ``other`` field.
	
	We can turn off ``headings`` as in :numref:`lst:bf-no-headings-yaml` and then run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,bf-no-headings.yaml tw-headings1.tex
	
	gives the output in :numref:`lst:tw-headings1-mod2`, in which text wrapping has been instructed *not to happen* following headings.
	
	.. literalinclude:: demonstrations/tw-headings1-mod2.tex
		:class: .tex
		:caption: ``tw-headings1-mod2.tex`` 
		:name: lst:tw-headings1-mod2
	
	.. literalinclude:: demonstrations/bf-no-headings.yaml
		:class: .mlbyaml
		:caption: ``bf-no-headings.yaml`` 
		:name: lst:bf-no-headings-yaml
	


.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:tw-comments1`.
	
	.. index:: text wrap;blocksFollow!comments
	
	.. literalinclude:: demonstrations/tw-comments1.tex
		:class: .tex
		:caption: ``tw-comments1.tex`` 
		:name: lst:tw-comments1
	
	We note that :numref:`lst:tw-comments1` contains trailing comments. Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-comments1.tex
	
	then we receive the output given in :numref:`lst:tw-comments1-mod1`.
	
	.. literalinclude:: demonstrations/tw-comments1-mod1.tex
		:class: .tex
		:caption: ``tw-comments1-mod1.tex`` 
		:name: lst:tw-comments1-mod1
	
	With reference to :numref:`lst:textWrapOptionsAll` the ``commentOnPreviousLine`` field is set to ``1``, which instructs ``latexindent.pl`` to find text wrap blocks after a comment on its own line.
	
	We can turn off ``comments`` as in :numref:`lst:bf-no-comments-yaml` and then run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,bf-no-comments.yaml tw-comments1.tex
	
	gives the output in :numref:`lst:tw-comments1-mod2`, in which text wrapping has been instructed *not to happen* following comments on their own line.
	
	.. literalinclude:: demonstrations/tw-comments1-mod2.tex
		:class: .tex
		:caption: ``tw-comments1-mod2.tex`` 
		:name: lst:tw-comments1-mod2
	
	.. literalinclude:: demonstrations/bf-no-comments.yaml
		:class: .mlbyaml
		:caption: ``bf-no-comments.yaml`` 
		:name: lst:bf-no-comments-yaml
	


Referencing :numref:`lst:textWrapOptionsAll` the ``blocksFollow`` fields ``par``, ``blankline``, ``verbatim`` and ``filecontents`` fields operate in analogous ways to those demonstrated in the above.

The ``other`` field of the ``blocksFollow`` can either be ``0`` (turned off) or set as a regular expression. The default value is set to ``\\\]|\\item(?:\h|\[)`` which can be translated to *backslash followed by a square bracket* or *backslash item followed by horizontal space or a square bracket*, or in other words, *end of display math* or an item command.

.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:tw-disp-math1`.
	
	.. index:: text wrap;blocksFollow!other
	
	.. index:: regular expressions;text wrap!blocksFollow
	
	.. literalinclude:: demonstrations/tw-disp-math1.tex
		:class: .tex
		:caption: ``tw-disp-math1.tex`` 
		:name: lst:tw-disp-math1
	
	We note that :numref:`lst:tw-disp-math1` contains display math. Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-disp-math1.tex
	
	then we receive the output given in :numref:`lst:tw-disp-math1-mod1`.
	
	.. literalinclude:: demonstrations/tw-disp-math1-mod1.tex
		:class: .tex
		:caption: ``tw-disp-math1-mod1.tex`` 
		:name: lst:tw-disp-math1-mod1
	
	With reference to :numref:`lst:textWrapOptionsAll` the ``other`` field is set to ``\\\]``, which instructs ``latexindent.pl`` to find text wrap blocks after the end of display math.
	
	We can turn off this switch as in :numref:`lst:bf-no-disp-math-yaml` and then run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,bf-no-disp-math.yaml tw-disp-math1.tex
	
	gives the output in :numref:`lst:tw-disp-math1-mod2`, in which text wrapping has been instructed *not to happen* following display math.
	
	.. literalinclude:: demonstrations/tw-disp-math1-mod2.tex
		:class: .tex
		:caption: ``tw-disp-math1-mod2.tex`` 
		:name: lst:tw-disp-math1-mod2
	
	.. literalinclude:: demonstrations/bf-no-disp-math.yaml
		:class: .mlbyaml
		:caption: ``bf-no-disp-math.yaml`` 
		:name: lst:bf-no-disp-math-yaml
	
	Naturally, you should feel encouraged to customise this as you see fit.


The ``blocksFollow`` field *deliberately* does not default to allowing text wrapping to occur after ``begin environment`` statements. You are encouraged to customize the ``other`` field to accommodate the environments that you would like to text wrap individually, as in the next example.

.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:tw-bf-myenv1`.
	
	.. index:: text wrap;blocksFollow!other
	
	.. index:: regular expressions;text wrap!blocksFollow
	
	.. literalinclude:: demonstrations/tw-bf-myenv1.tex
		:class: .tex
		:caption: ``tw-bf-myenv1.tex`` 
		:name: lst:tw-bf-myenv1
	
	We note that :numref:`lst:tw-bf-myenv1` contains ``myenv`` environment. Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-bf-myenv1.tex
	
	then we receive the output given in :numref:`lst:tw-bf-myenv1-mod1`.
	
	.. literalinclude:: demonstrations/tw-bf-myenv1-mod1.tex
		:class: .tex
		:caption: ``tw-bf-myenv1-mod1.tex`` 
		:name: lst:tw-bf-myenv1-mod1
	
	We note that we have *not* received much text wrapping. We can turn do better by employing :numref:`lst:tw-bf-myenv-yaml` and then run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,tw-bf-myenv.yaml tw-bf-myenv1.tex
	
	which gives the output in :numref:`lst:tw-bf-myenv1-mod2`, in which text wrapping has been implemented across the file.
	
	.. literalinclude:: demonstrations/tw-bf-myenv1-mod2.tex
		:class: .tex
		:caption: ``tw-bf-myenv1-mod2.tex`` 
		:name: lst:tw-bf-myenv1-mod2
	
	.. literalinclude:: demonstrations/tw-bf-myenv.yaml
		:class: .mlbyaml
		:caption: ``tw-bf-myenv.yaml`` 
		:name: lst:tw-bf-myenv-yaml
	


Text wrap: ``blocksBeginWith`` examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We examine the ``blocksBeginWith`` field of :numref:`lst:textWrapOptionsAll` with a series of examples.

.. index:: text wrap;blocksBeginWith

.. proof:example::	
	
	By default, text wrap blocks can begin with the characters ``a-z`` and ``A-Z``.
	
	If we start with the file given in :numref:`lst:tw-0-9`
	
	.. literalinclude:: demonstrations/tw-0-9.tex
		:class: .tex
		:caption: ``tw-0-9.tex`` 
		:name: lst:tw-0-9
	
	and run the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-0-9.tex
	
	then we receive the output given in :numref:`lst:tw-0-9-mod1` in which text wrapping has *not* occurred.
	
	.. literalinclude:: demonstrations/tw-0-9-mod1.tex
		:class: .tex
		:caption: ``tw-0-9-mod1.tex`` 
		:name: lst:tw-0-9-mod1
	
	We can allow paragraphs to begin with ``0-9`` characters by using the settings in :numref:`lst:bb-0-9-yaml` and running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,bb-0-9-yaml tw-0-9.tex
	
	gives the output in :numref:`lst:tw-0-9-mod2`, in which text wrapping *has* happened.
	
	.. literalinclude:: demonstrations/tw-0-9-mod2.tex
		:class: .tex
		:caption: ``tw-0-9-mod2.tex`` 
		:name: lst:tw-0-9-mod2
	
	.. literalinclude:: demonstrations/bb-0-9.yaml
		:class: .mlbyaml
		:caption: ``bb-0-9.yaml.yaml`` 
		:name: lst:bb-0-9-yaml
	


.. proof:example::	
	
	Let’s now use the file given in :numref:`lst:tw-bb-announce1`
	
	.. literalinclude:: demonstrations/tw-bb-announce1.tex
		:class: .tex
		:caption: ``tw-bb-announce1.tex`` 
		:name: lst:tw-bb-announce1
	
	and run the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml tw-bb-announce1.tex
	
	then we receive the output given in :numref:`lst:tw-bb-announce1-mod1` in which text wrapping has *not* occurred.
	
	.. literalinclude:: demonstrations/tw-bb-announce1-mod1.tex
		:class: .tex
		:caption: ``tw-bb-announce1-mod1.tex`` 
		:name: lst:tw-bb-announce1-mod1
	
	We can allow ``\announce`` to be at the beginning of paragraphs by using the settings in :numref:`lst:tw-bb-announce-yaml` and running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1.yaml,tw-bb-announce.yaml tw-bb-announce1.tex
	
	gives the output in :numref:`lst:tw-bb-announce1-mod2`, in which text wrapping *has* happened.
	
	.. literalinclude:: demonstrations/tw-bb-announce1-mod2.tex
		:class: .tex
		:caption: ``tw-bb-announce1-mod2.tex`` 
		:name: lst:tw-bb-announce1-mod2
	
	.. literalinclude:: demonstrations/tw-bb-announce.yaml
		:class: .mlbyaml
		:caption: ``tw-bb-announce.yaml`` 
		:name: lst:tw-bb-announce-yaml
	


Text wrap: ``blocksEndBefore`` examples
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We examine the ``blocksEndBefore`` field of :numref:`lst:textWrapOptionsAll` with a series of examples.

.. index:: text wrap;blocksEndBefore

.. proof:example::	
	
	Let’s use the sample text given in :numref:`lst:tw-be-equation`.
	
	.. index:: text wrap;blocksFollow!other
	
	.. index:: regular expressions;text wrap!blocksFollow
	
	.. literalinclude:: demonstrations/tw-be-equation.tex
		:class: .tex
		:caption: ``tw-be-equation.tex`` 
		:name: lst:tw-be-equation
	
	We note that :numref:`lst:tw-be-equation` contains an environment. Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1A.yaml tw-be-equation.tex
	
	then we receive the output given in :numref:`lst:tw-be-equation-mod1`.
	
	.. literalinclude:: demonstrations/tw-be-equation-mod1.tex
		:class: .tex
		:caption: ``tw-be-equation-mod1.tex`` 
		:name: lst:tw-be-equation-mod1
	
	With reference to :numref:`lst:textWrapOptionsAll` the ``other`` field is set to ``\\begin\{|\\\[|\\end\{``, which instructs ``latexindent.pl`` to *stop* text wrap blocks before ``begin`` statements, display math, and ``end`` statements.
	
	We can turn off this switch as in :numref:`lst:tw-be-equation-yaml` and then run
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l textwrap1A.yaml,tw-be-equation.yaml tw-be-equation.tex
	
	gives the output in :numref:`lst:tw-be-equation-mod2`, in which text wrapping has been instructed *not* to stop at these statements.
	
	.. literalinclude:: demonstrations/tw-be-equation.yaml
		:class: .mlbyaml
		:caption: ``tw-be-equation.yaml`` 
		:name: lst:tw-be-equation-yaml
	
	.. literalinclude:: demonstrations/tw-be-equation-mod2.tex
		:class: .tex
		:caption: ``tw-be-equation-mod2.tex`` 
		:name: lst:tw-be-equation-mod2
	
	Naturally, you should feel encouraged to customise this as you see fit.


Text wrap: trailing comments and spaces
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We explore the behaviour of the text wrap routine in relation to trailing comments using the following examples.

.. proof:example::	
	
	The file in :numref:`lst:tw-tc1` contains a trailing comment which *does* have a space infront of it.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc1.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output given in :numref:`lst:tw-tc1-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc1.tex
		:class: .tex
		:caption: ``tw-tc1.tex`` 
		:name: lst:tw-tc1
	
	.. literalinclude:: demonstrations/tw-tc1-mod1.tex
		:class: .tex
		:caption: ``tw-tc1-mod1.tex`` 
		:name: lst:tw-tc1-mod1
	


.. proof:example::	
	
	The file in :numref:`lst:tw-tc2` contains a trailing comment which does *not* have a space infront of it.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc2.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:tw-tc2-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc2.tex
		:class: .tex
		:caption: ``tw-tc2.tex`` 
		:name: lst:tw-tc2
	
	.. literalinclude:: demonstrations/tw-tc2-mod1.tex
		:class: .tex
		:caption: ``tw-tc2-mod1.tex`` 
		:name: lst:tw-tc2-mod1
	
	We note that, because there is *not* a space before the trailing comment, that the lines have been joined *without* a space.


.. proof:example::	
	
	The file in :numref:`lst:tw-tc3` contains multiple trailing comments.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc3.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:tw-tc3-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc3.tex
		:class: .tex
		:caption: ``tw-tc3.tex`` 
		:name: lst:tw-tc3
	
	.. literalinclude:: demonstrations/tw-tc3-mod1.tex
		:class: .tex
		:caption: ``tw-tc3-mod1.tex`` 
		:name: lst:tw-tc3-mod1
	


.. proof:example::	
	
	The file in :numref:`lst:tw-tc4` contains multiple trailing comments.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc4.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:tw-tc4-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc4.tex
		:class: .tex
		:caption: ``tw-tc4.tex`` 
		:name: lst:tw-tc4
	
	.. literalinclude:: demonstrations/tw-tc4-mod1.tex
		:class: .tex
		:caption: ``tw-tc4-mod1.tex`` 
		:name: lst:tw-tc4-mod1
	


.. proof:example::	
	
	The file in :numref:`lst:tw-tc5` contains multiple trailing comments.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc5.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:tw-tc5-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc5.tex
		:class: .tex
		:caption: ``tw-tc5.tex`` 
		:name: lst:tw-tc5
	
	.. literalinclude:: demonstrations/tw-tc5-mod1.tex
		:class: .tex
		:caption: ``tw-tc5-mod1.tex`` 
		:name: lst:tw-tc5-mod1
	
	The space at the end of the text block has been preserved.


.. proof:example::	
	
	The file in :numref:`lst:tw-tc6` contains multiple trailing comments.
	
	Running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tw-tc6.tex -l textwrap1A.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:tw-tc6-mod1`.
	
	.. literalinclude:: demonstrations/tw-tc6.tex
		:class: .tex
		:caption: ``tw-tc6.tex`` 
		:name: lst:tw-tc6
	
	.. literalinclude:: demonstrations/tw-tc6-mod1.tex
		:class: .tex
		:caption: ``tw-tc6-mod1.tex`` 
		:name: lst:tw-tc6-mod1
	
	The space at the end of the text block has been preserved.


.. label follows

.. _subsubsec:tw:before:after:

Text wrap: when before/after
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The text wrapping routine operates, by default, ``before`` the code blocks have been found, but this can be changed to ``after``:

-  ``before`` means it is likely that the columns of wrapped text may *exceed* the value specified in ``columns``;

-  ``after`` means it columns of wrapped text should *not* exceed the value specified in ``columns``.

We demonstrate this in the following examples. See also :numref:`subsubsec:ospl:before:after`.

.. proof:example::	
	
	Let’s begin with the file in :numref:`lst:textwrap8`.
	
	.. literalinclude:: demonstrations/textwrap8.tex
		:class: .tex
		:caption: ``textwrap8.tex`` 
		:name: lst:textwrap8
	
	Using the settings given in :numref:`lst:tw-before1` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl textwrap8.tex -o=+-mod1.tex -l=tw-before1.yaml -m
	
	gives the output given in :numref:`lst:textwrap8-mod1`.
	
	.. literalinclude:: demonstrations/textwrap8-mod1.tex
		:class: .tex
		:caption: ``textwrap8-mod1.tex`` 
		:name: lst:textwrap8-mod1
	
	.. literalinclude:: demonstrations/tw-before1.yaml
		:class: .mlbyaml
		:caption: ``tw-before1.yaml`` 
		:name: lst:tw-before1
	
	We note that, in :numref:`lst:textwrap8-mod1`, that the wrapped text has *exceeded* the specified value of ``columns`` (35) given in :numref:`lst:tw-before1`. We can affect this by changing ``when``; we explore this next.


.. proof:example::	
	
	We continue working with :numref:`lst:textwrap8`.
	
	Using the settings given in :numref:`lst:tw-after1` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl textwrap8.tex -o=+-mod2.tex -l=tw-after1.yaml -m
	
	gives the output given in :numref:`lst:textwrap8-mod2`.
	
	.. literalinclude:: demonstrations/textwrap8-mod2.tex
		:class: .tex
		:caption: ``textwrap8-mod2.tex`` 
		:name: lst:textwrap8-mod2
	
	.. literalinclude:: demonstrations/tw-after1.yaml
		:class: .mlbyaml
		:caption: ``tw-after1.yaml`` 
		:name: lst:tw-after1
	
	We note that, in :numref:`lst:textwrap8-mod2`, that the wrapped text has *obeyed* the specified value of ``columns`` (35) given in :numref:`lst:tw-after1`.


.. label follows

.. _subsubsec:tw:comments:

Text wrap: wrapping comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can instruct ``latexindent.pl`` to apply text wrapping to comments ; we demonstrate this with examples, see also :numref:`subsubsec:ospl:tw:comments`.

.. index:: comments;text wrap

.. index:: text wrap;comments

.. proof:example::	
	
	We use the file in :numref:`lst:textwrap9` which contains a trailing comment block.
	
	.. literalinclude:: demonstrations/textwrap9.tex
		:class: .tex
		:caption: ``textwrap9.tex`` 
		:name: lst:textwrap9
	
	Using the settings given in :numref:`lst:wrap-comments1` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl textwrap9.tex -o=+-mod1.tex -l=wrap-comments1.yaml -m
	
	gives the output given in :numref:`lst:textwrap9-mod1`.
	
	.. literalinclude:: demonstrations/textwrap9-mod1.tex
		:class: .tex
		:caption: ``textwrap9-mod1.tex`` 
		:name: lst:textwrap9-mod1
	
	.. literalinclude:: demonstrations/wrap-comments1.yaml
		:class: .mlbyaml
		:caption: ``wrap-comments1.yaml`` 
		:name: lst:wrap-comments1
	
	We note that, in :numref:`lst:textwrap9-mod1`, that the comments have been *combined and wrapped* because of the annotated line specified in :numref:`lst:wrap-comments1`.


.. proof:example::	
	
	We use the file in :numref:`lst:textwrap10` which contains a trailing comment block.
	
	.. literalinclude:: demonstrations/textwrap10.tex
		:class: .tex
		:caption: ``textwrap10.tex`` 
		:name: lst:textwrap10
	
	Using the settings given in :numref:`lst:wrap-comments1:repeat` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl textwrap10.tex -o=+-mod1.tex -l=wrap-comments1.yaml -m
	
	gives the output given in :numref:`lst:textwrap10-mod1`.
	
	.. literalinclude:: demonstrations/textwrap10-mod1.tex
		:class: .tex
		:caption: ``textwrap10-mod1.tex`` 
		:name: lst:textwrap10-mod1
	
	.. literalinclude:: demonstrations/wrap-comments1.yaml
		:class: .mlbyaml
		:caption: ``wrap-comments1.yaml`` 
		:name: lst:wrap-comments1:repeat
	
	We note that, in :numref:`lst:textwrap10-mod1`, that the comments have been *combined and wrapped* because of the annotated line specified in :numref:`lst:wrap-comments1:repeat`, and that the space from the leading comment has not been inherited; we will explore this further in the next example.


.. proof:example::	
	
	We continue to use the file in :numref:`lst:textwrap10`.
	
	Using the settings given in :numref:`lst:wrap-comments2` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl textwrap10.tex -o=+-mod2.tex -l=wrap-comments2.yaml -m
	
	gives the output given in :numref:`lst:textwrap10-mod2`.
	
	.. literalinclude:: demonstrations/textwrap10-mod2.tex
		:class: .tex
		:caption: ``textwrap10-mod2.tex`` 
		:name: lst:textwrap10-mod2
	
	.. literalinclude:: demonstrations/wrap-comments2.yaml
		:class: .mlbyaml
		:caption: ``wrap-comments2.yaml`` 
		:name: lst:wrap-comments2
	
	We note that, in :numref:`lst:textwrap10-mod2`, that the comments have been *combined and wrapped* and that the leading space has been inherited because of the annotated lines specified in :numref:`lst:wrap-comments2`.


Text wrap: huge, tabstop and separator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The default value of ``huge`` is ``overflow``, which means that words will *not* be broken by the text wrapping routine, implemented by the ``Text::Wrap`` (“Text::Wrap Perl Module” n.d.). There are options to change the ``huge`` option for the ``Text::Wrap`` module to either ``wrap`` or ``die``. Before modifying the value of ``huge``, please bear in mind the following warning:

.. index:: warning;changing huge (textwrap)

.. warning::	
	
	Changing the value of ``huge`` to anything other than ``overflow`` will slow down ``latexindent.pl`` significantly when the ``-m`` switch is active.
	
	Furthermore, changing ``huge`` means that you may have some words *or commands*\ (!) split across lines in your .tex file, which may affect your output. I do not recommend changing this field.


.. proof:example::	
	
	For example, using the settings in :numref:`lst:textwrap2A-yaml` and :numref:`lst:textwrap2B-yaml` and running the commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. index:: switches;-o demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	        latexindent.pl -m textwrap4.tex -o=+-mod2A -l textwrap2A.yaml
	        latexindent.pl -m textwrap4.tex -o=+-mod2B -l textwrap2B.yaml
	
	gives the respective output in :numref:`lst:textwrap4-mod2A` and :numref:`lst:textwrap4-mod2B`.
	
	.. literalinclude:: demonstrations/textwrap4-mod2A.tex
		:class: .tex
		:caption: ``textwrap4-mod2A.tex`` 
		:name: lst:textwrap4-mod2A
	
	.. literalinclude:: demonstrations/textwrap2A.yaml
		:class: .mlbyaml
		:caption: ``textwrap2A.yaml`` 
		:name: lst:textwrap2A-yaml
	
	.. literalinclude:: demonstrations/textwrap4-mod2B.tex
		:class: .tex
		:caption: ``textwrap4-mod2B.tex`` 
		:name: lst:textwrap4-mod2B
	
	.. literalinclude:: demonstrations/textwrap2B.yaml
		:class: .mlbyaml
		:caption: ``textwrap2B.yaml`` 
		:name: lst:textwrap2B-yaml
	


You can also specify the ``tabstop`` field as an integer value, which is passed to the text wrap module; see (“Text::Wrap Perl Module” n.d.) for details.

.. proof:example::	
	
	Starting with the code in :numref:`lst:textwrap-ts` with settings in :numref:`lst:tabstop`, and running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. index:: switches;-o demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	        latexindent.pl -m textwrap-ts.tex -o=+-mod1 -l tabstop.yaml
	
	gives the code given in :numref:`lst:textwrap-ts-mod1`.
	
	.. literalinclude:: demonstrations/textwrap-ts.tex
		:class: .tex
		:caption: ``textwrap-ts.tex`` 
		:name: lst:textwrap-ts
	
	.. literalinclude:: demonstrations/tabstop.yaml
		:class: .mlbyaml
		:caption: ``tabstop.yaml`` 
		:name: lst:tabstop
	
	.. literalinclude:: demonstrations/textwrap-ts-mod1.tex
		:class: .tex
		:caption: ``textwrap-ts-mod1.tex`` 
		:name: lst:textwrap-ts-mod1
	


You can specify ``separator``, ``break`` and ``unexpand`` options in your settings in analogous ways to those demonstrated in :numref:`lst:textwrap2B-yaml` and :numref:`lst:tabstop`, and they will be passed to the ``Text::Wrap`` module. I have not found a useful reason to do this; see (“Text::Wrap Perl Module” n.d.) for more details.

.. label follows

.. _sec:onesentenceperline:

oneSentencePerLine: modifying line breaks for sentences
-------------------------------------------------------

You can instruct ``latexindent.pl`` to format your file so that it puts one sentence per line. Thank you to (mlep 2017) for helping to shape and test this feature. The behaviour of this part of the script is controlled by the switches detailed in :numref:`lst:oneSentencePerLine`, all of which we discuss next.

.. index:: modifying linebreaks; by using one sentence per line

.. index:: sentences;oneSentencePerLine

.. index:: sentences;one sentence per line

.. index:: regular expressions;lowercase alph a-z

.. index:: regular expressions;uppercase alph A-Z

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``oneSentencePerLine`` 
	:name: lst:oneSentencePerLine
	:lines: 503-529
	:linenos:
	:lineno-start: 503

oneSentencePerLine: overview
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

An overview of how the oneSentencePerLine routine feature works:

#. the default value of ``manipulateSentences`` is 0, which means that oneSentencePerLine will *not* happen by default;

#. it happens *after* verbatim blocks have been found;

#. it happens *before* the text wrapping routine (see :numref:`subsec:textwrapping`);

#. it happens *before* the main code blocks have been found;

#. sentences to be found:

   #. *follow* the fields specified in ``sentencesFollow``

   #. *begin* with the fields specified in ``sentencesBeginWith``

   #. *end* with the fields specified in ``sentencesEndWith``

#. by default, the oneSentencePerLine routine will remove line breaks within sentences because ``removeBlockLineBreaks`` is set to 1; switch it to 0 if you wish to change this;

#. sentences can be text wrapped according to ``textWrapSentences``, and will be done either ``before`` or ``after`` the main indentation routine (see :numref:`subsubsec:ospl:before:after`);

#. about trailing comments within text wrap blocks:

   #. multiple trailing comments will be connected at the end of the sentence;

   #. the number of spaces between the end of the sentence and the (possibly combined) trailing comments is determined by the spaces (if any) at the end of the sentence.

We demonstrate this feature using a series of examples. .. describe:: manipulateSentences:0|1

This is a binary switch that details if ``latexindent.pl`` should perform the sentence manipulation routine; it is *off* (set to ``0``) by default, and you will need to turn it on (by setting it to ``1``) if you want the script to modify line breaks surrounding and within sentences.

.. describe:: removeSentenceLineBreaks:0|1

When operating upon sentences ``latexindent.pl`` will, by default, remove internal line breaks as ``removeSentenceLineBreaks`` is set to ``1``. Setting this switch to ``0`` instructs ``latexindent.pl`` not to do so.

.. index:: sentences;removing sentence line breaks

.. proof:example::	
	
	For example, consider ``multiple-sentences.tex`` shown in :numref:`lst:multiple-sentences`.
	
	.. literalinclude:: demonstrations/multiple-sentences.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` 
		:name: lst:multiple-sentences
	
	If we use the YAML files in :numref:`lst:manipulate-sentences-yaml` and :numref:`lst:keep-sen-line-breaks-yaml`, and run the commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences -m -l=manipulate-sentences.yaml
	   latexindent.pl multiple-sentences -m -l=keep-sen-line-breaks.yaml
	
	then we obtain the respective output given in :numref:`lst:multiple-sentences-mod1` and :numref:`lst:multiple-sentences-mod2`.
	
	.. literalinclude:: demonstrations/multiple-sentences-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` using :numref:`lst:manipulate-sentences-yaml` 
		:name: lst:multiple-sentences-mod1
	
	.. literalinclude:: demonstrations/manipulate-sentences.yaml
		:class: .mlbyaml
		:caption: ``manipulate-sentences.yaml`` 
		:name: lst:manipulate-sentences-yaml
	
	.. literalinclude:: demonstrations/multiple-sentences-mod2.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` using :numref:`lst:keep-sen-line-breaks-yaml` 
		:name: lst:multiple-sentences-mod2
	
	.. literalinclude:: demonstrations/keep-sen-line-breaks.yaml
		:class: .mlbyaml
		:caption: ``keep-sen-line-breaks.yaml`` 
		:name: lst:keep-sen-line-breaks-yaml
	
	Notice, in particular, that the ‘internal’ sentence line breaks in :numref:`lst:multiple-sentences` have been removed in :numref:`lst:multiple-sentences-mod1`, but have not been removed in :numref:`lst:multiple-sentences-mod2`.


.. describe:: multipleSpacesToSingle:0|1

By default, the one-sentence-per-line routine will convert multiple spaces into single spaces. You can change this behaviour by changing the switch ``multipleSpacesToSingle`` to a value of ``0``.

The remainder of the settings displayed in :numref:`lst:oneSentencePerLine` instruct ``latexindent.pl`` on how to define a sentence. From the perspective of ``latexindent.pl`` a sentence must:

.. index:: sentences;follow

.. index:: sentences;begin with

.. index:: sentences;end with

-  *follow* a certain character or set of characters (see :numref:`lst:sentencesFollow`); by default, this is either ``\par``, a blank line, a full stop/period (.), exclamation mark (!), question mark (?) right brace (}) or a comment on the previous line;

-  *begin* with a character type (see :numref:`lst:sentencesBeginWith`); by default, this is only capital letters;

-  *end* with a character (see :numref:`lst:sentencesEndWith`); by default, these are full stop/period (.), exclamation mark (!) and question mark (?).

In each case, you can specify the ``other`` field to include any pattern that you would like; you can specify anything in this field using the language of regular expressions.

.. index:: regular expressions;lowercase alph a-z

.. index:: regular expressions;uppercase alph A-Z

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``sentencesFollow`` 
	:name: lst:sentencesFollow
	:lines: 509-517
	:linenos:
	:lineno-start: 509

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``sentencesBeginWith`` 
	:name: lst:sentencesBeginWith
	:lines: 518-521
	:linenos:
	:lineno-start: 518

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``sentencesEndWith`` 
	:name: lst:sentencesEndWith
	:lines: 522-527
	:linenos:
	:lineno-start: 522

oneSentencePerLine: sentencesFollow
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let’s explore a few of the switches in ``sentencesFollow``.

.. proof:example::	
	
	We start with :numref:`lst:multiple-sentences`, and use the YAML settings given in :numref:`lst:sentences-follow1-yaml`. Using the command
	
	.. index:: sentences;follow
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences -m -l=sentences-follow1.yaml
	
	we obtain the output given in :numref:`lst:multiple-sentences-mod3`.
	
	.. literalinclude:: demonstrations/multiple-sentences-mod3.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-follow1-yaml` 
		:name: lst:multiple-sentences-mod3
	
	.. literalinclude:: demonstrations/sentences-follow1.yaml
		:class: .mlbyaml
		:caption: ``sentences-follow1.yaml`` 
		:name: lst:sentences-follow1-yaml
	
	Notice that, because ``blankLine`` is set to ``0``, ``latexindent.pl`` will not seek sentences following a blank line, and so the fourth sentence has not been accounted for.


.. proof:example::	
	
	We can explore the ``other`` field in :numref:`lst:sentencesFollow` with the ``.tex`` file detailed in :numref:`lst:multiple-sentences1`.
	
	.. literalinclude:: demonstrations/multiple-sentences1.tex
		:class: .tex
		:caption: ``multiple-sentences1.tex`` 
		:name: lst:multiple-sentences1
	
	Upon running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences1 -m -l=manipulate-sentences.yaml
	   latexindent.pl multiple-sentences1 -m -l=manipulate-sentences.yaml,sentences-follow2.yaml
	
	then we obtain the respective output given in :numref:`lst:multiple-sentences1-mod1` and :numref:`lst:multiple-sentences1-mod2`.
	
	.. literalinclude:: demonstrations/multiple-sentences1-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences1.tex`` using :numref:`lst:manipulate-sentences-yaml` 
		:name: lst:multiple-sentences1-mod1
	
	.. literalinclude:: demonstrations/multiple-sentences1-mod2.tex
		:class: .tex
		:caption: ``multiple-sentences1.tex`` using :numref:`lst:sentences-follow2-yaml` 
		:name: lst:multiple-sentences1-mod2
	
	.. literalinclude:: demonstrations/sentences-follow2.yaml
		:class: .mlbyaml
		:caption: ``sentences-follow2.yaml`` 
		:name: lst:sentences-follow2-yaml
	
	Notice that in :numref:`lst:multiple-sentences1-mod1` the first sentence after the ``)`` has not been accounted for, but that following the inclusion of :numref:`lst:sentences-follow2-yaml`, the output given in :numref:`lst:multiple-sentences1-mod2` demonstrates that the sentence *has* been accounted for correctly.


oneSentencePerLine: sentencesBeginWith
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, ``latexindent.pl`` will only assume that sentences begin with the upper case letters ``A-Z``; you can instruct the script to define sentences to begin with lower case letters (see :numref:`lst:sentencesBeginWith`), and we can use the ``other`` field to define sentences to begin with other characters.

.. index:: sentences;begin with

.. proof:example::	
	
	We use the file in :numref:`lst:multiple-sentences2`.
	
	.. literalinclude:: demonstrations/multiple-sentences2.tex
		:class: .tex
		:caption: ``multiple-sentences2.tex`` 
		:name: lst:multiple-sentences2
	
	Upon running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences2 -m -l=manipulate-sentences.yaml
	   latexindent.pl multiple-sentences2 -m -l=manipulate-sentences.yaml,sentences-begin1.yaml
	
	then we obtain the respective output given in :numref:`lst:multiple-sentences2-mod1` and :numref:`lst:multiple-sentences2-mod2`.
	
	.. literalinclude:: demonstrations/multiple-sentences2-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences2.tex`` using :numref:`lst:manipulate-sentences-yaml` 
		:name: lst:multiple-sentences2-mod1
	
	.. index:: regular expressions;numeric 0-9
	
	.. literalinclude:: demonstrations/multiple-sentences2-mod2.tex
		:class: .tex
		:caption: ``multiple-sentences2.tex`` using :numref:`lst:sentences-begin1-yaml` 
		:name: lst:multiple-sentences2-mod2
	
	.. literalinclude:: demonstrations/sentences-begin1.yaml
		:class: .mlbyaml
		:caption: ``sentences-begin1.yaml`` 
		:name: lst:sentences-begin1-yaml
	
	Notice that in :numref:`lst:multiple-sentences2-mod1`, the first sentence has been accounted for but that the subsequent sentences have not. In :numref:`lst:multiple-sentences2-mod2`, all of the sentences have been accounted for, because the ``other`` field in :numref:`lst:sentences-begin1-yaml` has defined sentences to begin with either ``$`` or any numeric digit, ``0`` to ``9``.


oneSentencePerLine: sentencesEndWith
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. proof:example::	
	
	Let’s return to :numref:`lst:multiple-sentences`; we have already seen the default way in which ``latexindent.pl`` will operate on the sentences in this file in :numref:`lst:multiple-sentences-mod1`. We can populate the ``other`` field with any character that we wish; for example, using the YAML specified in :numref:`lst:sentences-end1-yaml` and the command
	
	.. index:: sentences;end with
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences -m -l=sentences-end1.yaml
	   latexindent.pl multiple-sentences -m -l=sentences-end2.yaml
	
	then we obtain the output in :numref:`lst:multiple-sentences-mod4`.
	
	.. index:: regular expressions;lowercase alph a-z
	
	.. literalinclude:: demonstrations/multiple-sentences-mod4.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-end1-yaml` 
		:name: lst:multiple-sentences-mod4
	
	.. literalinclude:: demonstrations/sentences-end1.yaml
		:class: .mlbyaml
		:caption: ``sentences-end1.yaml`` 
		:name: lst:sentences-end1-yaml
	
	.. literalinclude:: demonstrations/multiple-sentences-mod5.tex
		:class: .tex
		:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-end2-yaml` 
		:name: lst:multiple-sentences-mod5
	
	.. literalinclude:: demonstrations/sentences-end2.yaml
		:class: .mlbyaml
		:caption: ``sentences-end2.yaml`` 
		:name: lst:sentences-end2-yaml
	
	There is a subtle difference between the output in :numref:`lst:multiple-sentences-mod4` and :numref:`lst:multiple-sentences-mod5`; in particular, in :numref:`lst:multiple-sentences-mod4` the word ``sentence`` has not been defined as a sentence, because we have not instructed ``latexindent.pl`` to begin sentences with lower case letters. We have changed this by using the settings in :numref:`lst:sentences-end2-yaml`, and the associated output in :numref:`lst:multiple-sentences-mod5`
	reflects this.


Referencing :numref:`lst:sentencesEndWith`, you’ll notice that there is a field called ``basicFullStop``, which is set to ``0``, and that the ``betterFullStop`` is set to ``1`` by default.

.. proof:example::	
	
	Let’s consider the file shown in :numref:`lst:url`.
	
	.. literalinclude:: demonstrations/url.tex
		:class: .tex
		:caption: ``url.tex`` 
		:name: lst:url
	
	Upon running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl url -m -l=manipulate-sentences.yaml
	
	we obtain the output given in :numref:`lst:url-mod1`.
	
	.. literalinclude:: demonstrations/url-mod1.tex
		:class: .tex
		:caption: ``url.tex`` using :numref:`lst:manipulate-sentences-yaml` 
		:name: lst:url-mod1
	
	Notice that the full stop within the url has been interpreted correctly. This is because, within the ``betterFullStop``, full stops at the end of sentences have the following properties:
	
	-  they are ignored within ``e.g.`` and ``i.e.``;
	
	-  they can not be immediately followed by a lower case or upper case letter;
	
	-  they can not be immediately followed by a hyphen, comma, or number.
	


If you find that the ``betterFullStop`` does not work for your purposes, then you can switch it off by setting it to ``0``, and you can experiment with the ``other`` field. You can also seek to customise the ``betterFullStop`` routine by using the *fine tuning*, detailed in :numref:`lst:fineTuning`.

The ``basicFullStop`` routine should probably be avoided in most situations, as it does not accommodate the specifications above.

.. proof:example::	
	
	For example, using the following command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl url -m -l=alt-full-stop1.yaml
	
	and the YAML in :numref:`lst:alt-full-stop1-yaml` gives the output in :numref:`lst:url-mod2`.
	
	.. literalinclude:: demonstrations/url-mod2.tex
		:class: .tex
		:caption: ``url.tex`` using :numref:`lst:alt-full-stop1-yaml` 
		:name: lst:url-mod2
	
	.. literalinclude:: demonstrations/alt-full-stop1.yaml
		:class: .mlbyaml
		:caption: ``alt-full-stop1.yaml`` 
		:name: lst:alt-full-stop1-yaml
	
	Notice that the full stop within the URL has not been accommodated correctly because of the non-default settings in :numref:`lst:alt-full-stop1-yaml`.


oneSentencePerLine: sentencesDoNOTcontain
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can specify patterns that sentences do *not* contain using the field in :numref:`lst:sentencesDoNOTcontain`.

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``sentencesDoNOTcontain`` 
	:name: lst:sentencesDoNOTcontain
	:lines: 528-530
	:linenos:
	:lineno-start: 528

If sentences run across environments then, by default, they will *not* be considered a sentence by ``latexindent.pl``.

.. proof:example::	
	
	For example, if we use the ``.tex`` file in :numref:`lst:multiple-sentences4`
	
	.. literalinclude:: demonstrations/multiple-sentences4.tex
		:class: .tex
		:caption: ``multiple-sentences4.tex`` 
		:name: lst:multiple-sentences4
	
	and run the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences4 -m -l=manipulate-sentences.yaml
	
	then the output is unchanged, because the default value of ``sentencesDoNOTcontain`` says, *sentences do NOT contain*
	
	This means that, by default, ``latexindent.pl`` does *not* consider the file in :numref:`lst:multiple-sentences4` to have a sentence. ``\\begin``


.. proof:example::	
	
	We can customise the ``sentencesDoNOTcontain`` field with anything that we do *not* want sentences to contain.
	
	We begin with the file in :numref:`lst:sentence-dnc1`.
	
	.. literalinclude:: demonstrations/sentence-dnc1.tex
		:class: .tex
		:caption: ``sentence-dnc1.tex`` 
		:name: lst:sentence-dnc1
	
	Upon running the following commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl sentence-dnc1.tex -m -l=dnc1.yaml
	
	then we obtain the output given in :numref:`lst:sentence-dnc1-mod1`.
	
	.. literalinclude:: demonstrations/sentence-dnc1-mod1.tex
		:class: .tex
		:caption: ``sentence-dnc1-mod1.tex`` 
		:name: lst:sentence-dnc1-mod1
	
	.. literalinclude:: demonstrations/dnc1.yaml
		:class: .mlbyaml
		:caption: ``dnc1.yaml`` 
		:name: lst:dnc1-yaml
	
	The settings in :numref:`lst:dnc1-yaml` say that sentences do *not* contain ``\begin`` and that they do not contain ``\cmh``


.. proof:example::	
	
	We can implement case insensitivity for the ``sentencesDoNOTcontain`` field.
	
	We begin with the file in :numref:`lst:sentence-dnc2`.
	
	.. literalinclude:: demonstrations/sentence-dnc2.tex
		:class: .tex
		:caption: ``sentence-dnc2.tex`` 
		:name: lst:sentence-dnc2
	
	Upon running the following commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl sentence-dnc2.tex -m -l=dnc2.yaml
	
	then we obtain the output given in :numref:`lst:sentence-dnc2-mod2`.
	
	.. literalinclude:: demonstrations/sentence-dnc2-mod2.tex
		:class: .tex
		:caption: ``sentence-dnc2-mod2.tex`` 
		:name: lst:sentence-dnc2-mod2
	
	.. literalinclude:: demonstrations/dnc2.yaml
		:class: .mlbyaml
		:caption: ``dnc2.yaml`` 
		:name: lst:dnc2-yaml
	
	The settings in :numref:`lst:dnc2-yaml` say that sentences do *not* contain ``\begin`` and that they do not contain *case insensitive* versions of ``\cmh``


.. proof:example::	
	
	We can turn off ``sentenceDoNOTcontain`` by setting it to ``0`` as in :numref:`lst:dnc-off-yaml`.
	
	.. literalinclude:: demonstrations/dnc-off.yaml
		:class: .mlbyaml
		:caption: ``dnc-off.yaml`` 
		:name: lst:dnc-off-yaml
	
	The settings in :numref:`lst:dnc-off-yaml` mean that sentences can contain any character.


Features of the oneSentencePerLine routine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The sentence manipulation routine takes place *after* verbatim

.. index:: verbatim;in relation to oneSentencePerLine

environments, preamble and trailing comments have been accounted for; this means that any characters within these types of code blocks will not be part of the sentence manipulation routine.

.. proof:example::	
	
	For example, if we begin with the ``.tex`` file in :numref:`lst:multiple-sentences3`, and run the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences3 -m -l=manipulate-sentences.yaml
	
	then we obtain the output in :numref:`lst:multiple-sentences3-mod1`.
	
	.. literalinclude:: demonstrations/multiple-sentences3.tex
		:class: .tex
		:caption: ``multiple-sentences3.tex`` 
		:name: lst:multiple-sentences3
	
	.. literalinclude:: demonstrations/multiple-sentences3-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences3.tex`` using :numref:`lst:manipulate-sentences-yaml` 
		:name: lst:multiple-sentences3-mod1
	


oneSentencePerLine: text wrapping and indenting sentences
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``oneSentencePerLine`` can be instructed to perform text wrapping and indentation upon sentences.

.. index:: sentences;text wrapping

.. index:: sentences;indenting

.. proof:example::	
	
	Let’s use the code in :numref:`lst:multiple-sentences5`.
	
	.. literalinclude:: demonstrations/multiple-sentences5.tex
		:class: .tex
		:caption: ``multiple-sentences5.tex`` 
		:name: lst:multiple-sentences5
	
	Referencing :numref:`lst:sentence-wrap1-yaml`, and running the following command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences5 -m -l=sentence-wrap1.yaml
	
	we receive the output given in :numref:`lst:multiple-sentences5-mod1`.
	
	.. literalinclude:: demonstrations/multiple-sentences5-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences5.tex`` using :numref:`lst:sentence-wrap1-yaml` 
		:name: lst:multiple-sentences5-mod1
	
	.. literalinclude:: demonstrations/sentence-wrap1.yaml
		:class: .mlbyaml
		:caption: ``sentence-wrap1.yaml`` 
		:name: lst:sentence-wrap1-yaml
	


If you specify ``textWrapSentences`` as 1, but do *not* specify a value for ``columns`` then the text wrapping will *not* operate on sentences, and you will see a warning in ``indent.log``.

.. proof:example::	
	
	The indentation of sentences requires that sentences are stored as code blocks. This means that you may need to tweak :numref:`lst:sentencesEndWith`. Let’s explore this in relation to :numref:`lst:multiple-sentences6`.
	
	.. literalinclude:: demonstrations/multiple-sentences6.tex
		:class: .tex
		:caption: ``multiple-sentences6.tex`` 
		:name: lst:multiple-sentences6
	
	By default, ``latexindent.pl`` will find the full-stop within the first ``item``, which means that, upon running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. index:: switches;-y demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences6 -m -l=sentence-wrap1.yaml 
	   latexindent.pl multiple-sentences6 -m -l=sentence-wrap1.yaml -y="modifyLineBreaks:oneSentencePerLine:sentenceIndent:''"
	
	we receive the respective output in :numref:`lst:multiple-sentences6-mod1` and :numref:`lst:multiple-sentences6-mod2`.
	
	.. literalinclude:: demonstrations/multiple-sentences6-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences6-mod1.tex`` using :numref:`lst:sentence-wrap1-yaml` 
		:name: lst:multiple-sentences6-mod1
	
	.. literalinclude:: demonstrations/multiple-sentences6-mod2.tex
		:class: .tex
		:caption: ``multiple-sentences6-mod2.tex`` using :numref:`lst:sentence-wrap1-yaml` and no sentence indentation 
		:name: lst:multiple-sentences6-mod2
	
	We note that :numref:`lst:multiple-sentences6-mod1` the ``itemize`` code block has *not* been indented appropriately. This is because the oneSentencePerLine has been instructed to store sentences (because :numref:`lst:sentence-wrap1-yaml`); each sentence is then searched for code blocks.


.. proof:example::	
	
	We can tweak the settings in :numref:`lst:sentencesEndWith` to ensure that full stops are not followed by ``item`` commands, and that the end of sentences contains ``\end{itemize}`` as in :numref:`lst:itemize-yaml`. This setting is actually an appended version of the ``betterFullStop`` from the ``fineTuning``, detailed in :numref:`lst:fineTuning`.
	
	.. index:: regular expressions;lowercase alph a-z
	
	.. index:: regular expressions;uppercase alph A-Z
	
	.. index:: regular expressions;numeric 0-9
	
	.. literalinclude:: demonstrations/itemize.yaml
		:class: .mlbyaml
		:caption: ``itemize.yaml`` 
		:name: lst:itemize-yaml
	
	Upon running
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences6 -m -l=sentence-wrap1.yaml,itemize.yaml
	
	we receive the output in :numref:`lst:multiple-sentences6-mod3`.
	
	.. literalinclude:: demonstrations/multiple-sentences6-mod3.tex
		:class: .tex
		:caption: ``multiple-sentences6-mod3.tex`` using :numref:`lst:sentence-wrap1-yaml` and :numref:`lst:itemize-yaml` 
		:name: lst:multiple-sentences6-mod3
	
	Notice that the sentence has received indentation, and that the ``itemize`` code block has been found and indented correctly.


Text wrapping when using the ``oneSentencePerLine`` routine determines if it will remove line breaks while text wrapping, from the value of ``removeSentenceLineBreaks``.

.. label follows

.. _subsubsec:ospl:before:after:

oneSentencePerLine: text wrapping and indenting sentences, when before/after
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The text wrapping routine operates, by default, ``before`` the code blocks have been found, but this can be changed to ``after``:

-  ``before`` means it is likely that the columns of wrapped text may *exceed* the value specified in ``columns``;

-  ``after`` means it columns of wrapped text should *not* exceed the value specified in ``columns``.

We demonstrate this in the following examples. See also :numref:`subsubsec:tw:before:after`.

.. proof:example::	
	
	Let’s begin with the file in :numref:`lst:multiple-sentences8`.
	
	.. literalinclude:: demonstrations/multiple-sentences8.tex
		:class: .tex
		:caption: ``multiple-sentences8.tex`` 
		:name: lst:multiple-sentences8
	
	Using the settings given in :numref:`lst:sentence-wrap2` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences8 -o=+-mod1.tex -l=sentence-wrap2 -m
	
	gives the output given in :numref:`lst:multiple-sentences8-mod1`.
	
	.. literalinclude:: demonstrations/multiple-sentences8-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences8-mod1.tex`` 
		:name: lst:multiple-sentences8-mod1
	
	.. literalinclude:: demonstrations/sentence-wrap2.yaml
		:class: .mlbyaml
		:caption: ``sentence-wrap2.yaml`` 
		:name: lst:sentence-wrap2
	
	We note that, in :numref:`lst:multiple-sentences8-mod1`, that the wrapped text has *exceeded* the specified value of ``columns`` (35) given in :numref:`lst:sentence-wrap2`. We can affect this by changing ``when``; we explore this next.


.. proof:example::	
	
	We continue working with :numref:`lst:multiple-sentences8`.
	
	Using the settings given in :numref:`lst:sentence-wrap3` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences8.tex -o=+-mod2.tex -l=sentence-wrap3 -m
	
	gives the output given in :numref:`lst:multiple-sentences8-mod2`.
	
	.. literalinclude:: demonstrations/multiple-sentences8-mod2.tex
		:class: .tex
		:caption: ``multiple-sentences8-mod2.tex`` 
		:name: lst:multiple-sentences8-mod2
	
	.. literalinclude:: demonstrations/sentence-wrap3.yaml
		:class: .mlbyaml
		:caption: ``sentence-wrap3.yaml`` 
		:name: lst:sentence-wrap3
	
	We note that, in :numref:`lst:multiple-sentences8-mod2`, that the wrapped text has *obeyed* the specified value of ``columns`` (35) given in :numref:`lst:sentence-wrap3`.


.. label follows

.. _subsubsec:ospl:tw:comments:

oneSentencePerLine: text wrapping sentences and comments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We demonstrate the one sentence per line routine with respect to text wrapping *comments*. See also :numref:`subsubsec:tw:comments`.

.. index:: comments;text wrap

.. index:: text wrap;comments

.. index:: sentences;comments

.. index:: sentences;text wrap

.. proof:example::	
	
	Let’s begin with the file in :numref:`lst:multiple-sentences9`.
	
	.. literalinclude:: demonstrations/multiple-sentences9.tex
		:class: .tex
		:caption: ``multiple-sentences9.tex`` 
		:name: lst:multiple-sentences9
	
	Using the settings given in :numref:`lst:sentence-wrap4` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl multiple-sentences9 -o=+-mod1.tex -l=sentence-wrap4 -m
	
	gives the output given in :numref:`lst:multiple-sentences9-mod1`.
	
	.. literalinclude:: demonstrations/multiple-sentences9-mod1.tex
		:class: .tex
		:caption: ``multiple-sentences9-mod1.tex`` 
		:name: lst:multiple-sentences9-mod1
	
	.. literalinclude:: demonstrations/sentence-wrap4.yaml
		:class: .mlbyaml
		:caption: ``sentence-wrap4.yaml`` 
		:name: lst:sentence-wrap4
	
	We note that, in :numref:`lst:multiple-sentences9-mod1`, that the sentences have been wrapped, and so too have the comments because of the annotated line in :numref:`lst:sentence-wrap4`.


.. label follows

.. _sec:poly-switches:

Poly-switches
-------------

Every other field in the ``modifyLineBreaks`` field uses poly-switches, and can take one of the following integer values:

.. index:: modifying linebreaks; using poly-switches

.. index:: poly-switches;definition

.. index:: poly-switches;values

.. index:: poly-switches;off by default: set to 0

:math:`-1`
   *remove mode*: line breaks before or after the *<part of thing>* can be removed (assuming that ``preserveBlankLines`` is set to ``0``);

0
   *off mode*: line breaks will not be modified for the *<part of thing>* under consideration;

1
   *add mode*: a line break will be added before or after the *<part of thing>* under consideration, assuming that there is not already a line break before or after the *<part of thing>*;

2
   *comment then add mode*: a comment symbol will be added, followed by a line break before or after the *<part of thing>* under consideration, assuming that there is not already a comment and line break before or after the *<part of thing>*;

3
   *add then blank line mode* : a line break will be added before or after the *<part of thing>* under consideration, assuming that there is not already a line break before or after the *<part of thing>*, followed by a blank line;

4
   *add blank line mode* ; a blank line will be added before or after the *<part of thing>* under consideration, even if the *<part of thing>* is already on its own line.

In the above, *<part of thing>* refers to either the *begin statement*, *body* or *end statement* of the code blocks detailed in :numref:`tab:code-blocks`. All poly-switches are *off* by default; ``latexindent.pl`` searches first of all for per-name settings, and then followed by global per-thing settings.

.. label follows

.. _sec:modifylinebreaks-environments:

Poly-switches for environments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We start by viewing a snippet of ``defaultSettings.yaml`` in :numref:`lst:environments-mlb`; note that it contains *global* settings (immediately after the ``environments`` field) and that *per-name* settings are also allowed – in the case of :numref:`lst:environments-mlb`, settings for ``equation*`` have been specified for demonstration. Note that all poly-switches are *off* (set to 0) by default.

.. index:: poly-switches;default values

.. index:: poly-switches;environment global example

.. index:: poly-switches;environment per-code block example

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``environments`` 
	:name: lst:environments-mlb
	:lines: 559-568
	:linenos:
	:lineno-start: 559

Let’s begin with the simple example given in :numref:`lst:env-mlb1-tex`; note that we have annotated key parts of the file using ♠, ♥, ◆ and ♣, these will be related to fields specified in :numref:`lst:environments-mlb`.

.. index:: poly-switches;visualisation: ♠, ♥, ◆, ♣

.. code-block:: latex
   :caption: ``env-mlb1.tex`` 
   :name: lst:env-mlb1-tex

   before words♠ \begin{myenv}♥body of myenv◆\end{myenv}♣ after words

Adding line breaks: BeginStartsOnOwnLine and BodyStartsOnOwnLine
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	Let’s explore ``BeginStartsOnOwnLine`` and ``BodyStartsOnOwnLine`` in :numref:`lst:env-mlb1` and :numref:`lst:env-mlb2`, and in particular, let’s allow each of them in turn to take a value of :math:`1`.
	
	.. index:: poly-switches;adding line breaks: set to 1
	
	.. literalinclude:: demonstrations/env-mlb1.yaml
		:class: .mlbyaml
		:caption: ``env-mlb1.yaml`` 
		:name: lst:env-mlb1
	
	.. literalinclude:: demonstrations/env-mlb2.yaml
		:class: .mlbyaml
		:caption: ``env-mlb2.yaml`` 
		:name: lst:env-mlb2
	
	After running the following commands,
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb1.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb2.yaml
	
	the output is as in :numref:`lst:env-mlb-mod1` and :numref:`lst:env-mlb-mod2` respectively.
	
	.. literalinclude:: demonstrations/env-mlb-mod1.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb1` 
		:name: lst:env-mlb-mod1
	
	.. literalinclude:: demonstrations/env-mlb-mod2.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb2` 
		:name: lst:env-mlb-mod2
	
	There are a couple of points to note:
	
	-  in :numref:`lst:env-mlb-mod1` a line break has been added at the point denoted by ♠ in :numref:`lst:env-mlb1-tex`; no other line breaks have been changed;
	
	-  in :numref:`lst:env-mlb-mod2` a line break has been added at the point denoted by ♥ in :numref:`lst:env-mlb1-tex`; furthermore, note that the *body* of ``myenv`` has received the appropriate (default) indentation.
	


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb1` and :numref:`lst:env-mlb2` so that they are :math:`2` and save them into ``env-mlb3.yaml`` and ``env-mlb4.yaml`` respectively (see :numref:`lst:env-mlb3` and :numref:`lst:env-mlb4`).
	
	.. index:: poly-switches;adding comments and then line breaks: set to 2
	
	.. literalinclude:: demonstrations/env-mlb3.yaml
		:class: .mlbyaml
		:caption: ``env-mlb3.yaml`` 
		:name: lst:env-mlb3
	
	.. literalinclude:: demonstrations/env-mlb4.yaml
		:class: .mlbyaml
		:caption: ``env-mlb4.yaml`` 
		:name: lst:env-mlb4
	
	Upon running the commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb3.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb4.yaml
	
	we obtain :numref:`lst:env-mlb-mod3` and :numref:`lst:env-mlb-mod4`.
	
	.. literalinclude:: demonstrations/env-mlb-mod3.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb3` 
		:name: lst:env-mlb-mod3
	
	.. literalinclude:: demonstrations/env-mlb-mod4.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb4` 
		:name: lst:env-mlb-mod4
	
	Note that line breaks have been added as in :numref:`lst:env-mlb-mod1` and :numref:`lst:env-mlb-mod2`, but this time a comment symbol has been added before adding the line break; in both cases, trailing horizontal space has been stripped before doing so.


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb1` and :numref:`lst:env-mlb2` so that they are :math:`3` and save them into ``env-mlb5.yaml`` and ``env-mlb6.yaml`` respectively (see :numref:`lst:env-mlb5` and :numref:`lst:env-mlb6`).
	
	.. index:: poly-switches;adding blank lines: set to 3
	
	.. literalinclude:: demonstrations/env-mlb5.yaml
		:class: .mlbyaml
		:caption: ``env-mlb5.yaml`` 
		:name: lst:env-mlb5
	
	.. literalinclude:: demonstrations/env-mlb6.yaml
		:class: .mlbyaml
		:caption: ``env-mlb6.yaml`` 
		:name: lst:env-mlb6
	
	Upon running the commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb5.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb6.yaml
	
	we obtain :numref:`lst:env-mlb-mod5` and :numref:`lst:env-mlb-mod6`.
	
	.. literalinclude:: demonstrations/env-mlb-mod5.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb5` 
		:name: lst:env-mlb-mod5
	
	.. literalinclude:: demonstrations/env-mlb-mod6.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb6` 
		:name: lst:env-mlb-mod6
	
	Note that line breaks have been added as in :numref:`lst:env-mlb-mod1` and :numref:`lst:env-mlb-mod2`, but this time a *blank line* has been added after adding the line break.


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb5` and :numref:`lst:env-mlb6` so that they are :math:`4` and save them into ``env-beg4.yaml`` and ``env-body4.yaml`` respectively (see :numref:`lst:env-beg4` and :numref:`lst:env-body4`).
	
	.. index:: poly-switches;adding blank lines (again"!): set to 4
	
	.. literalinclude:: demonstrations/env-beg4.yaml
		:class: .mlbyaml
		:caption: ``env-beg4.yaml`` 
		:name: lst:env-beg4
	
	.. literalinclude:: demonstrations/env-body4.yaml
		:class: .mlbyaml
		:caption: ``env-body4.yaml`` 
		:name: lst:env-body4
	
	We will demonstrate this poly-switch value using the code in :numref:`lst:env-mlb1-text`.
	
	.. literalinclude:: demonstrations/env-mlb1.tex
		:class: .tex
		:caption: ``env-mlb1.tex`` 
		:name: lst:env-mlb1-text
	
	Upon running the commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb1.tex -l env-beg4.yaml
	   latexindent.pl -m env-mlb.1tex -l env-body4.yaml
	
	then we receive the respective outputs in :numref:`lst:env-mlb1-beg4` and :numref:`lst:env-mlb1-body4`.
	
	.. literalinclude:: demonstrations/env-mlb1-beg4.tex
		:class: .tex
		:caption: ``env-mlb1.tex`` using :numref:`lst:env-beg4` 
		:name: lst:env-mlb1-beg4
	
	.. literalinclude:: demonstrations/env-mlb1-body4.tex
		:class: .tex
		:caption: ``env-mlb1.tex`` using :numref:`lst:env-body4` 
		:name: lst:env-mlb1-body4
	
	We note in particular that, by design, for this value of the poly-switches:
	
	#. in :numref:`lst:env-mlb1-beg4` a blank line has been inserted before the ``\begin`` statement, even though the ``\begin`` statement was already on its own line;
	
	#. in :numref:`lst:env-mlb1-body4` a blank line has been inserted before the beginning of the *body*, even though it already began on its own line.
	


Adding line breaks: EndStartsOnOwnLine and EndFinishesWithLineBreak
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	Let’s explore ``EndStartsOnOwnLine`` and ``EndFinishesWithLineBreak`` in :numref:`lst:env-mlb7` and :numref:`lst:env-mlb8`, and in particular, let’s allow each of them in turn to take a value of :math:`1`.
	
	.. index:: poly-switches;adding line breaks: set to 1
	
	.. literalinclude:: demonstrations/env-mlb7.yaml
		:class: .mlbyaml
		:caption: ``env-mlb7.yaml`` 
		:name: lst:env-mlb7
	
	.. literalinclude:: demonstrations/env-mlb8.yaml
		:class: .mlbyaml
		:caption: ``env-mlb8.yaml`` 
		:name: lst:env-mlb8
	
	After running the following commands,
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb7.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb8.yaml
	
	the output is as in :numref:`lst:env-mlb-mod7` and :numref:`lst:env-mlb-mod8`.
	
	.. literalinclude:: demonstrations/env-mlb-mod7.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb7` 
		:name: lst:env-mlb-mod7
	
	.. literalinclude:: demonstrations/env-mlb-mod8.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb8` 
		:name: lst:env-mlb-mod8
	
	There are a couple of points to note:
	
	-  in :numref:`lst:env-mlb-mod7` a line break has been added at the point denoted by ◆ in :numref:`lst:env-mlb1-tex`; no other line breaks have been changed and the ``\end{myenv}`` statement has *not* received indentation (as intended);
	
	-  in :numref:`lst:env-mlb-mod8` a line break has been added at the point denoted by ♣ in :numref:`lst:env-mlb1-tex`.
	


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb7` and :numref:`lst:env-mlb8` so that they are :math:`2` and save them into ``env-mlb9.yaml`` and ``env-mlb10.yaml`` respectively (see :numref:`lst:env-mlb9` and :numref:`lst:env-mlb10`).
	
	.. index:: poly-switches;adding comments and then line breaks: set to 2
	
	.. literalinclude:: demonstrations/env-mlb9.yaml
		:class: .mlbyaml
		:caption: ``env-mlb9.yaml`` 
		:name: lst:env-mlb9
	
	.. literalinclude:: demonstrations/env-mlb10.yaml
		:class: .mlbyaml
		:caption: ``env-mlb10.yaml`` 
		:name: lst:env-mlb10
	
	Upon running the commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb9.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb10.yaml
	
	we obtain :numref:`lst:env-mlb-mod9` and :numref:`lst:env-mlb-mod10`.
	
	.. literalinclude:: demonstrations/env-mlb-mod9.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb9` 
		:name: lst:env-mlb-mod9
	
	.. literalinclude:: demonstrations/env-mlb-mod10.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb10` 
		:name: lst:env-mlb-mod10
	
	Note that line breaks have been added as in :numref:`lst:env-mlb-mod7` and :numref:`lst:env-mlb-mod8`, but this time a comment symbol has been added before adding the line break; in both cases, trailing horizontal space has been stripped before doing so.


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb7` and :numref:`lst:env-mlb8` so that they are :math:`3` and save them into ``env-mlb11.yaml`` and ``env-mlb12.yaml`` respectively (see :numref:`lst:env-mlb11` and :numref:`lst:env-mlb12`).
	
	.. index:: poly-switches;adding blank lines: set to 3
	
	.. literalinclude:: demonstrations/env-mlb11.yaml
		:class: .mlbyaml
		:caption: ``env-mlb11.yaml`` 
		:name: lst:env-mlb11
	
	.. literalinclude:: demonstrations/env-mlb12.yaml
		:class: .mlbyaml
		:caption: ``env-mlb12.yaml`` 
		:name: lst:env-mlb12
	
	Upon running the commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb.tex -l env-mlb11.yaml
	   latexindent.pl -m env-mlb.tex -l env-mlb12.yaml
	
	we obtain :numref:`lst:env-mlb-mod11` and :numref:`lst:env-mlb-mod12`.
	
	.. literalinclude:: demonstrations/env-mlb-mod11.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb11` 
		:name: lst:env-mlb-mod11
	
	.. literalinclude:: demonstrations/env-mlb-mod12.tex
		:class: .tex
		:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb12` 
		:name: lst:env-mlb-mod12
	
	Note that line breaks have been added as in :numref:`lst:env-mlb-mod7` and :numref:`lst:env-mlb-mod8`, and that a *blank line* has been added after the line break.


.. proof:example::	
	
	Let’s now change each of the ``1`` values in :numref:`lst:env-mlb11` and :numref:`lst:env-mlb12` so that they are :math:`4` and save them into ``env-end4.yaml`` and ``env-end-f4.yaml`` respectively (see :numref:`lst:env-end4` and :numref:`lst:env-end-f4`).
	
	.. index:: poly-switches;adding blank lines (again"!): set to 4
	
	.. literalinclude:: demonstrations/env-end4.yaml
		:class: .mlbyaml
		:caption: ``env-end4.yaml`` 
		:name: lst:env-end4
	
	.. literalinclude:: demonstrations/env-end-f4.yaml
		:class: .mlbyaml
		:caption: ``env-end-f4.yaml`` 
		:name: lst:env-end-f4
	
	We will demonstrate this poly-switch value using the code from :numref:`lst:env-mlb1-text`.
	
	Upon running the commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb1.tex -l env-end4.yaml
	   latexindent.pl -m env-mlb.1tex -l env-end-f4.yaml
	
	then we receive the respective outputs in :numref:`lst:env-mlb1-end4` and :numref:`lst:env-mlb1-end-f4`.
	
	.. literalinclude:: demonstrations/env-mlb1-end4.tex
		:class: .tex
		:caption: ``env-mlb1.tex`` using :numref:`lst:env-end4` 
		:name: lst:env-mlb1-end4
	
	.. literalinclude:: demonstrations/env-mlb1-end-f4.tex
		:class: .tex
		:caption: ``env-mlb1.tex`` using :numref:`lst:env-end-f4` 
		:name: lst:env-mlb1-end-f4
	
	We note in particular that, by design, for this value of the poly-switches:
	
	#. in :numref:`lst:env-mlb1-end4` a blank line has been inserted before the ``\end`` statement, even though the ``\end`` statement was already on its own line;
	
	#. in :numref:`lst:env-mlb1-end-f4` a blank line has been inserted after the ``\end`` statement, even though it already began on its own line.
	


poly-switches 1, 2, and 3 only add line breaks when necessary
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you ask ``latexindent.pl`` to add a line break (possibly with a comment) using a poly-switch value of :math:`1` (or :math:`2` or :math:`3`), it will only do so if necessary.

.. proof:example::	
	
	For example, if you process the file in :numref:`lst:mlb2` using poly-switch values of 1, 2, or 3, it will be left unchanged.
	
	.. literalinclude:: demonstrations/env-mlb2.tex
		:class: .tex
		:caption: ``env-mlb2.tex`` 
		:name: lst:mlb2
	
	.. literalinclude:: demonstrations/env-mlb3.tex
		:class: .tex
		:caption: ``env-mlb3.tex`` 
		:name: lst:mlb3
	


Setting the poly-switches to a value of :math:`4` instructs ``latexindent.pl`` to add a line break even if the *<part of thing>* is already on its own line; see :numref:`lst:env-mlb1-beg4` and :numref:`lst:env-mlb1-body4` and :numref:`lst:env-mlb1-end4` and :numref:`lst:env-mlb1-end-f4`.

.. proof:example::	
	
	In contrast, the output from processing the file in :numref:`lst:mlb3` will vary depending on the poly-switches used; in :numref:`lst:env-mlb3-mod2` you’ll see that the comment symbol after the ``\begin{myenv}`` has been moved to the next line, as ``BodyStartsOnOwnLine`` is set to ``1``. In :numref:`lst:env-mlb3-mod4` you’ll see that the comment has been accounted for correctly because ``BodyStartsOnOwnLine`` has been set to ``2``, and the comment symbol has *not* been moved to its own
	line. You’re encouraged to experiment with :numref:`lst:mlb3` and by setting the other poly-switches considered so far to ``2`` in turn.
	
	.. literalinclude:: demonstrations/env-mlb3-mod2.tex
		:class: .tex
		:caption: ``env-mlb3.tex`` using :numref:`lst:env-mlb2` 
		:name: lst:env-mlb3-mod2
	
	.. literalinclude:: demonstrations/env-mlb3-mod4.tex
		:class: .tex
		:caption: ``env-mlb3.tex`` using :numref:`lst:env-mlb4` 
		:name: lst:env-mlb3-mod4
	


The details of the discussion in this section have concerned *global* poly-switches in the ``environments`` field; each switch can also be specified on a *per-name* basis, which would take priority over the global values; with reference to :numref:`lst:environments-mlb`, an example is shown for the ``equation*`` environment.

Removing line breaks (poly-switches set to :math:`-1`)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Setting poly-switches to :math:`-1` tells ``latexindent.pl`` to remove line breaks of the *<part of the thing>*, if necessary.

.. proof:example::	
	
	We will consider the example code given in :numref:`lst:mlb4`, noting in particular the positions of the line break highlighters, ♠, ♥, ◆ and ♣, together with the associated YAML files in :numref:`lst:env-mlb13` – :numref:`lst:env-mlb16`.
	
	.. index:: poly-switches;removing line breaks: set to -1
	
	.. code-block:: latex
	   :caption: ``env-mlb4.tex`` 
	   :name: lst:mlb4
	
	   before words♠
	   \begin{myenv}♥
	   body of myenv◆
	   \end{myenv}♣
	   after words
	
	After
	
	.. literalinclude:: demonstrations/env-mlb13.yaml
		:class: .mlbyaml
		:caption: ``env-mlb13.yaml`` 
		:name: lst:env-mlb13
	
	.. literalinclude:: demonstrations/env-mlb14.yaml
		:class: .mlbyaml
		:caption: ``env-mlb14.yaml`` 
		:name: lst:env-mlb14
	
	.. literalinclude:: demonstrations/env-mlb15.yaml
		:class: .mlbyaml
		:caption: ``env-mlb15.yaml`` 
		:name: lst:env-mlb15
	
	.. literalinclude:: demonstrations/env-mlb16.yaml
		:class: .mlbyaml
		:caption: ``env-mlb16.yaml`` 
		:name: lst:env-mlb16
	
	running the commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb4.tex -l env-mlb13.yaml
	   latexindent.pl -m env-mlb4.tex -l env-mlb14.yaml
	   latexindent.pl -m env-mlb4.tex -l env-mlb15.yaml
	   latexindent.pl -m env-mlb4.tex -l env-mlb16.yaml
	
	we obtain the respective output in :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16`.
	
	.. literalinclude:: demonstrations/env-mlb4-mod13.tex
		:class: .tex
		:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb13` 
		:name: lst:env-mlb4-mod13
	
	.. literalinclude:: demonstrations/env-mlb4-mod14.tex
		:class: .tex
		:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb14` 
		:name: lst:env-mlb4-mod14
	
	.. literalinclude:: demonstrations/env-mlb4-mod15.tex
		:class: .tex
		:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb15` 
		:name: lst:env-mlb4-mod15
	
	.. literalinclude:: demonstrations/env-mlb4-mod16.tex
		:class: .tex
		:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb16` 
		:name: lst:env-mlb4-mod16
	
	Notice that in:
	
	-  :numref:`lst:env-mlb4-mod13` the line break denoted by ♠ in :numref:`lst:mlb4` has been removed;
	
	-  :numref:`lst:env-mlb4-mod14` the line break denoted by ♥ in :numref:`lst:mlb4` has been removed;
	
	-  :numref:`lst:env-mlb4-mod15` the line break denoted by ◆ in :numref:`lst:mlb4` has been removed;
	
	-  :numref:`lst:env-mlb4-mod16` the line break denoted by ♣ in :numref:`lst:mlb4` has been removed.
	
	We examined each of these cases separately for clarity of explanation, but you can combine all of the YAML settings in :numref:`lst:env-mlb13` – :numref:`lst:env-mlb16` into one file; alternatively, you could tell ``latexindent.pl`` to load them all by using the following command, for example
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb4.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml
	
	which gives the output in :numref:`lst:env-mlb1-tex`.


About trailing horizontal space
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Recall that on :ref:`page yaml:removeTrailingWhitespace <yaml:removeTrailingWhitespace>` we discussed the YAML field ``removeTrailingWhitespace``, and that it has two (binary) switches to determine if horizontal space should be removed ``beforeProcessing`` and ``afterProcessing``. The ``beforeProcessing`` is particularly relevant when considering the ``-m`` switch.

.. proof:example::	
	
	We consider the file shown in :numref:`lst:mlb5`, which highlights trailing spaces.
	
	.. code-block:: latex
	   :caption: ``env-mlb5.tex`` 
	   :name: lst:mlb5
	
	   before words   ♠ 
	   \begin{myenv}           ♥
	   body of myenv      ◆ 
	   \end{myenv}     ♣
	   after words
	
	The
	
	.. literalinclude:: demonstrations/removeTWS-before.yaml
		:class: .baseyaml
		:caption: ``removeTWS-before.yaml`` 
		:name: lst:removeTWS-before
	
	output from the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb5.tex -l env-mlb13,env-mlb14,env-mlb15,env-mlb16
	   latexindent.pl -m env-mlb5.tex -l env-mlb13,env-mlb14,env-mlb15,env-mlb16,removeTWS-before
	
	is shown, respectively, in :numref:`lst:env-mlb5-modAll` and :numref:`lst:env-mlb5-modAll-remove-WS`; note that the trailing horizontal white space has been preserved (by default) in :numref:`lst:env-mlb5-modAll`, while in :numref:`lst:env-mlb5-modAll-remove-WS`, it has been removed using the switch specified in :numref:`lst:removeTWS-before`.
	
	.. literalinclude:: demonstrations/env-mlb5-modAll.tex
		:class: .tex
		:caption: ``env-mlb5.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` 
		:name: lst:env-mlb5-modAll
	
	.. literalinclude:: demonstrations/env-mlb5-modAll-remove-WS.tex
		:class: .tex
		:caption: ``env-mlb5.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` *and* :numref:`lst:removeTWS-before` 
		:name: lst:env-mlb5-modAll-remove-WS
	


poly-switch line break removal and blank lines
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	Now let’s consider the file in :numref:`lst:mlb6`, which contains blank lines.
	
	.. index:: poly-switches;blank lines
	
	.. code-block:: latex
	   :caption: ``env-mlb6.tex`` 
	   :name: lst:mlb6
	
	   before words♠
	
	
	   \begin{myenv}♥
	
	
	   body of myenv◆
	
	
	   \end{myenv}♣
	
	   after words
	
	Upon
	
	.. literalinclude:: demonstrations/UnpreserveBlankLines.yaml
		:class: .mlbyaml
		:caption: ``UnpreserveBlankLines.yaml`` 
		:name: lst:UnpreserveBlankLines
	
	running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb6.tex -l env-mlb13,env-mlb14,env-mlb15,env-mlb16
	   latexindent.pl -m env-mlb6.tex -l env-mlb13,env-mlb14,env-mlb15,env-mlb16,UnpreserveBlankLines
	
	we receive the respective outputs in :numref:`lst:env-mlb6-modAll` and :numref:`lst:env-mlb6-modAll-un-Preserve-Blank-Lines`. In :numref:`lst:env-mlb6-modAll` we see that the multiple blank lines have each been condensed into one blank line, but that blank lines have *not* been removed by the poly-switches – this is because, by default, ``preserveBlankLines`` is set to ``1``. By contrast, in :numref:`lst:env-mlb6-modAll-un-Preserve-Blank-Lines`, we have allowed the poly-switches to
	remove blank lines because, in :numref:`lst:UnpreserveBlankLines`, we have set ``preserveBlankLines`` to ``0``.
	
	.. literalinclude:: demonstrations/env-mlb6-modAll.tex
		:class: .tex
		:caption: ``env-mlb6.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` 
		:name: lst:env-mlb6-modAll
	
	.. literalinclude:: demonstrations/env-mlb6-modAll-un-Preserve-Blank-Lines.tex
		:class: .tex
		:caption: ``env-mlb6.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` *and* :numref:`lst:UnpreserveBlankLines` 
		:name: lst:env-mlb6-modAll-un-Preserve-Blank-Lines
	


.. proof:example::	
	
	We can explore this further using the blank-line poly-switch value of :math:`3`; let’s use the file given in :numref:`lst:env-mlb7-tex`.
	
	.. literalinclude:: demonstrations/env-mlb7.tex
		:class: .tex
		:caption: ``env-mlb7.tex`` 
		:name: lst:env-mlb7-tex
	
	Upon running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m env-mlb7.tex -l env-mlb12.yaml,env-mlb13.yaml
	   latexindent.pl -m env-mlb7.tex -l env-mlb13,env-mlb14,UnpreserveBlankLines
	
	we receive the outputs given in :numref:`lst:env-mlb7-preserve` and :numref:`lst:env-mlb7-no-preserve`.
	
	.. literalinclude:: demonstrations/env-mlb7-preserve.tex
		:class: .tex
		:caption: ``env-mlb7-preserve.tex`` 
		:name: lst:env-mlb7-preserve
	
	.. literalinclude:: demonstrations/env-mlb7-no-preserve.tex
		:class: .tex
		:caption: ``env-mlb7-no-preserve.tex`` 
		:name: lst:env-mlb7-no-preserve
	
	Notice that in:
	
	-  :numref:`lst:env-mlb7-preserve` that ``\end{one}`` has added a blank line, because of the value of ``EndFinishesWithLineBreak`` in :numref:`lst:env-mlb12`, and even though the line break ahead of ``\begin{two}`` should have been removed (because of ``BeginStartsOnOwnLine`` in :numref:`lst:env-mlb13`), the blank line has been preserved by default;
	
	-  :numref:`lst:env-mlb7-no-preserve`, by contrast, has had the additional line-break removed, because of the settings in :numref:`lst:UnpreserveBlankLines`.
	


.. label follows

.. _subsec:dbs:

Poly-switches for double backslash
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With reference to ``lookForAlignDelims`` (see :numref:`lst:aligndelims:basic`) you can specify poly-switches to dictate the line-break behaviour of double backslashes in environments (:numref:`lst:tabularafter:basic`), commands (:numref:`lst:matrixafter`), or special code blocks (:numref:`lst:specialafter`). [1]_

.. index:: delimiters;poly-switches for double backslash

.. index:: modifying linebreaks; surrounding double backslash

.. index:: poly-switches;for double back slash (delimiters)

Consider the code given in :numref:`lst:dbs-demo`.

.. code-block:: latex
   :caption: ``tabular3.tex`` 
   :name: lst:dbs-demo

   \begin{tabular}{cc}
    1 & 2 ★\\□ 3 & 4 ★\\□
   \end{tabular}

Referencing :numref:`lst:dbs-demo`:

-  ``DBS`` stands for *double backslash*;

-  line breaks ahead of the double backslash are annotated by ★, and are controlled by ``DBSStartsOnOwnLine``;

-  line breaks after the double backslash are annotated by □, and are controlled by ``DBSFinishesWithLineBreak``.

Let’s explore each of these in turn.

Double backslash starts on own line
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	We explore ``DBSStartsOnOwnLine`` (★ in :numref:`lst:dbs-demo`); starting with the code in :numref:`lst:dbs-demo`, together with the YAML files given in :numref:`lst:DBS1` and :numref:`lst:DBS2` and running the following commands
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tabular3.tex -l DBS1.yaml
	   latexindent.pl -m tabular3.tex -l DBS2.yaml
	
	then we receive the respective output given in :numref:`lst:tabular3-DBS1` and :numref:`lst:tabular3-DBS2`.
	
	.. literalinclude:: demonstrations/tabular3-mod1.tex
		:class: .tex
		:caption: ``tabular3.tex`` using :numref:`lst:DBS1` 
		:name: lst:tabular3-DBS1
	
	.. literalinclude:: demonstrations/DBS1.yaml
		:class: .mlbyaml
		:caption: ``DBS1.yaml`` 
		:name: lst:DBS1
	
	.. literalinclude:: demonstrations/tabular3-mod2.tex
		:class: .tex
		:caption: ``tabular3.tex`` using :numref:`lst:DBS2` 
		:name: lst:tabular3-DBS2
	
	.. literalinclude:: demonstrations/DBS2.yaml
		:class: .mlbyaml
		:caption: ``DBS2.yaml`` 
		:name: lst:DBS2
	
	We note that
	
	-  :numref:`lst:DBS1` specifies ``DBSStartsOnOwnLine`` for *every* environment (that is within ``lookForAlignDelims``, :numref:`lst:aligndelims:advanced`); the double backslashes from :numref:`lst:dbs-demo` have been moved to their own line in :numref:`lst:tabular3-DBS1`;
	
	-  :numref:`lst:DBS2` specifies ``DBSStartsOnOwnLine`` on a *per-name* basis for ``tabular`` (that is within ``lookForAlignDelims``, :numref:`lst:aligndelims:advanced`); the double backslashes from :numref:`lst:dbs-demo` have been moved to their own line in :numref:`lst:tabular3-DBS2`, having added comment symbols before moving them.
	


.. proof:example::	
	
	We can combine DBS poly-switches with, for example, the ``alignContentAfterDoubleBackSlash`` in :numref:`sec:alignContentAfterDoubleBackSlash`.
	
	For example, starting with the file :numref:`lst:tabular6`, and using the settings in :numref:`lst:alignContentAfterDBS1` and :numref:`lst:alignContentAfterDBS2` and running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -s -m -l alignContentAfterDBS1.yaml,DBS1.yaml tabular6.tex -o=+-mod1
	   latexindent.pl -s -m -l alignContentAfterDBS2.yaml,DBS1.yaml tabular6.tex -o=+-mod2
	
	gives the respective outputs shown in :numref:`lst:tabular6-mod1` and :numref:`lst:tabular6-mod2`.
	
	.. literalinclude:: demonstrations/tabular6.tex
		:class: .tex
		:caption: ``tabular6.tex`` 
		:name: lst:tabular6
	
	.. literalinclude:: demonstrations/tabular6-mod1.tex
		:class: .tex
		:caption: ``tabular6-mod1.tex`` 
		:name: lst:tabular6-mod1
	
	.. literalinclude:: demonstrations/tabular6-mod2.tex
		:class: .tex
		:caption: ``tabular6-mod2.tex`` 
		:name: lst:tabular6-mod2
	
	We note that:
	
	-  in :numref:`lst:tabular6-mod1` the content *after* the double back slash has been aligned;
	
	-  in :numref:`lst:tabular6-mod2` we see that 3 spaces have been added after the double back slash.
	


Double backslash finishes with line break
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	Let’s now explore ``DBSFinishesWithLineBreak`` (□ in :numref:`lst:dbs-demo`); starting with the code in :numref:`lst:dbs-demo`, together with the YAML files given in :numref:`lst:DBS3` and :numref:`lst:DBS4` and running the following commands
	
	.. index:: poly-switches;for double backslash (delimiters)
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m tabular3.tex -l DBS3.yaml
	   latexindent.pl -m tabular3.tex -l DBS4.yaml
	
	then we receive the respective output given in :numref:`lst:tabular3-DBS3` and :numref:`lst:tabular3-DBS4`.
	
	.. literalinclude:: demonstrations/tabular3-mod3.tex
		:class: .tex
		:caption: ``tabular3.tex`` using :numref:`lst:DBS3` 
		:name: lst:tabular3-DBS3
	
	.. literalinclude:: demonstrations/DBS3.yaml
		:class: .mlbyaml
		:caption: ``DBS3.yaml`` 
		:name: lst:DBS3
	
	.. literalinclude:: demonstrations/tabular3-mod4.tex
		:class: .tex
		:caption: ``tabular3.tex`` using :numref:`lst:DBS4` 
		:name: lst:tabular3-DBS4
	
	.. literalinclude:: demonstrations/DBS4.yaml
		:class: .mlbyaml
		:caption: ``DBS4.yaml`` 
		:name: lst:DBS4
	
	We note that
	
	-  :numref:`lst:DBS3` specifies ``DBSFinishesWithLineBreak`` for *every* environment (that is within ``lookForAlignDelims``, :numref:`lst:aligndelims:advanced`); the code following the double backslashes from :numref:`lst:dbs-demo` has been moved to their own line in :numref:`lst:tabular3-DBS3`;
	
	-  :numref:`lst:DBS4` specifies ``DBSFinishesWithLineBreak`` on a *per-name* basis for ``tabular`` (that is within ``lookForAlignDelims``, :numref:`lst:aligndelims:advanced`); the first double backslashes from :numref:`lst:dbs-demo` have moved code following them to their own line in :numref:`lst:tabular3-DBS4`, having added comment symbols before moving them; the final double backslashes have *not* added a line break as they are at the end of the body within the code block.
	


Double backslash poly-switches for specialBeginEnd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. proof:example::	
	
	Let’s explore the double backslash poly-switches for code blocks within ``specialBeginEnd`` code blocks (:numref:`lst:specialBeginEnd`); we begin with the code within :numref:`lst:special4`.
	
	.. index:: specialBeginEnd;double backslash poly-switch demonstration
	
	.. index:: poly-switches;double backslash
	
	.. index:: poly-switches;for double backslash (delimiters)
	
	.. index:: specialBeginEnd;lookForAlignDelims
	
	.. index:: delimiters
	
	.. index:: linebreaks;summary of poly-switches
	
	.. literalinclude:: demonstrations/special4.tex
		:class: .tex
		:caption: ``special4.tex`` 
		:name: lst:special4
	
	Upon using the YAML settings in :numref:`lst:DBS5`, and running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m special4.tex -l DBS5.yaml
	
	then we receive the output given in :numref:`lst:special4-DBS5`.
	
	.. index:: delimiters;with specialBeginEnd and the -m switch
	
	.. literalinclude:: demonstrations/special4-mod5.tex
		:class: .tex
		:caption: ``special4.tex`` using :numref:`lst:DBS5` 
		:name: lst:special4-DBS5
	
	.. literalinclude:: demonstrations/DBS5.yaml
		:class: .mlbyaml
		:caption: ``DBS5.yaml`` 
		:name: lst:DBS5
	
	There are a few things to note:
	
	-  in :numref:`lst:DBS5` we have specified ``cmhMath`` within ``lookForAlignDelims``; without this, the double backslash poly-switches would be ignored for this code block;
	
	-  the ``DBSFinishesWithLineBreak`` poly-switch has controlled the line breaks following the double backslashes;
	
	-  the ``SpecialEndStartsOnOwnLine`` poly-switch has controlled the addition of a comment symbol, followed by a line break, as it is set to a value of 2.
	


Double backslash poly-switches for optional and mandatory arguments
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For clarity, we provide a demonstration of controlling the double backslash poly-switches for optional and mandatory arguments.

.. proof:example::	
	
	We use with the code in :numref:`lst:mycommand2`.
	
	.. index:: poly-switches;for double backslash (delimiters)
	
	.. literalinclude:: demonstrations/mycommand2.tex
		:class: .tex
		:caption: ``mycommand2.tex`` 
		:name: lst:mycommand2
	
	Upon using the YAML settings in :numref:`lst:DBS6` and :numref:`lst:DBS7`, and running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m mycommand2.tex -l DBS6.yaml
	   latexindent.pl -m mycommand2.tex -l DBS7.yaml
	
	then we receive the output given in :numref:`lst:mycommand2-DBS6` and :numref:`lst:mycommand2-DBS7`.
	
	.. literalinclude:: demonstrations/mycommand2-mod6.tex
		:class: .tex
		:caption: ``mycommand2.tex`` using :numref:`lst:DBS6` 
		:name: lst:mycommand2-DBS6
	
	.. literalinclude:: demonstrations/DBS6.yaml
		:class: .mlbyaml
		:caption: ``DBS6.yaml`` 
		:name: lst:DBS6
	
	.. literalinclude:: demonstrations/mycommand2-mod7.tex
		:class: .tex
		:caption: ``mycommand2.tex`` using :numref:`lst:DBS7` 
		:name: lst:mycommand2-DBS7
	
	.. literalinclude:: demonstrations/DBS7.yaml
		:class: .mlbyaml
		:caption: ``DBS7.yaml`` 
		:name: lst:DBS7
	


Double backslash optional square brackets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The pattern matching for the double backslash will also, optionally, allow trailing square brackets that contain a measurement of vertical spacing, for example ``\\[3pt]``.

.. index:: poly-switches;for double backslash (delimiters)

.. proof:example::	
	
	For example, beginning with the code in :numref:`lst:pmatrix3`
	
	.. literalinclude:: demonstrations/pmatrix3.tex
		:class: .tex
		:caption: ``pmatrix3.tex`` 
		:name: lst:pmatrix3
	
	and running the following command, using :numref:`lst:DBS3`,
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m pmatrix3.tex -l DBS3.yaml
	
	then we receive the output given in :numref:`lst:pmatrix3-DBS3`.
	
	.. literalinclude:: demonstrations/pmatrix3-mod3.tex
		:class: .tex
		:caption: ``pmatrix3.tex`` using :numref:`lst:DBS3` 
		:name: lst:pmatrix3-DBS3
	


You can customise the pattern for the double backslash by exploring the *fine tuning* field detailed in :numref:`lst:fineTuning`.

Poly-switches for other code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Rather than repeat the examples shown for the environment code blocks (in :numref:`sec:modifylinebreaks-environments`), we choose to detail the poly-switches for all other code blocks in :numref:`tab:poly-switch-mapping`; note that each and every one of these poly-switches is *off by default*, i.e, set to ``0``.

Note also that, by design, line breaks involving, ``filecontents`` and ‘comment-marked’ code blocks (:numref:`lst:alignmentmarkup`) can *not* be modified using ``latexindent.pl``. However, there are two poly-switches available for ``verbatim`` code blocks: environments (:numref:`lst:verbatimEnvironments`), commands (:numref:`lst:verbatimCommands`) and ``specialBeginEnd`` (:numref:`lst:special-verb1-yaml`).

.. index:: specialBeginEnd;poly-switch summary

.. index:: verbatim;poly-switch summary

.. index:: poly-switches;summary of all poly-switches

.. label follows

.. _tab:poly-switch-mapping:



.. table:: Poly-switch mappings for all code-block types

   ============================= ====================================== = ==================================
   Code block                    Sample                                   
   ============================= ====================================== = ==================================
   environment                   ``before words``\ ♠                    ♠ BeginStartsOnOwnLine
   \                             ``\begin{myenv}``\ ♥                   ♥ BodyStartsOnOwnLine
   \                             ``body of myenv``\ ◆                   ◆ EndStartsOnOwnLine
   \                             ``\end{myenv}``\ ♣                     ♣ EndFinishesWithLineBreak
   \                             ``after words``                          
   ifelsefi                      ``before words``\ ♠                    ♠ IfStartsOnOwnLine
   \                             ``\if...``\ ♥                          ♥ BodyStartsOnOwnLine
   \                             ``body of if/or statement``\ ▲         ▲ OrStartsOnOwnLine
   \                             ``\or``\ ▼                             ▼ OrFinishesWithLineBreak
   \                             ``body of if/or statement``\ ★         ★ ElseStartsOnOwnLine
   \                             ``\else``\ □                           □ ElseFinishesWithLineBreak
   \                             ``body of else statement``\ ◆          ◆ FiStartsOnOwnLine
   \                             ``\fi``\ ♣                             ♣ FiFinishesWithLineBreak
   \                             ``after words``                          
   optionalArguments             ``...``\ ♠                             ♠ LSqBStartsOnOwnLine [2]_
   \                             ``[``\ ♥                               ♥ OptArgBodyStartsOnOwnLine
   \                             ``value before comma``\ ★,             ★ CommaStartsOnOwnLine
   \                             □                                      □ CommaFinishesWithLineBreak
   \                             ``end of body of opt arg``\ ◆          ◆ RSqBStartsOnOwnLine
   \                             ``]``\ ♣                               ♣ RSqBFinishesWithLineBreak
   \                             ``...``                                  
   mandatoryArguments            ``...``\ ♠                             ♠ LCuBStartsOnOwnLine [3]_
   \                             ``\{``\ ♥                              ♥ MandArgBodyStartsOnOwnLine
   \                             ``value before comma``\ ★,             ★ CommaStartsOnOwnLine
   \                             □                                      □ CommaFinishesWithLineBreak
   \                             ``end of body of mand arg``\ ◆         ◆ RCuBStartsOnOwnLine
   \                             ``}``\ ♣                               ♣ RCuBFinishesWithLineBreak
   \                             ``...``                                  
   commands                      ``before words``\ ♠                    ♠ CommandStartsOnOwnLine
   \                             ``\mycommand``\ ♥                      ♥ CommandNameFinishesWithLineBreak
   \                             <arguments>                              
   namedGroupingBracesBrackets   before words♠                          ♠ NameStartsOnOwnLine
   \                             myname♥                                ♥ NameFinishesWithLineBreak
   \                             <braces/brackets>                        
   keyEqualsValuesBracesBrackets before words♠                          ♠ KeyStartsOnOwnLine
   \                             key●=♥                                 ● EqualsStartsOnOwnLine
   \                             <braces/brackets>                      ♥ EqualsFinishesWithLineBreak
   items                         before words♠                          ♠ ItemStartsOnOwnLine
   \                             ``\item``\ ♥                           ♥ ItemFinishesWithLineBreak
   \                             ``...``                                  
   specialBeginEnd               before words♠                          ♠ SpecialBeginStartsOnOwnLine
   \                             ``\[``\ ♥                              ♥ SpecialBodyStartsOnOwnLine
   \                             ``body of special/middle``\ ★          ★ SpecialMiddleStartsOnOwnLine
   \                             ``\middle``\ □                         □ SpecialMiddleFinishesWithLineBreak
   \                             body of special/middle ◆               ◆ SpecialEndStartsOnOwnLine
   \                             ``\]``\ ♣                              ♣ SpecialEndFinishesWithLineBreak
   \                             after words                              
   verbatim                      before words♠\ ``\begin{verbatim}``    ♠ VerbatimBeginStartsOnOwnLine
   \                             body of verbatim ``\end{verbatim}``\ ♣ ♣ VerbatimEndFinishesWithLineBreak
   \                             after words                              
   ============================= ====================================== = ==================================

Partnering BodyStartsOnOwnLine with argument-based poly-switches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some poly-switches need to be partnered together; in particular, when line breaks involving the *first* argument of a code block need to be accounted for using both ``BodyStartsOnOwnLine`` (or its equivalent, see :numref:`tab:poly-switch-mapping`) and ``LCuBStartsOnOwnLine`` for mandatory arguments, and ``LSqBStartsOnOwnLine`` for optional arguments.

.. index:: poly-switches;conflicting partnering

.. proof:example::	
	
	Let’s begin with the code in :numref:`lst:mycommand1` and the YAML settings in :numref:`lst:mycom-mlb1`; with reference to :numref:`tab:poly-switch-mapping`, the key ``CommandNameFinishesWithLineBreak`` is an alias for ``BodyStartsOnOwnLine``.
	
	.. literalinclude:: demonstrations/mycommand1.tex
		:class: .tex
		:caption: ``mycommand1.tex`` 
		:name: lst:mycommand1
	
	Upon running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb1.yaml mycommand1.tex
	
	we obtain :numref:`lst:mycommand1-mlb1`; note that the *second* mandatory argument beginning brace ``\{`` has had its leading line break removed, but that the *first* brace has not.
	
	.. literalinclude:: demonstrations/mycommand1-mlb1.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb1` 
		:name: lst:mycommand1-mlb1
	
	.. literalinclude:: demonstrations/mycom-mlb1.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb1.yaml`` 
		:name: lst:mycom-mlb1
	


.. proof:example::	
	
	Now let’s change the YAML file so that it is as in :numref:`lst:mycom-mlb2`; upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb2.yaml mycommand1.tex
	
	we obtain :numref:`lst:mycommand1-mlb2`; both beginning braces ``\{`` have had their leading line breaks removed.
	
	.. literalinclude:: demonstrations/mycommand1-mlb2.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb2` 
		:name: lst:mycommand1-mlb2
	
	.. literalinclude:: demonstrations/mycom-mlb2.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb2.yaml`` 
		:name: lst:mycom-mlb2
	


.. proof:example::	
	
	Now let’s change the YAML file so that it is as in :numref:`lst:mycom-mlb3`; upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb3.yaml mycommand1.tex
	
	we obtain :numref:`lst:mycommand1-mlb3`.
	
	.. literalinclude:: demonstrations/mycommand1-mlb3.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb3` 
		:name: lst:mycommand1-mlb3
	
	.. literalinclude:: demonstrations/mycom-mlb3.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb3.yaml`` 
		:name: lst:mycom-mlb3
	


Conflicting poly-switches: sequential code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is very easy to have conflicting poly-switches.

.. proof:example::	
	
	We use the example from :numref:`lst:mycommand1`, and consider the YAML settings given in :numref:`lst:mycom-mlb4`. The output from running
	
	.. index:: poly-switches;conflicting switches
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb4.yaml mycommand1.tex
	
	is given in :numref:`lst:mycom-mlb4`.
	
	.. literalinclude:: demonstrations/mycommand1-mlb4.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb4` 
		:name: lst:mycommand1-mlb4
	
	.. literalinclude:: demonstrations/mycom-mlb4.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb4.yaml`` 
		:name: lst:mycom-mlb4
	
	Studying :numref:`lst:mycom-mlb4`, we see that the two poly-switches are at opposition with one another:
	
	-  on the one hand, ``LCuBStartsOnOwnLine`` should *not* start on its own line (as poly-switch is set to :math:`-1`);
	
	-  on the other hand, ``RCuBFinishesWithLineBreak`` *should* finish with a line break.
	
	So, which should win the conflict? As demonstrated in :numref:`lst:mycommand1-mlb4`, it is clear that ``LCuBStartsOnOwnLine`` won this conflict, and the reason is that *the second argument was processed after the first* – in general, the most recently-processed code block and associated poly-switch takes priority.


.. proof:example::	
	
	We can explore this further by considering the YAML settings in :numref:`lst:mycom-mlb5`; upon running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb5.yaml mycommand1.tex
	
	we obtain the output given in :numref:`lst:mycommand1-mlb5`.
	
	.. literalinclude:: demonstrations/mycommand1-mlb5.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb5` 
		:name: lst:mycommand1-mlb5
	
	.. literalinclude:: demonstrations/mycom-mlb5.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb5.yaml`` 
		:name: lst:mycom-mlb5
	
	As previously, the most-recently-processed code block takes priority – as before, the second (i.e, *last*) argument.
	
	Exploring this further, we consider the YAML settings in :numref:`lst:mycom-mlb6`, and run the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=mycom-mlb6.yaml mycommand1.tex
	
	which gives the output in :numref:`lst:mycommand1-mlb6`.
	
	.. literalinclude:: demonstrations/mycommand1-mlb6.tex
		:class: .tex
		:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb6` 
		:name: lst:mycommand1-mlb6
	
	.. literalinclude:: demonstrations/mycom-mlb6.yaml
		:class: .mlbyaml
		:caption: ``mycom-mlb6.yaml`` 
		:name: lst:mycom-mlb6
	
	Note that a ``%`` *has* been added to the trailing first ``}``; this is because:
	
	-  while processing the *first* argument, the trailing line break has been removed (``RCuBFinishesWithLineBreak`` set to :math:`-1`);
	
	-  while processing the *second* argument, ``latexindent.pl`` finds that it does *not* begin on its own line, and so because ``LCuBStartsOnOwnLine`` is set to :math:`2`, it adds a comment, followed by a line break.
	


Conflicting poly-switches: nested code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. proof:example::	
	
	Now let’s consider an example when nested code blocks have conflicting poly-switches; we’ll use the code in :numref:`lst:nested-env`, noting that it contains nested environments.
	
	.. index:: poly-switches;conflicting switches
	
	.. literalinclude:: demonstrations/nested-env.tex
		:class: .tex
		:caption: ``nested-env.tex`` 
		:name: lst:nested-env
	
	Let’s use the YAML settings given in :numref:`lst:nested-env-mlb1-yaml`, which upon running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=nested-env-mlb1.yaml nested-env.tex
	
	gives the output in :numref:`lst:nested-env-mlb1`.
	
	.. literalinclude:: demonstrations/nested-env-mlb1.tex
		:class: .tex
		:caption: ``nested-env.tex`` using :numref:`lst:nested-env-mlb1-yaml` 
		:name: lst:nested-env-mlb1
	
	.. literalinclude:: demonstrations/nested-env-mlb1.yaml
		:class: .mlbyaml
		:caption: ``nested-env-mlb1.yaml`` 
		:name: lst:nested-env-mlb1-yaml
	
	In :numref:`lst:nested-env-mlb1`, let’s first of all note that both environments have received the appropriate (default) indentation; secondly, note that the poly-switch ``EndStartsOnOwnLine`` appears to have won the conflict, as ``\end{one}`` has had its leading line break removed.


To understand it, let’s talk about the three basic phases

.. label follows

.. _page:phases:

of ``latexindent.pl``:

#. Phase 1: packing, in which code blocks are replaced with unique ids, working from *the inside to the outside*, and then sequentially – for example, in :numref:`lst:nested-env`, the ``two`` environment is found *before* the ``one`` environment; if the -m switch is active, then during this phase:

   -  line breaks at the beginning of the ``body`` can be added (if ``BodyStartsOnOwnLine`` is :math:`1` or :math:`2`) or removed (if ``BodyStartsOnOwnLine`` is :math:`-1`);

   -  line breaks at the end of the body can be added (if ``EndStartsOnOwnLine`` is :math:`1` or :math:`2`) or removed (if ``EndStartsOnOwnLine`` is :math:`-1`);

   -  line breaks after the end statement can be added (if ``EndFinishesWithLineBreak`` is :math:`1` or :math:`2`).

#. Phase 2: indentation, in which white space is added to the begin, body, and end statements;

#. Phase 3: unpacking, in which unique ids are replaced by their *indented* code blocks; if the -m switch is active, then during this phase,

   -  line breaks before ``begin`` statements can be added or removed (depending upon ``BeginStartsOnOwnLine``);

   -  line breaks after *end* statements can be removed but *NOT* added (see ``EndFinishesWithLineBreak``).

With reference to :numref:`lst:nested-env-mlb1`, this means that during Phase 1:

-  the ``two`` environment is found first, and the line break ahead of the ``\end{two}`` statement is removed because ``EndStartsOnOwnLine`` is set to :math:`-1`. Importantly, because, *at this stage*, ``\end{two}`` *does* finish with a line break, ``EndFinishesWithLineBreak`` causes no action.

-  next, the ``one`` environment is found; the line break ahead of ``\end{one}`` is removed because ``EndStartsOnOwnLine`` is set to :math:`-1`.

The indentation is done in Phase 2; in Phase 3 *there is no option to add a line break after the ``end`` statements*. We can justify this by remembering that during Phase 3, the ``one`` environment will be found and processed first, followed by the ``two`` environment. If the ``two`` environment were to add a line break after the ``\end{two}`` statement, then ``latexindent.pl`` would have no way of knowing how much indentation to add to the subsequent text (in this case, ``\end{one}``).

.. proof:example::	
	
	We can explore this further using the poly-switches in :numref:`lst:nested-env-mlb2`; upon running the command
	
	.. index:: switches;-l demonstration
	
	.. index:: switches;-m demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l=nested-env-mlb2.yaml nested-env.tex
	
	we obtain the output given in :numref:`lst:nested-env-mlb2-output`.
	
	.. literalinclude:: demonstrations/nested-env-mlb2.tex
		:class: .tex
		:caption: ``nested-env.tex`` using :numref:`lst:nested-env-mlb2` 
		:name: lst:nested-env-mlb2-output
	
	.. literalinclude:: demonstrations/nested-env-mlb2.yaml
		:class: .mlbyaml
		:caption: ``nested-env-mlb2.yaml`` 
		:name: lst:nested-env-mlb2
	
	During Phase 1:
	
	-  the ``two`` environment is found first, and the line break ahead of the ``\end{two}`` statement is not changed because ``EndStartsOnOwnLine`` is set to :math:`1`. Importantly, because, *at this stage*, ``\end{two}`` *does* finish with a line break, ``EndFinishesWithLineBreak`` causes no action.
	
	-  next, the ``one`` environment is found; the line break ahead of ``\end{one}`` is already present, and no action is needed.
	
	The indentation is done in Phase 2, and then in Phase 3, the ``one`` environment is found and processed first, followed by the ``two`` environment. *At this stage*, the ``two`` environment finds ``EndFinishesWithLineBreak`` is :math:`-1`, so it removes the trailing line break; remember, at this point, ``latexindent.pl`` has completely finished with the ``one`` environment.


.. container:: references hanging-indent
   :name: refs

   .. container::
      :name: ref-mlep

      mlep. 2017. “One Sentence Per Line.” August 16, 2017. https://github.com/cmhughes/latexindent.pl/issues/81.

   .. container::
      :name: ref-textwrap

      “Text::Wrap Perl Module.” n.d. Accessed May 1, 2017. http://perldoc.perl.org/Text/Wrap.html.

.. [1]
   There is no longer any need for the code block to be specified within ``lookForAlignDelims`` for DBS poly-switches to activate.

.. [2]
   LSqB stands for Left Square Bracket

.. [3]
   LCuB stands for Left Curly Brace
