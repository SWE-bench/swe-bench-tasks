I think we can fix this by just adding an empty line after the RST prolog internally. IIRC, the prolog is just prepended directly to the RST string given to the RST parser.
After investigation, the issue is that the prolog is inserted between <code>:mod:\`...\`</code> and the header definnition but does not check that there is heading inbetween.

https://github.com/sphinx-doc/sphinx/blob/d3c91f951255c6729a53e38c895ddc0af036b5b9/sphinx/util/rst.py#L81-L91

