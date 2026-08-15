This one's a bug in `diophantine`:
```
In [1]: diophantine(x**2 - 1 - y)
Out[1]: set()
```
The equation has rather trivial integer solutions.
```
In [14]: from sympy.solvers.diophantine import diop_quadratic                                                                  
In [15]: diop_quadratic(m**2 - n - 1, k)                                                                                       
Out[15]:
⎧⎛    2    ⎞⎫
⎨⎝k, k  - 1⎠⎬
⎩           ⎭

In [16]: diophantine(m**2 - n - 1, k)
Out[16]: set()
```
The solutions are discarded somewhere inside `diophantine`.

Actually, when `diop_quadratic` is invoked via `diophantine` the signs of the coefficients are negated. So the issue can be reproduced as follows:
```
In [1]: from sympy.solvers.diophantine import diop_quadratic

In [2]: diop_quadratic(m**2 - n - 1, k)
Out[2]:
⎧⎛    2    ⎞⎫
⎨⎝k, k  - 1⎠⎬
⎩           ⎭

In [3]: diop_quadratic(-m**2 + n + 1, k)
Out[3]: set()
```