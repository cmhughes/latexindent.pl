How to use the script
=====================

``latexindent.pl`` ships as part of the TeXLive distribution for Linux
and Mac users; ``latexindent.exe`` ships as part of the TeXLive and
MiKTeX distributions for Windows users. These files are also available
from github (“Home of Latexindent.pl” 2017) should you wish to use them
without a TeX distribution; in this case, you may like to read
:numref:`sec:updating-path` which details how the ``path`` variable
can be updated.

In what follows, we will always refer to ``latexindent.pl``, but
depending on your operating system and preference, you might substitute
``latexindent.exe`` or simply ``latexindent``.

There are two ways to use ``latexindent.pl``: from the command line, and
using ``arara``; we discuss these in :numref:`sec:commandline` and
:numref:`sec:arara` respectively. We will discuss how to change the
settings and behaviour of the script in :numref:`sec:defuseloc`.

``latexindent.pl`` ships with ``latexindent.exe`` for Windows users, so
that you can use the script with or without a Perl distribution. If you
plan to use ``latexindent.pl`` (i.e, the original Perl script) then you
will need a few standard Perl modules – see
:numref:`sec:requiredmodules` for details; in particular, note that a
module installer helper script is shipped with ``latexindent.pl``.

.. label follows

.. _sec:commandline:

From the command line
---------------------

``latexindent.pl`` has a number of different switches/flags/options,
which can be combined in any way that you like, either in short or long
form as detailed below. ``latexindent.pl`` produces a ``.log`` file,
``indent.log``, every time it is run; the name of the log file can be
customised, but we will refer to the log file as ``indent.log``
throughout this document. There is a base of information that is written
to ``indent.log``, but other additional information will be written
depending on which of the following options are used.

.. describe:: -v, –version

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -v

This will output only the version number to the terminal.

.. describe:: -h, –help

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -h

As above this will output a welcome message to the terminal, including
the version number and available options.

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex

This will operate on ``myfile.tex``, but will simply output to your
terminal; ``myfile.tex`` will not be changed by ``latexindent.pl`` in
any way using this command.

.. describe:: -w, –overwrite

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -w myfile.tex
    latexindent.pl --overwrite myfile.tex
    latexindent.pl myfile.tex --overwrite 

This *will* overwrite ``myfile.tex``, but it will make a copy of
``myfile.tex`` first. You can control the name of the extension (default
is ``.bak``), and how many different backups are made – more on this in
:numref:`sec:defuseloc`, and in particular see ``backupExtension`` and
``onlyOneBackUp``.

Note that if ``latexindent.pl`` can not create the backup, then it will
exit without touching your original file; an error message will be given
asking you to check the permissions of the backup file.

.. describe:: -o=output.tex,–outputfile=output.tex

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -o=output.tex myfile.tex
    latexindent.pl myfile.tex -o=output.tex 
    latexindent.pl --outputfile=output.tex myfile.tex
    latexindent.pl --outputfile output.tex myfile.tex

This will indent ``myfile.tex`` and output it to ``output.tex``,
overwriting it (``output.tex``) if it already exists [1]_. Note that if
``latexindent.pl`` is called with both the ``-w`` and ``-o`` switches,
then ``-w`` will be ignored and ``-o`` will take priority (this seems
safer than the other way round).

Note that using ``-o`` as above is equivalent to using

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex > output.tex

You can call the ``-o`` switch with the name of the output file
*without* an extension; in this case, ``latexindent.pl`` will use the
extension from the original file. For example, the following two calls
to ``latexindent.pl`` are equivalent:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=output
    latexindent.pl myfile.tex -o=output.tex

You can call the ``-o`` switch using a ``+`` symbol at the beginning;
this will concatenate the name of the input file and the text given to
the ``-o`` switch. For example, the following two calls to
``latexindent.pl`` are equivalent:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=+new
    latexindent.pl myfile.tex -o=myfilenew.tex

You can call the ``-o`` switch using a ``++`` symbol at the end of the
name of your output file; this tells ``latexindent.pl`` to search
successively for the name of your output file concatenated with
:math:`0, 1, \ldots` while the name of the output file exists. For
example,

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=output++

tells ``latexindent.pl`` to output to ``output0.tex``, but if it exists
then output to ``output1.tex``, and so on.

Calling ``latexindent.pl`` with simply

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=++

tells it to output to ``myfile0.tex``, but if it exists then output to
``myfile1.tex`` and so on.

The ``+`` and ``++`` feature of the ``-o`` switch can be combined; for
example, calling

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=+out++

tells ``latexindent.pl`` to output to ``myfileout0.tex``, but if it
exists, then try ``myfileout1.tex``, and so on.

There is no need to specify a file extension when using the ``++``
feature, but if you wish to, then you should include it *after* the
``++`` symbols, for example

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -o=+out++.tex

See :numref:`app:differences` for details of how the interface has
changed from Version 2.2 to Version 3.0 for this flag.

.. describe:: -s, –silent

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -s myfile.tex
    latexindent.pl myfile.tex -s

Silent mode: no output will be given to the terminal.

.. describe:: -t, –trace

.. label follows

.. _page:traceswitch:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -t myfile.tex
    latexindent.pl myfile.tex -t

Tracing mode: verbose output will be given to ``indent.log``. This is
useful if ``latexindent.pl`` has made a mistake and you’re trying to
find out where and why. You might also be interested in learning about
``latexindent.pl``\ ’s thought process – if so, this switch is for you,
although it should be noted that, especially for large files, this does
affect performance of the script.

.. describe:: -tt, –ttrace

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -tt myfile.tex
    latexindent.pl myfile.tex -tt

*More detailed* tracing mode: this option gives more details to
``indent.log`` than the standard ``trace`` option (note that, even more
so than with ``-t``, especially for large files, performance of the
script will be affected).

.. describe:: -l, –local[=myyaml.yaml,other.yaml,...]

.. label follows

.. _page:localswitch:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l myfile.tex
    latexindent.pl -l=myyaml.yaml myfile.tex
    latexindent.pl -l myyaml.yaml myfile.tex
    latexindent.pl -l first.yaml,second.yaml,third.yaml myfile.tex
    latexindent.pl -l=first.yaml,second.yaml,third.yaml myfile.tex
    latexindent.pl myfile.tex -l=first.yaml,second.yaml,third.yaml 

``latexindent.pl`` will always load ``defaultSettings.yaml`` (rhymes
with camel) and if it is called with the ``-l`` switch and it finds
``localSettings.yaml`` in the same directory as ``myfile.tex`` then
these settings will be added to the indentation scheme. Information will
be given in ``indent.log`` on the success or failure of loading
``localSettings.yaml``.

The ``-l`` flag can take an *optional* parameter which details the name
(or names separated by commas) of a YAML file(s) that resides in the
same directory as ``myfile.tex``; you can use this option if you would
like to load a settings file in the current working directory that is
*not* called ``localSettings.yaml``. In fact, you can specify both
*relative* and *absolute paths* for your YAML files; for example

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l=../../myyaml.yaml myfile.tex
    latexindent.pl -l=/home/cmhughes/Desktop/myyaml.yaml myfile.tex
    latexindent.pl -l=C:\Users\cmhughes\Desktop\myyaml.yaml myfile.tex

You will find a lot of other explicit demonstrations of how to use the
``-l`` switch throughout this documentation,

You can call the ``-l`` switch with a ‘+’ symbol either before or after
another YAML file; for example:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l=+myyaml.yaml myfile.tex
    latexindent.pl -l "+ myyaml.yaml" myfile.tex
    latexindent.pl -l=myyaml.yaml+  myfile.tex

which translate, respectively, to

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l=localSettings.yaml,myyaml.yaml myfile.tex
    latexindent.pl -l=localSettings.yaml,myyaml.yaml myfile.tex
    latexindent.pl -l=myyaml.yaml,localSettings.yaml myfile.tex

Note that the following is *not* allowed:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l+myyaml.yaml myfile.tex

and

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l + myyaml.yaml myfile.tex

will *only* load ``localSettings.yaml``, and ``myyaml.yaml`` will be
ignored. If you wish to use spaces between any of the YAML settings,
then you must wrap the entire list of YAML files in quotes, as
demonstrated above.

You may also choose to omit the ``yaml`` extension, such as

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -l=localSettings,myyaml myfile.tex

.. describe:: -y, –yaml=yaml settings

.. label follows

.. _page:yamlswitch:

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile.tex -y="defaultIndent: ' '"
    latexindent.pl myfile.tex -y="defaultIndent: ' ',maximumIndentation:' '"
    latexindent.pl myfile.tex -y="indentRules: one: '\t\t\t\t'"
    latexindent.pl myfile.tex -y='modifyLineBreaks:environments:EndStartsOnOwnLine:3' -m
    latexindent.pl myfile.tex -y='modifyLineBreaks:environments:one:EndStartsOnOwnLine:3' -m

You can specify YAML settings from the command line using the ``-y`` or
``–yaml`` switch; sample demonstrations are given above. Note, in
particular, that multiple settings can be specified by separating them
via commas. There is a further option to use a ``;`` to separate fields,
which is demonstrated in :numref:`sec:yamlswitch`.

Any settings specified via this switch will be loaded *after* any
specified using the ``-l`` switch. This is discussed further in
:numref:`sec:loadorder`.

.. describe:: -d, –onlydefault

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -d myfile.tex

Only ``defaultSettings.yaml``: you might like to read
:numref:`sec:defuseloc` before using this switch. By default,
``latexindent.pl`` will always search for ``indentconfig.yaml`` or
``.indentconfig.yaml`` in your home directory. If you would prefer it
not to do so then (instead of deleting or renaming ``indentconfig.yaml``
or ``.indentconfig.yaml``) you can simply call the script with the
``-d`` switch; note that this will also tell the script to ignore
``localSettings.yaml`` even if it has been called with the ``-l``
switch; ``latexindent.pl`` will also ignore any settings specified from
the ``-y`` switch.

.. describe:: -c, –cruft=<directory>

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -c=/path/to/directory/ myfile.tex

If you wish to have backup files and ``indent.log`` written to a
directory other than the current working directory, then you can send
these ‘cruft’ files to another directory. Note the use of a trailing
forward slash.

.. describe:: -g, –logfile=<name of log file>

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -g=other.log myfile.tex
    latexindent.pl -g other.log myfile.tex
    latexindent.pl --logfile other.log myfile.tex
    latexindent.pl myfile.tex -g other.log 

By default, ``latexindent.pl`` reports information to ``indent.log``,
but if you wish to change the name of this file, simply call the script
with your chosen name after the ``-g`` switch as demonstrated above.

.. describe:: -sl, –screenlog

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -sl myfile.tex
    latexindent.pl -screenlog myfile.tex

Using this option tells ``latexindent.pl`` to output the log file to the
screen, as well as to your chosen log file.

.. describe:: -m, –modifylinebreaks

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -m myfile.tex
    latexindent.pl -modifylinebreaks myfile.tex

One of the most exciting developments in Version 3.0 is the ability to
modify line breaks; for full details see
:numref:`sec:modifylinebreaks`

``latexindent.pl`` can also be called on a file without the file
extension, for example

.. code-block:: latex
   :class: .commandshell

    latexindent.pl myfile

and in which case, you can specify the order in which extensions are
searched for; see :numref:`lst:fileExtensionPreference` for full
details.

.. describe:: STDIN

.. code-block:: latex
   :class: .commandshell

    cat myfile.tex | latexindent.pl
    cat myfile.tex | latexindent.pl -

``latexindent.pl`` will allow input from STDIN, which means that you can
pipe output from other commands directly into the script. For example
assuming that you have content in ``myfile.tex``, then the above command
will output the results of operating upon ``myfile.tex``.

If you wish to use this feature with your own local settings, via the
``-l`` switch, then you should finish your call to ``latexindent.pl``
with a ``-`` sign:

.. code-block:: latex
   :class: .commandshell

    cat myfile.tex | latexindent.pl -l=mysettings.yaml -

Similarly, if you simply type ``latexindent.pl`` at the command line,
then it will expect (STDIN) input from the command line.

.. code-block:: latex
   :class: .commandshell

    latexindent.pl

Once you have finished typing your input, you can press

-  ``CTRL+D`` on Linux

-  ``CTRL+Z`` followed by ``ENTER`` on Windows

to signify that your input has finished. Thanks to ((xu-cheng) 2018) for
an update to this feature.

.. describe:: -r, –replacement

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -r myfile.tex
    latexindent.pl -replacement myfile.tex

You can call ``latexindent.pl`` with the ``-r`` switch to instruct it to
perform replacements/substitutions on your file; full details and
examples are given in :numref:`sec:replacements`.

.. describe:: -rv, –replacementrespectverb

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -rv myfile.tex
    latexindent.pl -replacementrespectverb myfile.tex

You can instruct ``latexindent.pl`` to perform
replacements/substitutions by using the ``-rv`` switch, but will
*respect verbatim code blocks*; full details and examples are given in
:numref:`sec:replacements`.

.. describe:: -rr, –onlyreplacement

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -rr myfile.tex
    latexindent.pl -onlyreplacement myfile.tex

You can instruct ``latexindent.pl`` to skip all of its other indentation
operations and *only* perform replacements/substitutions by using the
``-rr`` switch; full details and examples are given in
:numref:`sec:replacements`.

.. label follows

.. _sec:arara:

From arara
----------

Using ``latexindent.pl`` from the command line is fine for some folks,
but others may find it easier to use from ``arara``; you can find the
arara rule for ``latexindent.pl`` and its associated documentation at
(Cereda 2013).

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-paulo">

Cereda, Paulo. 2013. “Arara Rule, Indent.yaml.” May 23.
https://github.com/cereda/arara/blob/master/rules/indent.yaml.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-latexindent-home">

“Home of Latexindent.pl.” 2017. Accessed January 23.
https://github.com/cmhughes/latexindent.pl.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-xu-cheng">

(xu-cheng), Cheng Xu. 2018. “Always Output Log/Help Text to Stderr.”
July 13. https://github.com/cmhughes/latexindent.pl/pull/121.

.. raw:: html

   </div>

.. raw:: html

   </div>

.. [1]
   Users of version 2.\* should note the subtle change in syntax
