Appendices
==========

.. label follows

.. _sec:requiredmodules:

Required Perl modules
---------------------

If you intend to use ``latexindent.pl`` and *not* one of the supplied standalone executable files (``latexindent.exe`` is available for Windows users without Perl, see :numref:`subsubsec:latexindent:exe`), then you will need a few standard Perl modules.

If you can run the minimum code in :numref:`lst:helloworld` as in

.. code-block:: latex
   :class: .commandshell

   perl helloworld.pl

then you will be able to run ``latexindent.pl``, otherwise you may need to install the missing modules; see :numref:`sec:module-installer` and :numref:`sec:manual-module-instal`.

.. code-block:: latex
   :caption: ``helloworld.pl`` 
   :name: lst:helloworld

   #!/usr/bin/perl

   use strict;                         #     |
   use warnings;                       #     |
   use Encode;                         #     |
   use Getopt::Long;                   #     |
   use Data::Dumper;                   #  these modules are
   use List::Util qw(max);             #  generally part
   use PerlIO::encoding;               #  of a default perl distribution
   use open ':std', ':encoding(UTF-8)';#     |
   use Text::Wrap;                     #     |
   use Text::Tabs;                     #     |
   use FindBin;                        #     |
   use File::Copy;                     #     |
   use File::Basename;                 #     |
   use File::HomeDir;                  # <--- typically requires install via cpanm
   use YAML::Tiny;                     # <--- typically requires install via cpanm

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

.. code-block:: latex
   :class: .commandshell

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
   perlbrew install perl-5.34.0
   perlbrew switch perl-5.34.0
   sudo apt-get install curl
   curl -L http://cpanmin.us | perl - App::cpanminus
   cpanm YAML::Tiny
   cpanm File::HomeDir

.. index:: cpan

Ubuntu/Debian
^^^^^^^^^^^^^

For other distributions, the Ubuntu/Debian approach may work as follows

.. code-block:: latex
   :class: .commandshell

   sudo apt install perl
   sudo cpan -i App::cpanminus
   sudo cpanm YAML::Tiny
   sudo cpanm File::HomeDir

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

Ubuntu: users without perl
^^^^^^^^^^^^^^^^^^^^^^^^^^

``latexindent-linux`` is a standalone executable for Ubuntu Linux (and therefore does not require a Perl distribution) and caches copies of the Perl modules onto your system. It is available from (“Home of Latexindent.pl” n.d.).

.. index:: latexindent-linux

.. index:: linux

.. index:: TeXLive

Arch-based distributions
^^^^^^^^^^^^^^^^^^^^^^^^

First install the dependencies

.. code-block:: latex
   :class: .commandshell

   sudo pacman -S perl cpanminus

In addition, install ``perl-file-homedir`` from AUR, using your AUR helper of choice,

.. code-block:: latex
   :class: .commandshell

   sudo paru -S perl-file-homedir

then run the latexindent-module-installer.pl file located at helper-scripts/

Alpine
^^^^^^

If you are using Alpine, some ``Perl`` modules are not build-compatible with Alpine, but replacements are available through ``apk``. For example, you might use the commands given in :numref:`lst:alpine-install`; thanks to (J. 2020) for providing these details.

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

Alternatively,

.. code-block:: latex
   :class: .commandshell

   brew install latexindent

``latexindent-macos`` is a standalone executable for macOS (and therefore does not require a Perl distribution) and caches copies of the Perl modules onto your system. It is available from (“Home of Latexindent.pl” n.d.).

.. index:: latexindent-macos

.. index:: macOS

.. index:: TeXLive

Windows
~~~~~~~

Strawberry Perl users on Windows might use ``CPAN client``. All of the modules are readily available on CPAN (“CPAN: Comprehensive Perl Archive Network” n.d.). ``indent.log`` will contain details of the location of the Perl modules on your system.

``latexindent.exe`` is a standalone executable for Windows (and therefore does not require a Perl distribution) and caches copies of the Perl modules onto your system; if you wish to see where they are cached, use the ``trace`` option, e.g

.. code-block:: latex
   :class: .commandshell

   latexindent.exe -t myfile.tex

.. label follows

.. _subsec:the-GCString:

The GCString switch
~~~~~~~~~~~~~~~~~~~

If you find that the ``lookForAlignDelims`` (as in :numref:`subsec:align-at-delimiters`) does not work correctly for your language, then you may wish to use the ``Unicode::GCString`` module .

.. index:: perl;Unicode GCString module

.. index:: switches;–GCString demonstration

This can be loaded by calling ``latexindent.pl`` with the ``GCString`` switch as in

.. code-block:: latex
   :class: .commandshell

   latexindent.pl --GCString myfile.tex

In this case, you will need to have the ``Unicode::GCString`` installed in your ``perl`` distribution by using, for example,

.. code-block:: latex
   :class: .commandshell

   cpanm Unicode::GCString

Note: this switch does *nothing* for ``latexindent.exe`` which loads the module by default. Users of ``latexindent.exe`` should not see any difference in behaviour whether they use this switch or not, as ``latexindent.exe`` loads the ``Unicode::GCString`` module.

.. label follows

.. _sec:updating-path:

Updating the path variable
--------------------------

``latexindent.pl`` has a few scripts (available at (“Home of Latexindent.pl” n.d.)) that can update the ``path`` variables. Thank you to (Juang 2015) for this feature. If you’re on a Linux or Mac machine, then you’ll want ``CMakeLists.txt`` from (“Home of Latexindent.pl” n.d.).

Add to path for Linux
~~~~~~~~~~~~~~~~~~~~~

To add ``latexindent.pl`` to the path for Linux, follow these steps:

#. download ``latexindent.pl`` and its associated modules, ``defaultSettings.yaml``, to your chosen directory from (“Home of Latexindent.pl” n.d.) ;

#. within your directory, create a directory called ``path-helper-files`` and download ``CMakeLists.txt`` and ``cmake_uninstall.cmake.in`` from (“Home of Latexindent.pl” n.d.)/path-helper-files to this directory;

#. run

   .. code-block:: latex
      :class: .commandshell

      ls /usr/local/bin

   to see what is *currently* in there;

#. run the following commands

   .. code-block:: latex
      :class: .commandshell

      sudo apt-get update
      sudo apt-get install --no-install-recommends cmake make # or any other generator
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

   .. code-block:: latex
      :class: .commandshell

      echo %path%

#. right click on ``add-to-path.bat`` and *Run as administrator*;

#. log out, and log back in;

#. open a command prompt and run

   .. code-block:: latex
      :class: .commandshell

      echo %path%

   to check that the appropriate directory has been added to your ``%path%``.

To *remove* the directory from your ``%path%``, run ``remove-from-path.bat`` as administrator.

.. label follows

.. _sec:batches:

Batches of files
----------------

You can instruct ``latexindent.pl`` to operate on multiple files. For example, the following calls are all valid

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile1.tex
   latexindent.pl myfile1.tex myfile2.tex
   latexindent.pl myfile*.tex

We note the following features of the script in relation to the switches detailed in :numref:`sec:how:to:use`.

location of indent.log
~~~~~~~~~~~~~~~~~~~~~~

If the ``-c`` switch is *not* active, then ``indent.log`` goes to the directory of the final file called.

If the ``-c`` switch *is* active, then ``indent.log`` goes to the specified directory.

interaction with -w switch
~~~~~~~~~~~~~~~~~~~~~~~~~~

If the ``-w`` switch is active, as in

.. code-block:: latex
   :class: .commandshell

   latexindent.pl -w myfile*.tex

then files will be overwritten individually. Back-up files can be re-directed via the ``-c`` switch.

interaction with -o switch
~~~~~~~~~~~~~~~~~~~~~~~~~~

If ``latexindent.pl`` is called using the ``-o`` switch as in

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile*.tex -o=my-output-file.tex

and there are multiple files to operate upon, then the ``-o`` switch is ignored because there is only *one* output file specified.

More generally, if the ``-o`` switch does *not* have a ``+`` symbol at the beginning, then the ``-o`` switch will be ignored, and is turned it off.

For example

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile*.tex -o=+myfile

*will* work fine because *each* ``.tex`` file will output to ``<basename>myfile.tex``

Similarly,

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile*.tex -o=++

*will* work because the ‘existence check/incrementation’ routine will be applied.

interaction with lines switch
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This behaves as expected by attempting to operate on the line numbers specified for each file. See the examples in :numref:`sec:line-switch`.

interaction with check switches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The exit codes for ``latexindent.pl`` are given in :numref:`tab:exit-codes`.

When operating on multiple files with the check switch active, as in

.. code-block:: latex
   :class: .commandshell

   latexindent.pl myfile*.tex --check

then

-  exit code 0 means that the text from *none* of the files has been changed;

-  exit code 1 means that the text from *at least one* of the files been file changed.

The interaction with ``checkv`` switch is as in the check switch, but with verbose output.

when a file does not exist
~~~~~~~~~~~~~~~~~~~~~~~~~~

What happens if one of the files can not be operated upon?

-  if at least one of the files does not exist and ``latexindent.pl`` has been called to act upon multiple files, then the exit code is 3; note that ``latexindent.pl`` will try to operate on each file that it is called upon, and will not exit with a fatal message in this case;

-  if at least one of the files can not be read and ``latexindent.pl`` has been called to act upon multiple files, then the exit code is 4; note that ``latexindent.pl`` will try to operate on each file that it is called upon, and will not exit with a fatal message in this case;

-  if ``latexindent.pl`` has been told to operate on multiple files, and some do not exist and some cannot be read, then the exit code will be either 3 or 4, depending upon which it scenario it encountered most recently.

latexindent-yaml-schema.json
----------------------------

``latexindent.pl`` ships with ``latexindent-yaml-schema.json`` which might help you when constructing your YAML files.

.. index:: json;schema for YAML files

VSCode demonstration
~~~~~~~~~~~~~~~~~~~~

To use ``latexindent-yaml-schema.json`` with ``VSCode``, you can use the following steps:

.. index:: VSCode

.. index:: json;VSCode

#. download ``latexindent-yaml-schema.json`` from the ``documentation`` folder of (“Home of Latexindent.pl” n.d.), save it in whichever directory you would like, noting it for reference;

#. following the instructions from (“How to Create Your Own Auto-Completion for Json and Yaml Files on Vs Code with the Help of Json Schema” n.d.), for example, you should install the VSCode YAML extension (“VSCode Yaml Extension” n.d.);

#. set up your ``settings.json`` file using the directory you saved the file by adapting :numref:`lst:settings.json`; on my Ubuntu laptop this file lives at ``/home/cmhughes/.config/Code/User/settings.json``.

.. literalinclude:: demonstrations/settings.json
 	:class: .baseyaml
 	:caption: ``settings.json`` 
 	:name: lst:settings.json

Alternatively, if you would prefer not to download the json file, you might be able to use an adapted version of :numref:`lst:settings-alt.json`.

.. literalinclude:: demonstrations/settings-alt.json
 	:class: .baseyaml
 	:caption: ``settings-alt.json`` 
 	:name: lst:settings-alt.json

Finally, if your TeX distribution is up to date, then ``latexindent-yaml-schema.json`` *should* be in the documentation folder of your installation, so an adapted version of :numref:`lst:settings-alt1.json` may work.

.. literalinclude:: demonstrations/settings-alt1.json
 	:class: .baseyaml
 	:caption: ``settings-alt1.json`` 
 	:name: lst:settings-alt1.json

If you have details of how to implement this schema in other editors, please feel encouraged to contribute to this documentation.

.. label follows

.. _sec:app:conda:

Using conda
-----------

If you use conda you’ll only need

.. code-block:: latex
   :class: .commandshell

   conda install latexindent.pl -c conda-forge

This will install the executable and all its dependencies (including perl) in the activate environment. You don’t even have to worry about ``defaultSettings.yaml`` as it included too, you can thus skip :numref:`sec:requiredmodules` and :numref:`sec:updating-path`.

.. index:: conda

You can get a conda installation for example from (“Conda Forge” n.d.) or from (“Anacoda” n.d.).

Sample conda installation on Ubuntu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On Ubuntu I followed the 64-bit installation instructions at (“How to Install Anaconda on Ubuntu?” n.d.) and then I ran the following commands:

.. code-block:: latex
   :class: .commandshell

   conda create -n latexindent.pl
   conda activate latexindent.pl
   conda install latexindent.pl -c conda-forge
   conda info --envs
   conda list
   conda run latexindent.pl -vv

I found the details given at (“Solving Environment: Failed with Initial Frozen Solve. Retrying with Flexible Solve.” n.d.) to be helpful.

.. label follows

.. _sec:app:docker:

Using docker
------------

If you use docker you’ll only need

.. code-block:: latex
   :class: .commandshell

   docker pull ghcr.io/cmhughes/latexindent.pl

This will download the image packed ``latexindent``\ ’s executable and its all dependencies.

.. index:: docker

Thank you to (eggplants 2022) for contributing this feature; see also (“Latexindent.pl Ghcr (Github Container Repository) Location” n.d.). For reference, *ghcr* stands for *GitHub Container Repository*.

Sample docker installation on Ubuntu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To pull the image and show ``latexindent``\ ’s help on Ubuntu:

.. code-block:: latex
   :caption: ``docker-install.sh`` 
   :name: lst:docker-install

   # setup docker if not already installed
   if ! command -v docker &> /dev/null; then
     sudo apt install docker.io -y
     sudo groupadd docker
     sudo gpasswd -a "$USER" docker
     sudo systemctl restart docker
   fi

   # download image and execute
   docker pull ghcr.io/cmhughes/latexindent.pl
   docker run ghcr.io/cmhughes/latexindent.pl -h

How to format on Docker
~~~~~~~~~~~~~~~~~~~~~~~

When you use ``latexindent`` with the docker image, you have to mount target ``tex`` file like this:

.. code-block:: latex
   :class: .commandshell

   docker run -v /path/to/local/myfile.tex:/myfile.tex ghcr.io/cmhughes/latexindent.pl -s -w myfile.tex

pre-commit
----------

Users of ``.git`` may be interested in exploring the ``pre-commit`` tool (“Pre-Commit: A Framework for Managing and Maintaining Multi-Language Pre-Commit Hooks.” n.d.), which is supported by ``latexindent.pl``. Thank you to (Geus 2022) for contributing this feature, and to (Holthuis 2022) for their contribution to it.

To use the ``pre-commit`` tool, you will need to install ``pre-commit``; sample instructions for Ubuntu are given in :numref:`sec:pre-commit-ubuntu`. Once installed, there are two ways to use ``pre-commit``: using ``CPAN`` or using ``conda``, detailed in :numref:`sec:pre-commit-cpan` and :numref:`sec:pre-commit-conda` respectively.

.. label follows

.. _sec:pre-commit-ubuntu:

Sample pre-commit installation on Ubuntu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On Ubuntu I ran the following command:

.. code-block:: latex
   :class: .commandshell

   python3 -m pip install pre-commit

I then updated my path via .bashrc so that it includes the line in :numref:`lst:bashrc-update`.

.. code-block:: latex
   :caption: ``.bashrc`` update 
   :name: lst:bashrc-update

   ...
   export PATH=$PATH:/home/cmhughes/.local/bin

pre-commit defaults
~~~~~~~~~~~~~~~~~~~

The default values that are employed by ``pre-commit`` are shown in :numref:`lst:.pre-commit-yaml-default`.

.. index:: pre-commit;default

.. literalinclude:: ../.pre-commit-hooks.yaml
 	:class: .baseyaml
 	:caption: ``.pre-commit-hooks.yaml`` (default) 
 	:name: lst:.pre-commit-yaml-default

In particular, the decision has deliberately been made (in collaboration with (Holthuis 2022)) to have the default to employ the following switches: ``overwriteIfDifferent``, ``silent``, ``local``; this is detailed in the lines that specify ``args`` in :numref:`lst:.pre-commit-yaml-default`.

.. index:: pre-commit;warning

.. index:: warning;pre-commit

.. warning::	
	
	Users of ``pre-commit`` will, by default, have the ``overwriteIfDifferent`` switch employed. It is assumed that such users have version control in place, and are intending to overwrite their files.
	 

.. label follows

.. _sec:pre-commit-cpan:

pre-commit using CPAN
~~~~~~~~~~~~~~~~~~~~~

To use ``latexindent.pl`` with ``pre-commit``, create the file ``.pre-commit-config.yaml`` given in :numref:`lst:.pre-commit-config.yaml-cpan` in your git-repository.

.. index:: cpan

.. index:: git

.. index:: pre-commit;cpan

.. literalinclude:: demonstrations/pre-commit-config-cpan.yaml
 	:class: .baseyaml
 	:caption: ``.pre-commit-config.yaml`` (cpan) 
 	:name: lst:.pre-commit-config.yaml-cpan

Once created, you should then be able to run the following command:

.. code-block:: latex
   :class: .commandshell

   pre-commit run --all-files

A few notes about :numref:`lst:.pre-commit-config.yaml-cpan`:

-  the settings given in :numref:`lst:.pre-commit-config.yaml-cpan` instruct ``pre-commit`` to use ``CPAN`` to get dependencies;

-  this requires ``pre-commit`` and ``perl`` to be installed on your system;

-  the ``args`` lists selected command-line options; the settings in :numref:`lst:.pre-commit-config.yaml-cpan` are equivalent to calling

   .. code-block:: latex
      :class: .commandshell

      latexindent.pl -s myfile.tex

   for each ``.tex`` file in your repository;

-  to instruct ``latexindent.pl`` to overwrite the files in your repository, then you can update :numref:`lst:.pre-commit-config.yaml-cpan` so that ``args: [-s, -w]``.

Naturally you can add options, or omit ``-s`` and ``-w``, according to your preference.

.. label follows

.. _sec:pre-commit-conda:

pre-commit using conda
~~~~~~~~~~~~~~~~~~~~~~

You can also rely on ``conda`` (detailed in :numref:`sec:app:conda`) instead of ``CPAN`` for all dependencies, including ``latexindent.pl`` itself.

.. index:: conda

.. index:: git

.. index:: pre-commit;conda

.. literalinclude:: demonstrations/pre-commit-config-conda.yaml
 	:class: .baseyaml
 	:caption: ``.pre-commit-config.yaml`` (conda) 
 	:name: lst:.pre-commit-config.yaml-conda

Once created, you should then be able to run the following command:

.. code-block:: latex
   :class: .commandshell

   pre-commit run --all-files

A few notes about :numref:`lst:.pre-commit-config.yaml-cpan`:

-  the settings given in :numref:`lst:.pre-commit-config.yaml-conda` instruct ``pre-commit`` to use ``conda`` to get dependencies;

-  this requires ``pre-commit`` and ``conda`` to be installed on your system;

-  the ``args`` lists selected command-line options; the settings in :numref:`lst:.pre-commit-config.yaml-cpan` are equivalent to calling

   .. code-block:: latex
      :class: .commandshell

      conda run latexindent.pl -s myfile.tex

   for each ``.tex`` file in your repository;

-  to instruct ``latexindent.pl`` to overwrite the files in your repository, then you can update :numref:`lst:.pre-commit-config.yaml-cpan` so that ``args: [-s, -w]``.

.. label follows

.. _sec:pre-commit-docker:

pre-commit using docker
~~~~~~~~~~~~~~~~~~~~~~~

You can also rely on ``docker`` (detailed in :numref:`sec:app:docker`) instead of ``CPAN`` for all dependencies, including ``latexindent.pl`` itself.

.. index:: docker

.. index:: git

.. index:: pre-commit;docker

.. literalinclude:: demonstrations/pre-commit-config-docker.yaml
 	:class: .baseyaml
 	:caption: ``.pre-commit-config.yaml`` (docker) 
 	:name: lst:.pre-commit-config.yaml-docker

Once created, you should then be able to run the following command:

.. code-block:: latex
   :class: .commandshell

   pre-commit run --all-files

A few notes about :numref:`lst:.pre-commit-config.yaml-cpan`:

-  the settings given in :numref:`lst:.pre-commit-config.yaml-docker` instruct ``pre-commit`` to use ``docker`` to get dependencies;

-  this requires ``pre-commit`` and ``docker`` to be installed on your system;

-  the ``args`` lists selected command-line options; the settings in :numref:`lst:.pre-commit-config.yaml-cpan` are equivalent to calling

   .. code-block:: latex
      :class: .commandshell

      docker run -v /path/to/myfile.tex:/myfile.tex ghcr.io/cmhughes/latexindent.pl -s myfile.tex

   for each ``.tex`` file in your repository;

-  to instruct ``latexindent.pl`` to overwrite the files in your repository, then you can update :numref:`lst:.pre-commit-config.yaml-cpan` so that ``args: [-s, -w]``.

pre-commit example using -l, -m switches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Let’s consider a small example, with local ``latexindent.pl`` settings in ``.latexindent.yaml``.

.. proof:example::	
	
	We use the local settings given in :numref:`lst:.latexindent.yaml`.
	
	.. code-block:: latex
	   :caption: ``.latexindent.yaml`` 
	   :name: lst:.latexindent.yaml
	
	   onlyOneBackUp: 1
	
	   modifyLineBreaks:
	    oneSentencePerLine:
	      manipulateSentences: 1
	
	and ``.pre-commit-config.yaml`` as in :numref:`lst:.latexindent.yaml-switches`:
	
	.. literalinclude:: demonstrations/pre-commit-config-demo.yaml
	 	:class: .baseyaml
	 	:caption: ``.pre-commit-config.yaml`` (demo) 
	 	:name: lst:.latexindent.yaml-switches
	
	Now running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   pre-commit run --all-files
	
	is equivalent to running
	
	.. code-block:: latex
	   :class: .commandshell
	
	   latexindent.pl -l -m -s -w myfile.tex
	
	for each ``.tex`` file in your repository.
	
	A few notes about :numref:`lst:.latexindent.yaml-switches`:
	
	-  the ``-l`` option was added to use the local ``.latexindent.yaml`` (where it was specified to only create one back-up file, as ``git`` typically takes care of this when you use ``pre-commit``);
	
	-  ``-m`` to modify line breaks; in addition to ``-s`` to suppress command-line output, and ``-w`` to format files in place.
	
	
	 

.. label follows

.. _app:indentconfig:options:

indentconfig options
--------------------

This section describes the possible locations for the main configuration file, discussed in :numref:`sec:indentconfig`. Thank you to (Nehctargl 2022) for this contribution. The possible locations of ``indentconfig.yaml`` are evaluated one after the other, and evaluation stops when a valid file is found in one of the paths.

Before stating the list, we give summarise in :numref:`tab:environment:summary`.

.. label follows

.. _tab:environment:summary:

.. table:: indentconfig environment variable summaries

   ==================== ================= ===== ===== =======
   environment variable type              Linux macOS Windows
   ==================== ================= ===== ===== =======
   LATEXINDENT_CONFIG   full path to file yes   yes   yes
   XDG_CONFIG_HOME      directory path    yes   no    no
   LOCALAPPDATA         directory path    no    no    yes
   ==================== ================= ===== ===== =======

The following list shows the checked options and is sorted by their respective priority. It uses capitalized and with a dollar symbol prefixed names (e.g. ``$LATEXINDENT_CONFIG``) to symbolize environment variables. In addition to that the variable name ``$homeDir`` is used to symbolize your home directory.

#. The value of the environment variable ``$LATEXINDENT_CONFIG`` is treated as highest priority source for the path to the configuration file.

#. The next options are dependent on your operating system:

   -  Linux:

      #. The file at ``$XDG_CONFIG_HOME/latexindent/indentconfig.yaml``

      #. The file at ``$homeDir/.config/latexindent/indentconfig.yaml``

   -  Windows:

      #. The file at ``$LOCALAPPDATA\latexindent\indentconfig.yaml``

      #. The file at ``$homeDir\AppData\Local\latexindent\indentconfig.yaml``

   -  Mac:

      #. The file at ``$homeDir/Library/Preferences/latexindent/indentconfig.yaml``

#. The file at ``$homeDir/.indentconfig.yaml``

#. The file at ``$homeDir/indentconfig.yaml``

Why to change the configuration location
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is mostly a question about what you prefer, some like to put all their configuration files in their home directory (see ``$homeDir`` above), whilst some like to sort their configuration. And if you don’t care about it, you can just continue using the same defaults.

How to change the configuration location
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This depends on your preferred location, if, for example, you would like to set a custom location, you would have to change the ``$LATEXINDENT_CONFIG`` environment variable.

Although the following example only covers ``$LATEXINDENT_CONFIG``, the same process can be applied to ``$XDG_CONFIG_HOME`` or ``$LOCALAPPDATA`` because both are environment variables. You just have to change the path to your chosen configuration directory (e.g. ``$homeDir/.config`` or ``$homeDir\AppData\Local`` on Linux or Windows respectively)

.. label follows

.. _linux-1:

Linux
~~~~~

To change ``$LATEXINDENT_CONFIG`` on Linux you can run the following command in a terminal after changing the path:

.. code-block:: latex
   :class: .commandshell

   echo 'export LATEXINDENT_CONFIG="/home/cmh/latexindent-config.yaml"' >> ~/.profile

Context: This command adds the given line to your ``.profile`` file (which is commonly stored in ``$HOME/.profile``). All commands in this file a run after login, so the environment variable will be set after your next login.

You can check the value of ``$LATEXINDENT_CONFIG`` by typing

.. code-block:: latex
   :class: .commandshell

   echo $LATEXINDENT_CONFIG 
   /home/cmh/latexindent-config.yaml

Linux users interested in ``$XDG_CONFIG_HOME`` can explore variations of the following commands

.. code-block:: latex
   :class: .commandshell

   echo $XDG_CONFIG_HOME
   echo ${XDG_CONFIG_HOME:=$HOME/.config}
   echo $XDG_CONFIG_HOME
   mkdir /home/cmh/.config/latexindent
   touch /home/cmh/.config/latexindent/indentconfig.yaml

.. label follows

.. _windows-1:

Windows
~~~~~~~

To change ``$LATEXINDENT_CONFIG`` on Windows you can run the following command in ``powershell.exe`` after changing the path:

.. code-block:: latex
   :class: .commandshell

   [Environment]::SetEnvironmentVariable
       ("LATEXINDENT_CONFIG", "\your\config\path", "User")

This sets the environment variable for every user session.

.. label follows

.. _mac-1:

Mac
~~~

To change ``$LATEXINDENT_CONFIG`` on macOS you can run the following command in a terminal after changing the path:

.. code-block:: latex
   :class: .commandshell

   echo 'export LATEXINDENT_CONFIG="/your/config/path"' >> ~/.profile

Context: This command adds the line to your ``.profile`` file (which is commonly stored in ``$HOME/.profile``). All commands in this file a run after login, so the environment variable will be set after your next login.

.. label follows

.. _app:logfile-demo:

logFilePreferences
------------------

:numref:`lst:logFilePreferences` describes the options for customising the information given to the log file, and we provide a few demonstrations here.

.. proof:example::	
	
	Let’s say that we start with the code given in :numref:`lst:simple`, and the settings specified in :numref:`lst:logfile-prefs1-yaml`.
	
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
	          looking for COMMANDS and key ={value}
	   TRACE: Searching for commands with optional and/or mandatory arguments AND key ={value}
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

.. code-block:: latex
   :class: .commandshell

   chcp

They may receive the following result

.. code-block:: latex
   :class: .commandshell

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
 	:class: .baseyaml
 	:caption: Obsolete YAML fields from Version 3.0 
 	:name: lst:obsoleteYaml

There is a slight difference when specifying indentation after headings; specifically, we now write ``indentAfterThisHeading`` instead of ``indent``. See :numref:`lst:indentAfterThisHeadingOld` and :numref:`lst:indentAfterThisHeadingNew`

.. literalinclude:: demonstrations/indentAfterThisHeadingOld.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 2.2 
 	:name: lst:indentAfterThisHeadingOld

.. literalinclude:: demonstrations/indentAfterThisHeadingNew.yaml
 	:class: .baseyaml
 	:caption: ``indentAfterThisHeading`` in Version 3.0 
 	:name: lst:indentAfterThisHeadingNew

To specify ``noAdditionalIndent`` for display-math environments in Version 2.2, you would write YAML as in :numref:`lst:noAdditionalIndentOld`; as of Version 3.0, you would write YAML as in :numref:`lst:indentAfterThisHeadingNew1` or, if you’re using ``-m`` switch, :numref:`lst:indentAfterThisHeadingNew2`.

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
      :name: ref-eggplants

      eggplants. 2022. “Add Dockerfile and Its Updater/Releaser.” June 12, 2022. https://github.com/cmhughes/latexindent.pl/pull/370.

   .. container::
      :name: ref-tdegeusprecommit

      Geus, Tom de. 2022. “Adding Perl Installation + Pre-Commit Hook.” January 21, 2022. https://github.com/cmhughes/latexindent.pl/pull/322.

   .. container::
      :name: ref-holzhausprecommit

      Holthuis, Jan. 2022. “Fix Pre-Commit Usage.” March 31, 2022. https://github.com/cmhughes/latexindent.pl/pull/354.

   .. container::
      :name: ref-latexindent-home

      “Home of Latexindent.pl.” n.d. Accessed January 23, 2017. https://github.com/cmhughes/latexindent.pl.

   .. container::
      :name: ref-vscode-yaml-demo

      “How to Create Your Own Auto-Completion for Json and Yaml Files on Vs Code with the Help of Json Schema.” n.d. Accessed January 1, 2022. https://dev.to/brpaz/how-to-create-your-own-auto-completion-for-json-and-yaml-files-on-vs-code-with-the-help-of-json-schema-k1i.

   .. container::
      :name: ref-condainstallubuntu

      “How to Install Anaconda on Ubuntu?” n.d. Accessed January 21, 2022. https://askubuntu.com/questions/505919/how-to-install-anaconda-on-ubuntu.

   .. container::
      :name: ref-jun-sheaf

      J., Randolf. 2020. “Alpine-Linux Instructions.” August 10, 2020. https://github.com/cmhughes/latexindent.pl/pull/214.

   .. container::
      :name: ref-jasjuang

      Juang, Jason. 2015. “Add in Path Installation.” November 24, 2015. https://github.com/cmhughes/latexindent.pl/pull/38.

   .. container::
      :name: ref-cmhughesio

      “Latexindent.pl Ghcr (Github Container Repository) Location.” n.d. Accessed June 12, 2022. https://github.com/cmhughes?tab=packages.

   .. container::
      :name: ref-nehctargl

      Nehctargl. 2022. “Added Support for the Xdg Specification.” December 23, 2022. https://github.com/cmhughes/latexindent.pl/pull/397.

   .. container::
      :name: ref-perlbrew

      “Perlbrew.” n.d. Accessed January 23, 2017. http://perlbrew.pl/.

   .. container::
      :name: ref-pre-commithome

      “Pre-Commit: A Framework for Managing and Maintaining Multi-Language Pre-Commit Hooks.” n.d. Accessed January 8, 2022. https://pre-commit.com/.

   .. container::
      :name: ref-condainstallhelp

      “Solving Environment: Failed with Initial Frozen Solve. Retrying with Flexible Solve.” n.d. Accessed January 21, 2022. https://github.com/conda/conda/issues/9367#issuecomment-558863143.

   .. container::
      :name: ref-vscode-yaml-extentions

      “VSCode Yaml Extension.” n.d. Accessed January 1, 2022. `https://marketplace.visualstudio.com/items?itemName = redhat.vscode-yaml <https://marketplace.visualstudio.com/items?itemName = redhat.vscode-yaml>`__.

   .. container::
      :name: ref-bersbersbers

      “Windows Line Breaks on Linux Prevent Removal of White Space from End of Line.” n.d. Accessed June 18, 2021. https://github.com/cmhughes/latexindent.pl/issues/256.
