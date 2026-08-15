```
This if course has nothing to do with the limit function, but is just because primepi doesn't work with symbolic arguments.  It should be rewritten to derive from Function.

**Summary:** primepi doesn't work with symbolic arguments  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2735#c1
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2735#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Labels:** NumberTheory  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2735#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

should we just return  `x / ln(x)` for symbolic arguments ?

primepi(x) is equal to x/ln(x) only in the limit. 
