.. label follows

.. _sec:finetuning:

Fine tuning
===========

``latexindent.pl`` operates by looking for the code blocks detailed in
:numref:`tab:code-blocks`. The fine tuning of the details of such code
blocks is controlled by the ``fineTuning`` field, detailed in
:numref:`lst:fineTuning`.

This field is for those that would like to peek under the bonnet/hood
and make some fine tuning to ``latexindent.pl``\ ’s operating.

.. warning::	
	
	Making changes to the fine tuning may have significant consequences for
	your indentation scheme, proceed with caution!
	 

 .. literalinclude:: ../defaultSettings.yaml
 	:class: .baseyaml
 	:caption: ``fineTuning`` 
 	:name: lst:fineTuning
 	:lines: 582-603
 	:linenos:
 	:lineno-start: 582

The fields given in :numref:`lst:fineTuning` are all *regular
expressions*. This manual is not intended to be a tutorial on regular
expressions; you might like to read, for example, Friedl (n.d.) for a
detailed covering of the topic.

We make the following comments with reference to
:numref:`lst:fineTuning`:

#. the ``environments:name`` field details that the *name* of an
   environment can contain:

   #. ``a-z`` lower case letters

   #. ``A-Z`` upper case letters

   #. ``@`` the ``@`` ’letter’

   #. ``\*`` stars

   #. ``0-9`` numbers

   #. ``_`` underscores

   #. ``\`` backslashes

   The ``+`` at the end means *at least one* of the above characters.

#. the ``ifElseFi:name`` field:

   #. ``@?`` means that it *can possibly* begin with ``@``

   #. followed by ``if``

   #. followed by 0 or more characters from ``a-z``, ``A-Z`` and ``@``

   #. the ``?`` the end means *non-greedy*, which means ‘stop the match
      as soon as possible’

#. the ``keyEqualsValuesBracesBrackets`` contains some interesting
   syntax:

   #. ``|`` means ‘or’

   #. ``(?:(?<!\\)\{)`` the ``(?:...)`` uses a *non-capturing* group –
      you don’t necessarily need to worry about what this means, but
      just know that for the ``fineTuning`` feature you should only ever
      use *non*-capturing groups, and *not* capturing groups, which are
      simply ``(...)``

   #. ``(?<!\\)\{)`` means a ``{`` but it can *not* be immediately
      preceeded by a ``\``

#. in the ``arguments:before`` field

   #. ``\d\h*`` means a digit (i.e. a number), followed by 0 or more
      horizontal spaces

   #. ``;?,?`` means *possibly* a semi-colon, and possibly a comma

   #. ``\<.*?\>`` is designed for ’beamer’-type commands; the ``.*?``
      means anything in between ``<...>``

#. the ``modifyLineBreaks`` field refers to fine tuning settings
   detailed in :numref:`sec:modifylinebreaks`. In particular:

   #. ``betterFullStop`` is in relation to the one sentence per line
      routine, detailed in :numref:`sec:onesentenceperline`

   #. ``doubleBackSlash`` is in relation to the ``DBSStartsOnOwnLine``
      and ``DBSFinishesWithLineBreak`` polyswitches surrounding double
      back slashes, see :numref:`subsec:dbs`

   #. ``comma`` is in relation to the ``CommaStartsOnOwnLine`` and
      ``CommaFinishesWithLineBreak`` polyswitches surrounding commas in
      optional and mandatory arguments; see
      :numref:`tab:poly-switch-mapping`

It is not obvious from :numref:`lst:fineTuning`, but each of the
``follow``, ``before`` and ``between`` fields allow trailing comments,
line breaks, and horizontal spaces between each character.

As a demonstration, consider the file given in
:numref:`lst:finetuning1`, together with its default output using the
command

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

It’s clear from :numref:`lst:finetuning1-default` that the indentation
scheme has not worked as expected. We can *fine tune* the indentation
scheme by employing the settings given in :numref:`lst:fine-tuning1`
and running the command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl finetuning1.tex -l=fine-tuning1.yaml

and the associated (desired) output is given in
:numref:`lst:finetuning1-mod1`.

 .. literalinclude:: demonstrations/finetuning1-mod1.tex
 	:class: .tex
 	:caption: ``finetuning1.tex`` using :numref:`lst:fine-tuning1` 
 	:name: lst:finetuning1-mod1

 .. literalinclude:: demonstrations/fine-tuning1.yaml
 	:class: .baseyaml
 	:caption: ``finetuning1.yaml`` 
 	:name: lst:fine-tuning1

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-masteringregexp">

Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.

.. raw:: html

   </div>

.. raw:: html

   </div>
