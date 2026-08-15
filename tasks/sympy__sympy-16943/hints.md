well could you please elaborate your issue, as of documentation it returns correct without `O` term
if you wish to have value of p(0) try p.subs(x,0)
The issue is that the returned value is not a FormalPowerSeries object and doesn't support the same interface as it, so why is it being returned from a method that claims that's what it returns? 
I might be not completely sure about this, but according to what I understand fps can only be computed for a field, that is a series upto infinite number of terms, and I think that x**2 is treated here as an expression. Therefore it will not support the the same interface
There's no mathematical problem with treating a polynomial as a formal power series - it's just a power series where only finitely many coefficients are non zero. 

My basic point remains:

* the method's documentation says it returns a formal power series
* it is not returning a formal power series
* this seems bad, and implies that one of the documentation or the method must be wrong

It would seem very odd for this to be intended behaviour and it sharply limits the utility of the method if that is the case, but even if it is intended it's at the bare minimum a documentation bug. 
I agree that it doesn't makes sense to treat polynomials separately. 
@DRMacIver @asmeurer The documentation needs to updated. The documentation doesn't tell what the method returns if it is unable to compute the formal power series. In usage it just returns the expression unchanged. I did this keeping in mind how the series function works.

```
>>> series(x**2)
x**2
```

We need to think, if it is okay, to keep it as is and just update the documentation or should we raise an error? In either case documentation needs updation. Also, this is not the first time, users have been confused by this functionality.
> The documentation doesn't tell what the method returns if it is unable to compute the formal power series.

Could you elaborate on what's going on here? I don't see why it should be unable to compute a formal power series - as mentioned above, there's no problem with formal power series for polynomials, they just have all but finitely many coefficients zero.

It also seems like a very strange choice to return the value unmodified if it can't compute a formal power series as opposed to raising an error.
I raised a similar concern [here](https://github.com/sympy/sympy/issues/11102). I think it should error, rather than returning the expression unchanged. That way you can always assume that the return value is a formal power series. 

And I agree that polynomials should be trivially representable as formal power series. 
+1. Agreed.
I imagine making it error should be an easy change.

How hard is it to make the power series of polynomials work? Does it need a symbolic formula? The symbolic formula for the nth coefficient of p(x) is just coefficient(p(x), n), but we don't currently have a symbolic coefficient function. 
Although writing one would be trivial:

```py
class Coeff(Function):
    """
    Coeff(p, x, n) represents the nth coefficient of the polynomial p in x
    """
    @classmethod
    def eval(cls, p, x, n):
        if p.is_polynomial and n.is_integer:
            return p.coeff(x, n)
```
> How hard is it to make the power series of polynomials work? Does it need a symbolic formula? The symbolic formula for the nth coefficient of p(x) is just coefficient(p(x), n), but we don't currently have a symbolic coefficient function.

Well there is a need to define a function that identifies the polynomials and converts them to a ``FormalPowerSeries`` object. Which essentially means finding out a formula for the coefficients and the powers of x (``ak`` and ``xk`` in the documentation). Both of which will can be a simple ``Piecewise`` function. I am not sure how hard this will be. I will try to look into the code, if I can find an easy solution.
That Coeff class I suggested would be the formula. You could also represent it with existing functions like with Piecewise or with Subs and derivatives, but a new Coeff object would be the clearest and also the most efficient. 
> That Coeff class I suggested would be the formula. You could also represent it with existing functions like with Piecewise or with Subs and derivatives, but a new Coeff object would be the clearest and also the most efficient.

Somehow, missed your suggestion. Just did a small test. It seems to work very well.
+1 for implementing this.
