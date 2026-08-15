+1 for adding a new confval only for autodoc. It would be nice if we can give better name to it. I feel "add_module_names" is a bit ambiguous and difficult to understand its behavior from the name.
To be clear, the [`add_module_names` confval](https://www.sphinx-doc.org/en/master/usage/configuration.html?highlight=add_module_names#confval-add_module_names) already exists. It's just that it doesn't affect parameter types for some reason.
Sorry for confuse. I know that. I thought it's better to separate the confval for autodoc and python-domain.
Just FYI: Sphinx-4.0 provides a new configuration `python_use_unqualified_type_names`. It suppresses the module name if hyperlinks can be resolved.
So does this mean that the proposed `add_module_names` configuration is completely unnecessary?
My understanding is that `python_use_unqualified_type_names` only works with resolved refs and only for the `python` domain. Although, I would personally consider this issue fixed if `python_use_unqualified_type_names` would also work for unresolved refs.
Oh that's a fair point! Yep.
Also, not sure if this deserves a separate issue/feature request, but one more place where sphinx currently produces fully qualified names is in the package/module headings generated with `apidoc`. So for example, if you have
```
foo/__init__.py
foo/bar/__init__.py
foo/bar/baz.py
```
you will get the documentation for
```
foo package
 - foo.bar package
    - foo.bar.baz module
```
instead of
```
foo package
 - bar package
    - baz module
```

The FQN version is kind of redundant, since the parent packages of `bar` and `baz` are already obvious from the ToC. And with longer package/module names, this can lead to really ugly wrapping in the sidebar ToC.