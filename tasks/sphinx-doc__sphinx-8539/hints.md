
The bug reported in #7329 was that, when `autodoc_typehints="description"`, `autoclass_content="class"`, and `__init__` is documented separately from the class because `special-members` includes `__init__`, the constructor parameters would be duplicated in both the class documentation and the `__init__` method documentation, and the documentation for the parameters attached to the class docstring would be missing the parameter description and have only the type. This happened because `autodoc_typehints="description"` will add parameters with annotations to the documentation even if they weren't already present in the docstring.

[The fix that was applied](https://github.com/sphinx-doc/sphinx/pull/7336/commits/4399982a86bc90c97ecd167d2cdb78dd357e1cae) makes it so that `autodoc_typehints="description"` will never modify a class docstring if `autoclass_content="class"`.

This means that `autodoc_typehints="description"` is broken when `autoclass_content="class"` (the default) and arguments are documented in the class docstring (as both the Google and Numpy style docstrings do).

I suggest instead changing `sphinx.ext.autodoc.typehints.modify_field_list` to never add a `:param:`, only add a `:type:` for parameters with a pre-existing `:param:`, and to likewise only add an `:rtype:` if there was already a `:return:`. This would fix several issues:
- The bug noted in #7329 will be fixed: only the `__init__` docstring has a `:param:` in it, so the class description will be left unchanged by `autodoc_typehints`
- It will now be possible to have parameters that have type hints, but that are not shown in the documentation. I've been surprised in the past when an entry got added to my documentation for `kwargs` with only a declared type and no description; this would fix that.
- A function that returns `None` will no longer have `Return type: None` added unconditionally. While this is not incorrect, it is distracting, adds little value, and takes up valuable space.

The fix for #7329 fixed one special case of `autodoc_typehints="description"` documenting only a parameter's type without any description. This proposal would fix the general case by putting the user in control of which parameters are documented and reenabling automatic `:type:` documentation for constructor parameters.