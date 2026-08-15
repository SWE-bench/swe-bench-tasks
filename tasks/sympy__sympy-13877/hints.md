The source refers to a thesis that might justify a more general form of Bareiss algorithm, but I can't access the thesis.  Meanwhile, the LU method works fine. 
```
f = lambda n: Matrix([[i + a*j for i in range(n)] for j in range(n)]).det(method='lu')
```
Unless the failure of 'bareiss' here is due to an implementation flaw, it seems we should change the default method to old-fashioned but trusty LU.   
> isn't the Bareiss algorithm only valid for integer matrices

It is equally valid for other matrices. It is favoured for integer matrices since it tends to avoid denominators.

In this case, it seems that the computation of the determinant (as an expression) succeeds but `factor_terms` fails. It is possible to avoid that by using polynomials instead of plain expressions:

    f = lambda n: det(Matrix([[Poly(i + a*j, a) for i in range(n)] for j in range(n)]))
    
The recursive [`do`-method](https://github.com/sympy/sympy/blob/master/sympy/core/exprtools.py#L1154) deals with the arguments of a `Mul` object [one by one](https://github.com/sympy/sympy/blob/master/sympy/core/exprtools.py#L1197). The error occurs when a `Mul` object has arguments `a` and `b**-1` such that `a` and `b` have a common factor that simplifies to 0.
Still, isn't it a fault of the method that it produces a 0/0 expression? Consider a simpler example: 
```
var('a')
expr = (2*a**2 - a*(2*a + 3) + 3*a) / (a**2 - a*(a + 1) + a)
factor_terms(expr)     #  nan
```
Do we say that `factor_terms` is buggy, or that my `expr` was meaningless to begin with? 
  
I think it's reasonable to try Bareiss first, but if the expression that it produces becomes `nan`, fall back on LU. (Of course we shouldn't do this fallback if the matrix contained nan to begin with, but in that case we should just return nan immediately, without computations.) 
It seems that Bareiss' [`_find_pivot`](https://github.com/sympy/sympy/blob/master/sympy/matrices/matrices.py#L177) should use some zero detection like `val = val.expand()` before `if val:`.