Demonstration: before and after
===============================

Let’s give a demonstration of some before and after code – after all,
you probably won’t want to try the script if you don’t much like the
results. You might also like to watch the video demonstration I made on
youtube (“Video Demonstration of Latexindent.pl on Youtube” 2017)

As you look at :numref:`lst:filecontentsbefore` –
:numref:`lst:pstricksafter`, remember that ``latexindent.pl`` is just
following its rules, and there is nothing particular about these code
snippets. All of the rules can be modified so that you can personalise
your indentation scheme.

In each of the samples given in :numref:`lst:filecontentsbefore` –
:numref:`lst:pstricksafter` the ‘before’ case is a ‘worst case
scenario’ with no effort to make indentation. The ‘after’ result would
be the same, regardless of the leading white space at the beginning of
each line which is stripped by ``latexindent.pl`` (unless a
``verbatim``-like environment or ``noIndentBlock`` is specified – more
on this in :numref:`sec:defuseloc`).

 .. literalinclude:: demonstrations/filecontents1.tex
 	:class: .tex
 	:caption: ``filecontents1.tex`` 
 	:name: lst:filecontentsbefore

 .. literalinclude:: demonstrations/filecontents1-default.tex
 	:class: .tex
 	:caption: ``filecontents1.tex`` default output 
 	:name: lst:filecontentsafter

 .. literalinclude:: demonstrations/tikzset.tex
 	:class: .tex
 	:caption: ``tikzset.tex`` 
 	:name: lst:tikzsetbefore

 .. literalinclude:: demonstrations/tikzset-default.tex
 	:class: .tex
 	:caption: ``tikzset.tex`` default output 
 	:name: lst:tikzsetafter

 .. literalinclude:: demonstrations/pstricks.tex
 	:class: .tex
 	:caption: ``pstricks.tex`` 
 	:name: lst:pstricksbefore

 .. literalinclude:: demonstrations/pstricks-default.tex
 	:class: .tex
 	:caption: ``pstricks.tex`` default output 
 	:name: lst:pstricksafter

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-cmh:videodemo">

“Video Demonstration of Latexindent.pl on Youtube.” 2017. Accessed
February 21. https://www.youtube.com/watch?v=wo38aaH2F4E&spfreload=10.

.. raw:: html

   </div>

.. raw:: html

   </div>
