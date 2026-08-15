+1; Reasonable. But it seems some users need to change their configurations for MathJax. So some migration paths are needed.
Note: To keep compatibility, the default version of mathjax should be v2 during Sphinx-3.x. And I'm okay to change it to v3 on Sphinx-4.0.0.
Agreed - I think an early first step is to add a configuration option for the mathjax version and provide docs for the best way to configure if it is version >= 3.0. The option can default to 2.x, and in the future it can be switched to 3.x
I am also in favour of having the new MathJax v3 support added, eventually that is..
However, in the meanwhile it may be worth to add an extra "attention" in the documentation* stating that the `mathjax_path` should not be set to point to the v3 of MathJax.

*Somewhere appropriate in: https://github.com/sphinx-doc/sphinx/blob/713bbf5cafa3fc5e143ced59dafe56f4b802ef80/doc/usage/extensions/math.rst#modsphinxextmathjax----render-math-via-javascript 
For a while, I don't have time to work on this issue. So any pull requests are welcome!