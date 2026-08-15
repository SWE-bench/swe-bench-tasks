The '3' got parsed as a Symbol in expr2:
```python
>>> srepr(expr2)
"Mul(Pow(Integer(2), Symbol('n')), Pow(Symbol('3'), Symbol('n')))"
                                       ^^^^^^^^^^^
```
This is bug? Or what? :(
> how i can get zero after expr1 - expr2?

The hack is to do `expr2 = expr2.subs(Symbol('3'), 3)` and work with that until the bug is fixed.
Thank you, but i have this bug not only for '3', i can't fix this bug automatically for all cases :)
I hope, that this bug will be fix.
I'm not sure how easy this will be to fix: you have an ambiguous expression. `n3` is a valid variable name so either you have a syntax error -- one of the powers is missing an argument as in `2**n3*?**n` or `2**?*n3**n` or it should be split (as in this case you want). But if there is more than 1 number, then what?
`2**n32**n` could have a base of 32 or 2 and or `2**n2.3**n` could have a base of 2.3 or 0.3. Perhaps the simplest thing to do is raise a parsing error if any Symbol (not in a locals dictionary) is created whose name is a number.