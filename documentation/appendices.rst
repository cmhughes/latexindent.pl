Appendices
==========

.. label follows

.. _sec:requiredmodules:

Required Perl modules
---------------------

If you intend to use ``latexindent.pl`` and *not* one of the supplied
standalone executable files, then you will need a few standard Perl
modules – if you can run the minimum code in :numref:`lst:helloworld`
(``perl helloworld.pl``) then you will be able to run
``latexindent.pl``, otherwise you may need to install the missing
modules – see :numref:`sec:module-installer` and
:numref:`sec:manual-module-instal`.

.. code-block:: latex
   :caption: ``helloworld.pl`` 
   :name: lst:helloworld

    #!/usr/bin/perl

    use strict;
    use warnings;
    use utf8;
    use PerlIO::encoding;
    use Unicode::GCString;
    use open ':std', ':encoding(UTF-8)';
    use Text::Wrap;
    use Text::Tabs;
    use FindBin;
    use YAML::Tiny;
    use File::Copy;
    use File::Basename;
    use File::HomeDir;
    use Getopt::Long;
    use Data::Dumper;
    use List::Util qw(max);
    use Log::Log4perl qw(get_logger :levels);

    print "hello world";
    exit;

.. label follows

.. _sec:module-installer:

Module installer script
~~~~~~~~~~~~~~~~~~~~~~~

``latexindent.pl`` ships with a helper script that will install any
missing ``perl`` modules on your system; if you run

.. code-block:: latex
   :class: .commandshell

    perl latexindent-module-installer.pl
         

or

perl latexindent-module-installer.pl

then, once you have answered ``Y``, the appropriate modules will be
installed onto your distribution.

.. label follows

.. _sec:manual-module-instal:

Manually installed modules
~~~~~~~~~~~~~~~~~~~~~~~~~~

Manually installing the modules given in :numref:`lst:helloworld` will
vary depending on your operating system and ``Perl`` distribution. For
example, Ubuntu users might visit the software center, or else run

.. code-block:: latex
   :class: .commandshell

    sudo perl -MCPAN -e 'install "File::HomeDir"'
     

Linux users may be interested in exploring Perlbrew (“Perlbrew” 2017);
possible installation and setup options follow for Ubuntu (other
distributions will need slightly different commands).

.. code-block:: latex
   :class: .commandshell

    sudo apt-get install perlbrew
    perlbrew install perl-5.22.1
    perlbrew switch perl-5.22.1
    sudo apt-get install curl
    curl -L http://cpanmin.us | perl - App::cpanminus
    cpanm YAML::Tiny
    cpanm File::HomeDir
    cpanm Unicode::GCString
    cpanm Log::Log4perl
    cpanm Log::Dispatch

Users of the Macintosh operating system might like to explore the
following commands, for example:

.. code-block:: latex
   :class: .commandshell

    brew install perl
    brew install cpanm

    cpanm YAML::Tiny
    cpanm File::HomeDir
    cpanm Unicode::GCString
    cpanm Log::Log4perl
    cpanm Log::Dispatch

Strawberry Perl users on Windows might use ``CPAN client``. All of the
modules are readily available on CPAN (“CPAN: Comprehensive Perl Archive
Network” 2017).

``indent.log`` will contain details of the location of the Perl modules
on your system. ``latexindent.exe`` is a standalone executable for
Windows (and therefore does not require a Perl distribution) and caches
copies of the Perl modules onto your system; if you wish to see where
they are cached, use the ``trace`` option, e.g

latexindent.exe -t myfile.tex

.. label follows

.. _sec:updating-path:

Updating the path variable
--------------------------

``latexindent.pl`` has a few scripts (available at (“Home of
Latexindent.pl” 2017)) that can update the ``path`` variables. Thank you
to Juang (2015) for this feature. If you’re on a Linux or Mac machine,
then you’ll want ``CMakeLists.txt`` from (“Home of Latexindent.pl”
2017).

Add to path for Linux
~~~~~~~~~~~~~~~~~~~~~

To add ``latexindent.pl`` to the path for Linux, follow these steps:

#. download ``latexindent.pl`` and its associated modules,
   ``defaultSettings.yaml``, to your chosen directory from (“Home of
   Latexindent.pl” 2017) ;

#. within your directory, create a directory called
   ``path-helper-files`` and download ``CMakeLists.txt`` and
   ``cmake_uninstall.cmake.in`` from (“Home of Latexindent.pl”
   2017)/path-helper-files to this directory;

#. run

   .. code-block:: latex
      :class: .commandshell

       ls /usr/local/bin
                 

   to see what is *currently* in there;

#. run the following commands

   .. code-block:: latex
      :class: .commandshell

       sudo apt-get install cmake
       sudo apt-get update && sudo apt-get install build-essential
       mkdir build && cd build
       cmake ../path-helper-files
       sudo make install

#. run

   .. code-block:: latex
      :class: .commandshell

       ls /usr/local/bin
                 

   again to check that ``latexindent.pl``, its modules and
   ``defaultSettings.yaml`` have been added.

To *remove* the files, run

.. code-block:: latex
   :class: .commandshell

    sudo make uninstall
        

Add to path for Windows
~~~~~~~~~~~~~~~~~~~~~~~

To add ``latexindent.exe`` to the path for Windows, follow these steps:

#. download ``latexindent.exe``, ``defaultSettings.yaml``,
   ``add-to-path.bat`` from (“Home of Latexindent.pl” 2017) to your
   chosen directory;

#. open a command prompt and run the following command to see what is
   *currently* in your ``%path%`` variable;

   echo

#. right click on ``add-to-path.bat`` and *Run as administrator*;

#. log out, and log back in;

#. open a command prompt and run

   echo

   to check that the appropriate directory has been added to your
   ``%path%``.

To *remove* the directory from your ``%path%``, run
``remove-from-path.bat`` as administrator.

.. label follows

.. _app:logfile-demo:

logFilePreferences
------------------

:numref:`lst:logFilePreferences` describes the options for customising
the information given to the log file, and we provide a few
demonstrations here. Let’s say that we start with the code given in
:numref:`lst:simple`, and the settings specified in
:numref:`lst:logfile-prefs1-yaml`.

 .. literalinclude:: demonstrations/simple.tex
 	:class: .tex
 	:caption: ``simple.tex`` 
 	:name: lst:simple

 .. literalinclude:: demonstrations/logfile-prefs1.yaml
 	:class: .baseyaml
 	:caption: ``logfile-prefs1.yaml`` 
 	:name: lst:logfile-prefs1-yaml

If we run the following command (noting that ``-t`` is active)

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -t -l=logfile-prefs1.yaml simple.tex 
     

then on inspection of ``indent.log`` we will find the snippet given in
:numref:`lst:indentlog`.

.. code-block:: latex
   :caption: ``indent.log`` 
   :name: lst:indentlog

           +++++
    TRACE: environment found: myenv
           No ancestors found for myenv
           Storing settings for myenvenvironments
           indentRulesGlobal specified (0) for environments, ...
           Using defaultIndent for myenv
           Putting linebreak after replacementText for myenv
           looking for COMMANDS and key = {value}
    TRACE: Searching for commands with optional and/or mandatory arguments AND key = {value}
           looking for SPECIAL begin/end
    TRACE: Searching myenv for special begin/end (see specialBeginEnd)
    TRACE: Searching myenv for optional and mandatory arguments
           ... no arguments found
           -----
         

Notice that the information given about ``myenv`` is ‘framed’ using
``+++++`` and ``-----`` respectively.

.. label follows

.. _app:differences:

Differences from Version 2.2 to 3.0
-----------------------------------

There are a few (small) changes to the interface when comparing Version
2.2 to Version 3.0. Explicitly, in previous versions you might have run,
for example,

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -o myfile.tex outputfile.tex
     

whereas in Version 3.0 you would run any of the following, for example,

.. code-block:: latex
   :class: .commandshell

    latexindent.pl -o=outputfile.tex myfile.tex
    latexindent.pl -o outputfile.tex myfile.tex
    latexindent.pl myfile.tex -o outputfile.tex 
    latexindent.pl myfile.tex -o=outputfile.tex 
    latexindent.pl myfile.tex -outputfile=outputfile.tex 
    latexindent.pl myfile.tex -outputfile outputfile.tex 
     

noting that the *output* file is given *next to* the ``-o`` switch.

The fields given in :numref:`lst:obsoleteYaml` are *obsolete* from
Version 3.0 onwards.

 .. literalinclude:: demonstrations/obsolete.yaml
 	:class: .obsolete
 	:caption: Obsolete YAML fields from Version 3.0 
 	:name: lst:obsoleteYaml

There is a slight difference when specifying indentation after headings;
specifically, we now write ``indentAfterThisHeading`` instead of
``indent``. See :numref:`lst:indentAfterThisHeadingOld` and
:numref:`lst:indentAfterThisHeadingNew`

 .. literalinclude:: demonstrations/indentAfterThisHeadingOld.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 2.2 
 	:name: lst:indentAfterThisHeadingOld

 .. literalinclude:: demonstrations/indentAfterThisHeadingNew.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 3.0 
 	:name: lst:indentAfterThisHeadingNew

To specify ``noAdditionalIndent`` for display-math environments in
Version 2.2, you would write YAML as in
:numref:`lst:noAdditionalIndentOld`; as of Version 3.0, you would
write YAML as in :numref:`lst:indentAfterThisHeadingNew1` or, if
you’re using ``-m`` switch, :numref:`lst:indentAfterThisHeadingNew2`.

 .. literalinclude:: demonstrations/noAddtionalIndentOld.yaml
 	:class: .baseyaml
 	:caption: ``noAdditionalIndent`` in Version 2.2 
 	:name: lst:noAdditionalIndentOld

 .. literalinclude:: demonstrations/noAddtionalIndentNew.yaml
 	:class: .baseyaml
 	:caption: ``noAdditionalIndent`` for ``displayMath`` in Version 3.0 
 	:name: lst:indentAfterThisHeadingNew1

 .. literalinclude:: demonstrations/noAddtionalIndentNew1.yaml
 	:class: .baseyaml
 	:caption: ``noAdditionalIndent`` for ``displayMath`` in Version 3.0 
 	:name: lst:indentAfterThisHeadingNew2

--------------

.. raw:: html

   <div id="refs" class="references">

.. raw:: html

   <div id="ref-cpan">

“CPAN: Comprehensive Perl Archive Network.” 2017. Accessed January 23.
http://www.cpan.org/.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-latexindent-home">

“Home of Latexindent.pl.” 2017. Accessed January 23.
https://github.com/cmhughes/latexindent.pl.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-jasjuang">

Juang, Jason. 2015. “Add in PATH Installation.” November 24.
https://github.com/cmhughes/latexindent.pl/pull/38.

.. raw:: html

   </div>

.. raw:: html

   <div id="ref-perlbrew">

“Perlbrew.” 2017. Accessed January 23. http://perlbrew.pl/.

.. raw:: html

   </div>

.. raw:: html

   </div>
