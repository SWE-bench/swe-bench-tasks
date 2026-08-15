Seems to depend on where the 1 is when it comes to do the hnf:
```python
>>> hermite_normal_form(Matrix([  # row2
... [0, 12],
... [1,  8],
... [0,  5]]))
Matrix([
[0, 12],
[1,  0],
[0,  5]])
>>> hermite_normal_form(Matrix([  # row3
... [0, 12],
... [0,  8],
... [1,  5]]))
Matrix([
[12, 0],
[ 8, 0],
[ 0, 1]])
>>> hermite_normal_form(Matrix([  # row1
... [1, 12],
... [0,  8],
... [0,  5]]))
Matrix([
[12],
[ 8],
[ 5]])
```
Thanks. I believe this may be related to the also recently opened bug https://github.com/sympy/sympy/issues/23260. 

In Wolfram Language, I can just do `Last[HermiteDecomposition[{{5,8,12},{0,0,1}}]]` and get `{{5,8,0},{0,0,1}}` as expected. The above may be a workaround but it's not pretty.