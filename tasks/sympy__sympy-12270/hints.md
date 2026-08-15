I would like to work on this issue. Please help me to start with it!
I do not understand why do we need 
`elif self.is_positive and quotient.is_negative:
                    return None`
in line 1975-76 of `sympy/core/expr.py` ?? 
As mentioned in the doc of the function `extract_multiplicatively`, If it is to preserve the properties of args of self(i.e., if self being a positive number, result should be positive), then what about the args of `-2-4*I` here??
```>>> (-2-4*I).extract_multiplicatively(-1)   # yes```
``` 2 + 4*I```

I'm not an expert so this is not much of an answer...  See `could_extract_minus_sign()` for an example of something that uses this.  You could also try dropping that `elif` and running the tests: I think you'll see endless recursion b/c this is used internally in various algorithms.

> then what about the args of `-2-4*I` here??

That thing is an `Add`.  It should try to extract `-1` from each of the things in the `Add`.  In this case that is `-2` and `Mul(-4, I)`, each of which can have `-1` extracted from it.  (I think same should be true for `-2`, hence I filed this bug).
> I think same should be true for -2 

 This is what I thought it should work for, if it works fine for -1. But then what about the properties of arguments of self (the signs will then then be reversed )?? 
If we intend to preserve the properties, I think it shouldn't work for -1 as well!
Maybe those docs are vague, ignore. Could_extract_minus_sign definitely replies on the -1 to keep working.
Sorry "relies" not replies
well i have worked on it and noticed that extract_multiplicatively works fine if you give second argument as positive..and if you give negative value there are many cases where it fails...
For example 
`>>> f=x**3*y**2
 >>> f.extract_multiplicatively(x*y)
 >>> x**2*y
 >>> f.extract_multiplicatively(-x*y)
 >>>
`

That looks like the correct behaviour: there is no minus sign in `x**3*y**2` so cannot extract.

My understanding of `.extract_multiplicatively(-1)` is something like "would a human factor a minus sign out of this expression?"
Put another way (and as I think I've said above at least once), if you could extract a "-1" from `x*y` then `.could_extract_minus_sign` would fail the `{e, -e}` thing explained in its docs.
> do you think this is bug

Yes. Consider:

```
>>> (-2-4*x).extract_multiplicatively(1+2*x)
>>> (-2-4*x).extract_multiplicatively(-1-2*x)
2
```

It allows a negative expression to be extracted. It seems that it should allow a bare negative to be extracted. I think I would change the routine by just recasting the input. Something like

```
given expr, test
if test.is_Number and test < 0:
  return (-expr).extract_multiplicatively(-test)
```
@smichr, I think the recasting you suggested would fail in the following test case.
```
>>> (2*x).extract_multiplicatively(-1)
-2*x
```
But this should have been ```None```.

> I think the recasting you suggested would fail

Yes. What about doing something like

```
from sympy.core.function import _coeff_isneg as f
if test < 0 and all(f(t) for t in Add.make_args(expr)):
    return (-expr).extract_multiplicatively(-test)
```