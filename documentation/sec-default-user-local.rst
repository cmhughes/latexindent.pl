.. label follows

.. _sec:defuseloc:

defaultSettings.yaml
====================

``latexindent.pl`` loads its settings from ``defaultSettings.yaml``. The
idea is to separate the behaviour of the script from the internal
working – this is very similar to the way that we separate content from
form when writing our documents in LaTeX.

If you look in ``defaultSettings.yaml`` you’ll find the switches that
govern the behaviour of ``latexindent.pl``. If you’re not sure where
``defaultSettings.yaml`` resides on your computer, don’t worry as
``indent.log`` will tell you where to find it. ``defaultSettings.yaml``
is commented, but here is a description of what each switch is designed
to do. The default value is given in each case; whenever you see
*integer* in *this* section, assume that it must be greater than or
equal to ``0`` unless otherwise stated.

.. describe:: fileExtensionPreference:fields

``latexindent.pl`` can be called to act on a file without specifying the
file extension. For example we can call

::

    latexindent.pl myfile

in

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``fileExtensionPreference`` 
 	:name: lst:fileExtensionPreference
 	:lines: 38-42
 	:linenos:
 	:lineno-start: 38

which case the script will look for ``myfile`` with the extensions
specified in ``fileExtensionPreference`` in their numeric order. If no
match is found, the script will exit. As with all of the fields, you
should change and/or add to this as necessary.

Calling ``latexindent.pl myfile`` with the (default) settings specified
in :numref:`lst:fileExtensionPreference` means that the script will
first look for ``myfile.tex``, then ``myfile.sty``, ``myfile.cls``, and
finally ``myfile.bib`` in order [1]_.

.. describe:: backupExtension:extension name

If you call ``latexindent.pl`` with the ``-w`` switch (to overwrite
``myfile.tex``) then it will create a backup file before doing any
indentation; the default extension is ``.bak``, so, for example,
``myfile.bak0`` would be created when calling
``latexindent.pl myfile.tex`` for the first time.

By default, every time you subsequently call ``latexindent.pl`` with the
``-w`` to act upon ``myfile.tex``, it will create successive back up
files: ``myfile.bak1``, ``myfile.bak2``, etc.

.. describe:: onlyOneBackUp:integer

.. label follows

.. _page:onlyonebackup:

If you don’t want a backup for every time that you call
``latexindent.pl`` (so you don’t want ``myfile.bak1``, ``myfile.bak2``,
etc) and you simply want ``myfile.bak`` (or whatever you chose
``backupExtension`` to be) then change ``onlyOneBackUp`` to ``1``; the
default value of ``onlyOneBackUp`` is ``0``.

.. describe:: maxNumberOfBackUps:integer

Some users may only want a finite number of backup files, say at most
:math:`3`, in which case, they can change this switch. The smallest
value of ``maxNumberOfBackUps`` is :math:`0` which will *not* prevent
backup files being made; in this case, the behaviour will be dictated
entirely by ``onlyOneBackUp``. The default value of
``maxNumberOfBackUps`` is ``0``.

.. describe:: cycleThroughBackUps:integer

Some users may wish to cycle through backup files, by deleting the
oldest backup file and keeping only the most recent; for example, with
``maxNumberOfBackUps: 4``, and ``cycleThroughBackUps`` set to ``1`` then
the ``copy`` procedure given below would be obeyed.

::

    copy myfile.bak1 to myfile.bak0
    copy myfile.bak2 to myfile.bak1
    copy myfile.bak3 to myfile.bak2
    copy myfile.bak4 to myfile.bak3
        

The default value of ``cycleThroughBackUps`` is ``0``.

.. describe:: logFilePreferences:fields

``latexindent.pl`` writes information to ``indent.log``, some of which
can be customized by changing ``logFilePreferences``; see
:numref:`lst:logFilePreferences`. If you load your own user settings
(see :numref:`sec:indentconfig`) then ``latexindent.pl`` will detail
them in ``indent.log``; you can choose not to have the details logged by
switching ``showEveryYamlRead`` to ``0``. Once all of your settings have
been loaded, you can see the amalgamated settings in the log file by
switching ``showAmalgamatedSettings`` to ``1``, if you wish.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``logFilePreferences`` 
 	:name: lst:logFilePreferences
 	:lines: 79-89
 	:linenos:
 	:lineno-start: 79

When either of the ``trace`` modes (see
:ref:`page page:traceswitch <page:traceswitch>`) are active, you will
receive detailed information in ``indent.log``. You can specify
character strings to appear before and after the notification of a found
code block using, respectively, ``showDecorationStartCodeBlockTrace``
and ``showDecorationFinishCodeBlockTrace``. A demonstration is given in
:numref:`app:logfile-demo`.

The log file will end with the characters given in ``endLogFileWith``,
and will report the ``GitHub`` address of ``latexindent.pl`` to the log
file if ``showGitHubInfoFooter`` is set to ``1``.

``latexindent.pl`` uses the ``log4perl`` module (“Log4perl Perl Module”
2017) to handle the creation of the logfile. You can specify the layout
of the information given in the logfile using any of the ``Log Layouts``
detailed at (“Log4perl Perl Module” 2017).

.. describe:: verbatimEnvironments:fields

A field that contains a list of environments that you would like left
completely alone – no indentation will be performed on environments that
you have specified in this field, see
:numref:`lst:verbatimEnvironments`.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``verbatimEnvironments`` 
 	:name: lst:verbatimEnvironments
 	:lines: 93-96
 	:linenos:
 	:lineno-start: 93

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``verbatimCommands`` 
 	:name: lst:verbatimCommands
 	:lines: 99-101
 	:linenos:
 	:lineno-start: 99

Note that if you put an environment in ``verbatimEnvironments`` and in
other fields such as ``lookForAlignDelims`` or ``noAdditionalIndent``
then ``latexindent.pl`` will *always* prioritize
``verbatimEnvironments``.

.. describe:: verbatimCommands:fields

A field that contains a list of commands that are verbatim commands, for
example ``\verb``; any commands populated in this field are protected
from line breaking routines (only relevant if the ``-m`` is active, see
:numref:`sec:modifylinebreaks`).

.. describe:: noIndentBlock:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``noIndentBlock`` 
 	:name: lst:noIndentBlock
 	:lines: 107-109
 	:linenos:
 	:lineno-start: 107

If you have a block of code that you don’t want ``latexindent.pl`` to
touch (even if it is *not* a verbatim-like environment) then you can
wrap it in an environment from ``noIndentBlock``; you can use any name
you like for this, provided you populate it as demonstrate in
:numref:`lst:noIndentBlock`.

Of course, you don’t want to have to specify these as null environments
in your code, so you use them with a comment symbol, ``%``, followed by
as many spaces (possibly none) as you like; see
:numref:`lst:noIndentBlockdemo` for example.

.. code-block:: latex
   :caption: ``noIndentBlock`` demonstration 
   :name: lst:noIndentBlockdemo

    %(*@@*) \begin{noindent}
            this code
                    won't
         be touched
                        by
                 latexindent.pl!
    %(*@@*)\end{noindent}
        

.. describe:: removeTrailingWhitespace:fields

.. label follows

.. _yaml:removeTrailingWhitespace:

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: removeTrailingWhitespace 
 	:name: lst:removeTrailingWhitespace
 	:lines: 112-114
 	:linenos:
 	:lineno-start: 112

.. code-block:: latex
   :caption: removeTrailingWhitespace (alt) 
   :name: lst:removeTrailingWhitespace-alt

    removeTrailingWhitespace: 1

Trailing white space can be removed both *before* and *after* processing
the document, as detailed in :numref:`lst:removeTrailingWhitespace`;
each of the fields can take the values ``0`` or ``1``. See
:numref:`lst:removeTWS-before` and :numref:`lst:env-mlb5-modAll` and
:numref:`lst:env-mlb5-modAll-remove-WS` for before and after results.
Thanks to Voßkuhle (2013) for providing this feature.

You can specify ``removeTrailingWhitespace`` simply as ``0`` or ``1``,
if you wish; in this case, ``latexindent.pl`` will set both
``beforeProcessing`` and ``afterProcessing`` to the value you specify;
see :numref:`lst:removeTrailingWhitespace-alt`. .. describe::
fileContentsEnvironments:field

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``fileContentsEnvironments`` 
 	:name: lst:fileContentsEnvironments
 	:lines: 118-120
 	:linenos:
 	:lineno-start: 118

Before ``latexindent.pl`` determines the difference between preamble (if
any) and the main document, it first searches for any of the
environments specified in ``fileContentsEnvironments``, see
:numref:`lst:fileContentsEnvironments`. The behaviour of
``latexindent.pl`` on these environments is determined by their location
(preamble or not), and the value ``indentPreamble``, discussed next.

.. describe:: indentPreamble:0\|1

The preamble of a document can sometimes contain some trickier code for
``latexindent.pl`` to operate upon. By default, ``latexindent.pl`` won’t
try to operate on the preamble (as ``indentPreamble`` is set to ``0``,
by default), but if you’d like ``latexindent.pl`` to try then change
``indentPreamble`` to ``1``.

.. describe:: lookForPreamble:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: lookForPreamble 
 	:name: lst:lookForPreamble
 	:lines: 126-130
 	:linenos:
 	:lineno-start: 126

Not all files contain preamble; for example, ``sty``, ``cls`` and
``bib`` files typically do *not*. Referencing
:numref:`lst:lookForPreamble`, if you set, for example, ``.tex`` to
``0``, then regardless of the setting of the value of
``indentPreamble``, preamble will not be assumed when operating upon
``.tex`` files. .. describe:: preambleCommandsBeforeEnvironments:0\|1

Assuming that ``latexindent.pl`` is asked to operate upon the preamble
of a document, when this switch is set to ``0`` then environment code
blocks will be sought first, and then command code blocks. When this
switch is set to ``1``, commands will be sought first. The example that
first motivated this switch contained the code given in
:numref:`lst:motivatepreambleCommandsBeforeEnvironments`.

.. code-block:: latex
   :caption: Motivating ``preambleCommandsBeforeEnvironments`` 
   :name: lst:motivatepreambleCommandsBeforeEnvironments

    ...
    preheadhook={\begin{mdframed}[style=myframedstyle]},
    postfoothook=\end{mdframed},
    ...

.. describe:: defaultIndent:horizontal space

This is the default indentation (``\t`` means a tab, and is the default
value) used in the absence of other details for the command or
environment we are working with; see ``indentRules`` in
:numref:`sec:noadd-indent-rules` for more details.

If you’re interested in experimenting with ``latexindent.pl`` then you
can *remove* all indentation by setting ``defaultIndent: ""``.

.. describe:: lookForAlignDelims:fields

.. label follows

.. _yaml:lookforaligndelims:

.. code-block:: latex
   :caption: ``lookForAlignDelims`` (basic) 
   :name: lst:aligndelims:basic

    lookForAlignDelims:
       tabular: 1
       tabularx: 1
       longtable: 1
       array: 1
       matrix: 1
       ...
        

This contains a list of environments and/or commands that are operated
upon in a special way by ``latexindent.pl`` (see
:numref:`lst:aligndelims:basic`). In fact, the fields in
``lookForAlignDelims`` can actually take two different forms: the
*basic* version is shown in :numref:`lst:aligndelims:basic` and the
*advanced* version in :numref:`lst:aligndelims:advanced`; we will
discuss each in turn.

The environments specified in this field will be operated on in a
special way by ``latexindent.pl``. In particular, it will try and align
each column by its alignment tabs. It does have some limitations
(discussed further in :numref:`sec:knownlimitations`), but in many
cases it will produce results such as those in
:numref:`lst:tabularbefore:basic` and
:numref:`lst:tabularafter:basic`.

If you find that ``latexindent.pl`` does not perform satisfactorily on
such environments then you can set the relevant key to ``0``, for
example ``tabular: 0``; alternatively, if you just want to ignore
*specific* instances of the environment, you could wrap them in
something from ``noIndentBlock`` (see :numref:`lst:noIndentBlock`).

 .. literalinclude:: demonstrations/tabular1.tex
 	:caption: ``tabular1.tex`` 
 	:name: lst:tabularbefore:basic

 .. literalinclude:: demonstrations/tabular1-default.tex
 	:caption: ``tabular1.tex`` default output 
 	:name: lst:tabularafter:basic

If, for example, you wish to remove the alignment of the ``\\`` within a
delimiter-aligned block, then the advanced form of
``lookForAlignDelims`` shown in :numref:`lst:aligndelims:advanced` is
for you.

 .. literalinclude:: demonstrations/tabular.yaml
 	:caption: ``tabular.yaml`` 
 	:name: lst:aligndelims:advanced

Note that you can use a mixture of the basic and advanced form: in
:numref:`lst:aligndelims:advanced` ``tabular`` and ``tabularx`` are
advanced and ``longtable`` is basic. When using the advanced form, each
field should receive at least 1 sub-field, and *can* (but does not have
to) receive any of the following fields:

-  ``delims``: binary switch (0 or 1) equivalent to simply specifying,
   for example, ``tabular: 1`` in the basic version shown in
   :numref:`lst:aligndelims:basic`. If ``delims`` is set to ``0`` then
   the align at ampersand routine will not be called for this code block
   (default: 1);

-  ``alignDoubleBackSlash``: binary switch (0 or 1) to determine if
   ``\\`` should be aligned (default: 1);

-  ``spacesBeforeDoubleBackSlash``: optionally, specifies the number
   (integer :math:`\geq` 0) of spaces to be inserted before ``\\``
   (default: 1). [2]_

-  ``multiColumnGrouping``: binary switch (0 or 1) that details if
   ``latexindent.pl`` should group columns above and below a
   ``\multicolumn`` command (default: 0);

-  ``alignRowsWithoutMaxDelims``: binary switch (0 or 1) that details if
   rows that do not contain the maximum number of delimeters should be
   formatted so as to have the ampersands aligned (default: 1);

-  ``spacesBeforeAmpersand``: optionally specifies the number (integer
   :math:`\geq` 0) of spaces to be placed *before* ampersands (default:
   1);

-  ``spacesAfterAmpersand``: optionally specifies the number (integer
   :math:`\geq` 0) of spaces to be placed *After* ampersands (default:
   1);

-  ``justification``: optionally specifies the justification of each
   cell as either *left* or *right* (default: left).

We will explore each of these features using the file ``tabular2.tex``
in :numref:`lst:tabular2` (which contains a ``\multicolumn`` command),
and the YAML files in :numref:`lst:tabular2YAML` –
:numref:`lst:tabular8YAML`.

 .. literalinclude:: demonstrations/tabular2.tex
 	:caption: ``tabular2.tex`` 
 	:name: lst:tabular2

 .. literalinclude:: demonstrations/tabular2.yaml
 	:caption: ``tabular2.yaml`` 
 	:name: lst:tabular2YAML

 .. literalinclude:: demonstrations/tabular3.yaml
 	:caption: ``tabular3.yaml`` 
 	:name: lst:tabular3YAML

 .. literalinclude:: demonstrations/tabular4.yaml
 	:caption: ``tabular4.yaml`` 
 	:name: lst:tabular4YAML

 .. literalinclude:: demonstrations/tabular5.yaml
 	:caption: ``tabular5.yaml`` 
 	:name: lst:tabular5YAML

 .. literalinclude:: demonstrations/tabular6.yaml
 	:caption: ``tabular6.yaml`` 
 	:name: lst:tabular6YAML

 .. literalinclude:: demonstrations/tabular7.yaml
 	:caption: ``tabular7.yaml`` 
 	:name: lst:tabular7YAML

 .. literalinclude:: demonstrations/tabular8.yaml
 	:caption: ``tabular8.yaml`` 
 	:name: lst:tabular8YAML

On running the commands

::

    latexindent.pl tabular2.tex 
    latexindent.pl tabular2.tex -l tabular2.yaml
    latexindent.pl tabular2.tex -l tabular3.yaml
    latexindent.pl tabular2.tex -l tabular2.yaml,tabular4.yaml
    latexindent.pl tabular2.tex -l tabular2.yaml,tabular5.yaml
    latexindent.pl tabular2.tex -l tabular2.yaml,tabular6.yaml
    latexindent.pl tabular2.tex -l tabular2.yaml,tabular7.yaml
    latexindent.pl tabular2.tex -l tabular2.yaml,tabular8.yaml
            

we obtain the respective outputs given in
:numref:`lst:tabular2-default` – :numref:`lst:tabular2-mod8`.

 .. literalinclude:: demonstrations/tabular2-default.tex
 	:caption: ``tabular2.tex`` default output 
 	:name: lst:tabular2-default

 .. literalinclude:: demonstrations/tabular2-mod2.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` 
 	:name: lst:tabular2-mod2

 .. literalinclude:: demonstrations/tabular2-mod3.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular3YAML` 
 	:name: lst:tabular2-mod3

 .. literalinclude:: demonstrations/tabular2-mod4.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` and :numref:`lst:tabular4YAML` 
 	:name: lst:tabular2-mod4

 .. literalinclude:: demonstrations/tabular2-mod5.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` and :numref:`lst:tabular5YAML` 
 	:name: lst:tabular2-mod5

 .. literalinclude:: demonstrations/tabular2-mod6.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` and :numref:`lst:tabular6YAML` 
 	:name: lst:tabular2-mod6

 .. literalinclude:: demonstrations/tabular2-mod7.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` and :numref:`lst:tabular7YAML` 
 	:name: lst:tabular2-mod7

 .. literalinclude:: demonstrations/tabular2-mod8.tex
 	:caption: ``tabular2.tex`` using :numref:`lst:tabular2YAML` and :numref:`lst:tabular8YAML` 
 	:name: lst:tabular2-mod8

Notice in particular:

-  in both :numref:`lst:tabular2-default` and
   :numref:`lst:tabular2-mod2` all rows have been aligned at the
   ampersand, even those that do not contain the maximum number of
   ampersands (3 ampersands, in this case);

-  in :numref:`lst:tabular2-default` the columns have been aligned at
   the ampersand;

-  in :numref:`lst:tabular2-mod2` the ``\multicolumn`` command has
   grouped the :math:`2` columns beneath *and* above it, because
   ``multiColumnGrouping`` is set to :math:`1` in
   :numref:`lst:tabular2YAML`;

-  in :numref:`lst:tabular2-mod3` rows 3 and 6 have *not* been aligned
   at the ampersand, because ``alignRowsWithoutMaxDelims`` has been to
   set to :math:`0` in :numref:`lst:tabular3YAML`; however, the ``\\``
   *have* still been aligned;

-  in :numref:`lst:tabular2-mod4` the columns beneath and above the
   ``\multicolumn`` commands have been grouped (because
   ``multiColumnGrouping`` is set to :math:`1`), and there are at least
   :math:`4` spaces *before* each aligned ampersand because
   ``spacesBeforeAmpersand`` is set to :math:`4`;

-  in :numref:`lst:tabular2-mod5` the columns beneath and above the
   ``\multicolumn`` commands have been grouped (because
   ``multiColumnGrouping`` is set to :math:`1`), and there are at least
   :math:`4` spaces *after* each aligned ampersand because
   ``spacesAfterAmpersand`` is set to :math:`4`;

-  in :numref:`lst:tabular2-mod6` the ``\\`` have *not* been aligned,
   because ``alignDoubleBackSlash`` is set to ``0``, otherwise the
   output is the same as :numref:`lst:tabular2-mod2`;

-  in :numref:`lst:tabular2-mod7` the ``\\`` *have* been aligned, and
   because ``spacesBeforeDoubleBackSlash`` is set to ``0``, there are no
   spaces ahead of them; the output is otherwise the same as
   :numref:`lst:tabular2-mod2`.

-  in :numref:`lst:tabular2-mod8` the cells have been
   *right*-justified; note that cells above and below the ``\multicol``
   statements have still been group correctly, because of the settings
   in :numref:`lst:tabular2YAML`.

As of Version 3.0, the alignment routine works on mandatory and optional
arguments within commands, and also within ‘special’ code blocks (see
``specialBeginEnd`` on
:ref:`page yaml:specialBeginEnd <yaml:specialBeginEnd>`); for example,
assuming that you have a command called ``\matrix`` and that it is
populated within ``lookForAlignDelims`` (which it is, by default), and
that you run the command

::

    latexindent.pl matrix1.tex 
        

then the before-and-after results shown in :numref:`lst:matrixbefore`
and :numref:`lst:matrixafter` are achievable by default.

 .. literalinclude:: demonstrations/matrix1.tex
 	:caption: ``matrix1.tex`` 
 	:name: lst:matrixbefore

 .. literalinclude:: demonstrations/matrix1-default.tex
 	:caption: ``matrix1.tex`` default output 
 	:name: lst:matrixafter

If you have blocks of code that you wish to align at the & character
that are *not* wrapped in, for example, ``\begin{tabular}``
…\ ``\end{tabular}``, then you can use the mark up illustrated in
:numref:`lst:alignmentmarkup`; the default output is shown in
:numref:`lst:alignmentmarkup-default`. Note that the ``%*`` must be
next to each other, but that there can be any number of spaces (possibly
none) between the ``*`` and ``\begin{tabular}``; note also that you may
use any environment name that you have specified in
``lookForAlignDelims``.

 .. literalinclude:: demonstrations/align-block.tex
 	:caption: ``align-block.tex`` 
 	:name: lst:alignmentmarkup

 .. literalinclude:: demonstrations/align-block-default.tex
 	:caption: ``align-block.tex`` default output 
 	:name: lst:alignmentmarkup-default

With reference to :numref:`tab:code-blocks` and the, yet undiscussed,
fields of ``noAdditionalIndent`` and ``indentRules`` (see
:numref:`sec:noadd-indent-rules`), these comment-marked blocks are
considered ``environments``.

.. describe:: indentAfterItems:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``indentAfterItems`` 
 	:name: lst:indentafteritems
 	:lines: 183-187
 	:linenos:
 	:lineno-start: 183

The environment names specified in ``indentAfterItems`` tell
``latexindent.pl`` to look for ``\item`` commands; if these switches are
set to ``1`` then indentation will be performed so as indent the code
after each ``item``. A demonstration is given in
:numref:`lst:itemsbefore` and :numref:`lst:itemsafter`

 .. literalinclude:: demonstrations/items1.tex
 	:caption: ``items1.tex`` 
 	:name: lst:itemsbefore

 .. literalinclude:: demonstrations/items1-default.tex
 	:caption: ``items1.tex`` default output 
 	:name: lst:itemsafter

.. describe:: itemNames:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``itemNames`` 
 	:name: lst:itemNames
 	:lines: 193-195
 	:linenos:
 	:lineno-start: 193

| If you have your own ``item`` commands (perhaps you prefer to use
  ``myitem``, for example) then you can put populate them in
  ``itemNames``. For example, users of the ``exam`` document class might
  like to add ``parts`` to ``indentAfterItems`` and ``part`` to
  ``itemNames`` to their user settings (see :numref:`sec:indentconfig`
  for details of how to configure user settings, and
  :numref:`lst:mysettings`
| in particular

.. label follows

.. _page:examsettings:

.)

.. describe:: specialBeginEnd:fields

.. label follows

.. _yaml:specialBeginEnd:

The fields specified in ``specialBeginEnd`` are, in their default state,
focused on math mode begin and end statements, but there is no
requirement for this to be the case; :numref:`lst:specialBeginEnd`
shows the default settings of ``specialBeginEnd``.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``specialBeginEnd`` 
 	:name: lst:specialBeginEnd
 	:lines: 199-212
 	:linenos:
 	:lineno-start: 199

The field ``displayMath`` represents ``\[...\]``, ``inlineMath``
represents ``$...$`` and ``displayMathTex`` represents ``$$...$$``. You
can, of course, rename these in your own YAML files (see
:numref:`sec:localsettings`); indeed, you might like to set up your
own special begin and end statements.

A demonstration of the before-and-after results are shown in
:numref:`lst:specialbefore` and :numref:`lst:specialafter`.

 .. literalinclude:: demonstrations/special1.tex
 	:caption: ``special1.tex`` before 
 	:name: lst:specialbefore

 .. literalinclude:: demonstrations/special1-default.tex
 	:caption: ``special1.tex`` default output 
 	:name: lst:specialafter

For each field, ``lookForThis`` is set to ``1`` by default, which means
that ``latexindent.pl`` will look for this pattern; you can tell
``latexindent.pl`` not to look for the pattern, by setting
``lookForThis`` to ``0``.

There are examples in which it is advantageous to search for
``specialBeginEnd`` fields *before* searching for commands, and the
``specialBeforeCommand`` switch controls this behaviour. For example,
consider the file shown in :numref:`lst:specialLRbefore`.

 .. literalinclude:: demonstrations/specialLR.tex
 	:caption: ``specialLR.tex`` 
 	:name: lst:specialLRbefore

Now consider the YAML files shown in
:numref:`lst:specialsLeftRight-yaml` and
:numref:`lst:specialBeforeCommand-yaml`

 .. literalinclude:: demonstrations/specialsLeftRight.yaml
 	:caption: ``specialsLeftRight.yaml`` 
 	:name: lst:specialsLeftRight-yaml

 .. literalinclude:: demonstrations/specialBeforeCommand.yaml
 	:caption: ``specialBeforeCommand.yaml`` 
 	:name: lst:specialBeforeCommand-yaml

Upon running the following commands

::

    latexindent.pl specialLR.tex -l=specialsLeftRight.yaml      
    latexindent.pl specialLR.tex -l=specialsLeftRight.yaml,specialBeforeCommand.yaml      
        

we receive the respective outputs in
:numref:`lst:specialLR-comm-first-tex` and
:numref:`lst:specialLR-special-first-tex`.

 .. literalinclude:: demonstrations/specialLR-comm-first.tex
 	:caption: ``specialLR.tex`` using :numref:`lst:specialsLeftRight-yaml` 
 	:name: lst:specialLR-comm-first-tex

 .. literalinclude:: demonstrations/specialLR-special-first.tex
 	:caption: ``specialLR.tex`` using :numref:`lst:specialsLeftRight-yaml` and :numref:`lst:specialBeforeCommand-yaml` 
 	:name: lst:specialLR-special-first-tex

Notice that in:

-  :numref:`lst:specialLR-comm-first-tex` the ``\left`` has been
   treated as a *command*, with one optional argument;

-  :numref:`lst:specialLR-special-first-tex` the ``specialBeginEnd``
   pattern in :numref:`lst:specialsLeftRight-yaml` has been obeyed
   because :numref:`lst:specialBeforeCommand-yaml` specifies that the
   ``specialBeginEnd`` should be sought *before* commands.

You can,optionally, specify the ``middle`` field for anything that you
specify in ``specialBeginEnd``. For example, let’s consider the ``.tex``
file in :numref:`lst:special2`.

 .. literalinclude:: demonstrations/special2.tex
 	:caption: ``special2.tex`` 
 	:name: lst:special2

Upon saving the YAML settings in :numref:`lst:middle-yaml` and
:numref:`lst:middle1-yaml` and running the commands

::

    latexindent.pl special2.tex -l=middle
    latexindent.pl special2.tex -l=middle1
        

then we obtain the output given in :numref:`lst:special2-mod1` and
:numref:`lst:special2-mod2`.

 .. literalinclude:: demonstrations/middle.yaml
 	:caption: ``middle.yaml`` 
 	:name: lst:middle-yaml

 .. literalinclude:: demonstrations/special2-mod1.tex
 	:caption: ``special2.tex`` using :numref:`lst:middle-yaml` 
 	:name: lst:special2-mod1

 .. literalinclude:: demonstrations/middle1.yaml
 	:caption: ``middle1.yaml`` 
 	:name: lst:middle1-yaml

 .. literalinclude:: demonstrations/special2-mod2.tex
 	:caption: ``special2.tex`` using :numref:`lst:middle1-yaml` 
 	:name: lst:special2-mod2

We note that:

-  in :numref:`lst:special2-mod1` the bodies of each of the ``Elsif``
   statements have been indented appropriately;

-  the ``Else`` statement has *not* been indented appropriately in
   :numref:`lst:special2-mod1` – read on!

-  we have specified multiple settings for the ``middle`` field using
   the syntax demonstrated in :numref:`lst:middle1-yaml` so that the
   body of the ``Else`` statement has been indented appropriately in
   :numref:`lst:special2-mod2`.

.. describe:: indentAfterHeadings:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``indentAfterHeadings`` 
 	:name: lst:indentAfterHeadings
 	:lines: 222-231
 	:linenos:
 	:lineno-start: 222

This field enables the user to specify indentation rules that take
effect after heading commands such as ``\part``, ``\chapter``,
``\section``, ``\subsection*``, or indeed any user-specified command
written in this field. [3]_

| The default settings do *not* place indentation after a heading, but
  you can easily switch them on by changing
| ``indentAfterThisHeading: 0`` to
| ``indentAfterThisHeading: 1``. The ``level`` field tells
  ``latexindent.pl`` the hierarchy of the heading structure in your
  document. You might, for example, like to have both ``section`` and
  ``subsection`` set with ``level: 3`` because you do not want the
  indentation to go too deep.

You can add any of your own custom heading commands to this field,
specifying the ``level`` as appropriate. You can also specify your own
indentation in ``indentRules`` (see :numref:`sec:noadd-indent-rules`);
you will find the default ``indentRules`` contains ``chapter: " "``
which tells ``latexindent.pl`` simply to use a space character after
headings (once ``indent`` is set to ``1`` for ``chapter``).

For example, assuming that you have the code in
:numref:`lst:headings1yaml` saved into ``headings1.yaml``, and that
you have the text from :numref:`lst:headings1` saved into
``headings1.tex``.

 .. literalinclude:: demonstrations/headings1.yaml
 	:caption: ``headings1.yaml`` 
 	:name: lst:headings1yaml

 .. literalinclude:: demonstrations/headings1.tex
 	:caption: ``headings1.tex`` 
 	:name: lst:headings1

If you run the command

::

    latexindent.pl headings1.tex -l=headings1.yaml

then you should receive the output given in
:numref:`lst:headings1-mod1`.

 .. literalinclude:: demonstrations/headings1-mod1.tex
 	:caption: ``headings1.tex`` using :numref:`lst:headings1yaml` 
 	:name: lst:headings1-mod1

 .. literalinclude:: demonstrations/headings1-mod2.tex
 	:caption: ``headings1.tex`` second modification 
 	:name: lst:headings1-mod2

Now say that you modify the ``YAML`` from :numref:`lst:headings1yaml`
so that the ``paragraph`` ``level`` is ``1``; after running

::

    latexindent.pl headings1.tex -l=headings1.yaml

you should receive the code given in :numref:`lst:headings1-mod2`;
notice that the ``paragraph`` and ``subsection`` are at the same
indentation level.

.. describe:: maximumIndentation:horizontal space

You can control the maximum indentation given to your file by specifying
the ``maximumIndentation`` field as horizontal space (but *not*
including tabs). This feature uses the ``Text::Tabs`` module (“Text:Tabs
Perl Module” 2017), and is *off* by default.

For example, consider the example shown in :numref:`lst:mult-nested`
together with the default output shown in
:numref:`lst:mult-nested-default`.

 .. literalinclude:: demonstrations/mult-nested.tex
 	:caption: ``mult-nested.tex`` 
 	:name: lst:mult-nested

 .. literalinclude:: demonstrations/mult-nested-default.tex
 	:caption: ``mult-nested.tex`` default output 
 	:name: lst:mult-nested-default

Now say that, for example, you have the ``max-indentation1.yaml`` from
:numref:`lst:max-indentation1yaml` and that you run the following
command:

::

    latexindent.pl mult-nested.tex -l=max-indentation1
        

You should receive the output shown in
:numref:`lst:mult-nested-max-ind1`.

 .. literalinclude:: demonstrations/max-indentation1.yaml
 	:caption: ``max-indentation1.yaml`` 
 	:name: lst:max-indentation1yaml

 .. literalinclude:: demonstrations/mult-nested-max-ind1.tex
 	:caption: ``mult-nested.tex`` using :numref:`lst:max-indentation1yaml` 
 	:name: lst:mult-nested-max-ind1

Comparing the output in :numref:`lst:mult-nested-default` and
:numref:`lst:mult-nested-max-ind1` we notice that the (default) tabs
of indentation have been replaced by a single space.

In general, when using the ``maximumIndentation`` feature, any leading
tabs will be replaced by equivalent spaces except, of course, those
found in ``verbatimEnvironments`` (see
:numref:`lst:verbatimEnvironments`) or ``noIndentBlock`` (see
:numref:`lst:noIndentBlock`).

.. label follows

.. _subsubsec:code-blocks:

The code blocks known latexindent.pl
------------------------------------

As of Version 3.0, ``latexindent.pl`` processes documents using code
blocks; each of these are shown in :numref:`tab:code-blocks`.

.. label follows

.. _tab:code-blocks:

.. table::  Code blocks known to ``latexindent.pl``

	
	
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| Code block                      | characters allowed in name                                                           | example                                                                               |
	+=================================+======================================================================================+=======================================================================================+
	| environments                    | ``a-zA-Z@\*0-9_\\``                                                                  | ``\begin{myenv}body of myenv\end{myenv}``                                             |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| optionalArguments               | *inherits* name from parent (e.g environment name)                                   | ``[opt arg text]``                                                                    |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| mandatoryArguments              | *inherits* name from parent (e.g environment name)                                   | ``{mand arg text}``                                                                   |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| commands                        | ``+a-zA-Z@\*0-9_\:``                                                                 | ``\mycommand``\ <arguments>                                                           |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| keyEqualsValuesBracesBrackets   | ``a-zA-Z@\*0-9_\/.\h\{\}:\#-``                                                       | ``my key/.style=``\ <arguments>                                                       |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| namedGroupingBracesBrackets     | ``0-9\.a-zA-Z@\*><``                                                                 | ``in``\ <arguments>                                                                   |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| UnNamedGroupingBracesBrackets   | *No name!*                                                                           | ``{`` or ``[`` or ``,`` or ``&`` or ``)`` or ``(`` or ``$`` followed by <arguments>   |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| ifElseFi                        | ``@a-zA-Z`` but must begin with either ``\if`` of ``\@if``                           | ``\ifnum......\else...\fi``                                                           |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| items                           | User specified, see :numref:`lst:indentafteritems` and :numref:`lst:itemNames`       | ``\begin{enumerate}  \item ...\end{enumerate}``                                       |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| specialBeginEnd                 | User specified, see :numref:`lst:specialBeginEnd`                                    | ``\[  ...\]``                                                                         |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| afterHeading                    | User specified, see :numref:`lst:indentAfterHeadings`                                | ``\chapter{title}  ...\section{title}``                                               |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	| filecontents                    | User specified, see :numref:`lst:fileContentsEnvironments`                           | ``\begin{filecontents}...\end{filecontents}``                                         |
	+---------------------------------+--------------------------------------------------------------------------------------+---------------------------------------------------------------------------------------+
	


We will refer to these code blocks in what follows.

.. label follows

.. _sec:noadd-indent-rules:

noAdditionalIndent and indentRules
----------------------------------

``latexindent.pl`` operates on files by looking for code blocks, as
detailed in :numref:`subsubsec:code-blocks`; for each type of code
block in :numref:`tab:code-blocks` (which we will call a *<thing>* in
what follows) it searches YAML fields for information in the following
order:

#. ``noAdditionalIndent`` for the *name* of the current *<thing>*;

#. ``indentRules`` for the *name* of the current *<thing>*;

#. ``noAdditionalIndentGlobal`` for the *type* of the current *<thing>*;

#. ``indentRulesGlobal`` for the *type* of the current *<thing>*.

Using the above list, the first piece of information to be found will be
used; failing that, the value of ``defaultIndent`` is used. If
information is found in multiple fields, the first one according to the
list above will be used; for example, if information is present in both
``indentRules`` and in ``noAdditionalIndentGlobal``, then the
information from ``indentRules`` takes priority.

We now present details for the different type of code blocks known to
``latexindent.pl``, as detailed in :numref:`tab:code-blocks`; for
reference, there follows a list of the code blocks covered.

.. label follows

.. _subsubsec:env-and-their-args:

Environments and their arguments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are a few different YAML switches governing the indentation of
environments; let’s start with the code shown in
:numref:`lst:myenvtex`.

 .. literalinclude:: demonstrations/myenvironment-simple.tex
 	:caption: ``myenv.tex`` 
 	:name: lst:myenvtex

.. describe:: noAdditionalIndent:fields

If we do not wish ``myenv`` to receive any additional indentation, we
have a few choices available to us, as demonstrated in
:numref:`lst:myenv-noAdd1` and :numref:`lst:myenv-noAdd2`.

 .. literalinclude:: demonstrations/myenv-noAdd1.yaml
 	:caption: ``myenv-noAdd1.yaml`` 
 	:name: lst:myenv-noAdd1

 .. literalinclude:: demonstrations/myenv-noAdd2.yaml
 	:caption: ``myenv-noAdd2.yaml`` 
 	:name: lst:myenv-noAdd2

On applying either of the following commands,

::

    latexindent.pl myenv.tex -l myenv-noAdd1.yaml  
    latexindent.pl myenv.tex -l myenv-noAdd2.yaml  

we obtain the output given in :numref:`lst:myenv-output`; note in
particular that the environment ``myenv`` has not received any
*additional* indentation, but that the ``outer`` environment *has* still
received indentation.

 .. literalinclude:: demonstrations/myenvironment-simple-noAdd-body1.tex
 	:caption: ``myenv.tex`` output (using either :numref:`lst:myenv-noAdd1` or :numref:`lst:myenv-noAdd2`) 
 	:name: lst:myenv-output

Upon changing the YAML files to those shown in
:numref:`lst:myenv-noAdd3` and :numref:`lst:myenv-noAdd4`, and
running either

::

    latexindent.pl myenv.tex -l myenv-noAdd3.yaml  
    latexindent.pl myenv.tex -l myenv-noAdd4.yaml  

we obtain the output given in :numref:`lst:myenv-output-4`.

 .. literalinclude:: demonstrations/myenv-noAdd3.yaml
 	:caption: ``myenv-noAdd3.yaml`` 
 	:name: lst:myenv-noAdd3

 .. literalinclude:: demonstrations/myenv-noAdd4.yaml
 	:caption: ``myenv-noAdd4.yaml`` 
 	:name: lst:myenv-noAdd4

 .. literalinclude:: demonstrations/myenvironment-simple-noAdd-body4.tex
 	:caption: ``myenv.tex output`` (using either :numref:`lst:myenv-noAdd3` or :numref:`lst:myenv-noAdd4`) 
 	:name: lst:myenv-output-4

Let’s now allow ``myenv`` to have some optional and mandatory arguments,
as in :numref:`lst:myenv-args`.

 .. literalinclude:: demonstrations/myenvironment-args.tex
 	:caption: ``myenv-args.tex`` 
 	:name: lst:myenv-args

Upon running

::

    latexindent.pl -l=myenv-noAdd1.yaml myenv-args.tex  

we obtain the output shown in :numref:`lst:myenv-args-noAdd1`; note
that the optional argument, mandatory argument and body *all* have
received no additional indent. This is because, when
``noAdditionalIndent`` is specified in ‘scalar’ form (as in
:numref:`lst:myenv-noAdd1`), then *all* parts of the environment
(body, optional and mandatory arguments) are assumed to want no
additional indent.

 .. literalinclude:: demonstrations/myenvironment-args-noAdd-body1.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-noAdd1` 
 	:name: lst:myenv-args-noAdd1

We may customise ``noAdditionalIndent`` for optional and mandatory
arguments of the ``myenv`` environment, as shown in, for example,
:numref:`lst:myenv-noAdd5` and :numref:`lst:myenv-noAdd6`.

 .. literalinclude:: demonstrations/myenv-noAdd5.yaml
 	:caption: ``myenv-noAdd5.yaml`` 
 	:name: lst:myenv-noAdd5

 .. literalinclude:: demonstrations/myenv-noAdd6.yaml
 	:caption: ``myenv-noAdd6.yaml`` 
 	:name: lst:myenv-noAdd6

Upon running

::

    latexindent.pl myenv.tex -l myenv-noAdd5.yaml  
    latexindent.pl myenv.tex -l myenv-noAdd6.yaml  

we obtain the respective outputs given in
:numref:`lst:myenv-args-noAdd5` and :numref:`lst:myenv-args-noAdd6`.
Note that in :numref:`lst:myenv-args-noAdd5` the text for the
*optional* argument has not received any additional indentation, and
that in :numref:`lst:myenv-args-noAdd6` the *mandatory* argument has
not received any additional indentation; in both cases, the *body* has
not received any additional indentation.

 .. literalinclude:: demonstrations/myenvironment-args-noAdd5.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-noAdd5` 
 	:name: lst:myenv-args-noAdd5

 .. literalinclude:: demonstrations/myenvironment-args-noAdd6.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-noAdd6` 
 	:name: lst:myenv-args-noAdd6

.. describe:: indentRules:fields

We may also specify indentation rules for environment code blocks using
the ``indentRules`` field; see, for example,
:numref:`lst:myenv-rules1` and :numref:`lst:myenv-rules2`.

 .. literalinclude:: demonstrations/myenv-rules1.yaml
 	:caption: ``myenv-rules1.yaml`` 
 	:name: lst:myenv-rules1

 .. literalinclude:: demonstrations/myenv-rules2.yaml
 	:caption: ``myenv-rules2.yaml`` 
 	:name: lst:myenv-rules2

On applying either of the following commands,

::

    latexindent.pl myenv.tex -l myenv-rules1.yaml  
    latexindent.pl myenv.tex -l myenv-rules2.yaml  

we obtain the output given in :numref:`lst:myenv-rules-output`; note
in particular that the environment ``myenv`` has received one tab (from
the ``outer`` environment) plus three spaces from
:numref:`lst:myenv-rules1` or :numref:`lst:myenv-rules2`.

 .. literalinclude:: demonstrations/myenv-rules1.tex
 	:caption: ``myenv.tex`` output (using either :numref:`lst:myenv-rules1` or :numref:`lst:myenv-rules2`) 
 	:name: lst:myenv-rules-output

If you specify a field in ``indentRules`` using anything other than
horizontal space, it will be ignored.

Returning to the example in :numref:`lst:myenv-args` that contains
optional and mandatory arguments. Upon using
:numref:`lst:myenv-rules1` as in

::

    latexindent.pl myenv-args.tex -l=myenv-rules1.yaml  

we obtain the output in :numref:`lst:myenv-args-rules1`; note that the
body, optional argument and mandatory argument of ``myenv`` have *all*
received the same customised indentation.

 .. literalinclude:: demonstrations/myenvironment-args-rules1.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-rules1` 
 	:name: lst:myenv-args-rules1

You can specify different indentation rules for the different features
using, for example, :numref:`lst:myenv-rules3` and
:numref:`lst:myenv-rules4`

 .. literalinclude:: demonstrations/myenv-rules3.yaml
 	:caption: ``myenv-rules3.yaml`` 
 	:name: lst:myenv-rules3

 .. literalinclude:: demonstrations/myenv-rules4.yaml
 	:caption: ``myenv-rules4.yaml`` 
 	:name: lst:myenv-rules4

After running

::

    latexindent.pl myenv-args.tex -l myenv-rules3.yaml  
    latexindent.pl myenv-args.tex -l myenv-rules4.yaml  

then we obtain the respective outputs given in
:numref:`lst:myenv-args-rules3` and :numref:`lst:myenv-args-rules4`.

 .. literalinclude:: demonstrations/myenvironment-args-rules3.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-rules3` 
 	:name: lst:myenv-args-rules3

 .. literalinclude:: demonstrations/myenvironment-args-rules4.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-rules4` 
 	:name: lst:myenv-args-rules4

Note that in :numref:`lst:myenv-args-rules3`, the optional argument
has only received a single space of indentation, while the mandatory
argument has received the default (tab) indentation; the environment
body has received three spaces of indentation.

In :numref:`lst:myenv-args-rules4`, the optional argument has received
the default (tab) indentation, the mandatory argument has received two
tabs of indentation, and the body has received three spaces of
indentation.

.. describe:: noAdditionalIndentGlobal:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``noAdditionalIndentGlobal`` 
 	:name: lst:noAdditionalIndentGlobal:environments
 	:lines: 280-281
 	:linenos:
 	:lineno-start: 280

Assuming that your environment name is not found within neither
``noAdditionalIndent`` nor ``indentRules``, the next place that
``latexindent.pl`` will look is ``noAdditionalIndentGlobal``, and in
particular *for the environments* key (see
:numref:`lst:noAdditionalIndentGlobal:environments`). Let’s say that
you change the value of ``environments`` to ``1`` in
:numref:`lst:noAdditionalIndentGlobal:environments`, and that you run

::

    latexindent.pl myenv-args.tex -l env-noAdditionalGlobal.yaml
    latexindent.pl myenv-args.tex -l myenv-rules1.yaml,env-noAdditionalGlobal.yaml

The respective output from these two commands are in
:numref:`lst:myenv-args-no-add-global1` and
:numref:`lst:myenv-args-no-add-global2`; in
:numref:`lst:myenv-args-no-add-global1` notice that *both*
environments receive no additional indentation but that the arguments of
``myenv`` still *do* receive indentation. In
:numref:`lst:myenv-args-no-add-global2` notice that the *outer*
environment does not receive additional indentation, but because of the
settings from ``myenv-rules1.yaml`` (in :numref:`lst:myenv-rules1`),
the ``myenv`` environment still *does* receive indentation.

.. literalinclude:: demonstrations/myenvironment-args-rules1-noAddGlobal1.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:noAdditionalIndentGlobal:environments` 
 	:name: lst:myenv-args-no-add-global1

.. literalinclude:: demonstrations/myenvironment-args-rules1-noAddGlobal2.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:noAdditionalIndentGlobal:environments` and :numref:`lst:myenv-rules1` 
 	:name: lst:myenv-args-no-add-global2

In fact, ``noAdditionalIndentGlobal`` also contains keys that control
the indentation of optional and mandatory arguments; on referencing
:numref:`lst:opt-args-no-add-glob` and
:numref:`lst:mand-args-no-add-glob`

 .. literalinclude:: demonstrations/opt-args-no-add-glob.yaml
 	:caption: ``opt-args-no-add-glob.yaml`` 
 	:name: lst:opt-args-no-add-glob

 .. literalinclude:: demonstrations/mand-args-no-add-glob.yaml
 	:caption: ``mand-args-no-add-glob.yaml`` 
 	:name: lst:mand-args-no-add-glob

we may run the commands

::

    latexindent.pl  myenv-args.tex -local opt-args-no-add-glob.yaml
    latexindent.pl  myenv-args.tex -local mand-args-no-add-glob.yaml

which produces the respective outputs given in
:numref:`lst:myenv-args-no-add-opt` and
:numref:`lst:myenv-args-no-add-mand`. Notice that in
:numref:`lst:myenv-args-no-add-opt` the *optional* argument has not
received any additional indentation, and in
:numref:`lst:myenv-args-no-add-mand` the *mandatory* argument has not
received any additional indentation.

.. literalinclude:: demonstrations/myenvironment-args-rules1-noAddGlobal3.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:opt-args-no-add-glob` 
 	:name: lst:myenv-args-no-add-opt

.. literalinclude:: demonstrations/myenvironment-args-rules1-noAddGlobal4.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:mand-args-no-add-glob` 
 	:name: lst:myenv-args-no-add-mand

.. describe:: indentRulesGlobal:fields

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``indentRulesGlobal`` 
 	:name: lst:indentRulesGlobal:environments
 	:lines: 296-297
 	:linenos:
 	:lineno-start: 296

The final check that ``latexindent.pl`` will make is to look for
``indentRulesGlobal`` as detailed in
:numref:`lst:indentRulesGlobal:environments`; if you change the
``environments`` field to anything involving horizontal space, say
``" "``, and then run the following commands

::

    latexindent.pl  myenv-args.tex -l env-indentRules.yaml
    latexindent.pl  myenv-args.tex -l myenv-rules1.yaml,env-indentRules.yaml

then the respective output is shown in
:numref:`lst:myenv-args-indent-rules-global1` and
:numref:`lst:myenv-args-indent-rules-global2`. Note that in
:numref:`lst:myenv-args-indent-rules-global1`, both the environment
blocks have received a single-space indentation, whereas in
:numref:`lst:myenv-args-indent-rules-global2` the ``outer``
environment has received single-space indentation (specified by
``indentRulesGlobal``), but ``myenv`` has received ``"   "``, as
specified by the particular ``indentRules`` for ``myenv``
:numref:`lst:myenv-rules1`.

 .. literalinclude:: demonstrations/myenvironment-args-global-rules1.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:indentRulesGlobal:environments` 
 	:name: lst:myenv-args-indent-rules-global1

 .. literalinclude:: demonstrations/myenvironment-args-global-rules2.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:myenv-rules1` and :numref:`lst:indentRulesGlobal:environments` 
 	:name: lst:myenv-args-indent-rules-global2

You can specify ``indentRulesGlobal`` for both optional and mandatory
arguments, as detailed in :numref:`lst:opt-args-indent-rules-glob` and
:numref:`lst:mand-args-indent-rules-glob`

 .. literalinclude:: demonstrations/opt-args-indent-rules-glob.yaml
 	:caption: ``opt-args-indent-rules-glob.yaml`` 
 	:name: lst:opt-args-indent-rules-glob

 .. literalinclude:: demonstrations/mand-args-indent-rules-glob.yaml
 	:caption: ``mand-args-indent-rules-glob.yaml`` 
 	:name: lst:mand-args-indent-rules-glob

Upon running the following commands

::

    latexindent.pl  myenv-args.tex -local opt-args-indent-rules-glob.yaml
    latexindent.pl  myenv-args.tex -local mand-args-indent-rules-glob.yaml

we obtain the respective outputs in
:numref:`lst:myenv-args-indent-rules-global3` and
:numref:`lst:myenv-args-indent-rules-global4`. Note that the
*optional* argument in :numref:`lst:myenv-args-indent-rules-global3`
has received two tabs worth of indentation, while the *mandatory*
argument has done so in :numref:`lst:myenv-args-indent-rules-global4`.

 .. literalinclude:: demonstrations/myenvironment-args-global-rules3.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:opt-args-indent-rules-glob` 
 	:name: lst:myenv-args-indent-rules-global3

 .. literalinclude:: demonstrations/myenvironment-args-global-rules4.tex
 	:caption: ``myenv-args.tex`` using :numref:`lst:mand-args-indent-rules-glob` 
 	:name: lst:myenv-args-indent-rules-global4

Environments with items
~~~~~~~~~~~~~~~~~~~~~~~

With reference to :numref:`lst:indentafteritems` and
:numref:`lst:itemNames`, some commands may contain ``item`` commands;
for the purposes of this discussion, we will use the code from
:numref:`lst:itemsbefore`.

Assuming that you’ve populated ``itemNames`` with the name of your
``item``, you can put the item name into ``noAdditionalIndent`` as in
:numref:`lst:item-noAdd1`, although a more efficient approach may be
to change the relevant field in ``itemNames`` to ``0``. Similarly, you
can customise the indentation that your ``item`` receives using
``indentRules``, as in :numref:`lst:item-rules1`

 .. literalinclude:: demonstrations/item-noAdd1.yaml
 	:caption: ``item-noAdd1.yaml`` 
 	:name: lst:item-noAdd1

 .. literalinclude:: demonstrations/item-rules1.yaml
 	:caption: ``item-rules1.yaml`` 
 	:name: lst:item-rules1

Upon running the following commands

::

    latexindent.pl items1.tex -local item-noAdd1.yaml  
    latexindent.pl items1.tex -local item-rules1.yaml  

the respective outputs are given in :numref:`lst:items1-noAdd1` and
:numref:`lst:items1-rules1`; note that in
:numref:`lst:items1-noAdd1` that the text after each ``item`` has not
received any additional indentation, and in
:numref:`lst:items1-rules1`, the text after each ``item`` has received
a single space of indentation, specified by :numref:`lst:item-rules1`.

 .. literalinclude:: demonstrations/items1-noAdd1.tex
 	:caption: ``items1.tex`` using :numref:`lst:item-noAdd1` 
 	:name: lst:items1-noAdd1

 .. literalinclude:: demonstrations/items1-rules1.tex
 	:caption: ``items1.tex`` using :numref:`lst:item-rules1` 
 	:name: lst:items1-rules1

Alternatively, you might like to populate ``noAdditionalIndentGlobal``
or ``indentRulesGlobal`` using the ``items`` key, as demonstrated in
:numref:`lst:items-noAdditionalGlobal` and
:numref:`lst:items-indentRulesGlobal`. Note that there is a need to
‘reset/remove’ the ``item`` field from ``indentRules`` in both cases
(see the hierarchy description given on
:ref:`page sec:noadd-indent-rules <sec:noadd-indent-rules>`) as the
``item`` command is a member of ``indentRules`` by default.

 .. literalinclude:: demonstrations/items-noAdditionalGlobal.yaml
 	:caption: ``items-noAdditionalGlobal.yaml`` 
 	:name: lst:items-noAdditionalGlobal

 .. literalinclude:: demonstrations/items-indentRulesGlobal.yaml
 	:caption: ``items-indentRulesGlobal.yaml`` 
 	:name: lst:items-indentRulesGlobal

Upon running the following commands,

::

    latexindent.pl items1.tex -local items-noAdditionalGlobal.yaml
    latexindent.pl items1.tex -local items-indentRulesGlobal.yaml

the respective outputs from :numref:`lst:items1-noAdd1` and
:numref:`lst:items1-rules1` are obtained; note, however, that *all*
such ``item`` commands without their own individual
``noAdditionalIndent`` or ``indentRules`` settings would behave as in
these listings.

.. label follows

.. _subsubsec:commands-arguments:

Commands with arguments
~~~~~~~~~~~~~~~~~~~~~~~

Let’s begin with the simple example in :numref:`lst:mycommand`; when
``latexindent.pl`` operates on this file, the default output is shown in
:numref:`lst:mycommand-default`. [4]_

 .. literalinclude:: demonstrations/mycommand.tex
 	:caption: ``mycommand.tex`` 
 	:name: lst:mycommand

 .. literalinclude:: demonstrations/mycommand-default.tex
 	:caption: ``mycommand.tex`` default output 
 	:name: lst:mycommand-default

As in the environment-based case (see :numref:`lst:myenv-noAdd1` and
:numref:`lst:myenv-noAdd2`) we may specify ``noAdditionalIndent``
either in ‘scalar’ form, or in ‘field’ form, as shown in
:numref:`lst:mycommand-noAdd1` and :numref:`lst:mycommand-noAdd2`

 .. literalinclude:: demonstrations/mycommand-noAdd1.yaml
 	:caption: ``mycommand-noAdd1.yaml`` 
 	:name: lst:mycommand-noAdd1

 .. literalinclude:: demonstrations/mycommand-noAdd2.yaml
 	:caption: ``mycommand-noAdd2.yaml`` 
 	:name: lst:mycommand-noAdd2

After running the following commands,

::

    latexindent.pl mycommand.tex -l mycommand-noAdd1.yaml  
    latexindent.pl mycommand.tex -l mycommand-noAdd2.yaml  

we receive the respective output given in
:numref:`lst:mycommand-output-noAdd1` and
:numref:`lst:mycommand-output-noAdd2`

 .. literalinclude:: demonstrations/mycommand-noAdd1.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd1` 
 	:name: lst:mycommand-output-noAdd1

 .. literalinclude:: demonstrations/mycommand-noAdd2.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd2` 
 	:name: lst:mycommand-output-noAdd2

Note that in :numref:`lst:mycommand-output-noAdd1` that the ‘body’,
optional argument *and* mandatory argument have *all* received no
additional indentation, while in
:numref:`lst:mycommand-output-noAdd2`, only the ‘body’ has not
received any additional indentation. We define the ‘body’ of a command
as any lines following the command name that include its optional or
mandatory arguments.

We may further customise ``noAdditionalIndent`` for ``mycommand`` as we
did in :numref:`lst:myenv-noAdd5` and :numref:`lst:myenv-noAdd6`;
explicit examples are given in :numref:`lst:mycommand-noAdd3` and
:numref:`lst:mycommand-noAdd4`.

 .. literalinclude:: demonstrations/mycommand-noAdd3.yaml
 	:caption: ``mycommand-noAdd3.yaml`` 
 	:name: lst:mycommand-noAdd3

 .. literalinclude:: demonstrations/mycommand-noAdd4.yaml
 	:caption: ``mycommand-noAdd4.yaml`` 
 	:name: lst:mycommand-noAdd4

After running the following commands,

::

    latexindent.pl mycommand.tex -l mycommand-noAdd3.yaml  
    latexindent.pl mycommand.tex -l mycommand-noAdd4.yaml  

we receive the respective output given in
:numref:`lst:mycommand-output-noAdd3` and
:numref:`lst:mycommand-output-noAdd4`.

 .. literalinclude:: demonstrations/mycommand-noAdd3.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd3` 
 	:name: lst:mycommand-output-noAdd3

 .. literalinclude:: demonstrations/mycommand-noAdd4.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd4` 
 	:name: lst:mycommand-output-noAdd4

Attentive readers will note that the body of ``mycommand`` in both
:numref:`lst:mycommand-output-noAdd3` and
:numref:`lst:mycommand-output-noAdd4` has received no additional
indent, even though ``body`` is explicitly set to ``0`` in both
:numref:`lst:mycommand-noAdd3` and :numref:`lst:mycommand-noAdd4`.
This is because, by default, ``noAdditionalIndentGlobal`` for
``commands`` is set to ``1`` by default; this can be easily fixed as in
:numref:`lst:mycommand-noAdd5` and :numref:`lst:mycommand-noAdd6`.

.. label follows

.. _page:command:noAddGlobal:

 .. literalinclude:: demonstrations/mycommand-noAdd5.yaml
 	:caption: ``mycommand-noAdd5.yaml`` 
 	:name: lst:mycommand-noAdd5

 .. literalinclude:: demonstrations/mycommand-noAdd6.yaml
 	:caption: ``mycommand-noAdd6.yaml`` 
 	:name: lst:mycommand-noAdd6

After running the following commands,

::

    latexindent.pl mycommand.tex -l mycommand-noAdd5.yaml  
    latexindent.pl mycommand.tex -l mycommand-noAdd6.yaml  

we receive the respective output given in
:numref:`lst:mycommand-output-noAdd5` and
:numref:`lst:mycommand-output-noAdd6`.

 .. literalinclude:: demonstrations/mycommand-noAdd5.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd5` 
 	:name: lst:mycommand-output-noAdd5

 .. literalinclude:: demonstrations/mycommand-noAdd6.tex
 	:caption: ``mycommand.tex`` using :numref:`lst:mycommand-noAdd6` 
 	:name: lst:mycommand-output-noAdd6

Both ``indentRules`` and ``indentRulesGlobal`` can be adjusted as they
were for *environment* code blocks, as in :numref:`lst:myenv-rules3`
and :numref:`lst:myenv-rules4` and
:numref:`lst:indentRulesGlobal:environments` and
:numref:`lst:opt-args-indent-rules-glob` and
:numref:`lst:mand-args-indent-rules-glob`.

ifelsefi code blocks
~~~~~~~~~~~~~~~~~~~~

Let’s use the simple example shown in :numref:`lst:ifelsefi1`; when
``latexindent.pl`` operates on this file, the output as in
:numref:`lst:ifelsefi1-default`; note that the body of each of the
``\if`` statements have been indented, and that the ``\else`` statement
has been accounted for correctly.

 .. literalinclude:: demonstrations/ifelsefi1.tex
 	:caption: ``ifelsefi1.tex`` 
 	:name: lst:ifelsefi1

 .. literalinclude:: demonstrations/ifelsefi1-default.tex
 	:caption: ``ifelsefi1.tex`` default output 
 	:name: lst:ifelsefi1-default

It is recommended to specify ``noAdditionalIndent`` and ``indentRules``
in the ‘scalar’ form only for these type of code blocks, although the
‘field’ form would work, assuming that ``body`` was specified. Examples
are shown in :numref:`lst:ifnum-noAdd` and
:numref:`lst:ifnum-indent-rules`.

 .. literalinclude:: demonstrations/ifnum-noAdd.yaml
 	:caption: ``ifnum-noAdd.yaml`` 
 	:name: lst:ifnum-noAdd

 .. literalinclude:: demonstrations/ifnum-indent-rules.yaml
 	:caption: ``ifnum-indent-rules.yaml`` 
 	:name: lst:ifnum-indent-rules

After running the following commands,

::

    latexindent.pl ifelsefi1.tex -local ifnum-noAdd.yaml  
    latexindent.pl ifelsefi1.tex -l ifnum-indent-rules.yaml  

we receive the respective output given in
:numref:`lst:ifelsefi1-output-noAdd` and
:numref:`lst:ifelsefi1-output-indent-rules`; note that in
:numref:`lst:ifelsefi1-output-noAdd`, the ``ifnum`` code block has
*not* received any additional indentation, while in
:numref:`lst:ifelsefi1-output-indent-rules`, the ``ifnum`` code block
has received one tab and two spaces of indentation.

 .. literalinclude:: demonstrations/ifelsefi1-noAdd.tex
 	:caption: ``ifelsefi1.tex`` using :numref:`lst:ifnum-noAdd` 
 	:name: lst:ifelsefi1-output-noAdd

 .. literalinclude:: demonstrations/ifelsefi1-indent-rules.tex
 	:caption: ``ifelsefi1.tex`` using :numref:`lst:ifnum-indent-rules` 
 	:name: lst:ifelsefi1-output-indent-rules

We may specify ``noAdditionalIndentGlobal`` and ``indentRulesGlobal`` as
in :numref:`lst:ifelsefi-noAdd-glob` and
:numref:`lst:ifelsefi-indent-rules-global`.

 .. literalinclude:: demonstrations/ifelsefi-noAdd-glob.yaml
 	:caption: ``ifelsefi-noAdd-glob.yaml`` 
 	:name: lst:ifelsefi-noAdd-glob

 .. literalinclude:: demonstrations/ifelsefi-indent-rules-global.yaml
 	:caption: ``ifelsefi-indent-rules-global.yaml`` 
 	:name: lst:ifelsefi-indent-rules-global

Upon running the following commands

::

    latexindent.pl ifelsefi1.tex -local ifelsefi-noAdd-glob.yaml  
    latexindent.pl ifelsefi1.tex -l ifelsefi-indent-rules-global.yaml  

we receive the outputs in :numref:`lst:ifelsefi1-output-noAdd-glob`
and :numref:`lst:ifelsefi1-output-indent-rules-global`; notice that in
:numref:`lst:ifelsefi1-output-noAdd-glob` neither of the ``ifelsefi``
code blocks have received indentation, while in
:numref:`lst:ifelsefi1-output-indent-rules-global` both code blocks
have received a single space of indentation.

 .. literalinclude:: demonstrations/ifelsefi1-noAdd-glob.tex
 	:caption: ``ifelsefi1.tex`` using :numref:`lst:ifelsefi-noAdd-glob` 
 	:name: lst:ifelsefi1-output-noAdd-glob

 .. literalinclude:: demonstrations/ifelsefi1-indent-rules-global.tex
 	:caption: ``ifelsefi1.tex`` using :numref:`lst:ifelsefi-indent-rules-global` 
 	:name: lst:ifelsefi1-output-indent-rules-global

We can further explore the treatment of ``ifElseFi`` code blocks in
:numref:`lst:ifelsefi2`, and the associated default output given in
:numref:`lst:ifelsefi2-default`; note, in particular, that the bodies
of each of the ‘or statements’ have been indented.

 .. literalinclude:: demonstrations/ifelsefi2.tex
 	:caption: ``ifelsefi2.tex`` 
 	:name: lst:ifelsefi2

 .. literalinclude:: demonstrations/ifelsefi2-default.tex
 	:caption: ``ifelsefi2.tex`` default output 
 	:name: lst:ifelsefi2-default

specialBeginEnd code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let’s use the example from :numref:`lst:specialbefore` which has
default output shown in :numref:`lst:specialafter`.

It is recommended to specify ``noAdditionalIndent`` and ``indentRules``
in the ‘scalar’ form for these type of code blocks, although the ‘field’
form would work, assuming that ``body`` was specified. Examples are
shown in :numref:`lst:displayMath-noAdd` and
:numref:`lst:displayMath-indent-rules`.

 .. literalinclude:: demonstrations/displayMath-noAdd.yaml
 	:caption: ``displayMath-noAdd.yaml`` 
 	:name: lst:displayMath-noAdd

 .. literalinclude:: demonstrations/displayMath-indent-rules.yaml
 	:caption: ``displayMath-indent-rules.yaml`` 
 	:name: lst:displayMath-indent-rules

After running the following commands,

::

    latexindent.pl special1.tex -local displayMath-noAdd.yaml  
    latexindent.pl special1.tex -l displayMath-indent-rules.yaml  

we receive the respective output given in
:numref:`lst:special1-output-noAdd` and
:numref:`lst:special1-output-indent-rules`; note that in
:numref:`lst:special1-output-noAdd`, the ``displayMath`` code block
has *not* received any additional indentation, while in
:numref:`lst:special1-output-indent-rules`, the ``displayMath`` code
block has received three tabs worth of indentation.

 .. literalinclude:: demonstrations/special1-noAdd.tex
 	:caption: ``special1.tex`` using :numref:`lst:displayMath-noAdd` 
 	:name: lst:special1-output-noAdd

 .. literalinclude:: demonstrations/special1-indent-rules.tex
 	:caption: ``special1.tex`` using :numref:`lst:displayMath-indent-rules` 
 	:name: lst:special1-output-indent-rules

We may specify ``noAdditionalIndentGlobal`` and ``indentRulesGlobal`` as
in :numref:`lst:special-noAdd-glob` and
:numref:`lst:special-indent-rules-global`.

 .. literalinclude:: demonstrations/special-noAdd-glob.yaml
 	:caption: ``special-noAdd-glob.yaml`` 
 	:name: lst:special-noAdd-glob

 .. literalinclude:: demonstrations/special-indent-rules-global.yaml
 	:caption: ``special-indent-rules-global.yaml`` 
 	:name: lst:special-indent-rules-global

Upon running the following commands

::

    latexindent.pl special1.tex -local special-noAdd-glob.yaml  
    latexindent.pl special1.tex -l special-indent-rules-global.yaml  

we receive the outputs in :numref:`lst:special1-output-noAdd-glob` and
:numref:`lst:special1-output-indent-rules-global`; notice that in
:numref:`lst:special1-output-noAdd-glob` neither of the ``special``
code blocks have received indentation, while in
:numref:`lst:special1-output-indent-rules-global` both code blocks
have received a single space of indentation.

 .. literalinclude:: demonstrations/special1-noAdd-glob.tex
 	:caption: ``special1.tex`` using :numref:`lst:special-noAdd-glob` 
 	:name: lst:special1-output-noAdd-glob

 .. literalinclude:: demonstrations/special1-indent-rules-global.tex
 	:caption: ``special1.tex`` using :numref:`lst:special-indent-rules-global` 
 	:name: lst:special1-output-indent-rules-global

.. label follows

.. _subsubsec-headings-no-add-indent-rules:

afterHeading code blocks
~~~~~~~~~~~~~~~~~~~~~~~~

Let’s use the example :numref:`lst:headings2` for demonstration
throughout this . As discussed on
:ref:`page lst:headings1 <lst:headings1>`, by default
``latexindent.pl`` will not add indentation after headings.

 .. literalinclude:: demonstrations/headings2.tex
 	:caption: ``headings2.tex`` 
 	:name: lst:headings2

On using the YAML file in :numref:`lst:headings3yaml` by running the
command

::

    latexindent.pl headings2.tex -l headings3.yaml      
        

we obtain the output in :numref:`lst:headings2-mod3`. Note that the
argument of ``paragraph`` has received (default) indentation, and that
the body after the heading statement has received (default) indentation.

 .. literalinclude:: demonstrations/headings2-mod3.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings3yaml` 
 	:name: lst:headings2-mod3

 .. literalinclude:: demonstrations/headings3.yaml
 	:caption: ``headings3.yaml`` 
 	:name: lst:headings3yaml

If we specify ``noAdditionalIndent`` as in :numref:`lst:headings4yaml`
and run the command

::

    latexindent.pl headings2.tex -l headings4.yaml      
        

then we receive the output in :numref:`lst:headings2-mod4`. Note that
the arguments *and* the body after the heading of ``paragraph`` has
received no additional indentation, because we have specified
``noAdditionalIndent`` in scalar form.

 .. literalinclude:: demonstrations/headings2-mod4.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings4yaml` 
 	:name: lst:headings2-mod4

 .. literalinclude:: demonstrations/headings4.yaml
 	:caption: ``headings4.yaml`` 
 	:name: lst:headings4yaml

Similarly, if we specify ``indentRules`` as in
:numref:`lst:headings5yaml` and run analogous commands to those above,
we receive the output in :numref:`lst:headings2-mod5`; note that the
*body*, *mandatory argument* and content *after the heading* of
``paragraph`` have *all* received three tabs worth of indentation.

 .. literalinclude:: demonstrations/headings2-mod5.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings5yaml` 
 	:name: lst:headings2-mod5

 .. literalinclude:: demonstrations/headings5.yaml
 	:caption: ``headings5.yaml`` 
 	:name: lst:headings5yaml

We may, instead, specify ``noAdditionalIndent`` in ‘field’ form, as in
:numref:`lst:headings6yaml` which gives the output in
:numref:`lst:headings2-mod6`.

 .. literalinclude:: demonstrations/headings2-mod6.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings6yaml` 
 	:name: lst:headings2-mod6

 .. literalinclude:: demonstrations/headings6.yaml
 	:caption: ``headings6.yaml`` 
 	:name: lst:headings6yaml

Analogously, we may specify ``indentRules`` as in
:numref:`lst:headings7yaml` which gives the output in
:numref:`lst:headings2-mod7`; note that mandatory argument text has
only received a single space of indentation, while the body after the
heading has received three tabs worth of indentation.

 .. literalinclude:: demonstrations/headings2-mod7.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings7yaml` 
 	:name: lst:headings2-mod7

 .. literalinclude:: demonstrations/headings7.yaml
 	:caption: ``headings7.yaml`` 
 	:name: lst:headings7yaml

Finally, let’s consider ``noAdditionalIndentGlobal`` and
``indentRulesGlobal`` shown in :numref:`lst:headings8yaml` and
:numref:`lst:headings9yaml` respectively, with respective output in
:numref:`lst:headings2-mod8` and :numref:`lst:headings2-mod9`. Note
that in :numref:`lst:headings8yaml` the *mandatory argument* of
``paragraph`` has received a (default) tab’s worth of indentation, while
the body after the heading has received *no additional indentation*.
Similarly, in :numref:`lst:headings2-mod9`, the *argument* has
received both a (default) tab plus two spaces of indentation (from the
global rule specified in :numref:`lst:headings9yaml`), and the
remaining body after ``paragraph`` has received just two spaces of
indentation.

 .. literalinclude:: demonstrations/headings2-mod8.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings8yaml` 
 	:name: lst:headings2-mod8

 .. literalinclude:: demonstrations/headings8.yaml
 	:caption: ``headings8.yaml`` 
 	:name: lst:headings8yaml

 .. literalinclude:: demonstrations/headings2-mod9.tex
 	:caption: ``headings2.tex`` using :numref:`lst:headings9yaml` 
 	:name: lst:headings2-mod9

 .. literalinclude:: demonstrations/headings9.yaml
 	:caption: ``headings9.yaml`` 
 	:name: lst:headings9yaml

The remaining code blocks
~~~~~~~~~~~~~~~~~~~~~~~~~

Referencing the different types of code blocks in
:numref:`tab:code-blocks`, we have a few code blocks yet to cover;
these are very similar to the ``commands`` code block type covered
comprehensively in :numref:`subsubsec:commands-arguments`, but a small
discussion defining these remaining code blocks is necessary.

keyEqualsValuesBracesBrackets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``latexindent.pl`` defines this type of code block by the following
criteria:

-  it must immediately follow either ``{`` OR ``[`` OR ``,`` with
   comments and blank lines allowed;

-  then it has a name made up of the characters detailed in
   :numref:`tab:code-blocks`;

-  then an :math:`=` symbol;

-  then at least one set of curly braces or square brackets (comments
   and line breaks allowed throughout).

An example is shown in :numref:`lst:pgfkeysbefore`, with the default
output given in :numref:`lst:pgfkeys1:default`.

 .. literalinclude:: demonstrations/pgfkeys1.tex
 	:caption: ``pgfkeys1.tex`` 
 	:name: lst:pgfkeysbefore

 .. literalinclude:: demonstrations/pgfkeys1-default.tex
 	:caption: ``pgfkeys1.tex`` default output 
 	:name: lst:pgfkeys1:default

In :numref:`lst:pgfkeys1:default`, note that the maximum indentation
is three tabs, and these come from:

-  the ``\pgfkeys`` command’s mandatory argument;

-  the ``start coordinate/.initial`` key’s mandatory argument;

-  the ``start coordinate/.initial`` key’s body, which is defined as any
   lines following the name of the key that include its arguments. This
   is the part controlled by the *body* field for ``noAdditionalIndent``
   and friends from
   :ref:`page sec:noadd-indent-rules <sec:noadd-indent-rules>`.

namedGroupingBracesBrackets
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This type of code block is mostly motivated by tikz-based code; we
define this code block as follows:

-  it must immediately follow either *horizontal space* OR *one or more
   line breaks* OR ``{`` OR ``[`` OR ``$`` OR ``)`` OR ``(``;

-  the name may contain the characters detailed in
   :numref:`tab:code-blocks`;

-  then at least one set of curly braces or square brackets (comments
   and line breaks allowed throughout).

A simple example is given in :numref:`lst:child1`, with default output
in :numref:`lst:child1:default`.

 .. literalinclude:: demonstrations/child1.tex
 	:caption: ``child1.tex`` 
 	:name: lst:child1

 .. literalinclude:: demonstrations/child1-default.tex
 	:caption: ``child1.tex`` default output 
 	:name: lst:child1:default

In particular, ``latexindent.pl`` considers ``child``, ``parent`` and
``node`` all to be ``namedGroupingBracesBrackets``\  [5]_. Referencing
:numref:`lst:child1:default`, note that the maximum indentation is two
tabs, and these come from:

-  the ``child``\ ’s mandatory argument;

-  the ``child``\ ’s body, which is defined as any lines following the
   name of the ``namedGroupingBracesBrackets`` that include its
   arguments. This is the part controlled by the *body* field for
   ``noAdditionalIndent`` and friends from
   :ref:`page sec:noadd-indent-rules <sec:noadd-indent-rules>`.

UnNamedGroupingBracesBrackets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

occur in a variety of situations; specifically, we define this type of
code block as satisfying the following criteria:

-  it must immediately follow either ``{`` OR ``[`` OR ``,`` OR ``&`` OR
   ``)`` OR ``(`` OR ``$``;

-  then at least one set of curly braces or square brackets (comments
   and line breaks allowed throughout).

An example is shown in :numref:`lst:psforeach1` with default output
give in :numref:`lst:psforeach:default`.

 .. literalinclude:: demonstrations/psforeach1.tex
 	:caption: ``psforeach1.tex`` 
 	:name: lst:psforeach1

 .. literalinclude:: demonstrations/psforeach1-default.tex
 	:caption: ``psforeach1.tex`` default output 
 	:name: lst:psforeach:default

Referencing :numref:`lst:psforeach:default`, there are *three* sets of
unnamed braces. Note also that the maximum value of indentation is three
tabs, and these come from:

-  the ``\psforeach`` command’s mandatory argument;

-  the *first* un-named braces mandatory argument;

-  the *first* un-named braces *body*, which we define as any lines
   following the first opening ``{`` or ``[`` that defined the code
   block. This is the part controlled by the *body* field for
   ``noAdditionalIndent`` and friends from
   :ref:`page sec:noadd-indent-rules <sec:noadd-indent-rules>`.

Users wishing to customise the mandatory and/or optional arguments on a
*per-name* basis for the ``UnNamedGroupingBracesBrackets`` should use
``always-un-named``.

filecontents
^^^^^^^^^^^^

code blocks behave just as ``environments``, except that neither
arguments nor items are sought.

Summary
~~~~~~~

Having considered all of the different types of code blocks, the
functions of the fields given in
:numref:`lst:noAdditionalIndentGlobal` and
:numref:`lst:indentRulesGlobal` should now make sense.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``noAdditionalIndentGlobal`` 
 	:name: lst:noAdditionalIndentGlobal
 	:lines: 280-292
 	:linenos:
 	:lineno-start: 280

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``indentRulesGlobal`` 
 	:name: lst:indentRulesGlobal
 	:lines: 296-308
 	:linenos:
 	:lineno-start: 296

.. label follows

.. _subsec:commands-string-between:

Commands and the strings between their arguments
------------------------------------------------

The ``command`` code blocks will always look for optional (square
bracketed) and mandatory (curly braced) arguments which can contain
comments, line breaks and ‘beamer’ commands ``<.*?>`` between them.
There are switches that can allow them to contain other strings, which
we discuss next.

.. describe:: commandCodeBlocks:fields

The ``commandCodeBlocks`` field contains a few switches detailed in
:numref:`lst:commandCodeBlocks`.

 .. literalinclude:: ../defaultSettings.yaml
 	:caption: ``commandCodeBlocks`` 
 	:name: lst:commandCodeBlocks
 	:lines: 311-325
 	:linenos:
 	:lineno-start: 311

.. describe:: roundParenthesesAllowed:0\|1

The need for this field was mostly motivated by commands found in code
used to generate images in ``PSTricks`` and ``tikz``; for example, let’s
consider the code given in :numref:`lst:pstricks1`.

 .. literalinclude:: demonstrations/pstricks1.tex
 	:caption: ``pstricks1.tex`` 
 	:name: lst:pstricks1

 .. literalinclude:: demonstrations/pstricks1-default.tex
 	:caption: ``pstricks1`` default output 
 	:name: lst:pstricks1-default

Notice that the ``\defFunction`` command has an optional argument,
followed by a mandatory argument, followed by a round-parenthesis
argument, :math:`(u,v)`.

By default, because ``roundParenthesesAllowed`` is set to :math:`1` in
:numref:`lst:commandCodeBlocks`, then ``latexindent.pl`` will allow
round parenthesis between optional and mandatory arguments. In the case
of the code in :numref:`lst:pstricks1`, ``latexindent.pl`` finds *all*
the arguments of ``defFunction``, both before and after ``(u,v)``.

The default output from running ``latexindent.pl`` on
:numref:`lst:pstricks1` actually leaves it unchanged (see
:numref:`lst:pstricks1-default`); note in particular, this is because
of ``noAdditionalIndentGlobal`` as discussed on
:ref:`page page:command:noAddGlobal <page:command:noAddGlobal>`.

Upon using the YAML settings in :numref:`lst:noRoundParentheses`, and
running the command

::

    latexindent.pl pstricks1.tex -l noRoundParentheses.yaml
            

we obtain the output given in :numref:`lst:pstricks1-nrp`.

 .. literalinclude:: demonstrations/pstricks1-nrp.tex
 	:caption: ``pstricks1.tex`` using :numref:`lst:noRoundParentheses` 
 	:name: lst:pstricks1-nrp

 .. literalinclude:: demonstrations/noRoundParentheses.yaml
 	:caption: ``noRoundParentheses.yaml`` 
 	:name: lst:noRoundParentheses

Notice the difference between :numref:`lst:pstricks1-default` and
:numref:`lst:pstricks1-nrp`; in particular, in
:numref:`lst:pstricks1-nrp`, because round parentheses are *not*
allowed, ``latexindent.pl`` finds that the ``\defFunction`` command
finishes at the first opening round parenthesis. As such, the remaining
braced, mandatory, arguments are found to be
``UnNamedGroupingBracesBrackets`` (see :numref:`tab:code-blocks`)
which, by default, assume indentation for their body, and hence the
tabbed indentation in :numref:`lst:pstricks1-nrp`.

Let’s explore this using the YAML given in :numref:`lst:defFunction`
and run the command

::

    latexindent.pl pstricks1.tex -l defFunction.yaml
            

then the output is as in :numref:`lst:pstricks1-indent-rules`.

 .. literalinclude:: demonstrations/pstricks1-indent-rules.tex
 	:caption: ``pstricks1.tex`` using :numref:`lst:defFunction` 
 	:name: lst:pstricks1-indent-rules

 .. literalinclude:: demonstrations/defFunction.yaml
 	:caption: ``defFunction.yaml`` 
 	:name: lst:defFunction

Notice in :numref:`lst:pstricks1-indent-rules` that the *body* of the
``defFunction`` command i.e, the subsequent lines containing arguments
after the command name, have received the single space of indentation
specified by :numref:`lst:defFunction`.

.. describe:: stringsAllowedBetweenArguments:fields

``tikz`` users may well specify code such as that given in
:numref:`lst:tikz-node1`; processing this code using
``latexindent.pl`` gives the default output in
:numref:`lst:tikz-node1-default`.

 .. literalinclude:: demonstrations/tikz-node1.tex
 	:caption: ``tikz-node1.tex`` 
 	:name: lst:tikz-node1

 .. literalinclude:: demonstrations/tikz-node1-default.tex
 	:caption: ``tikz-node1`` default output 
 	:name: lst:tikz-node1-default

With reference to :numref:`lst:commandCodeBlocks`, we see that the
strings

    to, node, ++

are all allowed to appear between arguments; importantly, you are
encouraged to add further names to this field as necessary. This means
that when ``latexindent.pl`` processes :numref:`lst:tikz-node1`, it
consumes:

-  the optional argument ``[thin]``

-  the round-bracketed argument ``(c)`` because
   ``roundParenthesesAllowed`` is :math:`1` by default

-  the string ``to`` (specified in ``stringsAllowedBetweenArguments``)

-  the optional argument ``[in=110,out=-90]``

-  the string ``++`` (specified in ``stringsAllowedBetweenArguments``)

-  the round-bracketed argument ``(0,-0.5cm)`` because
   ``roundParenthesesAllowed`` is :math:`1` by default

-  the string ``node`` (specified in ``stringsAllowedBetweenArguments``)

-  the optional argument ``[below,align=left,scale=0.5]``

We can explore this further, for example using :numref:`lst:draw` and
running the command

::

    latexindent.pl tikz-node1.tex -l draw.yaml  

we receive the output given in :numref:`lst:tikz-node1-draw`.

 .. literalinclude:: demonstrations/tikz-node1-draw.tex
 	:caption: ``tikz-node1.tex`` using :numref:`lst:draw` 
 	:name: lst:tikz-node1-draw

 .. literalinclude:: demonstrations/draw.yaml
 	:caption: ``draw.yaml`` 
 	:name: lst:draw

Notice that each line after the ``\draw`` command (its ‘body’) in
:numref:`lst:tikz-node1-draw` has been given the appropriate
two-spaces worth of indentation specified in :numref:`lst:draw`.

Let’s compare this with the output from using the YAML settings in
:numref:`lst:no-strings`, and running the command

::

    latexindent.pl tikz-node1.tex -l no-strings.yaml  

given in :numref:`lst:tikz-node1-no-strings`.

 .. literalinclude:: demonstrations/tikz-node1-no-strings.tex
 	:caption: ``tikz-node1.tex`` using :numref:`lst:no-strings` 
 	:name: lst:tikz-node1-no-strings

 .. literalinclude:: demonstrations/no-strings.yaml
 	:caption: ``no-strings.yaml`` 
 	:name: lst:no-strings

In this case, ``latexindent.pl`` sees that:

-  the ``\draw`` command finishes after the ``(c)``, as
   ``stringsAllowedBetweenArguments`` has been set to :math:`0` so there
   are no strings allowed between arguments;

-  it finds a ``namedGroupingBracesBrackets`` called ``to`` (see
   :numref:`tab:code-blocks`) *with* argument ``[in=110,out=-90]``

-  it finds another ``namedGroupingBracesBrackets`` but this time called
   ``node`` with argument ``[below,align=left,scale=0.5]``

Referencing :numref:`lst:commandCodeBlocks`, , we see that the first
field in the ``stringsAllowedBetweenArguments`` is ``amalgamate`` and is
set to ``1`` by default. This is for users who wish to specify their
settings in multiple YAML files. For example, by using the settings in
either :numref:`lst:amalgamate-demo`
or:numref:\ ``lst:amalgamate-demo1`` is equivalent to using the settings
in :numref:`lst:amalgamate-demo2`.

 .. literalinclude:: demonstrations/amalgamate-demo.yaml
 	:caption: ``amalgamate-demo.yaml`` 
 	:name: lst:amalgamate-demo

 .. literalinclude:: demonstrations/amalgamate-demo1.yaml
 	:caption: ``amalgamate-demo1.yaml`` 
 	:name: lst:amalgamate-demo1

 .. literalinclude:: demonstrations/amalgamate-demo2.yaml
 	:caption: ``amalgamate-demo2.yaml`` 
 	:name: lst:amalgamate-demo2

We specify ``amalgamate`` to be set to ``0`` and in which case any
settings loaded prior to those specified, including the default, will be
overwritten. For example, using the settings in
:numref:`lst:amalgamate-demo3` means that only the strings specified
in that field will be used.

 .. literalinclude:: demonstrations/amalgamate-demo3.yaml
 	:caption: ``amalgamate-demo3.yaml`` 
 	:name: lst:amalgamate-demo3

It is important to note that the ``amalgamate`` field, if used, must be
in the first field, and specified using the syntax given in
:numref:`lst:amalgamate-demo1` and :numref:`lst:amalgamate-demo2`
and :numref:`lst:amalgamate-demo3`.

We may explore this feature further with the code in
:numref:`lst:for-each`, whose default output is given in
:numref:`lst:for-each-default`.

 .. literalinclude:: demonstrations/for-each.tex
 	:caption: ``for-each.tex`` 
 	:name: lst:for-each

 .. literalinclude:: demonstrations/for-each-default.tex
 	:caption: ``for-each`` default output 
 	:name: lst:for-each-default

Let’s compare this with the output from using the YAML settings in
:numref:`lst:foreach`, and running the command

::

    latexindent.pl for-each.tex -l foreach.yaml  

given in :numref:`lst:for-each-mod1`.

 .. literalinclude:: demonstrations/for-each-mod1.tex
 	:caption: ``for-each.tex`` using :numref:`lst:foreach` 
 	:name: lst:for-each-mod1

 .. literalinclude:: demonstrations/foreach.yaml
 	:caption: ``foreach.yaml`` 
 	:name: lst:foreach

You might like to compare the output given in
:numref:`lst:for-each-default` and :numref:`lst:for-each-mod1`.
Note,in particular, in :numref:`lst:for-each-default` that the
``foreach`` command has not included any of the subsequent strings, and
that the braces have been treated as a ``namedGroupingBracesBrackets``.
In :numref:`lst:for-each-mod1` the ``foreach`` command has been
allowed to have ``\x/\y`` and ``in`` between arguments because of the
settings given in :numref:`lst:foreach`.

.. describe:: commandNameSpecial:fields

There are some special command names that do not fit within the names
recognized by ``latexindent.pl``, the first one of which is
``\@ifnextchar[``. From the perspective of ``latexindent.pl``, the whole
of the text ``\@ifnextchar[`` is a command, because it is immediately
followed by sets of mandatory arguments. However, without the
``commandNameSpecial`` field, ``latexindent.pl`` would not be able to
label it as such, because the ``[`` is, necessarily, not matched by a
closing ``]``.

For example, consider the sample file in :numref:`lst:ifnextchar`,
which has default output in :numref:`lst:ifnextchar-default`.

 .. literalinclude:: demonstrations/ifnextchar.tex
 	:caption: ``ifnextchar.tex`` 
 	:name: lst:ifnextchar

 .. literalinclude:: demonstrations/ifnextchar-default.tex
 	:caption: ``ifnextchar.tex`` default output 
 	:name: lst:ifnextchar-default

Notice that in :numref:`lst:ifnextchar-default` the ``parbox`` command
has been able to indent its body, because ``latexindent.pl`` has
successfully found the command ``\@ifnextchar`` first; the
pattern-matching of ``latexindent.pl`` starts from *the inner most
<thing> and works outwards*, discussed in more detail on
:ref:`page page:phases <page:phases>`.

For demonstration, we can compare this output with that given in
:numref:`lst:ifnextchar-off` in which the settings from
:numref:`lst:no-ifnextchar` have dictated that no special command
names, including the ``\@ifnextchar[`` command, should not be searched
for specially; as such, the ``parbox`` command has been *unable* to
indent its body successfully, because the ``\@ifnextchar[`` command has
not been found.

 .. literalinclude:: demonstrations/ifnextchar-off.tex
 	:caption: ``ifnextchar.tex`` using :numref:`lst:no-ifnextchar` 
 	:name: lst:ifnextchar-off

 .. literalinclude:: demonstrations/no-ifnextchar.yaml
 	:caption: ``no-ifnextchar.yaml`` 
 	:name: lst:no-ifnextchar

The ``amalgamate`` field can be used for ``commandNameSpecial``, just as
for ``stringsAllowedBetweenArguments``. The same condition holds as
stated previously, which we state again here:

.. warning::	
	
	It is important to note that the ``amalgamate`` field, if used, in
	either ``commandNameSpecial`` or ``stringsAllowedBetweenArguments`` must
	be in the first field, and specified using the syntax given in
	:numref:`lst:amalgamate-demo1` and :numref:`lst:amalgamate-demo2`
	and :numref:`lst:amalgamate-demo3`.
	 

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-log4perl">

“Log4perl Perl Module.” 2017. Accessed September 24.
http://search.cpan.org/~mschilli/Log-Log4perl-1.49/lib/Log/Log4perl.pm.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-texttabs">

“Text:Tabs Perl Module.” 2017. Accessed July 6.
http://search.cpan.org/~muir/Text-Tabs+Wrap-2013.0523/lib.old/Text/Tabs.pm.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-vosskuhle">

Voßkuhle, Michel. 2013. “Remove Trailing White Space.” November 10.
https://github.com/cmhughes/latexindent.pl/pull/12.

.. raw:: html

   </div>

.. raw:: html

   </div>

.. [1]
   Throughout this manual, listings shown with line numbers represent
   code taken directly from ``defaultSettings.yaml``.

.. [2]
   Previously this only activated if ``alignDoubleBackSlash`` was set to
   ``0``.

.. [3]
   There is a slight difference in interface for this field when
   comparing Version 2.2 to Version 3.0; see :numref:`app:differences`
   for details.

.. [4]
   The command code blocks have quite a few subtleties, described in
   :numref:`subsec:commands-string-between`.

.. [5]
   You may like to verify this by using the ``-tt`` option and checking
   ``indent.log``!
