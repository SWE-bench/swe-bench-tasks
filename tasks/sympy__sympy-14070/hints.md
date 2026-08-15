```
Bisected to:

commit 9dc1d111d489624eef3b0c9481c3e6d99cd869e0
Author: Chris Smith <smichr@gmail.com>
Date:   Fri May 20 00:11:41 2011 +0545

    2397: log expansion changes

        Expansion of a log was being done in an as_numer_denom method;
        it should be done in _eval_expand_log where rules are followed
        concerning when the expansion shold be allowed. When this is
        handled there, the as_numer_denom method is no longer needed
        for log. But then tests fail because Rationals don't automatically
        expand, e.g. log(1/2) doesn't become -log(2). They also fail when
        simplifications that relied on that forced expansion of log(x/y)
        into log(x) - log(y) no longer can do the expansion so the
        force keyword was introduced to the log_expand method.

        A few failing solver tests needed tweaking.

        The expand docstring was PEP8'ed and edited a little.

**Cc:** smi...@gmail.com  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c1
Original author: https://code.google.com/u/101272611947379421629/

```
It's because we have:

In [46]: log(S(3)/2)
Out[46]: -log(2) + log(3)

so obviously it's impossible for logcombine to combine them.  Perhaps this should be removed?  We also automatically pull out perfect powers:

In [47]: log(16)
Out[47]: 4⋅log(2)

In [49]: log(S(16)/9)
Out[49]: -2⋅log(3) + 4⋅log(2)
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
By the way, I remember being not sure about this change.  Perhaps Chris will remember where the discussion was.  I think the motivation was to make it easier for certain expressions to automatically cancel.  But I now think that we should not automatically expand logs.  Rather, make expand_log call factorint() and expand it completely.

**Status:** NeedsDecision  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Right, I had forgotten about that, but if you step through the code, you can see that it doesn't even try to return log(3/2), and there is the same problem with    logcombine(log(x) - log(2)): it should return log(x/2) (which isn't autoconverted back to log(x) - log(2)) but it doesn't.

So there are really 2 separate issues here.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c4
Original author: https://code.google.com/u/101272611947379421629/

```
see also duplicate(?) issue 5808
```

Referenced issues: #5808
Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c5
Original author: https://code.google.com/u/117933771799683895267/

```
are you referring to the discussion on issue 5496 ?
```

Referenced issues: #5496
Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c6
Original author: https://code.google.com/u/117933771799683895267/

```
To me it seems like `log(x/2)` should autoexpand like `sqrt(4*x)`

2*sqrt(x)

log(x/2)
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c7
Original author: https://code.google.com/u/117933771799683895267/

```
I don't mind if the autoevaluation goes away, but the logic for it should not be duplicated (which makes tracking down logic errors difficult). Could eval be given a keyword so that expansion can be done optionally (e.g. not at instantiation but log expand could call the routine to have it autoexpand). It would be nice to allow sqrt to not autocombine, too, so sqrt(2) + x*sqrt(10) could be expanded and factored to sqrt(2)*(1 + x*sqrt(5)).
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c8
Original author: https://code.google.com/u/117933771799683895267/

```
> are you referring to the discussion on issue 5496 ?

No, that wasn't it.  There was some lengthy discussion that we had about what logs should do with numeric arguments.

>  It would be nice to allow sqrt to not autocombine, too, so sqrt(2) + x*sqrt(10) could be expanded and factored to sqrt(2)*(1 + x*sqrt(5)).

But that can already work:

In [117]: sqrt(2)*(1 + x*sqrt(5))
Out[117]: 
  ___ ⎛  ___      ⎞
╲╱ 2 ⋅⎝╲╱ 5 ⋅x + 1⎠
```

Referenced issues: #5496
Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c9
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Yes, it will stay...but how do you factor it into that form. Maybe
there is a factor option...?
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c10
Original author: https://code.google.com/u/117933771799683895267/

```
Whatever function (I'm not sure which would do it right now), would manually do it I guess.

I guess we could modify factor() to do it as part of the preprocessing (right now, it treats algebraic numbers as generators, if I remember correctly).
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2851#c11
Original author: https://code.google.com/u/asmeurer@gmail.com/

@asmeurer @smichr do you think the issue is valid?

It still doesn't work:

```
In [26]: logcombine(log(3) - log(2))
Out[26]: -log(2) + log(3)
```

I want to work on this issue