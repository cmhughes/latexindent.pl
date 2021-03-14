.. label follows

.. _sec:replacements:

The -r, -rv and -rr switches
============================

You can instruct ``latexindent.pl`` to perform replacements/substitutions on your file by using any
of the ``-r``, ``-rv`` or ``-rr`` switches:

:index:`verbatim;rv, replacementrespectverb switch`

-  the ``-r`` switch will perform indentation and replacements, not respecting verbatim code blocks;

-  the ``-rv`` switch will perform indentation and replacements, and *will* respect verbatim code
   blocks;

-  the ``-rr`` switch will *not* perform indentation, and will perform replacements not respecting
   verbatim code blocks.

We will demonstrate each of the ``-r``, ``-rv`` and ``-rr`` switches, but a summary is given in
:numref:`tab:replacementswitches`.

.. label follows

.. _tab:replacementswitches:

.. table::  The replacement mode switches

	
	
	+-----------+----------------+---------------------+
	| switch    | indentation?   | respect verbatim?   |
	+===========+================+=====================+
	| ``-r``    | yes            | no                  |
	+-----------+----------------+---------------------+
	| ``-rv``   | yes            | yes                 |
	+-----------+----------------+---------------------+
	| ``-rr``   | no             | no                  |
	+-----------+----------------+---------------------+
	


The default value of the ``replacements`` field is shown in :numref:`lst:replacements`; as with
all of the other fields, you are encouraged to customise and change this as you see fit. The options
in this field will *only* be considered if the ``-r``, ``-rv`` or ``-rr`` switches are active; when
discussing YAML settings related to the replacement-mode switches, we will use the style given in
:numref:`lst:replacements`.

 .. literalinclude:: ../defaultSettings.yaml
 	:class: .replaceyaml
 	:caption: ``replacements`` 
 	:name: lst:replacements
 	:lines: 602-610
 	:linenos:
 	:lineno-start: 602

The first entry within the ``replacements`` field is ``amalgamate``, and is *optional*; by default
it is set to 1, so that replacements will be amalgamated from each settings file that you specify.
As you’ll see in the demonstrations that follow, there is no need to specify this field.

You’ll notice that, by default, there is only *one* entry in the ``replacements`` field, but it can
take as many entries as you would like; each one needs to begin with a ``-`` on its own line.

Introduction to replacements
----------------------------

Let’s explore the action of the default settings, and then we’ll demonstrate the feature with
further examples. With reference to :numref:`lst:replacements`, the default action will replace
every instance of the text ``latexindent.pl`` with ``pl.latexindent``.

Beginning with the code in :numref:`lst:replace1` and running the command

:index:`switches;-r demonstration`

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r replace1.tex

gives the output given in :numref:`lst:replace1-r1`.

 .. literalinclude:: demonstrations/replace1.tex
 	:class: .tex
 	:caption: ``replace1.tex`` 
 	:name: lst:replace1

 .. literalinclude:: demonstrations/replace1-r1.tex
 	:class: .tex
 	:caption: ``replace1.tex`` default 
 	:name: lst:replace1-r1

If we don’t wish to perform this replacement, then we can tweak the default settings of
:numref:`lst:replacements` by changing ``lookForThis`` to 0; we perform this action in
:numref:`lst:replace1-yaml`, and run the command

:index:`switches;-l demonstration`

:index:`switches;-r demonstration`

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r replace1.tex -l=replace1.yaml

which gives the output in :numref:`lst:replace1-mod1`.

 .. literalinclude:: demonstrations/replace1-mod1.tex
 	:class: .tex
 	:caption: ``replace1.tex`` using :numref:`lst:replace1-yaml` 
 	:name: lst:replace1-mod1

 .. literalinclude:: demonstrations/replace1.yaml
 	:class: .replaceyaml
 	:caption: ``replace1.yaml`` 
 	:name: lst:replace1-yaml

Note that in :numref:`lst:replace1-yaml` we have specified ``amalgamate`` as 0 so that the default
replacements are overwritten.

We haven’t yet discussed the ``when`` field; don’t worry, we’ll get to it as part of the discussion
in what follows.

The two types of replacements
-----------------------------

There are two types of replacements:

#. *string*-based replacements, which replace the string in *this* with the string in *that*. If you
   specify ``this`` and you do not specify ``that``, then the ``that`` field will be assumed to be
   empty.

   :index:`regular expressions;replacement switch, -r`

#. *regex*-based replacements, which use the ``substitution`` field.

We will demonstrate both in the examples that follow.

``latexindent.pl`` chooses which type of replacement to make based on which fields have been
specified; if the ``this`` field is specified, then it will make *string*-based replacements,
regardless of if ``substitution`` is present or not.

Examples of replacements
------------------------

.. proof:example::	
	
	We begin with code given in :numref:`lst:colsep`
	
	 .. literalinclude:: demonstrations/colsep.tex
	 	:class: .tex
	 	:caption: ``colsep.tex`` 
	 	:name: lst:colsep
	
	Let’s assume that our goal is to remove both of the ``arraycolsep`` statements; we can achieve this
	in a few different ways.
	
	Using the YAML in :numref:`lst:colsep-yaml`, and running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r colsep.tex -l=colsep.yaml
	
	then we achieve the output in :numref:`lst:colsep-mod0`.
	
	 .. literalinclude:: demonstrations/colsep-mod0.tex
	 	:class: .tex
	 	:caption: ``colsep.tex`` using :numref:`lst:colsep` 
	 	:name: lst:colsep-mod0
	
	 .. literalinclude:: demonstrations/colsep.yaml
	 	:class: .replaceyaml
	 	:caption: ``colsep.yaml`` 
	 	:name: lst:colsep-yaml
	
	Note that in :numref:`lst:colsep-yaml`, we have specified *two* separate fields, each with their
	own ‘*this*’ field; furthermore, for both of the separate fields, we have not specified ‘``that``’,
	so the ``that`` field is assumed to be blank by ``latexindent.pl``;
	
	We can make the YAML in :numref:`lst:colsep-yaml` more concise by exploring the ``substitution``
	field. Using the settings in :numref:`lst:colsep1` and running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r colsep.tex -l=colsep1.yaml
	
	then we achieve the output in :numref:`lst:colsep-mod1`.
	
	:index:`regular expressions;substitution field, arraycolsep`
	
	:index:`regular expressions;at least one +`
	
	 .. literalinclude:: demonstrations/colsep-mod1.tex
	 	:class: .tex
	 	:caption: ``colsep.tex`` using :numref:`lst:colsep1` 
	 	:name: lst:colsep-mod1
	
	 .. literalinclude:: demonstrations/colsep1.yaml
	 	:class: .replaceyaml
	 	:caption: ``colsep1.yaml`` 
	 	:name: lst:colsep1
	
	The code given in :numref:`lst:colsep1` is an example of a *regular expression*, which we may
	abbreviate to *regex* in what follows. This manual is not intended to be a tutorial on regular
	expressions; you might like to read, for example, (Friedl, n.d.) for a detailed covering of the
	topic. With reference to :numref:`lst:colsep1`, we do note the following:
	
	-  the general form of the ``substitution`` field is ``s/regex/replacement/modifiers``. You can
	   place any regular expression you like within this;
	
	-  we have ‘escaped’ the backslash by using ``\\``
	
	-  we have used ``\d+`` to represent *at least* one digit
	
	-  the ``s`` *modifier* (in the ``sg`` at the end of the line) instructs ``latexindent.pl`` to treat
	   your file as one single line;
	
	-  the ``g`` *modifier* (in the ``sg`` at the end of the line) instructs ``latexindent.pl`` to make
	   the substitution *globally* throughout your file; you might try removing the ``g`` modifier from
	   :numref:`lst:colsep1` and observing the difference in output.
	
	You might like to see https://perldoc.perl.org/perlre.html#Modifiers for details of modifiers; in
	general, I recommend starting with the ``sg`` modifiers for this feature.
	 

.. proof:example::	
	
	We’ll keep working with the file in :numref:`lst:colsep` for this example.
	
	Using the YAML in :numref:`lst:multi-line`, and running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r colsep.tex -l=multi-line.yaml
	
	then we achieve the output in :numref:`lst:colsep-mod2`.
	
	 .. literalinclude:: demonstrations/colsep-mod2.tex
	 	:class: .tex
	 	:caption: ``colsep.tex`` using :numref:`lst:multi-line` 
	 	:name: lst:colsep-mod2
	
	 .. literalinclude:: demonstrations/multi-line.yaml
	 	:class: .replaceyaml
	 	:caption: ``multi-line.yaml`` 
	 	:name: lst:multi-line
	
	With reference to :numref:`lst:multi-line`, we have specified a *multi-line* version of ``this``
	by employing the *literal* YAML style ``|-``. See, for example,
	https://stackoverflow.com/questions/3790454/in-yaml-how-do-i-break-a-string-over-multiple-lines for
	further options, all of which can be used in your YAML file.
	
	This is a natural point to explore the ``when`` field, specified in :numref:`lst:replacements`.
	This field can take two values: *before* and *after*, which respectively instruct ``latexindent.pl``
	to perform the replacements *before* indentation or *after* it. The default value is ``before``.
	
	Using the YAML in :numref:`lst:multi-line1`, and running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r colsep.tex -l=multi-line1.yaml
	
	then we achieve the output in :numref:`lst:colsep-mod3`.
	
	 .. literalinclude:: demonstrations/colsep-mod3.tex
	 	:class: .tex
	 	:caption: ``colsep.tex`` using :numref:`lst:multi-line1` 
	 	:name: lst:colsep-mod3
	
	 .. literalinclude:: demonstrations/multi-line1.yaml
	 	:class: .replaceyaml
	 	:caption: ``multi-line1.yaml`` 
	 	:name: lst:multi-line1
	
	We note that, because we have specified ``when: after``, that ``latexindent.pl`` has not found the
	string specified in :numref:`lst:multi-line1` within the file in :numref:`lst:colsep`. As it has
	looked for the string within :numref:`lst:multi-line1` *after* the indentation has been performed.
	After indentation, the string as written in :numref:`lst:multi-line1` is no longer part of the
	file, and has therefore not been replaced.
	
	As a final note on this example, if you use the ``-rr`` switch, as follows,
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-rr demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -rr colsep.tex -l=multi-line1.yaml
	
	then the ``when`` field is ignored, no indentation is done, and the output is as in
	:numref:`lst:colsep-mod2`.
	 

.. proof:example::	
	
	An important part of the substitution routine is in *capture groups*.
	
	Assuming that we start with the code in :numref:`lst:displaymath`, let’s assume that our goal is
	to replace each occurrence of ``$$...$$`` with ``\begin{equation*}...\end{equation*}``. This example
	is partly motivated by `tex stackexchange question
	242150 <https://tex.stackexchange.com/questions/242150/good-looking-latex-code>`__.
	
	 .. literalinclude:: demonstrations/displaymath.tex
	 	:class: .tex
	 	:caption: ``displaymath.tex`` 
	 	:name: lst:displaymath
	
	We use the settings in :numref:`lst:displaymath1` and run the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r displaymath.tex -l=displaymath1.yaml
	
	to receive the output given in :numref:`lst:displaymath-mod1`.
	
	:index:`regular expressions;substitution field, equation`
	
	 .. literalinclude:: demonstrations/displaymath-mod1.tex
	 	:class: .tex
	 	:caption: ``displaymath.tex`` using :numref:`lst:displaymath1` 
	 	:name: lst:displaymath-mod1
	
	 .. literalinclude:: demonstrations/displaymath1.yaml
	 	:class: .replaceyaml
	 	:caption: ``displaymath1.yaml`` 
	 	:name: lst:displaymath1
	
	A few notes about :numref:`lst:displaymath1`:
	
	#. we have used the ``x`` modifier, which allows us to have white space within the regex;
	
	#. we have used a capture group, ``(.*?)`` which captures the content between the ``$$...$$`` into
	   the special variable, ``$1``;
	
	#. we have used the content of the capture group, ``$1``, in the replacement text.
	
	See https://perldoc.perl.org/perlre.html#Capture-groups for a discussion of capture groups.
	
	The features of the replacement switches can, of course, be combined with others from the toolkit of
	``latexindent.pl``. For example, we can combine the poly-switches of :numref:`sec:poly-switches`,
	which we do in :numref:`lst:equation`; upon running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-m demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r -m displaymath.tex -l=displaymath1.yaml,equation.yaml
	
	then we receive the output in :numref:`lst:displaymath-mod2`.
	
	 .. literalinclude:: demonstrations/displaymath-mod2.tex
	 	:class: .tex
	 	:caption: ``displaymath.tex`` using :numref:`lst:displaymath1` and :numref:`lst:equation` 
	 	:name: lst:displaymath-mod2
	
	 .. literalinclude:: demonstrations/equation.yaml
	 	:class: .mlbyaml
	 	:caption: ``equation.yaml`` 
	 	:name: lst:equation
	
	
	 

.. proof:example::	
	
	This example is motivated by `tex stackexchange question
	490086 <https://tex.stackexchange.com/questions/490086/bring-several-lines-together-to-fill-blank-spaces-in-texmaker>`__.
	We begin with the code in :numref:`lst:phrase`.
	
	 .. literalinclude:: demonstrations/phrase.tex
	 	:class: .tex
	 	:caption: ``phrase.tex`` 
	 	:name: lst:phrase
	
	Our goal is to make the spacing uniform between the phrases. To achieve this, we employ the settings
	in :numref:`lst:hspace`, and run the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r phrase.tex -l=hspace.yaml
	
	which gives the output in :numref:`lst:phrase-mod1`.
	
	:index:`regular expressions;at least one +`
	
	 .. literalinclude:: demonstrations/phrase-mod1.tex
	 	:class: .tex
	 	:caption: ``phrase.tex`` using :numref:`lst:hspace` 
	 	:name: lst:phrase-mod1
	
	 .. literalinclude:: demonstrations/hspace.yaml
	 	:class: .replaceyaml
	 	:caption: ``hspace.yaml`` 
	 	:name: lst:hspace
	
	The ``\h+`` setting in :numref:`lst:hspace` say to replace *at least one horizontal space* with a
	single space.
	 

.. proof:example::	
	
	We begin with the code in :numref:`lst:references`.
	
	 .. literalinclude:: demonstrations/references.tex
	 	:class: .tex
	 	:caption: ``references.tex`` 
	 	:name: lst:references
	
	Our goal is to change each reference so that both the text and the reference are contained within
	one hyperlink. We achieve this by employing :numref:`lst:reference` and running the command
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r references.tex -l=reference.yaml
	
	which gives the output in :numref:`lst:references-mod1`.
	
	 .. literalinclude:: demonstrations/references-mod1.tex
	 	:class: .tex
	 	:caption: ``references.tex`` using :numref:`lst:reference` 
	 	:name: lst:references-mod1
	
	 .. literalinclude:: demonstrations/reference.yaml
	 	:class: .replaceyaml
	 	:caption: ``reference.yaml`` 
	 	:name: lst:reference
	
	Referencing :numref:`lst:reference`, the ``|`` means *or*, we have used *capture groups*, together
	with an example of an *optional* pattern, ``(?:eq)?``.
	 

.. proof:example::	
	
	Let’s explore the three replacement mode switches (see :numref:`tab:replacementswitches`) in the
	context of an example that contains a verbatim code block, :numref:`lst:verb1`; we will use the
	settings in :numref:`lst:verbatim1-yaml`.
	
	 .. literalinclude:: demonstrations/verb1.tex
	 	:class: .tex
	 	:caption: ``verb1.tex`` 
	 	:name: lst:verb1
	
	 .. literalinclude:: demonstrations/verbatim1.yaml
	 	:class: .replaceyaml
	 	:caption: ``verbatim1.yaml`` 
	 	:name: lst:verbatim1-yaml
	
	Upon running the following commands,
	
	:index:`verbatim;comparison with -r and -rr switches`
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-o demonstration`
	
	:index:`switches;-r demonstration`
	
	:index:`switches;-rv demonstration`
	
	:index:`switches;-rr demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r verb1.tex -l=verbatim1.yaml -o=+mod1
	    latexindent.pl -rv verb1.tex -l=verbatim1.yaml -o=+-rv-mod1
	    latexindent.pl -rr verb1.tex -l=verbatim1.yaml -o=+-rr-mod1
	
	we receive the respective output in :numref:`lst:verb1-mod1` – :numref:`lst:verb1-rr-mod1`
	
	 .. literalinclude:: demonstrations/verb1-mod1.tex
	 	:class: .tex
	 	:caption: ``verb1-mod1.tex`` 
	 	:name: lst:verb1-mod1
	
	 .. literalinclude:: demonstrations/verb1-rv-mod1.tex
	 	:class: .tex
	 	:caption: ``verb1-rv-mod1.tex`` 
	 	:name: lst:verb1-rv-mod1
	
	 .. literalinclude:: demonstrations/verb1-rr-mod1.tex
	 	:class: .tex
	 	:caption: ``verb1-rr-mod1.tex`` 
	 	:name: lst:verb1-rr-mod1
	
	
	 

We note that:

#. in :numref:`lst:verb1-mod1` indentation has been performed, and that the replacements specified
   in :numref:`lst:verbatim1-yaml` have been performed, even within the verbatim code block;

#. in :numref:`lst:verb1-rv-mod1` indentation has been performed, but that the replacements have
   *not* been performed within the verbatim environment, because the ``rv`` switch is active;

#. in :numref:`lst:verb1-rr-mod1` indentation has *not* been performed, but that replacements have
   been performed, not respecting the verbatim code block.

See the summary within :numref:`tab:replacementswitches`.

.. proof:example::	
	
	Let’s explore the ``amalgamate`` field from :numref:`lst:replacements` in the context of the file
	specified in :numref:`lst:amalg1`.
	
	 .. literalinclude:: demonstrations/amalg1.tex
	 	:class: .tex
	 	:caption: ``amalg1.tex`` 
	 	:name: lst:amalg1
	
	Let’s consider the YAML files given in :numref:`lst:amalg1-yaml` – :numref:`lst:amalg3-yaml`.
	
	 .. literalinclude:: demonstrations/amalg1-yaml.yaml
	 	:class: .replaceyaml
	 	:caption: ``amalg1-yaml.yaml`` 
	 	:name: lst:amalg1-yaml
	
	 .. literalinclude:: demonstrations/amalg2-yaml.yaml
	 	:class: .replaceyaml
	 	:caption: ``amalg2-yaml.yaml`` 
	 	:name: lst:amalg2-yaml
	
	 .. literalinclude:: demonstrations/amalg3-yaml.yaml
	 	:class: .replaceyaml
	 	:caption: ``amalg3-yaml.yaml`` 
	 	:name: lst:amalg3-yaml
	
	Upon running the following commands,
	
	:index:`switches;-l demonstration`
	
	:index:`switches;-r demonstration`
	
	.. code-block:: latex
	   :class: .commandshell
	
	    latexindent.pl -r amalg1.tex -l=amalg1-yaml
	    latexindent.pl -r amalg1.tex -l=amalg1-yaml,amalg2-yaml
	    latexindent.pl -r amalg1.tex -l=amalg1-yaml,amalg2-yaml,amalg3-yaml
	
	we receive the respective output in :numref:`lst:amalg1-mod1` – :numref:`lst:amalg1-mod123`.
	
	 .. literalinclude:: demonstrations/amalg1-mod1.tex
	 	:class: .tex
	 	:caption: ``amalg1.tex`` using :numref:`lst:amalg1-yaml` 
	 	:name: lst:amalg1-mod1
	
	 .. literalinclude:: demonstrations/amalg1-mod12.tex
	 	:class: .tex
	 	:caption: ``amalg1.tex`` using :numref:`lst:amalg1-yaml` and :numref:`lst:amalg2-yaml` 
	 	:name: lst:amalg1-mod12
	
	 .. literalinclude:: demonstrations/amalg1-mod123.tex
	 	:class: .tex
	 	:caption: ``amalg1.tex`` using :numref:`lst:amalg1-yaml` and :numref:`lst:amalg2-yaml` and :numref:`lst:amalg3-yaml` 
	 	:name: lst:amalg1-mod123
	
	We note that:
	
	#. in :numref:`lst:amalg1-mod1` the replacements from :numref:`lst:amalg1-yaml` have been used;
	
	#. in :numref:`lst:amalg1-mod12` the replacements from :numref:`lst:amalg1-yaml` and
	   :numref:`lst:amalg2-yaml` have *both* been used, because the default value of ``amalgamate`` is
	   1;
	
	#. in :numref:`lst:amalg1-mod123` *only* the replacements from :numref:`lst:amalg3-yaml` have
	   been used, because the value of ``amalgamate`` has been set to 0.
	
	
	 

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-masteringregexp">

Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.

.. raw:: html

   </div>

.. raw:: html

   </div>
