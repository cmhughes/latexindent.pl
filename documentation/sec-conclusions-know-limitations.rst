.. label follows

.. _sec:knownlimitations:

Conclusions and known limitations
=================================

There are a number of known limitations of the script, and almost
certainly quite a few that are *unknown*!

The main limitation is to do with the alignment routine discussed on
:ref:`page yaml:lookforaligndelims <yaml:lookforaligndelims>`; for
example, consider the file given in :numref:`lst:matrix2`.

 .. literalinclude:: demonstrations/matrix2.tex
 	:class: .tex
 	:caption: ``matrix2.tex`` 
 	:name: lst:matrix2

The default output is given in :numref:`lst:matrix2-default`, and it
is clear that the alignment routine has not worked as hoped, but it is
*expected*.

 .. literalinclude:: demonstrations/matrix2-default.tex
 	:class: .tex
 	:caption: ``matrix2.tex`` default output 
 	:name: lst:matrix2-default

The reason for the problem is that when ``latexindent.pl`` stores its
code blocks (see :numref:`tab:code-blocks`) it uses replacement
tokens. The alignment routine is using the *length of the replacement
token* in its measuring – I hope to be able to address this in the
future.

There are other limitations to do with the multicolumn alignment routine
(see :numref:`lst:tabular2-mod2`); in particular, when working with
codeblocks in which multicolumn commands overlap, the algorithm can
fail.

Another limitation is to do with efficiency, particularly when the
``-m`` switch is active, as this adds many checks and processes. The
current implementation relies upon finding and storing *every* code
block (see the discussion on :ref:`page page:phases <page:phases>`);
it is hoped that, in a future version, only *nested* code blocks will
need to be stored in the ‘packing’ phase, and that this will improve the
efficiency of the script.

You can run ``latexindent`` on any file; if you don’t specify an
extension, then the extensions that you specify in
``fileExtensionPreference`` (see
:numref:`lst:fileExtensionPreference`) will be consulted. If you find
a case in which the script struggles, please feel free to report it at
(“Home of Latexindent.pl” 2017), and in the meantime, consider using a
``noIndentBlock`` (see
:ref:`page lst:noIndentBlockdemo <lst:noIndentBlockdemo>`).

I hope that this script is useful to some; if you find an example where
the script does not behave as you think it should, the best way to
contact me is to report an issue on (“Home of Latexindent.pl” 2017);
otherwise, feel free to find me on the
http://tex.stackexchange.com/users/6621/cmhughes.

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-latexindent-home">

“Home of Latexindent.pl.” 2017. Accessed January 23.
https://github.com/cmhughes/latexindent.pl.

.. raw:: html

   </div>

.. raw:: html

   </div>
