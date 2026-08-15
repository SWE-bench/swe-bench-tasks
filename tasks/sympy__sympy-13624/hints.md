Hi @bjodah! I'd like to make my first contribution. Can I work on this issue?
Sure! You can have a look here for how to get started: https://github.com/sympy/sympy/wiki/Development-workflow
Hi @bjodah !
As you stated, I made the code accessing `_settings` use `.get` with a default `False`.
But now I am getting some other error
```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "sympy/printing/pycode.py", line 187, in pycode
    return PythonCodePrinter(settings).doprint(expr)
  File "sympy/printing/codeprinter.py", line 100, in doprint
    lines = self._print(expr).splitlines()
  File "sympy/printing/printer.py", line 257, in _print
    return getattr(self, printmethod)(expr, *args, **kwargs)
  File "sympy/printing/codeprinter.py", line 319, in _print_Assignment
    return self._get_statement("%s = %s" % (lhs_code, rhs_code))
  File "sympy/printing/codeprinter.py", line 250, in _get_statement
    raise NotImplementedError("This function must be implemented by "
NotImplementedError: This function must be implemented by subclass of CodePrinter.
```
How can I implement this function?