and a more serious issue regarding the introduction of underscores when writing to mathml

```
sympy.sympify('x1') == sympy.sympify('x_1')
>>> False
sympy.mathml(sympy.sympify('x1')) == sympy.mathml(sympy.sympify('x_1'))
>>> True
```
CC @oscargus 