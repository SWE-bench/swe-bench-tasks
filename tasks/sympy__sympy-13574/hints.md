The problem is here:

https://github.com/sympy/sympy/blob/master/sympy/matrices/dense.py#L1413-L1415

After some values are set to 0, the matrix is shuffled, ruining the symmetry. I'm writing a fix.