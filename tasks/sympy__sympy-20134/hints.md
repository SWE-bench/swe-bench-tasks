```
Would just adding _print_Integral to LambdaPrinter be enough?
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2833#c1
Original author: https://code.google.com/u/100157245271348669141/

```
I think that would fix it for sympy (mpmath) evaluation.  As for making it work with other packages (scipy), you will have to modify lambdify(). 

By the way, when this is fixed, be sure to test against Integral(), not integrate(), in case the integration engine improves.

**Labels:** Integration Printing  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2833#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2833#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/
