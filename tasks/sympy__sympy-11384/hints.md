> That is, it really does represent it as the formula Sum((-1)**n/factorial(2_n + 1)_x**n, (n, 0, oo)) (albiet, not simplified). It out to print it like this, so you can see that that's what it's working with.

I got to admit that not much discussion was done on the printing aspect of Formal Power Series.  When I first wrote the code, I tried to keep it as similar as possible to what series has to offer. Since, Formal Power Series is all about a formula computed for the series expansion, I guess this is a good idea. +1

> Side question: if you enter something it can't compute, it just returns the function
> 
> In [25]: fps(tan(x))
> Out[25]: tan(x)
> Is that intentional? It seems like it ought to raise an exception in that case.

This is again similar to what series does. Return it in the original form, if it's unable to compute the expansion. 

```
>>> series(log(x))
log(x)
```

If we want to raise an exception, the inability to compute can be from various reasons:
1. This is simply not covered by the algorithm.
2. SymPy does not have the required capabilities(eg. we need to construct a differential equation as part of the algorithm).
3. There is some bug in the code (that can be fixed ofcourse).

I am not sure here. Should we raise an exception or keep it just like `series`?

I guess it depends on what the use-cases for fps are.  FWIW, I think series returning expressions unchanged is not so great either (but that's somewhat part of a bigger problem, where the type of series produced by `series` is not very well-defined). 
