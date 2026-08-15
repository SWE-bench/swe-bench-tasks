The simplest fix is to have the function check to see if x is not a symbol:
```python
>>> interpolate((1,2,3),1)
nan
>>> interpolate((1,2,3),x).subs(x,1)
1
```
So in the function a check at the top would be like
```python
if not isinstance(x, Symbol):
    d = Dummy()
    return interpolate(data, d).subs(d, x)
```
Or the docstring could be annotated to say that `x` should be a Symbol.
There now exist two functions, `interpolate` and `interpolating_poly`, that construct an interpolating polynomial, only their parameters are slightly different. It is reasonable that `interpolating_poly` would return a polynomial (expression) in the given symbol. However, `interpolate` could return the *value* of the polynomial at the given *point*. So I am +1 for this change.