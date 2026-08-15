Getting nan for `sign(0)` would be pretty [non-intuitive](https://en.wikipedia.org/wiki/Sign_function) for any mathematical programmer given it's non-derivative definition.

If a rewrite request cannot be fulfilled under all conditions and the request was not for Piecewise, I think the rewrite should return None.
Actually I think it's fine if the rewrite doesn't always work. At least something like this could rewrite:
```julia
In [2]: sign(1+I).rewrite(Abs)                                                                                                                 
Out[2]: sign(1 + ⅈ)
```
You can use piecewise like
```
Piecewise(
    (0, Eq(x, 0)),
    (x / Abs(x), Ne(x, 0))
)
```
Originally this question comes from SO:
https://stackoverflow.com/questions/61676438/integrating-and-deriving-absolute-functions-sympy/61681347#61681347

The original question was about `diff(Abs(x))`:
```
In [2]: x = Symbol('x', real=True)                                                                                                             

In [3]: Abs(x).diff(x)                                                                                                                         
Out[3]: sign(x)
```
Maybe the result from `diff` should be a `Piecewise` or at least an `ExprCondPair` guarding against `x=0`.
The problem is that real-valued functions like abs, re, im, arg,... are not holomorphic and have no complex derivative. See also https://github.com/sympy/sympy/issues/8502.
@jksuom could we add conditions in the `Derivative` class of the functions module which would check if the expression is an instance of a non-holomorphic function, in such a case it could raise an error or in the case of `Abs` simply  check the domain. I believe all the classes in `sympy/functions/elementary/complexes.py` could be checked.
Would it be possible to add an `_eval_derivative` method raising an error to those functions?
When would it raise?
If the function is non-holomorphic, there is no derivative to be returned.
There is a reasonable derivative of `Abs` when defined over the reals though e.g.:
```julia
In [1]: x = Symbol('x', real=True)                                                                                                

In [2]: Abs(x).diff(x)                                                                                                            
Out[2]: sign(x)
```
Maybe there should be two functions, one defined on reals and the other on complexes.
> Would it be possible to add an `_eval_derivative` method raising an error to those functions?

In the `Derivative` class in `sympy.function`?



> When would it raise?

As suggested, if the function is non-holomorphic or in the case of `Abs()` it could be a check on the domain of the argument.


> Maybe there should be two functions, one defined on reals and the other on complexes.

I am not sure if there are any non-holomorphic functions on Real numbers. In my opinion only the `Abs()` function would fall in this case. Hence I think this could be done using one function only.
```
def _eval_derivative(self, expr):
    if isinstance(expr,[re, im, sign, arg, conjugate]):
	raise TypeError("Derivative not possible for Non-Holomorphic functions")
    if isinstance(expr,Abs):
	if Abs.arg[0].free_symbols.is_complex:
	    raises TypeError("There is a complex argument which makes Abs non-holomorphic")
```
This is something I was thinking but I am not sure about it as `Derivative` class already has a method with the same name. I also think that appropriate changes also need to be made in the `fdiff()` method of the `Abs` class.
@jksuom I wanted to know if there are more non-holomorphic functions in sympy/functions/elementary/complexes.py to which an error can be raised.
Those functions in complexes.py have a `_eval_derivative` method. Maybe that would be the proper place for raising an error if that is desired.
Are there any other examples of functions that raise when differentiated?

I just tried
```julia
In [83]: n = Symbol('n', integer=True, positive=True)                                                                             

In [84]: totient(n).diff(n)                                                                                                       
Out[84]: 
d             
──(totient(n))
dn 
```
@oscarbenjamin I am not sure if this is a situation when it should raise, for example: if `n` here is a prime number the derivative wrt `n` would hence be `1` . Although in sympy 
```
>>> x = Symbol('x', real=True, prime=True)
>>> totient(x).evalf()
ϕ(x)
```
is the output and not `x-1`.Maybe this kind of functionality can be added.
@jksuom I think your way is correct and wanted to ask if the error to be raised is appropriately `TypeError`?
I don't think that the totient function should be differentiable. I was just trying to think of functions where it might be an error to differentiate them.

I think it's better to leave the derivative of Abs unevaluated. You might have something like `Abs(f(x))` where `f` can be substituted for something reasonable later.
@dhruvmendiratta6 Yes, I think that `TypeError` would be the appropriate choice. Note, however, that raising errors would probably break some tests. It may be desirable to add some try-except blocks to handle those properly.
What about something like this:
```julia
In [21]: x = Symbol('x', real=True)                                                                                               

In [22]: f = Function('f')                                                                                                        

In [23]: e = Derivative(Abs(f(x)), x)                                                                                             

In [24]: e                                                                                                                        
Out[24]: 
d         
──(│f(x)│)
dx        

In [25]: e.subs(f, cosh)                                                                                                          
Out[25]: 
d          
──(cosh(x))
dx         

In [26]: e.subs(f, cosh).doit()                                                                                                   
Out[26]: sinh(x)
```
@jksuom @oscarbenjamin 
Any suggestion on how this can be done?
I think changes need to be made here
https://github.com/sympy/sympy/blob/7c11a00d4ace555e8be084d69c4da4e6f4975f64/sympy/functions/elementary/complexes.py#L605-L608
to leave the derivative of `Abs` unevaluated. I tried changing this to 
```
def _eval_derivative(self, x):
        if self.args[0].is_extended_real or self.args[0].is_imaginary:
            return Derivative(self.args[0], x, evaluate=True) \
                * Derivative(self, x, evaluate=False)
```
which gives
```
>>> x = Symbol('x', real = True)
>>> Abs(x**3).diff(x)
x**2*Derivative(Abs(x), x) + 2*x*Abs(x)
```
But then I can't figure out how to evaluate when the need arises.The above result,which I think is wrong, occurs even when no changes are made.
I think rewrite in general can't avoid having situations where things are only defined correctly in the limit, unless we return a Piecewise. For example, `sinc(x).rewrite(sin)`.
```py
>>> pprint(sinc(x).rewrite(sin))
⎧sin(x)
⎪──────  for x ≠ 0
⎨  x
⎪
⎩  1     otherwise
```
I made `_eval_rewrite_as_Abs()` for the `sign` class which gives the following:
```
>>> sign(x).rewrite(Abs)
Piecewise((0, Eq(x, 0)), (x/Abs(x), True))
```
Although as discussed earlier raising an error in `_eval_derivative()` causes some tests to break :
```
File "c:\users\mendiratta\sympy\sympy\functions\elementary\tests\test_complexes.py", line 414, in test_Abs
    assert Abs(x).diff(x) == -sign(x)
 File "c:\users\mendiratta\sympy\sympy\functions\elementary\tests\test_complexes.py", line 833, in test_derivatives_issue_4757
    assert Abs(f(x)).diff(x).subs(f(x), 1 + I*x).doit() == x/sqrt(1 + x**2)
 File "c:\users\mendiratta\sympy\sympy\functions\elementary\tests\test_complexes.py", line 969, in test_issue_15893
    assert eq.doit() == sign(f(x))
```
The first two are understood but in the third one both `f` and `x` are real and still are caught by the newly raised error which doesn't make sense as I raised a `TypeError` only if the argument is not real.