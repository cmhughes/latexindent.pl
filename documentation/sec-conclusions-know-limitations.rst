.. label follows

.. _sec:knownlimitations:

Conclusions and known limitations
=================================

There are a number of known limitations of the script, and almost certainly quite a few that are *unknown*!

For example, with reference to the multicolumn alignment routine in :numref:`lst:tabular2-mod2`, when working with code blocks in which multicolumn commands overlap, the algorithm can fail.

Another limitation is to do with efficiency, particularly when the ``-m`` switch is active, as this adds many checks and processes. The current implementation relies upon finding and storing *every*
code block (see the discussion on :ref:`page page:phases <page:phases>`); I hope that, in a future version, only *nested* code blocks will need to be stored in the ‘packing’ phase, and that this
will improve the efficiency of the script.

You can run ``latexindent`` on any file; if you don’t specify an extension, then the extensions that you specify in ``fileExtensionPreference`` (see :numref:`lst:fileExtensionPreference`) will be
consulted. If you find a case in which the script struggles, please feel free to report it at (“Home of Latexindent.pl” n.d.), and in the meantime, consider using a ``noIndentBlock`` (see
:ref:`page lst:noIndentBlock <lst:noIndentBlock>`).

I hope that this script is useful to some; if you find an example where the script does not behave as you think it should, the best way to contact me is to report an issue on (“Home of Latexindent.pl”
n.d.); otherwise, feel free to find me on the http://tex.stackexchange.com/users/6621/cmhughes.

.. container:: references
   :name: refs

   .. container::
      :name: ref-latexindent-home

      “Home of Latexindent.pl.” n.d. Accessed January 23, 2017. https://github.com/cmhughes/latexindent.pl.
