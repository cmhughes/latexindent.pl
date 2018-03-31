.. label follows

.. _sec:modifylinebreaks:

The -m (modifylinebreaks) switch
================================

All features described in this section will only be relevant if the
``-m`` switch is used.

``modifylinebreaks``: *fields*

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``modifyLineBreaks`` 
 	:name: lst:modifylinebreaks
 	:lines: 391-393
 	:linenos:
 	:lineno-start: 391

As of Version 3.0, ``latexindent.pl`` has the ``-m`` switch, which
permits ``latexindent.pl`` to modify line breaks, according to the
specifications in the ``modifyLineBreaks`` field. *The settings in this
field will only be considered if the ``-m`` switch has been used*. A
snippet of the default settings of this field is shown in
:numref:`lst:modifylinebreaks`.

Having read the previous paragraph, it should sound reasonable that, if
you call ``latexindent.pl`` using the ``-m`` switch, then you give it
permission to modify line breaks in your file, but let’s be clear:

If you call ``latexindent.pl`` with the ``-m`` switch, then you are
giving it permission to modify line breaks. By default, the only thing
that will happen is that multiple blank lines will be condensed into one
blank line; many other settings are possible, discussed next.

``preserveBlankLines``: *0\|1*

This field is directly related to *poly-switches*, discussed below. By
default, it is set to ``1``, which means that blank lines will be
protected from removal; however, regardless of this setting, multiple
blank lines can be condensed if ``condenseMultipleBlankLinesInto`` is
greater than ``0``, discussed next.

``condenseMultipleBlankLinesInto``: *integer :math:`\geq 0`*

Assuming that this switch takes an integer value greater than ``0``,
``latexindent.pl`` will condense multiple blank lines into the number of
blank lines illustrated by this switch. As an example,
:numref:`lst:mlb-bl` shows a sample file with blank lines; upon
running

::

    latexindent.pl myfile.tex -m  

the output is shown in :numref:`lst:mlb-bl-out`; note that the
multiple blank lines have been condensed into one blank line, and note
also that we have used the ``-m`` switch!

 .. literalinclude:: demonstrations/mlb1.tex
 	:caption: ``mlb1.tex`` 
 	:name: lst:mlb-bl

 .. literalinclude:: demonstrations/mlb1-out.tex
 	:caption: ``mlb1.tex`` out output 
 	:name: lst:mlb-bl-out

``textWrapOptions``: *fields*

When the ``-m`` switch is active ``latexindent.pl`` has the ability to
wrap text using the options specified in the ``textWrapOptions`` field,
see :numref:`lst:textWrapOptions`. The value of ``columns`` specifies
the column at which the text should be wrapped. By default, the value of
``columns`` is ``0``, so ``latexindent.pl`` will *not* wrap text; if you
change it to a value of ``2`` or more, then text will be wrapped after
the character in the specified column.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``textWrapOptions`` 
 	:name: lst:textWrapOptions
 	:lines: 394-395
 	:linenos:
 	:lineno-start: 394

For example, consider the file give in :numref:`lst:textwrap1`.

 .. literalinclude:: demonstrations/textwrap1.tex
 	:caption: ``textwrap1.tex`` 
 	:name: lst:textwrap1

Using the file ``textwrap1.yaml`` in :numref:`lst:textwrap1-yaml`, and
running the command

::

    latexindent.pl -m textwrap1.tex -o textwrap1-mod1.tex -l textwrap1.yaml

we obtain the output in :numref:`lst:textwrap1-mod1`.

 .. literalinclude:: demonstrations/textwrap1-mod1.tex
 	:caption: ``textwrap1-mod1.tex`` 
 	:name: lst:textwrap1-mod1

 .. literalinclude:: demonstrations/textwrap1.yaml
 	:caption: ``textwrap1.yaml`` 
 	:name: lst:textwrap1-yaml

The text wrapping routine is performed *after* verbatim environments
have been stored, so verbatim environments and verbatim commands are
exempt from the routine. For example, using the file in
:numref:`lst:textwrap2`,

 .. literalinclude:: demonstrations/textwrap2.tex
 	:caption: ``textwrap2.tex`` 
 	:name: lst:textwrap2

and running the following command and continuing to use
``textwrap1.yaml`` from :numref:`lst:textwrap1-yaml`,

::

    latexindent.pl -m textwrap2.tex -o textwrap2-mod1.tex -l textwrap1.yaml

then the output is as in :numref:`lst:textwrap2-mod1`.

 .. literalinclude:: demonstrations/textwrap2-mod1.tex
 	:caption: ``textwrap2-mod1.tex`` 
 	:name: lst:textwrap2-mod1

Furthermore, the text wrapping routine is performed after the trailing
comments have been stored, and they are also exempt from text wrapping.
For example, using the file in :numref:`lst:textwrap3`

 .. literalinclude:: demonstrations/textwrap3.tex
 	:caption: ``textwrap3.tex`` 
 	:name: lst:textwrap3

and running the following command and continuing to use
``textwrap1.yaml`` from :numref:`lst:textwrap1-yaml`,

::

    latexindent.pl -m textwrap3.tex -o textwrap3-mod1.tex -l textwrap1.yaml

then the output is as in :numref:`lst:textwrap3-mod1`.

 .. literalinclude:: demonstrations/textwrap3-mod1.tex
 	:caption: ``textwrap3-mod1.tex`` 
 	:name: lst:textwrap3-mod1

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``textWrapOptions`` 
 	:name: lst:textWrapOptionsAll
 	:lines: 394-396
 	:linenos:
 	:lineno-start: 394

The text wrapping routine of ``latexindent.pl`` is performed by the
``Text::Wrap`` module, which provides a ``separator`` feature to
separate lines with characters other than a new line (see (“Text:Wrap
Perl Module” 2017)). By default, the separator is empty (see
:numref:`lst:textWrapOptionsAll`) which means that a new line token
will be used, but you can change it as you see fit.

For example starting with the file in :numref:`lst:textwrap4`

 .. literalinclude:: demonstrations/textwrap4.tex
 	:caption: ``textwrap4.tex`` 
 	:name: lst:textwrap4

and using ``textwrap2.yaml`` from :numref:`lst:textwrap2-yaml` with
the following command

::

    latexindent.pl -m textwrap4.tex -o textwrap4-mod2.tex -l textwrap2.yaml

then we obtain the output in :numref:`lst:textwrap4-mod2`.

 .. literalinclude:: demonstrations/textwrap4-mod2.tex
 	:caption: ``textwrap4-mod2.tex`` 
 	:name: lst:textwrap4-mod2

 .. literalinclude:: demonstrations/textwrap2.yaml
 	:caption: ``textwrap2.yaml`` 
 	:name: lst:textwrap2-yaml

**Summary of text wrapping** It is important to note the following:

-  Verbatim environments (:numref:`lst:verbatimEnvironments`) and
   verbatim commands (:numref:`lst:verbatimCommands`) will *not* be
   affected by the text wrapping routine (see
   :numref:`lst:textwrap2-mod1`);

-  comments will *not* be affected by the text wrapping routine (see
   :numref:`lst:textwrap3-mod1`);

-  indentation is performed *after* the text wrapping routine; as such,
   indented code will likely exceed any maximum value set in the
   ``columns`` field.

.. label follows

.. _sec:onesentenceperline:

oneSentencePerLine: modifying line breaks for sentences
-------------------------------------------------------

You can instruct ``latexindent.pl`` to format your file so that it puts
one sentence per line. Thank you to mlep (2017) for helping to shape and
test this feature. The behaviour of this part of the script is
controlled by the switches detailed in
:numref:`lst:oneSentencePerLine`, all of which we discuss next.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``oneSentencePerLine`` 
 	:name: lst:oneSentencePerLine
 	:lines: 397-418
 	:linenos:
 	:lineno-start: 397

``manipulateSentences``: *0\|1*

This is a binary switch that details if ``latexindent.pl`` should
perform the sentence manipulation routine; it is *off* (set to ``0``) by
default, and you will need to turn it on (by setting it to ``1``) if you
want the script to modify line breaks surrounding and within sentences.

``removeSentenceLineBreaks``: *0\|1*

When operating upon sentences ``latexindent.pl`` will, by default,
remove internal linebreaks as ``removeSentenceLineBreaks`` is set to
``1``. Setting this switch to ``0`` instructs ``latexindent.pl`` not to
do so.

For example, consider ``multiple-sentences.tex`` shown in
:numref:`lst:multiple-sentences`.

 .. literalinclude:: demonstrations/multiple-sentences.tex
 	:caption: ``multiple-sentences.tex`` 
 	:name: lst:multiple-sentences

If we use the YAML files in :numref:`lst:manipulate-sentences-yaml`
and :numref:`lst:keep-sen-line-breaks-yaml`, and run the commands

::

    latexindent.pl multiple-sentences -m -l=manipulate-sentences.yaml
    latexindent.pl multiple-sentences -m -l=keep-sen-line-breaks.yaml
        

then we obtain the respective output given in
:numref:`lst:multiple-sentences-mod1` and
:numref:`lst:multiple-sentences-mod2`.

 .. literalinclude:: demonstrations/multiple-sentences-mod1.tex
 	:caption: ``multiple-sentences.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:multiple-sentences-mod1

 .. literalinclude:: demonstrations/manipulate-sentences.yaml
 	:caption: ``manipulate-sentences.yaml`` 
 	:name: lst:manipulate-sentences-yaml

 .. literalinclude:: demonstrations/multiple-sentences-mod2.tex
 	:caption: ``multiple-sentences.tex`` using :numref:`lst:keep-sen-line-breaks-yaml` 
 	:name: lst:multiple-sentences-mod2

 .. literalinclude:: demonstrations/keep-sen-line-breaks.yaml
 	:caption: ``keep-sen-line-breaks.yaml`` 
 	:name: lst:keep-sen-line-breaks-yaml

Notice, in particular, that the ‘internal’ sentence line breaks in
:numref:`lst:multiple-sentences` have been removed in
:numref:`lst:multiple-sentences-mod1`, but have not been removed in
:numref:`lst:multiple-sentences-mod2`.

The remainder of the settings displayed in
:numref:`lst:oneSentencePerLine` instruct ``latexindent.pl`` on how to
define a sentence. From the perpesctive of ``latexindent.pl`` a sentence
must:

-  *follow* a certain character or set of characters (see
   :numref:`lst:sentencesFollow`); by default, this is either
   ``\par``, a blank line, a full stop/period (.), exclamation mark (!),
   question mark (?) right brace (}) or a comment on the previous line;

-  *begin* with a character type (see
   :numref:`lst:sentencesBeginWith`); by default, this is only capital
   letters;

-  *end* with a character (see :numref:`lst:sentencesEndWith`); by
   default, these are full stop/period (.), exclamation mark (!) and
   question mark (?).

In each case, you can specify the ``other`` field to include any pattern
that you would like; you can specify anything in this field using the
language of regular expressions.

-3.5cm-2.5cm

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``sentencesFollow`` 
 	:name: lst:sentencesFollow
 	:lines: 400-408
 	:linenos:
 	:lineno-start: 400

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``sentencesBeginWith`` 
 	:name: lst:sentencesBeginWith
 	:lines: 409-412
 	:linenos:
 	:lineno-start: 409

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``sentencesEndWith`` 
 	:name: lst:sentencesEndWith
 	:lines: 413-418
 	:linenos:
 	:lineno-start: 413

sentencesFollow
~~~~~~~~~~~~~~~

Let’s explore a few of the switches in ``sentencesFollow``; let’s start
with :numref:`lst:multiple-sentences`, and use the YAML settings given
in :numref:`lst:sentences-follow1-yaml`. Using the command

::

    latexindent.pl multiple-sentences -m -l=sentences-follow1.yaml

we obtain the output given in :numref:`lst:multiple-sentences-mod3`.

 .. literalinclude:: demonstrations/multiple-sentences-mod3.tex
 	:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-follow1-yaml` 
 	:name: lst:multiple-sentences-mod3

 .. literalinclude:: demonstrations/sentences-follow1.yaml
 	:caption: ``sentences-follow1.yaml`` 
 	:name: lst:sentences-follow1-yaml

Notice that, because ``blankLine`` is set to ``0``, ``latexindent.pl``
will not seek sentences following a blank line, and so the fourth
sentence has not been accounted for.

We can explore the ``other`` field in :numref:`lst:sentencesFollow`
with the ``.tex`` file detailed in :numref:`lst:multiple-sentences1`.

 .. literalinclude:: demonstrations/multiple-sentences1.tex
 	:caption: ``multiple-sentences1.tex`` 
 	:name: lst:multiple-sentences1

Upon running the following commands

::

    latexindent.pl multiple-sentences1 -m -l=manipulate-sentences.yaml
    latexindent.pl multiple-sentences1 -m -l=manipulate-sentences.yaml,sentences-follow2.yaml
        

then we obtain the respective output given in
:numref:`lst:multiple-sentences1-mod1` and
:numref:`lst:multiple-sentences1-mod2`.

 .. literalinclude:: demonstrations/multiple-sentences1-mod1.tex
 	:caption: ``multiple-sentences1.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:multiple-sentences1-mod1

 .. literalinclude:: demonstrations/multiple-sentences1-mod2.tex
 	:caption: ``multiple-sentences1.tex`` using :numref:`lst:sentences-follow2-yaml` 
 	:name: lst:multiple-sentences1-mod2

 .. literalinclude:: demonstrations/sentences-follow2.yaml
 	:caption: ``sentences-follow2.yaml`` 
 	:name: lst:sentences-follow2-yaml

Notice that in :numref:`lst:multiple-sentences1-mod1` the first
sentence after the ``)`` has not been accounted for, but that following
the inclusion of :numref:`lst:sentences-follow2-yaml`, the output
given in :numref:`lst:multiple-sentences1-mod2` demonstrates that the
sentence *has* been accounted for correctly.

sentencesBeginWith
~~~~~~~~~~~~~~~~~~

By default, ``latexindent.pl`` will only assume that sentences begin
with the upper case letters ``A-Z``; you can instruct the script to
define sentences to begin with lower case letters (see
:numref:`lst:sentencesBeginWith`), and we can use the ``other`` field
to define sentences to begin with other characters.

 .. literalinclude:: demonstrations/multiple-sentences2.tex
 	:caption: ``multiple-sentences2.tex`` 
 	:name: lst:multiple-sentences2

Upon running the following commands

::

    latexindent.pl multiple-sentences2 -m -l=manipulate-sentences.yaml
    latexindent.pl multiple-sentences2 -m -l=manipulate-sentences.yaml,sentences-begin1.yaml
        

then we obtain the respective output given in
:numref:`lst:multiple-sentences2-mod1` and
:numref:`lst:multiple-sentences2-mod2`.

 .. literalinclude:: demonstrations/multiple-sentences2-mod1.tex
 	:caption: ``multiple-sentences2.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:multiple-sentences2-mod1

 .. literalinclude:: demonstrations/multiple-sentences2-mod2.tex
 	:caption: ``multiple-sentences2.tex`` using :numref:`lst:sentences-begin1-yaml` 
 	:name: lst:multiple-sentences2-mod2

 .. literalinclude:: demonstrations/sentences-begin1.yaml
 	:caption: ``sentences-begin1.yaml`` 
 	:name: lst:sentences-begin1-yaml

Notice that in :numref:`lst:multiple-sentences2-mod1`, the first
sentence has been accounted for but that the subsequent sentences have
not. In :numref:`lst:multiple-sentences2-mod2`, all of the sentences
have been accounted for, because the ``other`` field in
:numref:`lst:sentences-begin1-yaml` has defined sentences to begin
with either ``$`` or any numeric digit, ``0`` to ``9``.

sentencesEndWith
~~~~~~~~~~~~~~~~

Let’s return to :numref:`lst:multiple-sentences`; we have already seen
the default way in which ``latexindent.pl`` will operate on the
sentences in this file in :numref:`lst:multiple-sentences-mod1`. We
can populate the ``other`` field with any character that we wish; for
example, using the YAML specified in :numref:`lst:sentences-end1-yaml`
and the command

::

    latexindent.pl multiple-sentences -m -l=sentences-end1.yaml
    latexindent.pl multiple-sentences -m -l=sentences-end2.yaml

then we obtain the output in :numref:`lst:multiple-sentences-mod4`.

 .. literalinclude:: demonstrations/multiple-sentences-mod4.tex
 	:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-end1-yaml` 
 	:name: lst:multiple-sentences-mod4

 .. literalinclude:: demonstrations/sentences-end1.yaml
 	:caption: ``sentences-end1.yaml`` 
 	:name: lst:sentences-end1-yaml

 .. literalinclude:: demonstrations/multiple-sentences-mod5.tex
 	:caption: ``multiple-sentences.tex`` using :numref:`lst:sentences-end2-yaml` 
 	:name: lst:multiple-sentences-mod5

 .. literalinclude:: demonstrations/sentences-end2.yaml
 	:caption: ``sentences-end2.yaml`` 
 	:name: lst:sentences-end2-yaml

There is a subtle difference between the output in
:numref:`lst:multiple-sentences-mod4` and
:numref:`lst:multiple-sentences-mod5`; in particular, in
:numref:`lst:multiple-sentences-mod4` the word ``sentence`` has not
been defined as a sentence, because we have not instructed
``latexindent.pl`` to begin sentences with lower case letters. We have
changed this by using the settings in
:numref:`lst:sentences-end2-yaml`, and the associated output in
:numref:`lst:multiple-sentences-mod5` reflects this.

Referencing :numref:`lst:sentencesEndWith`, you’ll notice that there
is a field called ``basicFullStop``, which is set to ``0``, and that the
``betterFullStop`` is set to ``1`` by default.

Let’s consider the file shown in :numref:`lst:url`.

 .. literalinclude:: demonstrations/url.tex
 	:caption: ``url.tex`` 
 	:name: lst:url

Upon running the following commands

::

    latexindent.pl url -m -l=manipulate-sentences.yaml

we obtain the output given in :numref:`lst:url-mod1`.

 .. literalinclude:: demonstrations/url-mod1.tex
 	:caption: ``url.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:url-mod1

Notice that the full stop within the url has been interpreted correctly.
This is because, within the ``betterFullStop``, full stops at the end of
sentences have the following properties:

-  they are ignored within ``e.g.`` and ``i.e.``;

-  they can not be immediately followed by a lower case or upper case
   letter;

-  they can not be immediately followed by a hyphen, comma, or number.

If you find that the ``betterFullStop`` does not work for your purposes,
then you can switch it off by setting it to ``0``, and you can
experiment with the ``other`` field.

The ``basicFullStop`` routine should probably be avoided in most
situations, as it does not accomodate the specifications above. For
example, using the YAML in :numref:`lst:alt-full-stop1-yaml` gives the
output from the following command in :numref:`lst:url-mod2`.

::

    latexindent.pl url -m -l=alt-full-stop1.yaml

-3.5cm-1.5cm

 .. literalinclude:: demonstrations/url-mod2.tex
 	:caption: ``url.tex`` using :numref:`lst:alt-full-stop1-yaml` 
 	:name: lst:url-mod2

 .. literalinclude:: demonstrations/alt-full-stop1.yaml
 	:caption: ``alt-full-stop1.yaml`` 
 	:name: lst:alt-full-stop1-yaml

Notice that the full stop within the URL has not been accomodated
correctly because of the non-default settings in
:numref:`lst:alt-full-stop1-yaml`.

Features of the oneSentencePerLine routine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The sentence manipulation routine takes place *after* verbatim
environments, preamble and trailing comments have been accounted for;
this means that any characters within these types of code blocks will
not be part of the sentence manipulation routine.

For example, if we begin with the ``.tex`` file in
:numref:`lst:multiple-sentences3`, and run the command

::

    latexindent.pl multiple-sentences3 -m -l=manipulate-sentences.yaml
        

then we obtain the output in :numref:`lst:multiple-sentences3-mod1`.

 .. literalinclude:: demonstrations/multiple-sentences3.tex
 	:caption: ``multiple-sentences3.tex`` 
 	:name: lst:multiple-sentences3

 .. literalinclude:: demonstrations/multiple-sentences3-mod1.tex
 	:caption: ``multiple-sentences3.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:multiple-sentences3-mod1

Furthermore, if sentences run across environments then, by default, the
line breaks internal to the sentence will be removed. For example, if we
use the ``.tex`` file in :numref:`lst:multiple-sentences4` and run the
commands

::

    latexindent.pl multiple-sentences4 -m -l=manipulate-sentences.yaml
    latexindent.pl multiple-sentences4 -m -l=keep-sen-line-breaks.yaml
        

then we obtain the output in :numref:`lst:multiple-sentences4-mod1`
and :numref:`lst:multiple-sentences4-mod2`.

 .. literalinclude:: demonstrations/multiple-sentences4.tex
 	:caption: ``multiple-sentences4.tex`` 
 	:name: lst:multiple-sentences4

 .. literalinclude:: demonstrations/multiple-sentences4-mod1.tex
 	:caption: ``multiple-sentences4.tex`` using :numref:`lst:manipulate-sentences-yaml` 
 	:name: lst:multiple-sentences4-mod1

 .. literalinclude:: demonstrations/multiple-sentences4-mod2.tex
 	:caption: ``multiple-sentences4.tex`` using :numref:`lst:keep-sen-line-breaks-yaml` 
 	:name: lst:multiple-sentences4-mod2

Once you’ve read :numref:`sec:poly-switches`, you will know that you
can accomodate the removal of internal sentence line breaks by using the
YAML in :numref:`lst:item-rules2-yaml` and the command

::

    latexindent.pl multiple-sentences4 -m -l=item-rules2.yaml
        

the output of which is shown in
:numref:`lst:multiple-sentences4-mod3`.

 .. literalinclude:: demonstrations/multiple-sentences4-mod3.tex
 	:caption: ``multiple-sentences4.tex`` using :numref:`lst:item-rules2-yaml` 
 	:name: lst:multiple-sentences4-mod3

 .. literalinclude:: demonstrations/item-rules2.yaml
 	:caption: ``item-rules2.yaml`` 
 	:name: lst:item-rules2-yaml

removeParagraphLineBreaks: modifying line breaks for paragraphs
---------------------------------------------------------------

When the ``-m`` switch is active ``latexindent.pl`` has the ability to
remove line breaks from within paragraphs; the behaviour is controlled
by the ``removeParagraphLineBreaks`` field, detailed in
:numref:`lst:removeParagraphLineBreaks`. Thank you to Owens (2017) for
shaping and assisting with the testing of this feature.
``removeParagraphLineBreaks``: *fields*

This feature is considered complimentary to the ``oneSentencePerLine``
feature described in :numref:`sec:onesentenceperline`.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``removeParagraphLineBreaks`` 
 	:name: lst:removeParagraphLineBreaks
 	:lines: 419-431
 	:linenos:
 	:lineno-start: 419

This routine can be turned on *globally* for *every* code block type
known to ``latexindent.pl`` (see :numref:`tab:code-blocks`) by using
the ``all`` switch; by default, this switch is *off*. Assuming that the
``all`` switch is off, then the routine can be controlled on a
per-code-block-type basis, and within that, on a per-name basis. We will
consider examples of each of these in turn, but before we do, let’s
specify what ``latexindent.pl`` considers as a paragraph:

-  it must begin on its own line with either an alphabetic or numeric
   character, and not with any of the code-block types detailed in
   :numref:`tab:code-blocks`;

-  it can include line breaks, but finishes when it meets either a blank
   line, a ``\par`` command, or any of the user-specified settings in
   the ``paragraphsStopAt`` field, detailed in
   :numref:`lst:paragraphsStopAt`.

Let’s start with the ``.tex`` file in :numref:`lst:shortlines`,
together with the YAML settings in :numref:`lst:remove-para1-yaml`.

 .. literalinclude:: demonstrations/shortlines.tex
 	:caption: ``shortlines.tex`` 
 	:name: lst:shortlines

 .. literalinclude:: demonstrations/remove-para1.yaml
 	:caption: ``remove-para1.yaml`` 
 	:name: lst:remove-para1-yaml

Upon running the command

::

    latexindent.pl -m shortlines.tex -o shortlines1.tex -l remove-para1.yaml

then we obtain the output given in :numref:`lst:shortlines1`.

 .. literalinclude:: demonstrations/shortlines1.tex
 	:caption: ``shortlines1.tex`` 
 	:name: lst:shortlines1

Keen readers may notice that some trailing white space must be present
in the file in :numref:`lst:shortlines` which has crept in to the
output in :numref:`lst:shortlines1`. This can be fixed using the YAML
file in :numref:`lst:removeTWS-before` and running, for example,

::

    latexindent.pl -m shortlines.tex -o shortlines1-tws.tex -l remove-para1.yaml,removeTWS-before.yaml  
        

in which case the output is as in :numref:`lst:shortlines1-tws`;
notice that the double spaces present in :numref:`lst:shortlines1`
have been addressed.

 .. literalinclude:: demonstrations/shortlines1-tws.tex
 	:caption: ``shortlines1-tws.tex`` 
 	:name: lst:shortlines1-tws

Keeping with the settings in :numref:`lst:remove-para1-yaml`, we note
that the ``all`` switch applies to *all* code block types. So, for
example, let’s consider the files in :numref:`lst:shortlines-mand` and
:numref:`lst:shortlines-opt`

 .. literalinclude:: demonstrations/shortlines-mand.tex
 	:caption: ``shortlines-mand.tex`` 
 	:name: lst:shortlines-mand

 .. literalinclude:: demonstrations/shortlines-opt.tex
 	:caption: ``shortlines-opt.tex`` 
 	:name: lst:shortlines-opt

Upon running the commands

::

    latexindent.pl -m shortlines-mand.tex -o shortlines-mand1.tex -l remove-para1.yaml
    latexindent.pl -m shortlines-opt.tex -o shortlines-opt1.tex -l remove-para1.yaml

then we obtain the respective output given in
:numref:`lst:shortlines-mand1` and :numref:`lst:shortlines-opt1`.

 .. literalinclude:: demonstrations/shortlines-mand1.tex
 	:caption: ``shortlines-mand1.tex`` 
 	:name: lst:shortlines-mand1

 .. literalinclude:: demonstrations/shortlines-opt1.tex
 	:caption: ``shortlines-opt1.tex`` 
 	:name: lst:shortlines-opt1

Assuming that we turn *off* the ``all`` switch (by setting it to ``0``),
then we can control the behaviour of ``removeParagraphLineBreaks``
either on a per-code-block-type basis, or on a per-name basis.

For example, let’s use the code in :numref:`lst:shortlines-envs`, and
consider the settings in :numref:`lst:remove-para2-yaml` and
:numref:`lst:remove-para3-yaml`; note that in
:numref:`lst:remove-para2-yaml` we specify that *every* environment
should receive treatment from the routine, while in
:numref:`lst:remove-para3-yaml` we specify that *only* the ``one``
environment should receive the treatment.

 .. literalinclude:: demonstrations/shortlines-envs.tex
 	:caption: ``shortlines-envs.tex`` 
 	:name: lst:shortlines-envs

 .. literalinclude:: demonstrations/remove-para2.yaml
 	:caption: ``remove-para2.yaml`` 
 	:name: lst:remove-para2-yaml

 .. literalinclude:: demonstrations/remove-para3.yaml
 	:caption: ``remove-para3.yaml`` 
 	:name: lst:remove-para3-yaml

Upon running the commands

::

    latexindent.pl -m shortlines-envs.tex -o shortlines-envs2.tex -l remove-para2.yaml
    latexindent.pl -m shortlines-envs.tex -o shortlines-envs3.tex -l remove-para3.yaml

then we obtain the respective output given in
:numref:`lst:shortlines-envs2` and :numref:`lst:shortlines-envs3`.

 .. literalinclude:: demonstrations/shortlines-envs2.tex
 	:caption: ``shortlines-envs2.tex`` 
 	:name: lst:shortlines-envs2

 .. literalinclude:: demonstrations/shortlines-envs3.tex
 	:caption: ``shortlines-envs3.tex`` 
 	:name: lst:shortlines-envs3

The remaining code-block types can be customized in analogous ways,
although note that ``commands``, ``keyEqualsValuesBracesBrackets``,
``namedGroupingBracesBrackets``, ``UnNamedGroupingBracesBrackets`` are
controlled by the ``optionalArguments`` and the ``mandatoryArguments``.

The only special case is the ``masterDocument`` field; this is designed
for ‘chapter’-type files that may contain paragraphs that are not within
any other code-blocks. For example, consider the file in
:numref:`lst:shortlines-md`, with the YAML settings in
:numref:`lst:remove-para4-yaml`.

 .. literalinclude:: demonstrations/shortlines-md.tex
 	:caption: ``shortlines-md.tex`` 
 	:name: lst:shortlines-md

 .. literalinclude:: demonstrations/remove-para4.yaml
 	:caption: ``remove-para4.yaml`` 
 	:name: lst:remove-para4-yaml

Upon running the following command

::

    latexindent.pl -m shortlines-md.tex -o shortlines-md4.tex -l remove-para4.yaml

then we obtain the output in :numref:`lst:shortlines-md4`.

 .. literalinclude:: demonstrations/shortlines-md4.tex
 	:caption: ``shortlines-md4.tex`` 
 	:name: lst:shortlines-md4

``paragraphsStopAt``: *fields*

The paragraph line break routine considers blank lines and the ``\par``
command to be the end of a paragraph; you can fine tune the behaviour of
the routine further by using the ``paragraphsStopAt`` fields, shown in
:numref:`lst:paragraphsStopAt`.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``paragraphsStopAt`` 
 	:name: lst:paragraphsStopAt
 	:lines: 432-440
 	:linenos:
 	:lineno-start: 432

The fields specified in ``paragraphsStopAt`` tell ``latexindent.pl`` to
stop the current paragraph when it reaches a line that *begins* with any
of the code-block types specified as ``1`` in
:numref:`lst:paragraphsStopAt`. By default, you’ll see that the
paragraph line break routine will stop when it reaches an environment at
the beginning of a line. It is *not* possible to specify these fields on
a per-name basis.

Let’s use the ``.tex`` file in :numref:`lst:sl-stop`; we will, in
turn, consider the settings in :numref:`lst:stop-command-yaml` and
:numref:`lst:stop-comment-yaml`.

 .. literalinclude:: demonstrations/sl-stop.tex
 	:caption: ``sl-stop.tex`` 
 	:name: lst:sl-stop

 .. literalinclude:: demonstrations/stop-command.yaml
 	:caption: ``stop-command.yaml`` 
 	:name: lst:stop-command-yaml

 .. literalinclude:: demonstrations/stop-comment.yaml
 	:caption: ``stop-comment.yaml`` 
 	:name: lst:stop-comment-yaml

Upon using the settings from :numref:`lst:remove-para4-yaml` and
running the commands

::

    latexindent.pl -m sl-stop.tex -o sl-stop4.tex -l remove-para4.yaml
    latexindent.pl -m sl-stop.tex -o sl-stop4-command.tex -l=remove-para4.yaml,stop-command.yaml
    latexindent.pl -m sl-stop.tex -o sl-stop4-comment.tex -l=remove-para4.yaml,stop-comment.yaml
        

we obtain the respective outputs in :numref:`lst:sl-stop4` –
:numref:`lst:sl-stop4-comment`; notice in particular that:

-  in :numref:`lst:sl-stop4` the paragraph line break routine has
   included commands and comments;

-  in :numref:`lst:sl-stop4-command` the paragraph line break routine
   has *stopped* at the ``emph`` command, because in
   :numref:`lst:stop-command-yaml` we have specified ``commands`` to
   be ``1``, and ``emph`` is at the beginning of a line;

-  in :numref:`lst:sl-stop4-comment` the paragraph line break routine
   has *stopped* at the comments, because in
   :numref:`lst:stop-comment-yaml` we have specified ``comments`` to
   be ``1``, and the comment is at the beginning of a line.

In all outputs in :numref:`lst:sl-stop4` –
:numref:`lst:sl-stop4-comment` we notice that the paragraph line break
routine has stopped at ``\begin{myenv}`` because, by default,
``environments`` is set to ``1`` in :numref:`lst:paragraphsStopAt`.

 .. literalinclude:: demonstrations/sl-stop4.tex
 	:caption: ``sl-stop4.tex`` 
 	:name: lst:sl-stop4

 .. literalinclude:: demonstrations/sl-stop4-command.tex
 	:caption: ``sl-stop4-command.tex`` 
 	:name: lst:sl-stop4-command

 .. literalinclude:: demonstrations/sl-stop4-comment.tex
 	:caption: ``sl-stop4-comment.tex`` 
 	:name: lst:sl-stop4-comment

.. label follows

.. _sec:poly-switches:

Poly-switches
-------------

Every other field in the ``modifyLineBreaks`` field uses poly-switches,
and can take one of *five* \*blank line poly-switch integer values:

-  *remove mode*: line breaks before or after the *<part of thing>* can
   be removed (assuming that ``preserveBlankLines`` is set to ``0``);

-  *off mode*: line breaks will not be modified for the *<part of
   thing>* under consideration;

-  *add mode*: a line break will be added before or after the *<part of
   thing>* under consideration, assuming that there is not already a
   line break before or after the *<part of thing>*;

-  *comment then add mode*: a comment symbol will be added, followed by
   a line break before or after the *<part of thing>* under
   consideration, assuming that there is not already a comment and line
   break before or after the *<part of thing>*;

-  *add then blank line mode* : a line break will be added before or
   after the *<part of thing>* under consideration, assuming that there
   is not already a line break before or after the *<part of thing>*,
   followed by a blank line.

In the above, *<part of thing>* refers to either the *begin statement*,
*body* or *end statement* of the code blocks detailed in
:numref:`tab:code-blocks`. All poly-switches are *off* by default;
``latexindent.pl`` searches first of all for per-name settings, and then
followed by global per-thing settings.

.. label follows

.. _sec:modifylinebreaks-environments:

modifyLineBreaks for environments
---------------------------------

We start by viewing a snippet of ``defaultSettings.yaml`` in
:numref:`lst:environments-mlb`; note that it contains *global*
settings (immediately after the ``environments`` field) and that
*per-name* settings are also allowed – in the case of
:numref:`lst:environments-mlb`, settings for ``equation*`` have been
specified. Note that all poly-switches are *off* by default.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``environments`` 
 	:name: lst:environments-mlb
 	:lines: 441-450
 	:linenos:
 	:lineno-start: 441

Let’s begin with the simple example given in
:numref:`lst:env-mlb1-tex`; note that we have annotated key parts of
the file using ♠, ♥, ◆ and ♣, these will be related to fields specified
in :numref:`lst:environments-mlb`.

.. code-block:: latex
   :caption: ``env-mlb1.tex`` 
   :name: lst:env-mlb1-tex

    before words♠ \begin{myenv}♥body of myenv◆\end{myenv}♣ after words

Adding line breaks: BeginStartsOnOwnLine and BodyStartsOnOwnLine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let’s explore ``BeginStartsOnOwnLine`` and ``BodyStartsOnOwnLine`` in
:numref:`lst:env-mlb1` and :numref:`lst:env-mlb2`, and in
particular, let’s allow each of them in turn to take a value of
:math:`1`.

 .. literalinclude:: demonstrations/env-mlb1.yaml
 	:caption: ``env-mlb1.yaml`` 
 	:name: lst:env-mlb1

 .. literalinclude:: demonstrations/env-mlb2.yaml
 	:caption: ``env-mlb2.yaml`` 
 	:name: lst:env-mlb2

After running the following commands,

::

    latexindent.pl -m env-mlb.tex -l env-mlb1.yaml
    latexindent.pl -m env-mlb.tex -l env-mlb2.yaml

the output is as in :numref:`lst:env-mlb-mod1` and
:numref:`lst:env-mlb-mod2` respectively.

 .. literalinclude:: demonstrations/env-mlb-mod1.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb1` 
 	:name: lst:env-mlb-mod1

 .. literalinclude:: demonstrations/env-mlb-mod2.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb2` 
 	:name: lst:env-mlb-mod2

There are a couple of points to note:

-  in :numref:`lst:env-mlb-mod1` a line break has been added at the
   point denoted by ♠ in :numref:`lst:env-mlb1-tex`; no other line
   breaks have been changed;

-  in :numref:`lst:env-mlb-mod2` a line break has been added at the
   point denoted by ♥ in :numref:`lst:env-mlb1-tex`; furthermore, note
   that the *body* of ``myenv`` has received the appropriate (default)
   indentation.

Let’s now change each of the ``1`` values in :numref:`lst:env-mlb1`
and :numref:`lst:env-mlb2` so that they are :math:`2` and save them
into ``env-mlb3.yaml`` and ``env-mlb4.yaml`` respectively (see
:numref:`lst:env-mlb3` and :numref:`lst:env-mlb4`).

 .. literalinclude:: demonstrations/env-mlb3.yaml
 	:caption: ``env-mlb3.yaml`` 
 	:name: lst:env-mlb3

 .. literalinclude:: demonstrations/env-mlb4.yaml
 	:caption: ``env-mlb4.yaml`` 
 	:name: lst:env-mlb4

Upon running commands analogous to the above, we obtain
:numref:`lst:env-mlb-mod3` and :numref:`lst:env-mlb-mod4`.

 .. literalinclude:: demonstrations/env-mlb-mod3.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb3` 
 	:name: lst:env-mlb-mod3

 .. literalinclude:: demonstrations/env-mlb-mod4.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb4` 
 	:name: lst:env-mlb-mod4

Note that line breaks have been added as in :numref:`lst:env-mlb-mod1`
and :numref:`lst:env-mlb-mod2`, but this time a comment symbol has
been added before adding the line break; in both cases, trailing
horizontal space has been stripped before doing so.

Let’s now change each of the ``1`` values in :numref:`lst:env-mlb1`
and :numref:`lst:env-mlb2` so that they are :math:`3` and save them
into ``env-mlb5.yaml`` and ``env-mlb6.yaml`` respectively (see
:numref:`lst:env-mlb5` and :numref:`lst:env-mlb6`).

 .. literalinclude:: demonstrations/env-mlb5.yaml
 	:caption: ``env-mlb5.yaml`` 
 	:name: lst:env-mlb5

 .. literalinclude:: demonstrations/env-mlb6.yaml
 	:caption: ``env-mlb6.yaml`` 
 	:name: lst:env-mlb6

Upon running commands analogous to the above, we obtain
:numref:`lst:env-mlb-mod5` and :numref:`lst:env-mlb-mod6`.

 .. literalinclude:: demonstrations/env-mlb-mod5.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb5` 
 	:name: lst:env-mlb-mod5

 .. literalinclude:: demonstrations/env-mlb-mod6.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb6` 
 	:name: lst:env-mlb-mod6

Note that line breaks have been added as in :numref:`lst:env-mlb-mod1`
and :numref:`lst:env-mlb-mod2`, but this time a *blank line* has been
added after adding the line break.

Adding line breaks using EndStartsOnOwnLine and EndFinishesWithLineBreak
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let’s explore ``EndStartsOnOwnLine`` and ``EndFinishesWithLineBreak`` in
:numref:`lst:env-mlb7` and :numref:`lst:env-mlb8`, and in
particular, let’s allow each of them in turn to take a value of
:math:`1`.

 .. literalinclude:: demonstrations/env-mlb7.yaml
 	:caption: ``env-mlb7.yaml`` 
 	:name: lst:env-mlb7

 .. literalinclude:: demonstrations/env-mlb8.yaml
 	:caption: ``env-mlb8.yaml`` 
 	:name: lst:env-mlb8

After running the following commands,

::

    latexindent.pl -m env-mlb.tex -l env-mlb7.yaml
    latexindent.pl -m env-mlb.tex -l env-mlb8.yaml

the output is as in :numref:`lst:env-mlb-mod7` and
:numref:`lst:env-mlb-mod8`.

 .. literalinclude:: demonstrations/env-mlb-mod7.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb7` 
 	:name: lst:env-mlb-mod7

 .. literalinclude:: demonstrations/env-mlb-mod8.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb8` 
 	:name: lst:env-mlb-mod8

There are a couple of points to note:

-  in :numref:`lst:env-mlb-mod7` a line break has been added at the
   point denoted by ◆ in :numref:`lst:env-mlb1-tex`; no other line
   breaks have been changed and the ``\end{myenv}`` statement has *not*
   received indentation (as intended);

-  in :numref:`lst:env-mlb-mod8` a line break has been added at the
   point denoted by ♣ in :numref:`lst:env-mlb1-tex`.

Let’s now change each of the ``1`` values in :numref:`lst:env-mlb7`
and :numref:`lst:env-mlb8` so that they are :math:`2` and save them
into ``env-mlb9.yaml`` and ``env-mlb10.yaml`` respectively (see
:numref:`lst:env-mlb9` and :numref:`lst:env-mlb10`).

 .. literalinclude:: demonstrations/env-mlb9.yaml
 	:caption: ``env-mlb9.yaml`` 
 	:name: lst:env-mlb9

 .. literalinclude:: demonstrations/env-mlb10.yaml
 	:caption: ``env-mlb10.yaml`` 
 	:name: lst:env-mlb10

Upon running commands analogous to the above, we obtain
:numref:`lst:env-mlb-mod9` and :numref:`lst:env-mlb-mod10`.

 .. literalinclude:: demonstrations/env-mlb-mod9.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb9` 
 	:name: lst:env-mlb-mod9

 .. literalinclude:: demonstrations/env-mlb-mod10.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb10` 
 	:name: lst:env-mlb-mod10

Note that line breaks have been added as in :numref:`lst:env-mlb-mod7`
and :numref:`lst:env-mlb-mod8`, but this time a comment symbol has
been added before adding the line break; in both cases, trailing
horizontal space has been stripped before doing so.

Let’s now change each of the ``1`` values in :numref:`lst:env-mlb7`
and :numref:`lst:env-mlb8` so that they are :math:`3` and save them
into ``env-mlb11.yaml`` and ``env-mlb12.yaml`` respectively (see
:numref:`lst:env-mlb11` and :numref:`lst:env-mlb12`).

 .. literalinclude:: demonstrations/env-mlb11.yaml
 	:caption: ``env-mlb11.yaml`` 
 	:name: lst:env-mlb11

 .. literalinclude:: demonstrations/env-mlb12.yaml
 	:caption: ``env-mlb12.yaml`` 
 	:name: lst:env-mlb12

Upon running commands analogous to the above, we obtain
:numref:`lst:env-mlb-mod11` and :numref:`lst:env-mlb-mod12`.

 .. literalinclude:: demonstrations/env-mlb-mod11.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb11` 
 	:name: lst:env-mlb-mod11

 .. literalinclude:: demonstrations/env-mlb-mod12.tex
 	:caption: ``env-mlb.tex`` using :numref:`lst:env-mlb12` 
 	:name: lst:env-mlb-mod12

Note that line breaks have been added as in :numref:`lst:env-mlb-mod7`
and :numref:`lst:env-mlb-mod8`, and that a *blank line* has been added
after the line break.

poly-switches only add line breaks when necessary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you ask ``latexindent.pl`` to add a line break (possibly with a
comment) using a poly-switch value of :math:`1` (or :math:`2`), it will
only do so if necessary. For example, if you process the file in
:numref:`lst:mlb2` using any of the YAML files presented so far in
this section, it will be left unchanged.

 .. literalinclude:: demonstrations/env-mlb2.tex
 	:caption: ``env-mlb2.tex`` 
 	:name: lst:mlb2

 .. literalinclude:: demonstrations/env-mlb3.tex
 	:caption: ``env-mlb3.tex`` 
 	:name: lst:mlb3

In contrast, the output from processing the file in :numref:`lst:mlb3`
will vary depending on the poly-switches used; in
:numref:`lst:env-mlb3-mod2` you’ll see that the comment symbol after
the ``\begin{myenv}`` has been moved to the next line, as
``BodyStartsOnOwnLine`` is set to ``1``. In
:numref:`lst:env-mlb3-mod4` you’ll see that the comment has been
accounted for correctly because ``BodyStartsOnOwnLine`` has been set to
``2``, and the comment symbol has *not* been moved to its own line.
You’re encouraged to experiment with :numref:`lst:mlb3` and by setting
the other poly-switches considered so far to ``2`` in turn.

 .. literalinclude:: demonstrations/env-mlb3-mod2.tex
 	:caption: ``env-mlb3.tex`` using :numref:`lst:env-mlb2` 
 	:name: lst:env-mlb3-mod2

 .. literalinclude:: demonstrations/env-mlb3-mod4.tex
 	:caption: ``env-mlb3.tex`` using :numref:`lst:env-mlb4` 
 	:name: lst:env-mlb3-mod4

The details of the discussion in this section have concerned *global*
poly-switches in the ``environments`` field; each switch can also be
specified on a *per-name* basis, which would take priority over the
global values; with reference to :numref:`lst:environments-mlb`, an
example is shown for the ``equation*`` environment.

Removing line breaks (poly-switches set to :math:`-1`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Setting poly-switches to :math:`-1` tells ``latexindent.pl`` to remove
line breaks of the *<part of the thing>*, if necessary. We will consider
the example code given in :numref:`lst:mlb4`, noting in particular the
positions of the line break highlighters, ♠, ♥, ◆ and ♣, together with
the associated YAML files in :numref:`lst:env-mlb13` –
:numref:`lst:env-mlb16`.

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
 	:caption: ``env-mlb13.yaml`` 
 	:name: lst:env-mlb13

 .. literalinclude:: demonstrations/env-mlb14.yaml
 	:caption: ``env-mlb14.yaml`` 
 	:name: lst:env-mlb14

 .. literalinclude:: demonstrations/env-mlb15.yaml
 	:caption: ``env-mlb15.yaml`` 
 	:name: lst:env-mlb15

 .. literalinclude:: demonstrations/env-mlb16.yaml
 	:caption: ``env-mlb16.yaml`` 
 	:name: lst:env-mlb16

running the commands

::

    latexindent.pl -m env-mlb4.tex -l env-mlb13.yaml
    latexindent.pl -m env-mlb4.tex -l env-mlb14.yaml
    latexindent.pl -m env-mlb4.tex -l env-mlb15.yaml
    latexindent.pl -m env-mlb4.tex -l env-mlb16.yaml

we obtain the respective output in :numref:`lst:env-mlb4-mod13` –
:numref:`lst:env-mlb4-mod16`.

 .. literalinclude:: demonstrations/env-mlb4-mod13.tex
 	:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb13` 
 	:name: lst:env-mlb4-mod13

 .. literalinclude:: demonstrations/env-mlb4-mod14.tex
 	:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb14` 
 	:name: lst:env-mlb4-mod14

 .. literalinclude:: demonstrations/env-mlb4-mod15.tex
 	:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb15` 
 	:name: lst:env-mlb4-mod15

 .. literalinclude:: demonstrations/env-mlb4-mod16.tex
 	:caption: ``env-mlb4.tex`` using :numref:`lst:env-mlb16` 
 	:name: lst:env-mlb4-mod16

Notice that in:

-  :numref:`lst:env-mlb4-mod13` the line break denoted by ♠ in
   :numref:`lst:mlb4` has been removed;

-  :numref:`lst:env-mlb4-mod14` the line break denoted by ♥ in
   :numref:`lst:mlb4` has been removed;

-  :numref:`lst:env-mlb4-mod15` the line break denoted by ◆ in
   :numref:`lst:mlb4` has been removed;

-  :numref:`lst:env-mlb4-mod16` the line break denoted by ♣ in
   :numref:`lst:mlb4` has been removed.

We examined each of these cases separately for clarity of explanation,
but you can combine all of the YAML settings in
:numref:`lst:env-mlb13` – :numref:`lst:env-mlb16` into one file;
alternatively, you could tell ``latexindent.pl`` to load them all by
using the following command, for example

::

    latexindent.pl -m env-mlb4.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml

which gives the output in :numref:`lst:env-mlb1-tex`.

About trailing horizontal space
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recall that on we discussed the YAML field ``removeTrailingWhitespace``,
and that it has two (binary) switches to determine if horizontal space
should be removed ``beforeProcessing`` and ``afterProcessing``. The
``beforeProcessing`` is particularly relevant when considering the
``-m`` switch; let’s consider the file shown in :numref:`lst:mlb5`,
which highlights trailing spaces.

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
 	:caption: ``removeTWS-before.yaml`` 
 	:name: lst:removeTWS-before

output from the following commands

::

    latexindent.pl -m env-mlb5.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml
    latexindent.pl -m env-mlb5.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml,removeTWS-before.yaml

is shown, respectively, in :numref:`lst:env-mlb5-modAll` and
:numref:`lst:env-mlb5-modAll-remove-WS`; note that the trailing
horizontal white space has been preserved (by default) in
:numref:`lst:env-mlb5-modAll`, while in
:numref:`lst:env-mlb5-modAll-remove-WS`, it has been removed using the
switch specified in :numref:`lst:removeTWS-before`.

 .. literalinclude:: demonstrations/env-mlb5-modAll.tex
 	:caption: ``env-mlb5.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` 
 	:name: lst:env-mlb5-modAll

 .. literalinclude:: demonstrations/env-mlb5-modAll-remove-WS.tex
 	:caption: ``env-mlb5.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` *and* :numref:`lst:removeTWS-before` 
 	:name: lst:env-mlb5-modAll-remove-WS

poly-switch line break removal and blank lines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now let’s consider the file in :numref:`lst:mlb6`, which contains
blank lines.

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
 	:caption: ``UnpreserveBlankLines.yaml`` 
 	:name: lst:UnpreserveBlankLines

running the following commands

::

    latexindent.pl -m env-mlb6.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml
    latexindent.pl -m env-mlb6.tex -l env-mlb13.yaml,env-mlb14.yaml,env-mlb15.yaml,env-mlb16.yaml,UnpreserveBlankLines.yaml

we receive the respective outputs in :numref:`lst:env-mlb6-modAll` and
:numref:`lst:env-mlb6-modAll-un-Preserve-Blank-Lines`. In
:numref:`lst:env-mlb6-modAll` we see that the multiple blank lines
have each been condensed into one blank line, but that blank lines have
*not* been removed by the poly-switches – this is because, by default,
``preserveBlankLines`` is set to ``1``. By contrast, in
:numref:`lst:env-mlb6-modAll-un-Preserve-Blank-Lines`, we have allowed
the poly-switches to remove blank lines because, in
:numref:`lst:UnpreserveBlankLines`, we have set ``preserveBlankLines``
to ``0``.

 .. literalinclude:: demonstrations/env-mlb6-modAll.tex
 	:caption: ``env-mlb6.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` 
 	:name: lst:env-mlb6-modAll

.. literalinclude:: demonstrations/env-mlb6-modAll-un-Preserve-Blank-Lines.tex
 	:caption: ``env-mlb6.tex`` using :numref:`lst:env-mlb4-mod13` – :numref:`lst:env-mlb4-mod16` *and* :numref:`lst:UnpreserveBlankLines` 
 	:name: lst:env-mlb6-modAll-un-Preserve-Blank-Lines

We can explore this further using the blank-line poly-switch value of
:math:`3`; let’s use the file given in :numref:`lst:env-mlb7-tex`.

 .. literalinclude:: demonstrations/env-mlb7.tex
 	:caption: ``env-mlb7.tex`` 
 	:name: lst:env-mlb7-tex

Upon running the following commands

::

    latexindent.pl -m env-mlb7.tex -l env-mlb12.yaml,env-mlb13.yaml
    latexindent.pl -m env-mlb7.tex -l env-mlb13.yaml,env-mlb14.yaml,UnpreserveBlankLines.yaml
                

we receive the outputs given in :numref:`lst:env-mlb7-preserve` and
:numref:`lst:env-mlb7-no-preserve`.

 .. literalinclude:: demonstrations/env-mlb7-preserve.tex
 	:caption: ``env-mlb7-preserve.tex`` 
 	:name: lst:env-mlb7-preserve

 .. literalinclude:: demonstrations/env-mlb7-no-preserve.tex
 	:caption: ``env-mlb7-no-preserve.tex`` 
 	:name: lst:env-mlb7-no-preserve

Notice that in:

-  :numref:`lst:env-mlb7-preserve` that ``\end{one}`` has added a
   blank line, because of the value of ``EndFinishesWithLineBreak`` in
   :numref:`lst:env-mlb12`, and even though the line break ahead of
   ``\begin{two}`` should have been removed (because of
   ``BeginStartsOnOwnLine`` in :numref:`lst:env-mlb13`), the blank
   line has been preserved by default;

-  :numref:`lst:env-mlb7-no-preserve`, by contrast, has had the
   additional line-break removed, because of the settings in
   :numref:`lst:UnpreserveBlankLines`.

Poly-switches for other code blocks
-----------------------------------

Rather than repeat the examples shown for the environment code blocks
(in :numref:`sec:modifylinebreaks-environments`), we choose to detail
the poly-switches for all other code blocks in
:numref:`tab:poly-switch-mapping`; note that each and every one of
these poly-switches is *off by default*, i.e, set to ``0``. Note also
that, by design, line breaks involving ``verbatim``, ``filecontents``
and ‘comment-marked’ code blocks (:numref:`lst:alignmentmarkup`) can
*not* be modified using ``latexindent.pl``.

.. label follows

.. _tab:poly-switch-mapping:

.. table::  Poly-switch mappings for all code-block types

	
	

	
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| Code block                      | Sample                           |     |                                    |
	+=================================+==================================+=====+====================================+
	| environment                     | ``before words``\ ♠              | ♠   | BeginStartsOnOwnLine               |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\begin{myenv}``\ ♥             | ♥   | BodyStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of myenv``\ ◆             | ◆   | EndStartsOnOwnLine                 |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\end{myenv}``\ ♣               | ♣   | EndFinishesWithLineBreak           |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``after words``                  |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| ifelsefi                        | ``before words``\ ♠              | ♠   | IfStartsOnOwnLine                  |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\if...``\ ♥                    | ♥   | BodyStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of if/or statement``\ ▲   | ▲   | OrStartsOnOwnLine                  |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\or``\ ▼                       | ▼   | OrFinishesWithLineBreak            |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of if/or statement``\ ★   | ★   | ElseStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\else``\ □                     | □   | ElseFinishesWithLineBreak          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of else statement``\ ◆    | ◆   | FiStartsOnOwnLine                  |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\fi``\ ♣                       | ♣   | FiFinishesWithLineBreak            |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``after words``                  |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| optionalArguments               | ``...``\ ♠                       | ♠   | LSqBStartsOnOwnLine [1]_           |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``[``\ ♥                         | ♥   | OptArgBodyStartsOnOwnLine          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of opt arg``\ ◆           | ◆   | RSqBStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``]``\ ♣                         | ♣   | RSqBFinishesWithLineBreak          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``...``                          |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| mandatoryArguments              | ``...``\ ♠                       | ♠   | LCuBStartsOnOwnLine [2]_           |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``{``\ ♥                         | ♥   | MandArgBodyStartsOnOwnLine         |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``body of mand arg``\ ◆          | ◆   | RCuBStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``}``\ ♣                         | ♣   | RCuBFinishesWithLineBreak          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``...``                          |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| commands                        | ``before words``\ ♠              | ♠   | CommandStartsOnOwnLine             |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\mycommand``\ ♥                | ♥   | CommandNameFinishesWithLineBreak   |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | <arguments>                      |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| namedGroupingBraces Brackets    | before words♠                    | ♠   | NameStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | myname♥                          | ♥   | NameFinishesWithLineBreak          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | <braces/brackets>                |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| keyEqualsValuesBracesBrackets   | before words♠                    | ♠   | KeyStartsOnOwnLine                 |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | key●=♥                           | ●   | EqualsStartsOnOwnLine              |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | <braces/brackets>                | ♥   | EqualsFinishesWithLineBreak        |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| items                           | before words♠                    | ♠   | ItemStartsOnOwnLine                |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\item``\ ♥                     | ♥   | ItemFinishesWithLineBreak          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``...``                          |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	| specialBeginEnd                 | before words♠                    | ♠   | SpecialBeginStartsOnOwnLine        |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\[``\ ♥                        | ♥   | SpecialBodyStartsOnOwnLine         |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | body of special◆                 | ◆   | SpecialEndStartsOnOwnLine          |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | ``\]``\ ♣                        | ♣   | SpecialEndFinishesWithLineBreak    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	|                                 | after words                      |     |                                    |
	+---------------------------------+----------------------------------+-----+------------------------------------+
	


Partnering BodyStartsOnOwnLine with argument-based poly-switches
----------------------------------------------------------------

Some poly-switches need to be partnered together; in particular, when
line breaks involving the *first* argument of a code block need to be
accounted for using both ``BodyStartsOnOwnLine`` (or its equivalent, see
:numref:`tab:poly-switch-mapping`) and ``LCuBStartsOnOwnLine`` for
mandatory arguments, and ``LSqBStartsOnOwnLine`` for optional arguments.

Let’s begin with the code in :numref:`lst:mycommand1` and the YAML
settings in :numref:`lst:mycom-mlb1`; with reference to
:numref:`tab:poly-switch-mapping`, the key
``CommandNameFinishesWithLineBreak`` is an alias for
``BodyStartsOnOwnLine``.

 .. literalinclude:: demonstrations/mycommand1.tex
 	:caption: ``mycommand1.tex`` 
 	:name: lst:mycommand1

Upon running the command

::

    latexindent.pl -m -l=mycom-mlb1.yaml mycommand1.tex

we obtain :numref:`lst:mycommand1-mlb1`; note that the *second*
mandatory argument beginning brace ``{`` has had its leading line break
removed, but that the *first* brace has not.

 .. literalinclude:: demonstrations/mycommand1-mlb1.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb1` 
 	:name: lst:mycommand1-mlb1

 .. literalinclude:: demonstrations/mycom-mlb1.yaml
 	:caption: ``mycom-mlb1.yaml`` 
 	:name: lst:mycom-mlb1

Now let’s change the YAML file so that it is as in
:numref:`lst:mycom-mlb2`; upon running the analogous command to that
given above, we obtain :numref:`lst:mycommand1-mlb2`; both beginning
braces ``{`` have had their leading line breaks removed.

 .. literalinclude:: demonstrations/mycommand1-mlb2.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb2` 
 	:name: lst:mycommand1-mlb2

 .. literalinclude:: demonstrations/mycom-mlb2.yaml
 	:caption: ``mycom-mlb2.yaml`` 
 	:name: lst:mycom-mlb2

Now let’s change the YAML file so that it is as in
:numref:`lst:mycom-mlb3`; upon running the analogous command to that
given above, we obtain :numref:`lst:mycommand1-mlb3`.

 .. literalinclude:: demonstrations/mycommand1-mlb3.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb3` 
 	:name: lst:mycommand1-mlb3

 .. literalinclude:: demonstrations/mycom-mlb3.yaml
 	:caption: ``mycom-mlb3.yaml`` 
 	:name: lst:mycom-mlb3

Conflicting poly-switches: sequential code blocks
-------------------------------------------------

It is very easy to have conflicting poly-switches; if we use the example
from :numref:`lst:mycommand1`, and consider the YAML settings given in
:numref:`lst:mycom-mlb4`. The output from running

::

    latexindent.pl -m -l=mycom-mlb4.yaml mycommand1.tex

is given in :numref:`lst:mycom-mlb4`.

 .. literalinclude:: demonstrations/mycommand1-mlb4.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb4` 
 	:name: lst:mycommand1-mlb4

 .. literalinclude:: demonstrations/mycom-mlb4.yaml
 	:caption: ``mycom-mlb4.yaml`` 
 	:name: lst:mycom-mlb4

Studying :numref:`lst:mycom-mlb4`, we see that the two poly-switches
are at opposition with one another:

-  on the one hand, ``LCuBStartsOnOwnLine`` should *not* start on its
   own line (as poly-switch is set to :math:`-1`);

-  on the other hand, ``RCuBFinishesWithLineBreak`` *should* finish with
   a line break.

So, which should win the conflict? As demonstrated in
:numref:`lst:mycommand1-mlb4`, it is clear that
``LCuBStartsOnOwnLine`` won this conflict, and the reason is that *the
second argument was processed after the first* – in general, the most
recently-processed code block and associated poly-switch takes priority.

We can explore this further by considering the YAML settings in
:numref:`lst:mycom-mlb5`; upon running the command

::

    latexindent.pl -m -l=mycom-mlb5.yaml mycommand1.tex

we obtain the output given in :numref:`lst:mycommand1-mlb5`.

 .. literalinclude:: demonstrations/mycommand1-mlb5.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb5` 
 	:name: lst:mycommand1-mlb5

 .. literalinclude:: demonstrations/mycom-mlb5.yaml
 	:caption: ``mycom-mlb5.yaml`` 
 	:name: lst:mycom-mlb5

As previously, the most-recently-processed code block takes priority –
as before, the second (i.e, *last*) argument. Exploring this further, we
consider the YAML settings in :numref:`lst:mycom-mlb6`, which give
associated output in :numref:`lst:mycommand1-mlb6`.

 .. literalinclude:: demonstrations/mycommand1-mlb6.tex
 	:caption: ``mycommand1.tex`` using :numref:`lst:mycom-mlb6` 
 	:name: lst:mycommand1-mlb6

 .. literalinclude:: demonstrations/mycom-mlb6.yaml
 	:caption: ``mycom-mlb6.yaml`` 
 	:name: lst:mycom-mlb6

Note that a ``%`` *has* been added to the trailing first ``}``; this is
because:

-  while processing the *first* argument, the trailing line break has
   been removed (``RCuBFinishesWithLineBreak`` set to :math:`-1`);

-  while processing the *second* argument, ``latexindent.pl`` finds that
   it does *not* begin on its own line, and so because
   ``LCuBStartsOnOwnLine`` is set to :math:`2`, it adds a comment,
   followed by a line break.

Conflicting poly-switches: nested code blocks
---------------------------------------------

Now let’s consider an example when nested code blocks have conflicting
poly-switches; we’ll use the code in :numref:`lst:nested-env`, noting
that it contains nested environments.

 .. literalinclude:: demonstrations/nested-env.tex
 	:caption: ``nested-env.tex`` 
 	:name: lst:nested-env

Let’s use the YAML settings given in
:numref:`lst:nested-env-mlb1-yaml`, which upon running the command

::

    latexindent.pl -m -l=nested-env-mlb1.yaml nested-env.tex
            

gives the output in :numref:`lst:nested-env-mlb1`.

 .. literalinclude:: demonstrations/nested-env-mlb1.tex
 	:caption: ``nested-env.tex`` using :numref:`lst:nested-env-mlb1-yaml` 
 	:name: lst:nested-env-mlb1

 .. literalinclude:: demonstrations/nested-env-mlb1.yaml
 	:caption: ``nested-env-mlb1.yaml`` 
 	:name: lst:nested-env-mlb1-yaml

In :numref:`lst:nested-env-mlb1`, let’s first of all note that both
environments have received the appropriate (default) indentation;
secondly, note that the poly-switch ``EndStartsOnOwnLine`` appears to
have won the conflict, as ``\end{one}`` has had its leading line break
removed.

To understand it, let’s talk about the three basic phases

.. label follows

.. _page:phases:

of ``latexindent.pl``:

#. Phase 1: packing, in which code blocks are replaced with unique ids,
   working from *the inside to the outside*, and then sequentially – for
   example, in :numref:`lst:nested-env`, the ``two`` environment is
   found *before* the ``one`` environment; if the -m switch is active,
   then during this phase:

   -  line breaks at the beginning of the ``body`` can be added (if
      ``BodyStartsOnOwnLine`` is :math:`1` or :math:`2`) or removed (if
      ``BodyStartsOnOwnLine`` is :math:`-1`);

   -  line breaks at the end of the body can be added (if
      ``EndStartsOnOwnLine`` is :math:`1` or :math:`2`) or removed (if
      ``EndStartsOnOwnLine`` is :math:`-1`);

   -  line breaks after the end statement can be added (if
      ``EndFinishesWithLineBreak`` is :math:`1` or :math:`2`).

#. Phase 2: indentation, in which white space is added to the begin,
   body, and end statements;

#. Phase 3: unpacking, in which unique ids are replaced by their
   *indented* code blocks; if the -m switch is active, then during this
   phase,

   -  line breaks before ``begin`` statements can be added or removed
      (depending upon ``BeginStartsOnOwnLine``);

   -  line breaks after *end* statements can be removed but *NOT* added
      (see ``EndFinishesWithLineBreak``).

With reference to :numref:`lst:nested-env-mlb1`, this means that
during Phase 1:

-  the ``two`` environment is found first, and the line break ahead of
   the ``\end{two}`` statement is removed because ``EndStartsOnOwnLine``
   is set to :math:`-1`. Importantly, because, *at this stage*,
   ``\end{two}`` *does* finish with a line break,
   ``EndFinishesWithLineBreak`` causes no action.

-  next, the ``one`` environment is found; the line break ahead of
   ``\end{one}`` is removed because ``EndStartsOnOwnLine`` is set to
   :math:`-1`.

The indentation is done in Phase 2; in Phase 3 *there is no option to
add a line break after the ``end`` statements*. We can justify this by
remembering that during Phase 3, the ``one`` environment will be found
and processed first, followed by the ``two`` environment. If the ``two``
environment were to add a line break after the ``\end{two}`` statement,
then ``latexindent.pl`` would have no way of knowing how much
indentation to add to the subsequent text (in this case, ``\end{one}``).

We can explore this further using the poly-switches in
:numref:`lst:nested-env-mlb2`; upon running the command

::

    latexindent.pl -m -l=nested-env-mlb2.yaml nested-env.tex
            

we obtain the output given in :numref:`lst:nested-env-mlb2-output`.

 .. literalinclude:: demonstrations/nested-env-mlb2.tex
 	:caption: ``nested-env.tex`` using :numref:`lst:nested-env-mlb2` 
 	:name: lst:nested-env-mlb2-output

 .. literalinclude:: demonstrations/nested-env-mlb2.yaml
 	:caption: ``nested-env-mlb2.yaml`` 
 	:name: lst:nested-env-mlb2

During Phase 1:

-  the ``two`` environment is found first, and the line break ahead of
   the ``\end{two}`` statement is not changed because
   ``EndStartsOnOwnLine`` is set to :math:`1`. Importantly, because, *at
   this stage*, ``\end{two}`` *does* finish with a line break,
   ``EndFinishesWithLineBreak`` causes no action.

-  next, the ``one`` environment is found; the line break ahead of
   ``\end{one}`` is already present, and no action is needed.

The indentation is done in Phase 2, and then in Phase 3, the ``one``
environment is found and processed first, followed by the ``two``
environment. *At this stage*, the ``two`` environment finds
``EndFinishesWithLineBreak`` is :math:`-1`, so it removes the trailing
line break; remember, at this point, ``latexindent.pl`` has completely
finished with the ``one`` environment.

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-mlep">

mlep. 2017. “One Sentence Per Line.” August 16.
https://github.com/cmhughes/latexindent.pl/issues/81.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-jowens">

Owens, John. 2017. “Paragraph Line Break Routine Removal.” May 27.
https://github.com/cmhughes/latexindent.pl/issues/33.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-textwrap">

“Text:Wrap Perl Module.” 2017. Accessed May 1.
http://perldoc.perl.org/Text/Wrap.html.

.. raw:: html

   </div>

.. raw:: html

   </div>

.. [1]
   LSqB stands for Left Square Bracket

.. [2]
   LCuB stands for Left Curly Brace
