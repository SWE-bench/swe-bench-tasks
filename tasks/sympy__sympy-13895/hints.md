The expressions really are equivalent, `simplify` is not to blame.  SymPy is inconsistent when raising negative numbers to the power of 9/5 (and probably other rational powers). 
```
>>> (-S(1))**(S(9)/5)
-(-1)**(4/5)                  #  complex number as a result 
>>> (-S(4))**(S(9)/5)
-8*2**(3/5)                  # the result is real
```
In a way, both are reasonable. The computation starts by writing 9/5 as 1 + 4/5. Then we get the base factored out, and are left with `(-1)**(4/5)` or `(-4)**(4/5)`. Somehow, the first is left alone while in the second, noticing that 4 is a square, SymPy does further manipulations, ending up by raising (-4) to the power of 4 and thus canceling the minus sign. So we get the second result.  

Can it be accepted that the expression is multi-valued and which of the possible values is chosen is arbitrary? But one perhaps would like more consistency on this.
OK, "inequivalent" was the wrong word. But is it reasonable to expect sympy to try to keep the same complex root choice through simplification?
Yes, I think there should be consistency there.  The issue is at the level of SymPy taking in an object like (-1)**(S(4)/5) and parsing it into an expression tree. The trees are formed in significantly different ways for different exponents: 
```
>>> for k in range(1, 5):
...     srepr((-4)**(S(k)/5))
'Pow(Integer(-4), Rational(1, 5))'    #  complex
'Pow(Integer(-4), Rational(2, 5))'    # complex 
'Mul(Integer(2), Pow(Integer(-2), Rational(1, 5)))'   # complex, factoring out 2 is okay
'Mul(Integer(2), Pow(Integer(2), Rational(3, 5)))'    # real, where did the minus sign go? 
```