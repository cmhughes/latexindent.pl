.. label follows

.. _sec:replacements:

The -r and -rr switches
=======================

You can instruct ``latexindent.pl`` to perform
replacements/substitutions on your file by using either the ``-r`` or
``-rr`` switches; the only difference between the two switches is that
the ``-rr`` instructs ``latexindent.pl`` to skip all of the other
indentation operations.

The default value of the ``replacements`` field is shown in
:numref:`lst:replacements`; as with all of the other fields, you are
encouraged to customise and change this as you see fit. The options in
this field will *only* be considered if either the ``-r`` or ``-rr``
switch are active; when discussing YAML settings related to either of
the replacement-mode switches, we will use the style given in
:numref:`lst:replacements`.

 .. literalinclude:: ../defaultSettings.yaml
 	:class: .replaceyaml
 	:caption: ``replacements`` 
 	:name: lst:replacements
 	:lines: 571-577
 	:linenos:
 	:lineno-start: 571

You’ll notice that, by default, there is only *one* entry in the
``replacements`` field, but it can take as many entries as you would
like; each one needs to begin with a ``-`` on its own line.

Introduction to replacements
----------------------------

Let’s explore the action of the default settings, and then we’ll
demonstrate the feature with further examples. with reference to
:numref:`lst:replacements`, the default action will replace every
instance of the text ``latexindent.pl`` with ``pl.latexindent``.

Beginning with the code in :numref:`lst:replace1` and running the
command

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

If we don’t wish to perform this replacement, then we can tweak the
default settings of :numref:`lst:replacements` by changing
``lookForThis`` to 0; we perform this action in
:numref:`lst:replace1-yaml`, and run the command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r replace1.tex -l=replace1.yaml

which gives the output in :numref:`lst:replace1-mod1`.

 .. literalinclude:: demonstrations/replace1-mod1.tex
 	:class: .tex
 	:caption: ``replace1.tex`` using :numref:`lst:replace1` 
 	:name: lst:replace1-mod1

 .. literalinclude:: demonstrations/replace1.yaml
 	:class: .replaceyaml
 	:caption: ``replace1.yaml`` 
 	:name: lst:replace1-yaml

We haven’t yet discussed the ``when`` field; don’t worry, we’ll get to
it as part of the discussion in what follows.

The two types of replacements
-----------------------------

There are two types of replacements:

#. *string*-based replacements, which replace the string in *this* with
   the string in *that*. If you specify ``this`` and you do not specify
   ``that``, then the ``that`` field will be assumed to be empty.

#. *regex*-based replacements, which use the ``substitution`` field.

We will demonstrate both in the examples that follow.

``latexindent.pl`` chooses which type of replacement to make based on
which fields have been specified; if the ``this`` field is specified,
then it will make *string*-based replacements, regardless of if
``substitution`` is present or not.

Examples of replacements
------------------------

We begin with code given in :numref:`lst:colsep`

 .. literalinclude:: demonstrations/colsep.tex
 	:class: .tex
 	:caption: ``colsep.tex`` 
 	:name: lst:colsep

Let’s assume that our goal is to remove both of the ``arraycolsep``
statements; we can achieve this in a few different ways.

Using the YAML in :numref:`lst:colsep-yaml`, and running the command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r colsep.tex -l=colsep.yaml

then we achieve the output in :numref:`lst:colsep-mod0`.

 .. literalinclude:: demonstrations/colsep-mod0.tex
 	:class: .tex
 	:caption: ``colsep.tex`` using :numref:`lst:colsep-yaml` 
 	:name: lst:colsep-mod0

 .. literalinclude:: demonstrations/colsep.yaml
 	:class: .replaceyaml
 	:caption: ``colsep.yaml`` 
 	:name: lst:colsep-yaml

Note that in :numref:`lst:colsep`, we have specified *two* separate
fields, each with their own ‘*this*’ field; furthermore, for both of the
separate fields, we have not specified ‘``that``’, so the ``that`` field
is assumed to be blank by ``latexindent.pl``;

We can make the YAML in :numref:`lst:colsep` more consise by exploring
the ``substitution`` field. Using the settings in
:numref:`lst:colsep1` and running the command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r colsep.tex -l=colsep1.yaml

then we achieve the output in :numref:`lst:colsep-mod1`.

]

 .. literalinclude:: demonstrations/colsep-mod1.tex
 	:class: .tex
 	:caption: ``colsep.tex`` using :numref:`lst:colsep1` 
 	:name: lst:colsep-mod1

 .. literalinclude:: demonstrations/colsep1.yaml
 	:class: .replaceyaml
 	:caption: ``colsep1.yaml`` 
 	:name: lst:colsep1

The code given in :numref:`lst:colsep1` is an example of a *regular
expression*. This manual is not intended to be a tutorial on regular
expressions; you might like to read, for example, Friedl (n.d.) for a
detailed covering of the topic. With reference to
:numref:`lst:colsep1`, we do note the following:

-  the general form of the ``substitution`` field is
   ``s/regex/replacement/modifiers``. You can place any regular
   expression you like within this;

-  we have ‘escaped’ the backslash by using ``\\``

-  we have used ``\d+`` to represent *at least* one digit

-  the ``s`` *modifier* (in the ``sg`` at the end of the line) instructs
   ``latexindent.pl`` to treat your file as one single line;

-  the ``g`` *modifier* (in the ``sg`` at the end of the line) instructs
   ``latexindent.pl`` to make the substitution *globally* throughout
   your file; you might try removing the ``g`` modifier from
   :numref:`lst:colsep1` and observing the difference in output.

You might like to see https://perldoc.perl.org/perlre.html#Modifiers for
details of modifiers; in general, I recommend starting with the ``sg``
modifiers for this feature.

We’ll keep working with the file in :numref:`lst:colsep` for this
example.

Using the YAML in :numref:`lst:multi-line`, and running the command

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

With reference to :numref:`lst:multi-line`, we have specified a
*multi-line* version of ``this`` by employing the *literal* style
``|-``. See, for example,
https://stackoverflow.com/questions/3790454/in-yaml-how-do-i-break-a-string-over-multiple-lines
for further options, all of which can be used in your YAML file.

This is a natural point to explore the ``when`` field, specified in
:numref:`lst:replacements`. This field can take two values: *before*
and *after*, which respectively instruct ``latexindent.pl`` to perform
the replacements *before* indentation or *after* it. The default value
is ``before``.

Using the YAML in :numref:`lst:multi-line1`, and running the command

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

We note that, because we have specified ``when: after``, that
``latexindent.pl`` has not found the string specified in
:numref:`lst:multi-line1` within the file in :numref:`lst:colsep`.
As it has looked for the string within :numref:`lst:multi-line1`
*after* the indentation has been performed. After indentation, the
string as written in :numref:`lst:multi-line1` is no longer part of
the file, and has therefore not been replaced.

As a final note on this example, if you use the ``-rr`` switch, as
follows,

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -rr colsep.tex -l=multi-line1.yaml

then the ``when`` field is ignored, no indentation is done, and the
output is as in :numref:`lst:colsep-mod2`.

An important part of the substitution routine is in *capture groups*.

Assuming that we start with the code in :numref:`lst:displaymath`,
let’s assume that our goal is to replace each occurrence of ``$$...$$``
with ``\begin{equation*}...\end{equation*}``. This example is partly
motivated by `tex stackexchange question
242150 <https://tex.stackexchange.com/questions/242150/good-looking-latex-code>`__.

 .. literalinclude:: demonstrations/displaymath.tex
 	:class: .tex
 	:caption: ``displaymath.tex`` 
 	:name: lst:displaymath

We use the settings in :numref:`lst:displaymath1` and run the command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r displaymath.tex -l=displaymath1.yaml

to receive the output given in :numref:`lst:displaymath-mod1`.

 .. literalinclude:: demonstrations/displaymath-mod1.tex
 	:class: .tex
 	:caption: ``displaymath.tex`` using :numref:`lst:displaymath1` 
 	:name: lst:displaymath-mod1

 .. literalinclude:: demonstrations/displaymath1.yaml
 	:class: .replaceyaml
 	:caption: ``displaymath1.yaml`` 
 	:name: lst:displaymath1

A few notes about :numref:`lst:displaymath1`:

#. we have used the ``x`` modifier, which allows us to have white space
   within the regex;

#. we have used a capture group, ``(.*?)`` which captures the content
   between the ``$$...$$`` into the special variable, ``$1``;

#. we have used the content of the capture group, ``$1``, in the
   replacement text.

See https://perldoc.perl.org/perlre.html#Capture-groups for a discussion
of capture groups.

The features of the replacement switches can, of course, be combined
with others from the toolkit of ``latexindent.pl``. For example, we can
combine the poly-switches of :numref:`sec:poly-switches`, which we do
in :numref:`lst:equation`; upon running the command

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

This example is motivated by `tex stackexchange question
490086 <https://tex.stackexchange.com/questions/490086/bring-several-lines-together-to-fill-blank-spaces-in-texmaker>`__.
We begin with the code in :numref:`lst:phrase`.

 .. literalinclude:: demonstrations/phrase.tex
 	:class: .tex
 	:caption: ``phrase.tex`` 
 	:name: lst:phrase

Our goal is to make the spacing uniform between the phrases. To achieve
this, we emply the settings in :numref:`lst:hspace`, and run the
command

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r phrase.tex -l=hspace.yaml

which gives the output in :numref:`lst:phrase-mod1`.

 .. literalinclude:: demonstrations/phrase-mod1.tex
 	:class: .tex
 	:caption: ``phrase.tex`` using :numref:`lst:hspace` 
 	:name: lst:phrase-mod1

 .. literalinclude:: demonstrations/hspace.yaml
 	:class: .replaceyaml
 	:caption: ``hspace.yaml`` 
 	:name: lst:hspace

The ``\h+`` setting in :numref:`lst:hspace` say to replace *at least
one horizontal space* with a single space.

We begin with the code in :numref:`lst:references`.

 .. literalinclude:: demonstrations/references.tex
 	:class: .tex
 	:caption: ``references.tex`` 
 	:name: lst:references

Our goal is to change each reference so that both the text and the
reference are contained within one hyperlink. We achieve this by
employing :numref:`lst:reference` and running the command

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

Referencing :numref:`lst:reference`, the ``|`` means *or*, we have
used *capture groups*, together with an example of an *optional*
pattern, ``(?:eq)?``.

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-masteringregexp">

Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.

.. raw:: html

   </div>

.. raw:: html

   </div>
