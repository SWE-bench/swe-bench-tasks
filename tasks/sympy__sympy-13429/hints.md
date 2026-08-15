Some experimentation shows that the behavior can be improved by computing the difference and then looking at the sign with .is_positive and .is_negative. However, that can break as well, you just need a bigger fraction:
```
>>> r = sympy.Rational('472202503979844695356573871761845338575143343779448489867569357017941709222155070092152068445390137810467671349/150306725297525326584926758194517569752043683130132471725266622178061377607334940381676735896625196994043838464')
>>> r < sympy.pi
True
>>> r > sympy.pi
True
>>> x = r - sympy.pi
>>> repr(x.is_positive)
'None'
>>> repr(x.is_negative)
'None'
```
This is the same as that issue. See the discussion there and at https://github.com/sympy/sympy/pull/12537. 
Ah, awesome.

Is there a workaround to force evalf() to use enough precision that the digits it gives me are correct? I don't mind if it uses a lot of memory, or loops forever, or tells me it can't determine the answer. I just want to avoid the case where I get an answer that's wrong.

Something like the behavior of Hans Boehm's [constructive reals](http://www.hboehm.info/new_crcalc/CRCalc.html) would be ideal.
evalf already does this. It's just the way it's being used in the comparisons is wrong. But if you do `(a - b).evalf()` the sign of the result should tell if you if a < b or a > b (or you'll get something like `-0.e-124` if it can't determine, which I believe you can check with `is_comparable). 
To clarify, evalf internally increases the precision to try to give you as many digits as you asked for correctly (the default is 15 digits). For comparisions, you can just use `evalf(2)`, which is what the [core does](https://github.com/sympy/sympy/blob/d1320814eda6549996190618a21eaf212cfd4d1e/sympy/core/expr.py#L3371). 

An example of where it can fail

```
>>> (sin(1)**2 + cos(1)**2 - 1).evalf()
-0.e-124
>>> (sin(1)**2 + cos(1)**2 - 1).evalf().is_comparable
False
```

Because `sin(1)**2 + cos(1)**2` and `1` are actually equal, it will never be able to compute enough digits of each to get something that it knows is greater than or less than 0 (you can also construct more diabolic examples where expressions aren't equal, but evalf won't try enough digits to determine that). 
Perfect.

So it seems like I can do the following to compare (rational or irrational reals) a and b:
1) check if a == b; if so, we're done
2) subtract, and keep calling evalf(2) with increasing arguments to maxn, until the result .is_comparable
3) if we find a comparable result, then return the appropriate ordering
4) otherwise give up at some point and claim the results are incomparable

Hmm, is there any benefit in actually checking a == b? Or will the subtraction always give exactly zero in that case?

Alternatively, is there any danger that a == b will be True even though the a and b aren't exactly equal?
For floats in the present code, yes (see https://github.com/sympy/sympy/issues/11707).  Once that is fixed no. 