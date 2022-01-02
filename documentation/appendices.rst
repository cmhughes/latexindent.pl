Appendices
==========

.. label follows

.. _sec:requiredmodules:

Required Perl modules
---------------------

If you intend to use ``latexindent.pl`` and *not* one of the supplied standalone executable files, then you will need a few standard Perl modules – if you can run the minimum code in
:numref:`lst:helloworld` (``perl helloworld.pl``) then you will be able to run ``latexindent.pl``, otherwise you may need to install the missing modules – see :numref:`sec:module-installer` and
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
   use Encode;
   use Getopt::Long;
   use Data::Dumper;
   use List::Util qw(max);

   print "hello world";
   exit;

.. label follows

.. _sec:module-installer:

Module installer script
~~~~~~~~~~~~~~~~~~~~~~~

``latexindent.pl`` ships with a helper script that will install any missing ``perl`` modules on your system; if you run

.. code-block:: latex
   :class: .commandshell

   perl latexindent-module-installer.pl

or

perl latexindent-module-installer.pl

then, once you have answered ``Y``, the appropriate modules will be installed onto your distribution.

.. label follows

.. _sec:manual-module-instal:

Manually installing modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Manually installing the modules given in :numref:`lst:helloworld` will vary depending on your operating system and ``Perl`` distribution.

Linux
~~~~~

perlbrew
^^^^^^^^

Linux users may be interested in exploring Perlbrew (“Perlbrew” n.d.); an example installation would be:

.. code-block:: latex
   :class: .commandshell

   sudo apt-get install perlbrew
   perlbrew init
   perlbrew install perl-5.28.1
   perlbrew switch perl-5.28.1
   sudo apt-get install curl
   curl -L http://cpanmin.us | perl - App::cpanminus
   cpanm YAML::Tiny
   cpanm File::HomeDir
   cpanm Unicode::GCString

Ubuntu/Debian
^^^^^^^^^^^^^

For other distributions, the Ubuntu/Debian approach may work as follows

.. code-block:: latex
   :class: .commandshell

   sudo apt install perl
   sudo cpan -i App::cpanminus
   sudo cpanm YAML::Tiny
   sudo cpanm File::HomeDir
   sudo cpanm Unicode::GCString

or else by running, for example,

.. code-block:: latex
   :class: .commandshell

   sudo perl -MCPAN -e'install "File::HomeDir"'

Ubuntu: using the texlive from apt-get
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Ubuntu users that install texlive using ``apt-get`` as in the following

.. code-block:: latex
   :class: .commandshell

   sudo apt install texlive
   sudo apt install texlive-latex-recommended

may need the following additional command to work with ``latexindent.pl``

.. code-block:: latex
   :class: .commandshell

   sudo apt install texlive-extra-utils 

Alpine
^^^^^^

If you are using Alpine, some ``Perl`` modules are not build-compatible with Alpine, but replacements are available through ``apk``. For example, you might use the commands given in
:numref:`lst:alpine-install`; thanks to (J. 2020) for providing these details.

.. code-block:: latex
   :caption: ``alpine-install.sh`` 
   :name: lst:alpine-install

   # Installing perl
   apk --no-cache add miniperl perl-utils

   # Installing incompatible latexindent perl dependencies via apk
   apk --no-cache add \
       perl-log-dispatch \
       perl-namespace-autoclean \
       perl-specio \
       perl-unicode-linebreak

   # Installing remaining latexindent perl dependencies via cpan
   apk --no-cache add curl wget make
   ls /usr/share/texmf-dist/scripts/latexindent
   cd /usr/local/bin && \
       curl -L https://cpanmin.us/ -o cpanm && \
       chmod +x cpanm
   cpanm -n App::cpanminus
   cpanm -n File::HomeDir
   cpanm -n Params::ValidationCompiler
   cpanm -n YAML::Tiny
   cpanm -n Unicode::GCString

Users of NixOS might like to see https://github.com/cmhughes/latexindent.pl/issues/222 for tips.

Mac
~~~

Users of the Macintosh operating system might like to explore the following commands, for example:

.. code-block:: latex
   :class: .commandshell

   brew install perl
   brew install cpanm

   cpanm YAML::Tiny
   cpanm File::HomeDir
   cpanm Unicode::GCString

Windows
~~~~~~~

Strawberry Perl users on Windows might use ``CPAN client``. All of the modules are readily available on CPAN (“CPAN: Comprehensive Perl Archive Network” n.d.).

``indent.log`` will contain details of the location of the Perl modules on your system. ``latexindent.exe`` is a standalone executable for Windows (and therefore does not require a Perl distribution)
and caches copies of the Perl modules onto your system; if you wish to see where they are cached, use the ``trace`` option, e.g

latexindent.exe -t myfile.tex

.. label follows

.. _sec:updating-path:

Updating the path variable
--------------------------

``latexindent.pl`` has a few scripts (available at (“Home of Latexindent.pl” n.d.)) that can update the ``path`` variables. Thank you to (Juang 2015) for this feature. If you’re on a Linux or Mac
machine, then you’ll want ``CMakeLists.txt`` from (“Home of Latexindent.pl” n.d.).

Add to path for Linux
~~~~~~~~~~~~~~~~~~~~~

To add ``latexindent.pl`` to the path for Linux, follow these steps:

#. download ``latexindent.pl`` and its associated modules, ``defaultSettings.yaml``, to your chosen directory from (“Home of Latexindent.pl” n.d.) ;

#. within your directory, create a directory called ``path-helper-files`` and download ``CMakeLists.txt`` and ``cmake_uninstall.cmake.in`` from (“Home of Latexindent.pl” n.d.)/path-helper-files to
   this directory;

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

   again to check that ``latexindent.pl``, its modules and ``defaultSettings.yaml`` have been added.

To *remove* the files, run

.. code-block:: latex
   :class: .commandshell

   sudo make uninstall

Add to path for Windows
~~~~~~~~~~~~~~~~~~~~~~~

To add ``latexindent.exe`` to the path for Windows, follow these steps:

#. download ``latexindent.exe``, ``defaultSettings.yaml``, ``add-to-path.bat`` from (“Home of Latexindent.pl” n.d.) to your chosen directory;

#. open a command prompt and run the following command to see what is *currently* in your ``%path%`` variable;

   echo

#. right click on ``add-to-path.bat`` and *Run as administrator*;

#. log out, and log back in;

#. open a command prompt and run

   echo

   to check that the appropriate directory has been added to your ``%path%``.

To *remove* the directory from your ``%path%``, run ``remove-from-path.bat`` as administrator.

latexindent-yaml-schema.json
----------------------------

``latexindent.pl`` ships with ``latexindent-yaml-schema.json`` which might help you when constructing your YAML files.

VSCode demonstration
~~~~~~~~~~~~~~~~~~~~

To use ``latexindent-yaml-schema.json`` with ``VSCode``, you can use the following steps:

#. download ``latexindent-yaml-schema.json`` from the ``documentation`` folder of (“Home of Latexindent.pl” n.d.), save it in whichever directory you would like, noting it for reference;

#. following the instructions from (“How to Create Your Own Auto-Completion for Json and Yaml Files on Vs Code with the Help of Json Schema” n.d.), for example, you should install the VSCode YAML
   extension (“VSCode Yaml Extension” n.d.);

#. set up your ``settings.json`` file using the directory you saved the file by adapting :numref:`lst:settings.json`; on my Ubuntu laptop this file lives at
   ``/home/cmhughes/.config/Code/User/settings.json``.

.. literalinclude:: settings.json
 	:class: .baseyaml
 	:caption: ``settings.json`` 
 	:name: lst:settings.json

Alternatively, if you would prefer not to download the json file, you might be able to use an adapted version of :numref:`lst:settings-alt.json`.

.. literalinclude:: settings-alt.json
 	:class: .baseyaml
 	:caption: ``settings-alt.json`` 
 	:name: lst:settings-alt.json

Finally, if your TeX distribution is up to date, then ``latexindent-yaml-schema.json`` *should* be in the documentation folder of your installation, so an adapted version of
:numref:`lst:settings-alt1.json` may work.

.. literalinclude:: settings-alt1.json
 	:class: .baseyaml
 	:caption: ``settings-alt1.json`` 
 	:name: lst:settings-alt1.json

If you have details of how to implement this schema in other editors, please feel encouraged to contribute to this documentation.

Using conda
-----------

If you use conda you’ll only need

.. code-block:: latex
   :class: .commandshell

   conda install latexindent.pl -c conda-forge

this will install the executable and all its dependencies (including perl) in the activate environment. You don’t even have to worry about ``defaultSettings.yaml`` as it included too, you can thus
skip :numref:`sec:requiredmodules` and :numref:`sec:updating-path`.

You can get a conda installation for example from (“Conda Forge” n.d.) or from (“Anacoda” n.d.).

.. label follows

.. _app:logfile-demo:

logFilePreferences
------------------

:numref:`lst:logFilePreferences` describes the options for customising the information given to the log file, and we provide a few demonstrations here. Let’s say that we start with the code given in
:numref:`lst:simple`, and the settings specified in :numref:`lst:logfile-prefs1-yaml`.

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

then on inspection of ``indent.log`` we will find the snippet given in :numref:`lst:indentlog`.

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

Notice that the information given about ``myenv`` is ‘framed’ using ``+++++`` and ``-----`` respectively.

.. label follows

.. _app:encoding:

Encoding indentconfig.yaml
--------------------------

In relation to :numref:`sec:indentconfig`, Windows users that encounter encoding issues with ``indentconfig.yaml``, may wish to run the following command in either ``cmd.exe`` or ``powershell.exe``:

chcp

They may receive the following result

Active code page: 936

and can then use the settings given in :numref:`lst:indentconfig-encoding1` within their ``indentconfig.yaml``, where 936 is the result of the ``chcp`` command.

.. literalinclude:: demonstrations/encoding1.yaml
 	:class: .baseyaml
 	:caption: ``encoding`` demonstration for ``indentconfig.yaml`` 
 	:name: lst:indentconfig-encoding1

dos2unix linebreak adjustment
-----------------------------

.. describe:: dos2unixlinebreaks:integer

If you use ``latexindent.pl`` on a dos-based Windows file on Linux then you may find that trailing horizontal space is not removed as you hope.

In such a case, you may wish to try setting ``dos2unixlinebreaks`` to 1 and employing, for example, the following command.

.. code-block:: latex
   :class: .commandshell

   latexindent.pl -y="dos2unixlinebreaks:1" myfile.tex

See (“Windows Line Breaks on Linux Prevent Removal of White Space from End of Line” n.d.) for further dertails.

.. label follows

.. _app:differences:

Differences from Version 2.2 to 3.0
-----------------------------------

There are a few (small) changes to the interface when comparing Version 2.2 to Version 3.0. Explicitly, in previous versions you might have run, for example,

.. index:: switches;-o demonstration

.. code-block:: latex
   :class: .commandshell

   latexindent.pl -o myfile.tex outputfile.tex

whereas in Version 3.0 you would run any of the following, for example,

.. index:: switches;-o demonstration

.. code-block:: latex
   :class: .commandshell

   latexindent.pl -o=outputfile.tex myfile.tex
   latexindent.pl -o outputfile.tex myfile.tex
   latexindent.pl myfile.tex -o outputfile.tex 
   latexindent.pl myfile.tex -o=outputfile.tex 
   latexindent.pl myfile.tex -outputfile=outputfile.tex 
   latexindent.pl myfile.tex -outputfile outputfile.tex 

noting that the *output* file is given *next to* the ``-o`` switch.

The fields given in :numref:`lst:obsoleteYaml` are *obsolete* from Version 3.0 onwards.

.. literalinclude:: demonstrations/obsolete.yaml
 	:class: .obsolete
 	:caption: Obsolete YAML fields from Version 3.0 
 	:name: lst:obsoleteYaml

There is a slight difference when specifying indentation after headings; specifically, we now write ``indentAfterThisHeading`` instead of ``indent``. See :numref:`lst:indentAfterThisHeadingOld` and
:numref:`lst:indentAfterThisHeadingNew`

.. literalinclude:: demonstrations/indentAfterThisHeadingOld.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 2.2 
 	:name: lst:indentAfterThisHeadingOld

.. literalinclude:: demonstrations/indentAfterThisHeadingNew.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 3.0 
 	:name: lst:indentAfterThisHeadingNew

To specify ``noAdditionalIndent`` for display-math environments in Version 2.2, you would write YAML as in :numref:`lst:noAdditionalIndentOld`; as of Version 3.0, you would write YAML as in
:numref:`lst:indentAfterThisHeadingNew1` or, if you’re using ``-m`` switch, :numref:`lst:indentAfterThisHeadingNew2`.

.. index:: specialBeginEnd;update to displaymath V3.0

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

.. container:: references
   :name: refs

   .. container::
      :name: ref-anacoda

      “Anacoda.” n.d. Accessed December 22, 2021. https://www.anaconda.com/products/individual.

   .. container::
      :name: ref-conda

      “Conda Forge.” n.d. Accessed December 22, 2021. https://github.com/conda-forge/miniforge.

   .. container::
      :name: ref-cpan

      “CPAN: Comprehensive Perl Archive Network.” n.d. Accessed January 23, 2017. http://www.cpan.org/.

   .. container::
      :name: ref-latexindent-home

      “Home of Latexindent.pl.” n.d. Accessed January 23, 2017. https://github.com/cmhughes/latexindent.pl.

   .. container::
      :name: ref-vscode-yaml-demo

      “How to Create Your Own Auto-Completion for Json and Yaml Files on Vs Code with the Help of Json Schema.” n.d. Accessed January 1, 2022.
      https://dev.to/brpaz/how-to-create-your-own-auto-completion-for-json-and-yaml-files-on-vs-code-with-the-help-of-json-schema-k1i.

   .. container::
      :name: ref-jun-sheaf

      J., Randolf. 2020. “Alpine-Linux Instructions.” August 10, 2020. https://github.com/cmhughes/latexindent.pl/pull/214.

   .. container::
      :name: ref-jasjuang

      Juang, Jason. 2015. “Add in Path Installation.” November 24, 2015. https://github.com/cmhughes/latexindent.pl/pull/38.

   .. container::
      :name: ref-perlbrew

      “Perlbrew.” n.d. Accessed January 23, 2017. http://perlbrew.pl/.

   .. container::
      :name: ref-vscode-yaml-extentions

      “VSCode Yaml Extension.” n.d. Accessed January 1, 2022. https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml.

   .. container::
      :name: ref-bersbersbers

      “Windows Line Breaks on Linux Prevent Removal of White Space from End of Line.” n.d. Accessed June 18, 2021. https://github.com/cmhughes/latexindent.pl/issues/256.
