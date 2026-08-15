Has anyone tried to represent SymPy's assumptions as a directed graph? Even just trying to draw it on paper might be a good idea for testing even if that isn't how the actual code handles it.
I would very much like to see an explanation defining the meanings of the different `is_*` attributes somewhere. The implied relationships between them would also be very useful but just the definitions would be a start!
Similarly:
```julia
In [1]: i = Symbol('i', integer=True)                                                                                                          

In [2]: print(i.is_finite)                                                                                                                     
None
```
Hi @oscarbenjamin there are really so many loose threads in case of assumptions and what they define. I have looked into thier code in `core` and most of them are a sequence of conditionals( which may sometimes produce different results). They are not logically very rich. It would really benefit to start a discussion on what each assumptions should be defining.
> an explanation defining the meanings of the different is_* attributes

Most of them are defined in `_assume_rules` of `core.assumptions`. Perhaps the second rule `'rational       ->  real'` should be extended to `'rational       ->  real & finite'`.
 Actually, `real` should already imply `finite` but currently its meaning is `extended_real`, and adding `finite` to `real` would probably break a lot of code. But I think that it should be safe to add `finite` to `rational`.
Consider integrals and summations where the variables are real and integer, respectively. Still, it is possible to integrate/accumulate with bounds of +/-oo. Not sure what it means here, but it slightly relates to #16014, (except that one will have to mark integration variables as `extended_real` for the general case).