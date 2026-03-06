Introduction
============

License
-------

``latexindent.pl`` is free and open source, and it always will be; it is released under the GNU General Public License v3.0.

Before you start using it on any important files, bear in mind that ``latexindent.pl`` has the option to overwrite your ``.tex`` files. It will always make at least one backup (you can choose how many it makes, see :ref:`page page:onlyonebackup <page:onlyonebackup>`) but you should still be careful when using it. The script has been tested on many files, but there are some known limitations (see :numref:`sec:knownlimitations`). You, the user, are responsible for ensuring that you maintain
backups of your files before running ``latexindent.pl`` on them. I think it is important at this stage to restate an important part of the license here:

   *This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.*

There is certainly no malicious intent in releasing this script, and I do hope that it works as you expect it to; if it does not, please first of all make sure that you have the correct settings, and then feel free to let me know at (“Home of Latexindent.pl” n.d.) with a complete minimum working example as I would like to improve the code as much as possible.

.. warning::	
	
	Before you try the script on anything important (like your thesis), test it out on the sample files in the ``test-case`` directory (“Home of Latexindent.pl” n.d.).
	
	.. index:: warning;be sure to test before use
	


.. label follows

.. _sec:quickstart:

Quick start
-----------

When ``latexindent.pl`` reads and writes files, the files are read and written in UTF-8 format by default. That is to say, the encoding format for tex and yaml files needs to be in UTF-8 format.

If you’d like to get started with ``latexindent.pl`` then simply type

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile.tex

from the command line.

We give an introduction to ``latexindent.pl`` using :numref:`lst:quick-start`; there is no explanation in this section, which is deliberate for a quick start. The rest of the manual is more verbose.

.. literalinclude:: demonstrations/quick-start.tex
	:class: .tex
	:caption: ``quick-start.tex`` 
	:name: lst:quick-start

Running

.. code-block:: latex
   :class: .commandshell

   latexindent.pl quick-start.tex

gives :numref:`lst:quick-start-default`.

.. literalinclude:: demonstrations/quick-start-default.tex
	:class: .tex
	:caption: ``quick-start-default.tex`` 
	:name: lst:quick-start-default

.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l quick-start1.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod1`.
	
	.. literalinclude:: demonstrations/quick-start-mod1.tex
		:class: .tex
		:caption: ``quick-start-mod1.tex`` 
		:name: lst:quick-start-mod1
	
	.. literalinclude:: demonstrations/quick-start1.yaml
		:class: .baseyaml
		:caption: ``quick-start1.yaml`` 
		:name: lst:quick-start1yaml
	
	See :numref:`subsec:indentation:and:horizontal:space`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l quick-start2.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod2`.
	
	.. literalinclude:: demonstrations/quick-start-mod2.tex
		:class: .tex
		:caption: ``quick-start-mod2.tex`` 
		:name: lst:quick-start-mod2
	
	.. literalinclude:: demonstrations/quick-start2.yaml
		:class: .baseyaml
		:caption: ``quick-start2.yaml`` 
		:name: lst:quick-start2yaml
	
	See :numref:`sec:noadd-indent-rules`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l quick-start3.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod3`.
	
	.. literalinclude:: demonstrations/quick-start-mod3.tex
		:class: .tex
		:caption: ``quick-start-mod3.tex`` 
		:name: lst:quick-start-mod3
	
	.. literalinclude:: demonstrations/quick-start3.yaml
		:class: .baseyaml
		:caption: ``quick-start3.yaml`` 
		:name: lst:quick-start3yaml
	
	See :numref:`sec:noadd-indent-rules`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l quick-start4.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod4`.
	
	.. literalinclude:: demonstrations/quick-start-mod4.tex
		:class: .tex
		:caption: ``quick-start-mod4.tex`` 
		:name: lst:quick-start-mod4
	
	.. literalinclude:: demonstrations/quick-start4.yaml
		:class: .mlbyaml
		:caption: ``quick-start4.yaml`` 
		:name: lst:quick-start4yaml
	
	Full details of text wrapping in :numref:`subsec:textwrapping`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l quick-start5.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod5`.
	
	.. literalinclude:: demonstrations/quick-start-mod5.tex
		:class: .tex
		:caption: ``quick-start-mod5.tex`` 
		:name: lst:quick-start-mod5
	
	.. literalinclude:: demonstrations/quick-start5.yaml
		:class: .mlbyaml
		:caption: ``quick-start5.yaml`` 
		:name: lst:quick-start5yaml
	
	Full details of text wrapping in :numref:`subsec:textwrapping`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l quick-start6.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod6`.
	
	.. literalinclude:: demonstrations/quick-start-mod6.tex
		:class: .tex
		:caption: ``quick-start-mod6.tex`` 
		:name: lst:quick-start-mod6
	
	.. literalinclude:: demonstrations/quick-start6.yaml
		:class: .mlbyaml
		:caption: ``quick-start6.yaml`` 
		:name: lst:quick-start6yaml
	
	This is an example of a *poly-switch*; full details of *poly-switches* are covered in :numref:`sec:poly-switches`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -m -l quick-start7.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod7`.
	
	.. literalinclude:: demonstrations/quick-start-mod7.tex
		:class: .tex
		:caption: ``quick-start-mod7.tex`` 
		:name: lst:quick-start-mod7
	
	.. literalinclude:: demonstrations/quick-start7.yaml
		:class: .mlbyaml
		:caption: ``quick-start7.yaml`` 
		:name: lst:quick-start7yaml
	
	Full details of *poly-switches* are covered in :numref:`sec:poly-switches`.


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l quick-start8.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod8`; note that the *preamble* has been indented.
	
	.. literalinclude:: demonstrations/quick-start-mod8.tex
		:class: .tex
		:caption: ``quick-start-mod8.tex`` 
		:name: lst:quick-start-mod8
	
	.. literalinclude:: demonstrations/quick-start8.yaml
		:class: .baseyaml
		:caption: ``quick-start8.yaml`` 
		:name: lst:quick-start8yaml
	
	See :numref:`subsec:filecontents:preamble`.
	


.. proof:example::	
	
	Running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l quick-start9.yaml quick-start.tex
	
	gives :numref:`lst:quick-start-mod9`.
	
	.. literalinclude:: demonstrations/quick-start-mod9.tex
		:class: .tex
		:caption: ``quick-start-mod9.tex`` 
		:name: lst:quick-start-mod9
	
	.. literalinclude:: demonstrations/quick-start9.yaml
		:class: .baseyaml
		:caption: ``quick-start9.yaml`` 
		:name: lst:quick-start9yaml
	
	See :numref:`sec:noadd-indent-rules`.


Requirements
------------

Perl users
~~~~~~~~~~

Perl users will need a few standard Perl modules – see :numref:`sec:requiredmodules` for details; in particular, note that a module installer helper script is shipped with ``latexindent.pl``. You might also like to see https://stackoverflow.com/questions/19590042/error-cant-locate-file-homedir-pm-in-inc.

.. label follows

.. _subsubsec:latexindent:exe:

Windows users without perl
~~~~~~~~~~~~~~~~~~~~~~~~~~

``latexindent.pl`` ships with ``latexindent.exe`` for Windows users, so that you can use the script with or without a Perl distribution.

``latexindent.exe`` is available from (“Home of Latexindent.pl” n.d.).

MiKTeX users on Windows may like to see (“How to Use Latexindent on Windows?” n.d.) for details of how to use ``latexindent.exe`` without a Perl installation.

.. index:: MiKTeX

.. index:: latexindent.exe

.. index:: Windows

Ubuntu Linux users without perl
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``latexindent.pl`` ships with ``latexindent-linux`` for Ubuntu Linux users, so that you can use the script with or without a Perl distribution.

.. index:: latexindent-linux

.. index:: linux

.. index:: TeXLive

``latexindent-linux`` is available from (“Home of Latexindent.pl” n.d.).

macOS users without perl
~~~~~~~~~~~~~~~~~~~~~~~~

``latexindent.pl`` ships with ``latexindent-macos`` for macOS users, so that you can use the script with or without a Perl distribution.

.. index:: latexindent-macos

.. index:: macOS

.. index:: TeXLive

``latexindent-macOS`` is available from (“Home of Latexindent.pl” n.d.).

conda users
~~~~~~~~~~~

Users of ``conda`` should see the details given in :numref:`sec:app:conda`.

.. index:: conda

docker users
~~~~~~~~~~~~

Users of ``docker`` should see the details given in :numref:`sec:app:docker`.

.. index:: docker

About this documentation
------------------------

As you read through this documentation, you will see many listings; in this version of the documentation, there are a total of 580. This may seem a lot, but I deem it necessary in presenting the various different options of ``latexindent.pl`` and the associated output that they are capable of producing.

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
	:lines: 31-35
	:linenos:
	:lineno-start: 31

This type of listing is a ``.yaml`` file; when you see line numbers given (as here) it means that the snippet is taken directly from ``defaultSettings.yaml``, discussed in detail in :numref:`sec:defuseloc`.

.. literalinclude:: ../defaultSettings.yaml
	:class: .mlbyaml
	:caption: ``modifyLineBreaks`` 
	:name: lst:modifylinebreaks-demo
	:lines: 309-311
	:linenos:
	:lineno-start: 309

This type of listing is a ``.yaml`` file, but it will only be relevant when the ``-m`` switch is active; see :numref:`sec:modifylinebreaks` for more details.

.. literalinclude:: ../defaultSettings.yaml
	:class: .replaceyaml
	:caption: ``replacements`` 
	:name: lst:replacements-demo
	:lines: 439-444
	:linenos:
	:lineno-start: 439

This type of listing is a ``.yaml`` file, but it will only be relevant when the ``-r`` switch is active; see :numref:`sec:replacements` for more details.

A word about regular expressions
--------------------------------

.. index:: regular expressions;a word about

As you read this documentation, you may encounter the term *regular expressions*. I’ve tried to write this documentation in such a way so as to allow you to engage with them or not, as you prefer. This documentation is not designed to be a guide to regular expressions, and if you’d like to read about them, I recommend (Friedl, n.d.).

.. container:: references hanging-indent
   :name: refs

   .. container::
      :name: ref-masteringregexp

      Friedl, Jeffrey E. F. n.d. *Mastering Regular Expressions*.

   .. container::
      :name: ref-latexindent-home

      “Home of Latexindent.pl.” n.d. Accessed January 23, 2017. https://github.com/cmhughes/latexindent.pl.

   .. container::
      :name: ref-miktex-guide

      “How to Use Latexindent on Windows?” n.d. Accessed January 8, 2022. https://tex.stackexchange.com/questions/577250/how-to-use-latexindent-on-windows.
