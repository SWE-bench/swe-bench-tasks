Looks like a similar issue: #9216. See the PR that fixed that case: #15060. 

For anyone looking to fix this, I suggest adding an `if` statement somewhere here:

https://github.com/sympy/sympy/blob/c094f1bb9b9047eaa4cf98790c1df997f4f489f8/sympy/printing/latex.py#L642-L648

Hopefully it should be a more general check than what is currently there.
I would like to work on this issue if it is open to work on.
@Maelstrom6 
Thank you for suggesting the part that need to be modified.
First, I solved the above issue by adding the code in sympy/sympy/printing/latex.py as below.
However I don't know if this is the right way, so I think a fundamental solution is needed.

**Changed Code**
```python
        elif expr.exp.is_Rational and expr.exp.is_negative and \
                expr.base.is_commutative:
            # special case for 1^(-x), issue 9216
            if expr.base == 1:
                return r"%s^{%s}" % (expr.base, expr.exp)
            
            # to solve this issue
            elif expr.base.is_Rational and expr.exp == -1:
                return r"\frac {1} {{%s}}" % (self._print(expr.base))

            # things like 1/x
            else:
                return self._print_Mul(expr)
```

**After change Code**
```python
In [1]: from sympy import *
In [2]: latex(Pow(Rational(1,2),-1, evaluate=False))
Out[2]: '\\frac {1} {{\\frac{1}{2}}}'

In [3]: latex(Pow(Rational(1,1),-1, evaluate=False))
Out[3]: '1^{-1}'

In [4]: latex(Pow(Rational(1,2.5),-1, evaluate=False))
Out[4]: '\\frac{1}{\\frac{2}{5}}'

In [5]: latex(Pow(Rational(1,-2),-1, evaluate=False))
Out[5]: '\\frac{1}{- \\frac{1}{2}}'

In [6]: latex(Pow(Rational(1,0),-1, evaluate=False))
Out[6]: '\\frac{1}{\\tilde{\\infty}}'

In [7]: latex(Pow(Rational(-1,5),-1, evaluate=False))
Out[7]: '\\frac{1}{- \\frac{1}{5}}'

In [8]: latex(Pow(Rational(-1,-5),-1, evaluate=False))
Out[8]: '\\frac {1} {{\\frac{1}{5}}}'
```
> I would like to work on this issue if it is open to work on. 

I'm sure it's open for anyone. All contributions are welcome. 

> However I don't know if this is the right way, so I think a fundamental solution is needed.

I agree. It might cause errors for other numbers as well and we shouldn't to single checks on each of them.

Also, in latex, your solution would look like it's evaluated when the user chose for it to be unevaluated. So it would rather be better to have `r"{%s}^{%s}"`.

I'm not familiar with this part of sympy so it might be better to wait for a more experienced opinion. You could also submit a pull request in order to get better feedback than what I can provide. 