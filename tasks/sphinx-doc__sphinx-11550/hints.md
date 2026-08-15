**TL;DR** `autodoc_preserve_defaults` does not work with lambdas.

Even the following simple example 

```python
X = object()
Z = lambda x=X: x
"""The Z function."""
```

miserably fails. The reason is because the object being documented is a lambda function. Because of that, the extracted AST node is not a function definition node:

https://github.com/sphinx-doc/sphinx/blob/d3c91f951255c6729a53e38c895ddc0af036b5b9/sphinx/ext/autodoc/preserve_defaults.py#L35-L41

Your example also highlights another issue. The corresponding source is

```python
    lambda self: None, doc="Foo.")
```

You'll wrap it in a fake block and would ask to parse:

```python
if True:
    lambda self: None, doc="Foo.")
```

and obviously it fails. The reason why it works when no lambda is used is because the source code of your function is correctly found. For the simple example above, the corresponding source code is

```python
Z = lambda x=X: x
```

which is an *assignment* and not a function definition. Note that `module.body[0].body[0]` is still incorrect because it is an expression node whose value is the lambda function (`module.body[0].body[0].value`). So we need to change the implementation of `get_function_def`. 

---

I can work on the issue today but won't be able to guarantee that it can be easily solved. I think I'll just consider the case of a lambda function differently and handle the case when the source code of the lambda function is wrapped or decorated and whether there are trailing braces to close.


Thanks for the analysis.

I understand this report is fairly obscure, so I'll be surprised and impressed if you're able to solve it elegantly or quickly.

From the sounds of things, my best bet would for now be to accept that this form isn't supported and work to port the usage in the library to use naturally-decorated property methods, which I'll do.
> I understand this report is fairly obscure, so I'll be surprised and impressed if you're able to solve it elegantly or quickly.

Well, it should not be that hard actually. It's just that I don't necessarily have all the corner cases in mind (nor the time to look carefully). I'll only be able to look at it in mid July