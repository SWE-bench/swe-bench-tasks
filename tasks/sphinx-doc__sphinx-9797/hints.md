By default, autodoc searches the docstring from the parent class. Please disable `autodoc_inherit_docstrings`.
https://www.sphinx-doc.org/en/master/usage/extensions/autodoc.html#confval-autodoc_inherit_docstrings
Setting `autodoc_inherit_docstrings = False` didn't fix it. As a matter of fact, it (as the name suggests) disabled inheritance of docstrings for all methods, not just classmethods. Also, explicitly setting  `autodoc_inherit_docstrings = True` didn't fix it

This to me seems like a bug specific to classmethods
@tk0miya I don't think this issue is resolved
Okay, I'll take a look.
Sorry, I misunderstand your report. Reproduced the error on my local.