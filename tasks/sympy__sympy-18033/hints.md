Hi I am looking to fix this error. Could you guide me on this one a bit? 
From what I understood `permutations.py` has some functions which use `print_cyclic` flag. But since this is a global flag, it should not be used. Instead it should use something from the `printing` module? Do I need to go through the `printing` module thoroughly? How do I get started on this?
@sudz123 Users should set printing preferences via `init_printing`, not by changing class attributes. So `print_cyclic` from the `Permutation` class should be deprecated, and `init_printing` should get a new keyword argument so we could do `init_printing(cyclic=True)` (or something like that) if we wanted permutations to be printed in cyclic notation.`init_printing` is [here](https://docs.sympy.org/latest/_modules/sympy/interactive/printing.html#init_printing).

> Additionally, it would be best if the str printer printed a Python valid representation and the pretty printers only (pprint/latex) printed things like (1 2 3).

Right now, permutation printing is all specified in its `__repr__` - this should always return `Permutation(<list>)` (i.e. what's returned now when `Permutation.print_cyclic=False`). The new "cyclic" flag should only be relevant when `pprint` and `latex` are called. The printing module is huge, but you only need to work out how to make `pprint` and `latex` work properly with the new keyword argument. For example, for `pprint`, you'll need to add `'cyclic'` (or whatever you decide to call it) to `PrettyPrinter._default_settings` and write a new method `_print_Permutation`.
Is my following interpretation of Printing correct?
`init_printing()` only sets what happens in an interactive session. i.e. like jupyter notebook.
For printing in a regular python file. we have to only use `pprint()` or `print_latex()`

After I change the codes for `pprint()` and `print_latex()`. How do I test it for interactive ipython. In my jupyter notebbok, I am only able to get output for Latex Printing and not pprint using `init_printing()`.

@valglad @asmeurer  Please help.