```
But our assumptions on Function mean it is a number, even if we don't know what that number is. 

Regarding solve, I don't see how it's related, nor why we should arbitrarily disallow that.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3547#c1
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
If we don't know what it is, then we can't evalf() it or compare it to a real real number, which means that is_number should be False. We could easily make the change in AppliedUndef, I think.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3547#c2
Original author: https://code.google.com/u/101272611947379421629/

```
I guess it's fine if defining is_number that way makes it more useful. This again goes back to issue 6015 .
```

Referenced issues: #6015
Original comment: http://code.google.com/p/sympy/issues/detail?id=3547#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Make that issue 5295 .

**Labels:** Assumptions  

```

Referenced issues: #5295
Original comment: http://code.google.com/p/sympy/issues/detail?id=3547#c4
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Blockedon:** 5295  

```

Referenced issues: #5295
Original comment: http://code.google.com/p/sympy/issues/detail?id=3547#c5
Original author: https://code.google.com/u/asmeurer@gmail.com/
