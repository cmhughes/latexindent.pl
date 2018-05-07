Introduction
============

Thanks
------

I first created ``latexindent.pl`` to help me format chapter files in a
big project. After I blogged about it on the TeX stack exchange (“A Perl
Script for Indenting Tex Files” 2017) I received some positive feedback
and follow-up feature requests. A big thank you to Harish Kumar Kumar
(2013) who helped to develop and test the initial versions of the
script.

The ``YAML``-based interface of ``latexindent.pl`` was inspired by the
wonderful ``arara`` tool; any similarities are deliberate, and I hope
that it is perceived as the compliment that it is. Thank you to Paulo
Cereda and the team for releasing this awesome tool; I initially worried
that I was going to have to make a GUI for ``latexindent.pl``, but the
release of ``arara`` has meant there is no need.

There have been several contributors to the project so far (and
hopefully more in the future!); thank you very much to the people
detailed in :numref:`sec:contributors` for their valued contributions,
and thank you to those who report bugs and request features at (“Home of
Latexindent.pl” 2017).

License
-------

``latexindent.pl`` is free and open source, and it always will be; it is
released under the GNU General Public License v3.0.

Before you start using it on any important files, bear in mind that
``latexindent.pl`` has the option to overwrite your ``.tex`` files. It
will always make at least one backup (you can choose how many it makes,
see :ref:`page page:onlyonebackup <page:onlyonebackup>`) but you
should still be careful when using it. The script has been tested on
many files, but there are some known limitations (see
:numref:`sec:knownlimitations`). You, the user, are responsible for
ensuring that you maintain backups of your files before running
``latexindent.pl`` on them. I think it is important at this stage to
restate an important part of the license here:

    *This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    General Public License for more details.*

There is certainly no malicious intent in releasing this script, and I
do hope that it works as you expect it to; if it does not, please first
of all make sure that you have the correct settings, and then feel free
to let me know at (“Home of Latexindent.pl” 2017) with a complete
minimum working example as I would like to improve the code as much as
possible.

.. warning::	
	
	Before you try the script on anything important (like your thesis), test
	it out on the sample files in the ``test-case`` directory (“Home of
	Latexindent.pl” 2017).
	 

*If you have used any version 2.\* of ``latexindent.pl``, there are a
few changes to the interface; see :numref:`app:differences` and the
comments throughout this document for details*.

About this documentation
------------------------

As you read through this documentation, you will see many listings; in
this version of the documentation, there are a total of 351. This may
seem a lot, but I deem it necessary in presenting the various different
options of ``latexindent.pl`` and the associated output that they are
capable of producing.

The different listings are presented using different styles:

 .. literalinclude:: demonstrations/demo-tex.tex
 	:class: .tex
 	:caption: ``demo-tex.tex`` 
 	:name: lst:demo-tex

This type of listing is a ``.tex`` file.

 .. literalinclude:: ../defaultSettings.yaml
 	:class: .baseyaml
 	:caption: ``fileExtensionPreference`` 
 	:name: lst:fileExtensionPreference-demo
 	:lines: 38-42
 	:linenos:
 	:lineno-start: 38

This type of listing is a ``.yaml`` file; when you see line numbers
given (as here) it means that the snippet is taken directly from
``defaultSettings.yaml``, discussed in detail in
:numref:`sec:defuseloc`.

 .. literalinclude:: ../defaultSettings.yaml
 	:class: .mlbyaml
 	:caption: ``modifyLineBreaks`` 
 	:name: lst:modifylinebreaks-demo
 	:lines: 395-397
 	:linenos:
 	:lineno-start: 395

This type of listing is a ``.yaml`` file, but it will only be relevant
when the ``-m`` switch is active; see :numref:`sec:modifylinebreaks`
for more details.

.. label follows

.. _sec:quickstart:

Quick start
-----------

If you’d like to get started with ``latexindent.pl`` then simply type

::

    latexindent.pl myfile.tex
        

from the command line. If you receive an error message such as that
given in :numref:`lst:poss-errors`, then you need to install the
missing perl modules.

.. code-block:: latex
   :caption: Possible error messages 
   :name: lst:poss-errors

    Can't locate File/HomeDir.pm in @INC (@INC contains: /Library/Perl/5.12/darwin-thread-multi-2level /Library/Perl/5.12 /Network/Library/Perl/5.12/darwin-thread-multi-2level /Network/Library/Perl/5.12 /Library/Perl/Updates/5.12.4/darwin-thread-multi-2level /Library/Perl/Updates/5.12.4 /System/Library/Perl/5.12/darwin-thread-multi-2level /System/Library/Perl/5.12 /System/Library/Perl/Extras/5.12/darwin-thread-multi-2level /System/Library/Perl/Extras/5.12 .) at helloworld.pl line 10.
    BEGIN failed--compilation aborted at helloworld.pl line 10.

``latexindent.pl`` ships with a script to help with this process; if you
run the following script, you should be prompted to install the
appropriate modules.

::

    perl latexindent-module-installer.pl
        

You might also like to see
https://stackoverflow.com/questions/19590042/error-cant-locate-file-homedir-pm-in-inc,
for example, as well as :numref:`sec:requiredmodules`.

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-cmhblog">

“A Perl Script for Indenting Tex Files.” 2017. Accessed January 23.
http://tex.blogoverflow.com/2012/08/a-perl-script-for-indenting-tex-files/.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-latexindent-home">

“Home of Latexindent.pl.” 2017. Accessed January 23.
https://github.com/cmhughes/latexindent.pl.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-harish">

Kumar, Harish. 2013. “Early Version Testing.” November 10.
https://github.com/harishkumarholla.

.. raw:: html

   </div>

.. raw:: html

   </div>
