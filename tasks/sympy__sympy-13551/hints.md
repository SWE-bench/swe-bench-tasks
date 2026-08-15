The responsible line seems to be [line 286](https://github.com/sympy/sympy/blob/97571bba21c7cab8ef81c40ff6d257a5e151cc8d/sympy/concrete/products.py#L286) in concrete/products.

This line seems to be assuming that the product of a sum is the same as the sum of the products of its summands.

This leads to nonsense like this (directly mentioned in the comment above this line!)

    >>> from sympy.abc import n, k
    >>> p = Product(k**(S(2)/3) + 1, [k, 0, n-1]).doit()
    >>> print(simplify(p))
    1
