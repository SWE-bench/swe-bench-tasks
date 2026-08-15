I don't think that `minpoly` can be expected to work reliably with expressions that contain Floats (`RR` is not "exact"). They could be first replaced by Rationals`. Maybe `minpoly` should do that automatically.
It isn't supposed to have floats. I messed up getting the srepr. This is it:
```
res = Add(Mul(Integer(-1), Integer(280898097948878450887044002323982963174671632174995451265117559518123750720061943079105185551006003416773064305074191140286225850817291393988597615), Pow(Add(Mul(Integer(-1), Integer(488144716373031204149459129212782509078221364279079444636386844223983756114492222145074506571622290776245390771587888364089507840000000), Pow(Integer(238368341569), Rational(1, 2)), Pow(Add(Rational(11918417078450, 63568729), Mul(Integer(-1), Rational(24411360, 63568729), Pow(Integer(238368341569), Rational(1, 2)))), Rational(1, 2))), Mul(Integer(238326799225996604451373809274348704114327860564921529846705817404208077866956345381951726531296652901169111729944612727047670549086208000000), Pow(Add(Rational(11918417078450, 63568729), Mul(Integer(-1), Rational(24411360, 63568729), Pow(Integer(238368341569), Rational(1, 2)))), Rational(1, 2)))), Integer(-1))), Mul(Integer(-1), Integer(180561807339168676696180573852937120123827201075968945871075967679148461189459480842956689723484024031016208588658753107), Pow(Add(Mul(Integer(-1), Integer(59358007109636562851035004992802812513575019937126272896569856090962677491318275291141463850327474176000000), Pow(Integer(238368341569), Rational(1, 2)), Pow(Add(Rational(11918417078450, 63568729), Mul(Integer(-1), Rational(24411360, 63568729), Pow(Integer(238368341569), Rational(1, 2)))), Rational(1, 2))), Mul(Integer(28980348180319251787320809875930301310576055074938369007463004788921613896002936637780993064387310446267596800000), Pow(Add(Rational(11918417078450, 63568729), Mul(Integer(-1), Rational(24411360, 63568729), Pow(Integer(238368341569), Rational(1, 2)))), Rational(1, 2)))), Integer(-1))))
```
That gives
```julia
In [7]: res.is_algebraic                                                                                               
Out[7]: True

In [8]: minpoly(res)                                                                                                   
---------------------------------------------------------------------------
NotImplementedError                       Traceback (most recent call last)
<ipython-input-8-a3b1550cf0cb> in <module>
----> 1 minpoly(res)

~/current/sympy/sympy/sympy/polys/numberfields.py in minimal_polynomial(ex, x, compose, polys, domain)
    670 
    671     if compose:
--> 672         result = _minpoly_compose(ex, x, domain)
    673         result = result.primitive()[1]
    674         c = result.coeff(x**degree(result, x))

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_compose(ex, x, dom)
    549 
    550     if ex.is_Add:
--> 551         res = _minpoly_add(x, dom, *ex.args)
    552     elif ex.is_Mul:
    553         f = Factors(ex).factors

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_add(x, dom, *a)
    361     returns ``minpoly(Add(*a), dom, x)``
    362     """
--> 363     mp = _minpoly_op_algebraic_element(Add, a[0], a[1], x, dom)
    364     p = a[0] + a[1]
    365     for px in a[2:]:

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_op_algebraic_element(op, ex1, ex2, x, dom, mp1, mp2)
    241     y = Dummy(str(x))
    242     if mp1 is None:
--> 243         mp1 = _minpoly_compose(ex1, x, dom)
    244     if mp2 is None:
    245         mp2 = _minpoly_compose(ex2, y, dom)

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_compose(ex, x, dom)
    562             nums = [base**(y.p*lcmdens // y.q) for base, y in r1.items()]
    563             ex2 = Mul(*nums)
--> 564             mp1 = minimal_polynomial(ex1, x)
    565             # use the fact that in SymPy canonicalization products of integers
    566             # raised to rational powers are organized in relatively prime

~/current/sympy/sympy/sympy/polys/numberfields.py in minimal_polynomial(ex, x, compose, polys, domain)
    670 
    671     if compose:
--> 672         result = _minpoly_compose(ex, x, domain)
    673         result = result.primitive()[1]
    674         c = result.coeff(x**degree(result, x))

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_compose(ex, x, dom)
    574             res = _minpoly_mul(x, dom, *ex.args)
    575     elif ex.is_Pow:
--> 576         res = _minpoly_pow(ex.base, ex.exp, x, dom)
    577     elif ex.__class__ is sin:
    578         res = _minpoly_sin(ex, x)

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_pow(ex, pw, x, dom, mp)
    336     pw = sympify(pw)
    337     if not mp:
--> 338         mp = _minpoly_compose(ex, x, dom)
    339     if not pw.is_rational:
    340         raise NotAlgebraic("%s doesn't seem to be an algebraic element" % ex)

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_compose(ex, x, dom)
    549 
    550     if ex.is_Add:
--> 551         res = _minpoly_add(x, dom, *ex.args)
    552     elif ex.is_Mul:
    553         f = Factors(ex).factors

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_add(x, dom, *a)
    361     returns ``minpoly(Add(*a), dom, x)``
    362     """
--> 363     mp = _minpoly_op_algebraic_element(Add, a[0], a[1], x, dom)
    364     p = a[0] + a[1]
    365     for px in a[2:]:

~/current/sympy/sympy/sympy/polys/numberfields.py in _minpoly_op_algebraic_element(op, ex1, ex2, x, dom, mp1, mp2)
    278     r = Poly(r, x, domain=dom)
    279     _, factors = r.factor_list()
--> 280     res = _choose_factor(factors, x, op(ex1, ex2), dom)
    281     return res.as_expr()
    282 

~/current/sympy/sympy/sympy/polys/numberfields.py in _choose_factor(factors, x, v, dom, prec, bound)
     79             prec1 *= 2
     80 
---> 81     raise NotImplementedError("multiple candidates for the minimal polynomial of %s" % v)
     82 
     83 

NotImplementedError: multiple candidates for the minimal polynomial of -488144716373031204149459129212782509078221364279079444636386844223983756114492222145074506571622290776245390771587888364089507840000000*sqrt(238368341569)*sqrt(11918417078450/63568729 - 24411360*sqrt(238368341569)/63568729) + 238326799225996604451373809274348704114327860564921529846705817404208077866956345381951726531296652901169111729944612727047670549086208000000*sqrt(11918417078450/63568729 - 24411360*sqrt(238368341569)/63568729)
```
Computing the minimal polynomial using Groebner bases gives a result:
```python
>>> p_groebner = minpoly(res, compose=False)
```
but it seems to be incorrect:
```python
>>> N(res)
-1.63818039957219e+39
>>> list(map(N, real_roots(p_groebner)))
[-27221879386.9438, -6.30292221711154e-16, 6.30292221711154e-16, 27221879386.9438]
```
Extending the precision of `_choose_factor` in `sympy/polys/numberfields.py` from `200` to `2000`

```python
[...]
def _choose_factor(factors, x, v, dom=QQ, prec=2000, bound=5):
[...]
```
makes the default method work:

```python
>>> p_compose = minpoly(res)
>>> list(map(N, real_roots(p_compose)))
[-1.63818039957219e+39, -6049.70941983707, 6049.70941983707, 1.63818039957219e+39]
>>> N(res)
-1.63818039957219e+39
```
The problem is in the `_choose_factor` function:
https://github.com/sympy/sympy/blob/fe44a9396123e7fbfa1401da5e9384ca073272be/sympy/polys/numberfields.py#L46

This loop exits because the precision gets too large:
https://github.com/sympy/sympy/blob/fe44a9396123e7fbfa1401da5e9384ca073272be/sympy/polys/numberfields.py#L67-L81

At the point when it fails we have:
```
ipdb> f.as_expr().evalf(2, points)                                                                                     
-2.2e+511
ipdb> float(eps)                                                                                                       
1e-160
ipdb> p prec1                                                                                                          
320
ipdb> p prec                                                                                                           
200
```
The loop is trying to distinguish which of the polynomials in factors has the value from points as a root:
```
ipdb> factors[0].as_expr().evalf(20, points)                                                                           
-0.e+361
ipdb> factors[1].as_expr().evalf(20, points)                                                                           
4.5659786618091374483e+572
ipdb> factors[2].as_expr().evalf(20, points)                                                                           
4.5067149186395800394e+572
ipdb> factors[3].as_expr().evalf(20, points)                                                                           
2.5048552185864658024e+501
```
The problem is that we need to use about 600 digits of precision to say that `factors[1,2,3]` are giving non-zero.

With this diff
```diff
diff --git a/sympy/polys/numberfields.py b/sympy/polys/numberfields.py
index d10f04eb1e..885034d0c0 100644
--- a/sympy/polys/numberfields.py
+++ b/sympy/polys/numberfields.py
@@ -43,7 +43,7 @@
 
 
 
-def _choose_factor(factors, x, v, dom=QQ, prec=200, bound=5):
+def _choose_factor(factors, x, v, dom=QQ, prec=1000, bound=5):
     """
     Return a factor having root ``v``
     It is assumed that one of the factors has root ``v``.
```
we can get
```julia
In [9]: p = minpoly(res, x)                                                                                            

In [10]: p.subs(x, res).simplify()                                                                                     
Out[10]: 0
```
Obviously there needs to be some limit on the precision though so maybe there could be a better way...
> Obviously there needs to be some limit on the precision

why? under appropriate assumptions (maybe fulfilled when trying to compute a minimal polynomial?) there should be only one factor vanishing at the given value. But if the precision limit is really needed, it should be added as a parameter to the function `minimal_polynomial`, I think.

btw: i do not understand the role of the parameter `bound`. Could there be situations when the default value of `5` is not sufficient?
There needs to be a limit on the precision because otherwise the calculation can become very expensive or can hit an infinite loop.

Actually though I wonder why `eps` needs to be so small. Generally if evalf can compute 2 digits of precision then it can tell you whether something that is non-zero is non-zero. If `evalf(2)` incorrectly gives a non-zero result with precision then that's a bug in evalf that should be fixed.

Maybe I've misunderstood the intent of the algorithm...

> Could there be situations when the default value of `5` is not sufficient?

Not sure. I haven't looked at this code before...
This seems to work:
```diff
diff --git a/sympy/polys/numberfields.py b/sympy/polys/numberfields.py
index d10f04eb1e..d37f98a522 100644
--- a/sympy/polys/numberfields.py
+++ b/sympy/polys/numberfields.py
@@ -58,25 +58,21 @@ def _choose_factor(factors, x, v, dom=QQ, prec=200, bound=5):
     t = QQ(1, 10)
 
     for n in range(bound**len(symbols)):
-        prec1 = 10
         n_temp = n
         for s in symbols:
             points[s] = n_temp % bound
             n_temp = n_temp // bound
 
-        while True:
-            candidates = []
-            eps = t**(prec1 // 2)
-            for f in factors:
-                if abs(f.as_expr().evalf(prec1, points)) < eps:
-                    candidates.append(f)
-            if candidates:
-                factors = candidates
-            if len(factors) == 1:
-                return factors[0]
-            if prec1 > prec:
-                break
-            prec1 *= 2
+        def nonzero(f):
+            n10 = abs(f.as_expr()).evalf(10, points)
+            if n10._prec > 1:
+                return n10 > 0
+
+        candidates = [f for f in factors if not nonzero(f)]
+        if candidates:
+            factors = candidates
+        if len(factors) == 1:
+            return factors[0]
```
It should be possible to use `.evalf(2, ...)`. The fact that that doesn't work indicates a bug in evalf somewhere.
That looks good. The use of fixed `eps` does not make sense as it does not scale with the coefficients of `factors` and the root. I'm not sure under which conditions `_prec` will be 1 but it seems to be a good indication of a very small result.
>        def nonzero(f):
>            n10 = abs(f.as_expr()).evalf(10, points)
>            if n10._prec > 1:
>                return n10 > 0

Is the missing return value intended if `n10._prec > 1` does not hold?

The parameter `prec` of `_choose_factor` is obsolete then. (It is never used inside numberfields.py)
> Is the missing return value intended if `n10._prec > 1` does not hold?

It is. Perhaps it could be set explicitly to `return False` but this works anyway because `None` is falsey.

> The parameter `prec` of `_choose_factor` is obsolete then. (It is never used inside numberfields.py)

Perhaps it could be set to 10 and used by `evalf`.

> I'm not sure under which conditions `_prec` will be 1 but it seems to be a good indication of a very small result.

We can get `_prec=1` from evalf for an expression that is identically zero:

```julia
In [11]: z = cos(1)**2 + sin(1)**2 - 1

In [12]: z.evalf()
Out[12]: -0.e-124

In [13]: z.evalf()._prec
Out[13]: 1
```

I think a `_prec` of 1 basically means no correct digits.
> > Is the missing return value intended if `n10._prec > 1` does not hold?
> 
> It is. Perhaps it could be set explicitly to `return False` but this works anyway because `None` is falsey.

In that case I would propose the following implementation:

    def nonzero(f):
      n10 = abs(f.as_expr()).evalf(10, points)
      return n10._prec > 1 and n10 > 0
