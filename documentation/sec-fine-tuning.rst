.. label follows

.. _sec:finetuning:

Fine tuning
===========

``latexindent.pl`` operates by looking for the code blocks detailed in :numref:`tab:code-blocks`. The fine tuning of the details of such code blocks is controlled by the ``fineTuning`` field, detailed in :numref:`lst:fineTuning`.

This field is for those that would like to peek under the bonnet/hood and make some fine tuning to ``latexindent.pl``\ ’s operating.

.. index:: warning;fine tuning

.. index:: regular expressions;fine tuning

.. index:: regular expressions;environments

.. index:: regular expressions;ifElseFi

.. index:: regular expressions;commands

.. index:: regular expressions;keyEqualsValuesBracesBrackets

.. index:: regular expressions;NamedGroupingBracesBrackets

.. index:: regular expressions;UnNamedGroupingBracesBrackets

.. index:: regular expressions;arguments

.. index:: regular expressions;modifyLineBreaks

.. index:: regular expressions;lowercase alph a-z

.. index:: regular expressions;uppercase alph A-Z

.. index:: regular expressions;numeric 0-9

.. index:: regular expressions;at least one +

.. warning::	
	
	Making changes to the fine tuning may have significant consequences for your indentation scheme, proceed with caution!
	 

.. literalinclude:: ../defaultSettings.yaml
 	:class: .baseyaml
 	:caption: ``fineTuning`` 
 	:name: lst:fineTuning
 	:lines: 627-679
 	:linenos:
 	:lineno-start: 627

The fields given in :numref:`lst:fineTuning` are all *regular expressions*. This manual is not intended to be a tutorial on regular expressions; you might like to read, for example, (Friedl, n.d.) for a detailed covering of the topic.

We make the following comments with reference to :numref:`lst:fineTuning`:

#. the ``environments:name`` field details that the *name* of an environment can contain:

   #. ``a-z`` lower case letters

   #. ``A-Z`` upper case letters

   #. ``@`` the ``@`` ’letter’

   #. ``\*`` stars

   #. ``0-9`` numbers

   #. ``_`` underscores

   #. ``\`` backslashes

   .. index:: regular expressions;at least one +

   The ``+`` at the end means *at least one* of the above characters.

#. the ``ifElseFi:name`` field:

   #. ``@?`` means that it *can possibly* begin with ``@``

   #. followed by ``if``

   #. followed by 0 or more characters from ``a-z``, ``A-Z`` and ``@``

   #. the ``?`` the end means *non-greedy*, which means ‘stop the match as soon as possible’

#. the ``keyEqualsValuesBracesBrackets`` contains some interesting syntax:

   #. ``|`` means ‘or’

   #. ``(?:(?<!\\)\{)`` the ``(?:...)`` uses a *non-capturing* group – you don’t necessarily need to worry about what this means, but just know that for the ``fineTuning`` feature you should only ever use *non*-capturing groups, and *not* capturing groups, which are simply ``(...)``

   #. ``(?<!\\)\{)`` means a ``{`` but it can *not* be immediately preceded by a ``\``

#. in the ``arguments:before`` field

   #. ``\d\h*`` means a digit (i.e. a number), followed by 0 or more horizontal spaces

   #. ``;?,?`` means *possibly* a semi-colon, and possibly a comma

   #. ``\<.*?\>`` is designed for ’beamer’-type commands; the ``.*?`` means anything in between ``<...>``

#. the ``modifyLineBreaks`` field refers to fine tuning settings detailed in :numref:`sec:modifylinebreaks`. In particular:

   #. ``betterFullStop`` is in relation to the one sentence per line routine, detailed in :numref:`sec:onesentenceperline`

   #. ``doubleBackSlash`` is in relation to the ``DBSStartsOnOwnLine`` and ``DBSFinishesWithLineBreak`` polyswitches surrounding double backslashes, see :numref:`subsec:dbs`

   #. ``comma`` is in relation to the ``CommaStartsOnOwnLine`` and ``CommaFinishesWithLineBreak`` polyswitches surrounding commas in optional and mandatory arguments; see :numref:`tab:poly-switch-mapping`

It is not obvious from :numref:`lst:fineTuning`, but each of the ``follow``, ``before`` and ``between`` fields allow trailing comments, line breaks, and horizontal spaces between each character.

.. index:: warning;capture groups

.. warning::	
	
	For the ``fineTuning`` feature you should only ever use *non*-capturing groups, such as ``(?:...)`` and *not* capturing groups, which are ``(...)``
	 

.. proof:example::	
	
	As a demonstration, consider the file given in :numref:`lst:finetuning1`, together with its default output using the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning1.tex 
	
	is given in :numref:`lst:finetuning1-default`.
	
	.. literalinclude:: demonstrations/finetuning1.tex
	 	:class: .tex
	 	:caption: ``finetuning1.tex`` 
	 	:name: lst:finetuning1
	
	.. literalinclude:: demonstrations/finetuning1-default.tex
	 	:class: .tex
	 	:caption: ``finetuning1.tex`` default 
	 	:name: lst:finetuning1-default
	
	It’s clear from :numref:`lst:finetuning1-default` that the indentation scheme has not worked as expected. We can *fine tune* the indentation scheme by employing the settings given in :numref:`lst:fine-tuning1` and running the command
	
	.. index:: switches;-l demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning1.tex -l=fine-tuning1.yaml
	
	and the associated (desired) output is given in :numref:`lst:finetuning1-mod1`.
	
	.. index:: regular expressions;at least one +
	
	.. literalinclude:: demonstrations/finetuning1-mod1.tex
	 	:class: .tex
	 	:caption: ``finetuning1.tex`` using :numref:`lst:fine-tuning1` 
	 	:name: lst:finetuning1-mod1
	
	.. literalinclude:: demonstrations/fine-tuning1.yaml
	 	:class: .baseyaml
	 	:caption: ``finetuning1.yaml`` 
	 	:name: lst:fine-tuning1
	
	
	 

.. proof:example::	
	
	Let’s have another demonstration; consider the file given in :numref:`lst:finetuning2`, together with its default output using the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning2.tex 
	
	is given in :numref:`lst:finetuning2-default`.
	
	.. literalinclude:: demonstrations/finetuning2.tex
	 	:class: .tex
	 	:caption: ``finetuning2.tex`` 
	 	:name: lst:finetuning2
	
	.. literalinclude:: demonstrations/finetuning2-default.tex
	 	:class: .tex
	 	:caption: ``finetuning2.tex`` default 
	 	:name: lst:finetuning2-default
	
	It’s clear from :numref:`lst:finetuning2-default` that the indentation scheme has not worked as expected. We can *fine tune* the indentation scheme by employing the settings given in :numref:`lst:fine-tuning2` and running the command
	
	.. index:: switches;-l demonstration
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning2.tex -l=fine-tuning2.yaml
	
	and the associated (desired) output is given in :numref:`lst:finetuning2-mod1`.
	
	.. literalinclude:: demonstrations/finetuning2-mod1.tex
	 	:class: .tex
	 	:caption: ``finetuning2.tex`` using :numref:`lst:fine-tuning2` 
	 	:name: lst:finetuning2-mod1
	
	.. literalinclude:: demonstrations/fine-tuning2.yaml
	 	:class: .baseyaml
	 	:caption: ``finetuning2.yaml`` 
	 	:name: lst:fine-tuning2
	
	In particular, note that the settings in :numref:`lst:fine-tuning2` specify that ``NamedGroupingBracesBrackets`` and ``UnNamedGroupingBracesBrackets`` can follow ``"`` and that we allow ``---`` between arguments.
	 

.. proof:example::	
	
	You can tweak the ``fineTuning`` using the ``-y`` switch, but to be sure to use quotes appropriately. For example, starting with the code in :numref:`lst:finetuning3` and running the following command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -y='modifyLineBreaks:oneSentencePerLine:manipulateSentences: 1, modifyLineBreaks:oneSentencePerLine:sentencesBeginWith:a-z: 1, fineTuning:modifyLineBreaks:betterFullStop: "(?:\.|;|:(?![a-z]))|(?:(?<!(?:(?:e\.g)|(?:i\.e)|(?:etc))))\.(?!(?:[a-z]|[A-Z]|\-|~|\,|[0-9]))"' issue-243.tex -o=+-mod1
	
	gives the output shown in :numref:`lst:finetuning3-mod1`.
	
	.. literalinclude:: demonstrations/finetuning3.tex
	 	:class: .tex
	 	:caption: ``finetuning3.tex`` 
	 	:name: lst:finetuning3
	
	.. literalinclude:: demonstrations/finetuning3-mod1.tex
	 	:class: .tex
	 	:caption: ``finetuning3.tex`` using -y switch 
	 	:name: lst:finetuning3-mod1
	
	
	 

.. proof:example::	
	
	We can tweak the ``fineTuning`` for how trailing comments are classified. For motivation, let’s consider the code given in :numref:`lst:finetuning4`
	
	.. literalinclude:: demonstrations/finetuning4.tex
	 	:class: .tex
	 	:caption: ``finetuning4.tex`` 
	 	:name: lst:finetuning4
	
	We will compare the settings given in :numref:`lst:href1` and :numref:`lst:href2`.
	
	.. literalinclude:: demonstrations/href1.yaml
	 	:class: .mlbyaml
	 	:caption: ``href1.yaml`` 
	 	:name: lst:href1
	
	.. literalinclude:: demonstrations/href2.yaml
	 	:class: .mlbyaml
	 	:caption: ``href2.yaml`` 
	 	:name: lst:href2
	
	Upon running the following commands
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m finetuning4.tex -o=+-mod1 -l=href1
	   latexindent.pl -m finetuning4.tex -o=+-mod2 -l=href2
	
	we receive the respective output in :numref:`lst:finetuning4-mod1` and :numref:`lst:finetuning4-mod2`.
	
	.. literalinclude:: demonstrations/finetuning4-mod1.tex
	 	:class: .tex
	 	:caption: ``finetuning4.tex`` using :numref:`lst:href1` 
	 	:name: lst:finetuning4-mod1
	
	.. literalinclude:: demonstrations/finetuning4-mod2.tex
	 	:class: .tex
	 	:caption: ``finetuning4.tex`` using :numref:`lst:href2` 
	 	:name: lst:finetuning4-mod2
	
	We note that in:
	
	-  :numref:`lst:finetuning4-mod1` the trailing comments are assumed to be everything following the first comment symbol, which has meant that everything following it has been moved to the end of the line; this is undesirable, clearly!
	
	-  :numref:`lst:finetuning4-mod2` has fine-tuned the trailing comment matching, and says that % cannot be immediately preceded by the words ‘Handbook’, ‘for’ or ‘Spoken’, which means that none of the % symbols have been treated as trailing comments, and the output is desirable.
	
	
	 

.. proof:example::	
	
	Another approach to this situation, which does not use ``fineTuning``, is to use ``noIndentBlock`` which we discussed in :numref:`lst:noIndentBlock`; using the settings in :numref:`lst:href3` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m finetuning4.tex -o=+-mod3 -l=href3
	
	then we receive the same output given in :numref:`lst:finetuning4-mod2`.
	
	.. literalinclude:: demonstrations/href3.yaml
	 	:class: .mlbyaml
	 	:caption: ``href3.yaml`` 
	 	:name: lst:href3
	
	With reference to the ``body`` field in :numref:`lst:href3`, we note that the ``body`` field can be interpreted as: the fewest number of zero or more characters that are not right braces. This is an example of character class.
	
	.. index:: regular expressions;character class demonstration
	
	
	 

.. proof:example::	
	
	We can use the ``fineTuning`` field to assist in the formatting of bibliography files.
	
	.. index:: bibliography files
	
	.. index:: regular expressions;delimiterRegEx
	
	.. index:: regular expressions;capturing parenthesis
	
	.. index:: regular expressions;ampersand alignment
	
	.. index:: delimiters;delimiterRegEx
	
	Starting with the file in :numref:`lst:bib1` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl bib1.tex -o=+-mod1 
	
	gives the output in :numref:`lst:bib1-mod1`.
	
	.. literalinclude:: demonstrations/bib1.bib
	 	:class: .tex
	 	:caption: ``bib1.bib`` 
	 	:name: lst:bib1
	
	.. literalinclude:: demonstrations/bib1-mod1.bib
	 	:class: .tex
	 	:caption: ``bib1-mod1.bib`` 
	 	:name: lst:bib1-mod1
	
	Let’s assume that we would like to format the output so as to align the ``=`` symbols. Using the settings in :numref:`lst:bibsettings1` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl bib1.bib -l bibsettings1.yaml -o=+-mod2 
	
	gives the output in :numref:`lst:bib1-mod2`.
	
	.. literalinclude:: demonstrations/bib1-mod2.bib
	 	:class: .tex
	 	:caption: ``bib1.bib`` using :numref:`lst:bibsettings1` 
	 	:name: lst:bib1-mod2
	
	.. literalinclude:: demonstrations/bibsettings1.yaml
	 	:class: .baseyaml
	 	:caption: ``bibsettings1.yaml`` 
	 	:name: lst:bibsettings1
	
	Some notes about :numref:`lst:bibsettings1`:
	
	-  we have populated the ``lookForAlignDelims`` field with the ``online`` command, and have used the ``delimiterRegEx``, discussed in :numref:`sec:delimiter-reg-ex`;
	
	-  we have tweaked the ``keyEqualsValuesBracesBrackets`` code block so that it will *not* be found following a comma; this means that, in contrast to the default behaviour, the lines such as ``date={2013-05-23},`` will *not* be treated as key-equals-value braces;
	
	-  the adjustment to ``keyEqualsValuesBracesBrackets`` necessitates the associated change to the ``UnNamedGroupingBracesBrackets`` field so that they will be searched for following ``=`` symbols.
	
	
	 

.. proof:example::	
	
	We can build upon :numref:`lst:bibsettings1` for slightly more complicated bibliography files.
	
	Starting with the file in :numref:`lst:bib2` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl bib2.bib -l bibsettings1.yaml -o=+-mod1 
	
	gives the output in :numref:`lst:bib2-mod1`.
	
	.. literalinclude:: demonstrations/bib2.bib
	 	:class: .tex
	 	:caption: ``bib2.bib`` 
	 	:name: lst:bib2
	
	.. literalinclude:: demonstrations/bib2-mod1.bib
	 	:class: .tex
	 	:caption: ``bib2-mod1.bib`` 
	 	:name: lst:bib2-mod1
	
	The output in :numref:`lst:bib2-mod1` is not ideal, as the ``=`` symbol within the url field has been incorrectly used as an alignment delimiter.
	
	We address this by tweaking the ``delimiterRegEx`` field in :numref:`lst:bibsettings2`.
	
	.. literalinclude:: demonstrations/bibsettings2.yaml
	 	:class: .baseyaml
	 	:caption: ``bibsettings2.yaml`` 
	 	:name: lst:bibsettings2
	
	Upon running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl bib2.bib -l bibsettings1.yaml,bibsettings2.yaml -o=+-mod2 
	
	we receive the *desired* output in :numref:`lst:bib2-mod2`.
	
	.. literalinclude:: demonstrations/bib2-mod2.bib
	 	:class: .tex
	 	:caption: ``bib2-mod2.bib`` 
	 	:name: lst:bib2-mod2
	
	With reference to :numref:`lst:bibsettings2` we note that the ``delimiterRegEx`` has been adjusted so that ``=`` symbols are used as the delimiter, but only when they are *not preceded* by either ``v`` or ``spfreload``.
	 

.. container:: references
   :name: refs

   .. container::
      :name: ref-masteringregexp

      Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.
