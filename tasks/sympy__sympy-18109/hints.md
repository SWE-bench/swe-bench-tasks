Also with oo - 5, for instance
> Also with oo - 5, for instance

No, it prints oo in that case :)
The documentation of `evaluate` says:
`Note that much of SymPy expects evaluated expressions.  This functionality is experimental and unlikely to function as intended on large expressions.`

Nonetheless, it happens because `evaluate` affects the auto-evaluations in `Add` (inherited from `Basic`) but in both the above cases `oo`(`S.Infinity`) 's `__add__` function is called, no Add object is generated, and the evaluated result is given.

One interesting case,
```py
>>> with evaluate(False):
...     print(S(5)+oo)
...     print(oo+S(5))
...
5 + oo
oo
```

One possible approach would be update the code in `__add__` (and other functions) in `S.Infinity` so that `Add` is called and `evaluate` is acknowledged. It should be easy to fix.

Hi @ShubhamKJha . I'm willing to work on this issue 
I need some help cause this is my first time dealing with such a huge codebase. Can you explain the steps a little more? 
The `__add__` method here ignores `global_evaluate`. It could be made to check `global_evaluate` but I actually think a better solution would be to remove the `__add__` method and let `Add.flatten` handle (or not handle) this logic:
```julia
In [1]: with evaluate(False): 
   ...:     pprint(Add(oo, -oo)) 
   ...:                                                                                                                                                       
-∞ + ∞
```
Hi @namannimmo10, if you are contributing for the first time read [this](https://github.com/sympy/sympy/wiki/Introduction-to-contributing)

And  as @oscarbenjamin suggested start with removing `__add__` method in `sympy.core.numbers.Infinity` class, [test it](https://github.com/sympy/sympy/wiki/Running-tests) and send a PR.