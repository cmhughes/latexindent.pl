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
	:lines: 447-522
	:linenos:
	:lineno-start: 447

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
	
	We can use the ``fineTuning`` settings to tweak how ``latexindent.pl`` finds trailing comments. We begin with the file in :numref:`lst:finetuning5`
	
	.. literalinclude:: demonstrations/finetuning5.tex
		:class: .tex
		:caption: ``finetuning5.tex`` 
		:name: lst:finetuning5
	
	Using the settings in :numref:`lst:fine-tuning3` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning5.tex -l=fine-tuning3.yaml
	
	gives the output in :numref:`lst:finetuning5-mod1`.
	
	.. literalinclude:: demonstrations/finetuning5-mod1.tex
		:class: .tex
		:caption: ``finetuning5-mod1.tex`` 
		:name: lst:finetuning5-mod1
	
	.. literalinclude:: demonstrations/fine-tuning3.yaml
		:class: .baseyaml
		:caption: ``fine-tuning3.yaml`` 
		:name: lst:fine-tuning3
	
	The settings in :numref:`lst:fine-tuning3` detail that trailing comments can *not* be followed by a single space, and then the text ‘end’. This means that the ``specialBeginEnd`` routine will be able to find the pattern ``% end`` as the ``end`` part. The trailing comments ``123`` and ``456`` are still treated as trailing comments.


.. proof:example::	
	
	We can use the ``fineTuning`` settings to tweak how ``latexindent.pl`` finds environments.
	
	We begin with the file in :numref:`lst:finetuning6`.
	
	.. literalinclude:: demonstrations/finetuning6.tex
		:class: .tex
		:caption: ``finetuning6.tex`` 
		:name: lst:finetuning6
	
	Using the settings in :numref:`lst:fine-tuning4` and running the command
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl finetuning6.tex -m -l=fine-tuning4.yaml
	
	gives the output in :numref:`lst:finetuning6-mod1`.
	
	.. literalinclude:: demonstrations/finetuning6-mod1.tex
		:class: .tex
		:caption: ``finetuning6-mod1.tex`` 
		:name: lst:finetuning6-mod1
	
	.. literalinclude:: demonstrations/fine-tuning4.yaml
		:class: .mlbyaml
		:caption: ``fine-tuning4.yaml`` 
		:name: lst:fine-tuning4
	
	By using the settings in :numref:`lst:fine-tuning4` it means that the default poly-switch location of ``BodyStartsOnOwnLine`` for environments (denoted ♥ in :numref:`tab:poly-switch-mapping`) has been overwritten so that it is *after* the ``label`` command.
	
	Referencing :numref:`lst:fine-tuning4`, unless both ``begin`` and ``end`` are specified, then the default value of ``name`` will be used.


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
	


.. container:: references hanging-indent
   :name: refs

   .. container::
      :name: ref-masteringregexp

      Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.
