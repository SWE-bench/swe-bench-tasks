In this regard, don't you think that `r.simplify()` is wrong? It returns `-a/b` which is not correct if b=a.
`simplify` works for the generic case. SymPy would be hard to use if getting a+b from `simplify((a**2-b**2)/(a-b))` required an explicit declaration that a is not equal to b. (Besides, there is currently no way to express that declaration to `simplify`, anyway). This is part of reason we avoid `simplify` in code:  it can change the outcome in edge cases. 

The fundamental issue here is: for what kind of expression `expr` do we want expr/expr to return 1? Current behavior:

zoo / zoo   # nan
(zoo + 3) / (zoo + 3)   # nan
(zoo + a) / (zoo + a)    # 1  
(zoo + a) / (a - zoo)   # 1 because -zoo is zoo  (zoo is complex infinity)  

The rules for combining an expression with its inverse in Mul appear to be too lax. 

There is a check of the form `if something is S.ComplexInfinity`... which returns nan in the first two cases, but this condition is not met by `zoo + a`. 

But using something like `numerator.is_finite` would not work either, because most of the time, we don't know if a symbolic expression is finite. E.g., `(a+b).is_finite` is None, unknown,  unless the symbols were explicitly declared to be finite.

My best idea so far is to have three cases for expr/expr: 

1. expr is infinite or 0: return nan
2. Otherwise, if expr contains infinities (how to check this efficiently? Mul needs to be really fast), return expr/expr without combining 
3. Otherwise, return 1
"But using something like numerator.is_finite would not work either"

I had thought of something like denom.is_zero. If in expr_1/expr_2 the denominator is zero, the fraction is undefined. The only way to get a value from this is to use limits. At least i would think so.

My first idea was that sympy first simplifies and then substitutes. But then, the result should be -1. 

(zoo+a)/(a-zoo) # 1
explains what happens, but i had expected, that
zoo/expr leads to nan and expr/zoo leads to nan as well.

I agree, that Mul needs to be really fast, but this is about subst. But i confess, i don't know much about symbolic math.
zoo/3 is zoo, and 4/zoo is 0. I think it's convenient, and not controversial, to have these. 

Substitution is not to blame: it replaces b by a as requested, evaluating 1/(a-a) as zoo.  This is how `r` becomes `(1/(2*a) + zoo) / (1/(2*a) - zoo)`. So far nothing wrong has happened. The problem is that (because of -zoo being same as zoo) both parts are identified as the same and then the `_gather` helper of Mul method combines the powers 1 and -1 into power 0. And anything to power 0 returns 1 in SymPy, hence the result. 

I think we should prevent combining powers when base contains Infinity or ComplexInfinity. For example, (x+zoo) / (x+zoo)**2  returning 1 / (x+zoo) isn't right either. 
I dont really understand what happens. How can i get the result zoo? 

In my example `r.subs(b,a)` returns ` 1`,  
but `r.subs(b,-a)` returns `(zoo + 1/(2*a))/(zoo - 1/(2*a))`

So how is zoo defined? Is it `(1/z).limit(z,0)`? I get `oo` as result, but how is this related to  `zoo`? As far as i know, `zoo` is ComplexInfinity. By playing around, i just found another confusing result:

`(zoo+z)/(zoo-z)` returns `(z + zoo)/(-z + zoo)`, 
but
`(z + zoo)/(z-zoo)` returns 1

I just found, `1/S.Zero` returns `zoo`, as well as `(1/S.Zero)**2`. To me, that would mean i should not divide by `zoo`.
There are three infinities: positive infinity oo, negative infinity -oo, and complex infinity zoo. Here is the difference:

- If z is a positive number that tends to zero, then 1/z tends to oo
- if z is a negative number than tends to zero, then 1/z tends to -oo
- If z is a complex number that tends to zero, then 1/z tends to zoo

The complex infinity zoo does not have a determined sign, so -zoo is taken to  be the same as zoo. So when you put `(z + zoo)/(z-zoo)` two things happen: first, z-zoo returns z+zoo (you can check this directly) and second, the two identical expressions are cancelled, leaving 1.

However, in (zoo+z)/(zoo-z) the terms are not identical, so they do not cancel. 

I am considering a solution that returns NaN when Mul cancels an expression with infinity of any kind. So for example (z+zoo)/(z+zoo) and (z-oo)/(z-oo) both return NaN. However, it changes the behavior in a couple of tests, so I have to investigate whether the tests are being wrong about infinities, or something else is. 
Ok. I think i got it. Thank you for your patient explanation. 
Maybe one last question. Should `z + zoo` result in `zoo`? I think that would be natural.