But `sqrt(sin(3*pi/2)**2)` != `sin(3*pi/2)`, the former being 1 and the latter being -1.
Knowing that x is positive is not sufficient to guarantee that the result will be positive.
I didn't realize that force=True changes variables to positive.  I thought force=True should do the simplification regardless of the assumptions.
It's difficult to know what the valid rules should be with something like `force=True` since by definition it should break the normal mathematical rules.
Yes, that is difficult.  I should have read the documentation better, but it seems weird to me that force=True makes symbols positive instead of forcing the simplification.  I feel like force should just do it and deal with wrong results.

When solving an integral by trig substitution, I'd want to simplify `sqrt(sin(x)**2))` to `sin(x)`.  This is valid because I can assume x is in some appropriate domain like 0<x<pi.  However, I'm lazy and don't want to define assumptions.  Is there a way to force the simplification without assumptions?
You can use `replace` to do this, e.g.
```python
>>> eq=1/sqrt(sin(x)**2)
>>> eq.replace(lambda x: x.is_Pow and abs(x.exp) is S.Half and x.base.is_Pow
...   and x.base.exp == 2, lambda x: x.base.base**(x.exp*2))
1/sin(x)
```
or with Wild for the principle root
```
>>> w,y,z=symbols('w y z',cls=Wild)
>>> eq.replace(Pow(w**z, y/z), w**y)
1/sin(x)
```
Thanks!  Assumptions can be tricky.  Should `x/x` not reduce to 1 because we haven't specified that x is not 0?
> Should `x/x` not reduce to 1 because we haven't specified that x is not 0?

Technically, yes. And even if you say that x *is* zero it will reduce to 1 because the flattening routine does not check for the assumptions when making this simplification. I'm not sure how much it would slow things down to check assumptions...or how desirable would be the result.
It seems to me there has to be a balance between being technically correct and getting somewhere.  It's interesting that Sympy does some simplifications without checking assumptions, but not others.  Why does `logcombine` with `force=True` force the simplification but `powdenest` with `force=True` change symbols to positive?
> Why does `logcombine` with `force=True` force the simplification but `powdenest` with `force=True` change symbols to positive?

historical, simplicity, mathematical myopia (often by myself). A change to replace all non-symbol bases with dummies at the outset if the force flag is true would be an appropriate change, I think:

```diff
diff --git a/sympy/simplify/powsimp.py b/sympy/simplify/powsimp.py
index 280bd9e..6dc283b 100644
--- a/sympy/simplify/powsimp.py
+++ b/sympy/simplify/powsimp.py
@@ -577,8 +577,18 @@ def powdenest(eq, force=False, polar=False):
     from sympy.simplify.simplify import posify
 
     if force:
-        eq, rep = posify(eq)
-        return powdenest(eq, force=False).xreplace(rep)
+        def core_base(pow):
+          if not isinstance(pow, Pow):
+            return pow
+          return core_base(pow.base)
+        reps = {k: Dummy(positive=True) for k in [core_base(p) for p in eq.atoms(Pow)] if not k.is_positive is None}
+        if reps:
+            ireps = {v: k for k,v in reps.items()}
+            eq = eq.subs(reps)
+        else:
+            ireps = {}
+        eq, reps = posify(eq)
+        return powdenest(eq, force=False, polar=polar).xreplace(reps).xreplace(ireps)
 
     if polar:
         eq, rep = polarify(eq)
```

That passes current tests but gives
```python
>>> powdenest(sqrt(sin(x)**2),force=1)
Abs(sin(x))
```
> ```python
> >>> powdenest(sqrt(sin(x)**2),force=1)
> Abs(sin(x))
> ```

That's what I get on master:
```
In [1]: powdenest(sqrt(sin(x)**2),force=1)                                                                                                     
Out[1]: │sin(x)│
```
> That's what I get on master:

Hmm. I tried this several times under Windows and did not see this result. Will check again later.
Looks like a difference in how Function and Symbol are handled:
```python
>>> from sympy.abc import x
>>> f=Function('f', positive=1)
>>> sqrt(f(x)**2)
Abs(f(x))
>>> var('x', positive=1)
x
>>> sqrt((x)**2)
x
```
I see this with a vanilla symbol:
```python
>>> from sympy import *
>>> x = Symbol('x')
>>> powdenest(sqrt(sin(x)**2),force=1)
Abs(sin(x))
```
That's current master.
> I see this with a vanilla symbol:

yes, agreed. But a function and a symbol, both defined as positive, are being treated differently when taking `sqrt` of the same per example that I gave. That's an issue in itself and might fix this issue if it is fixed.
That's due to this
https://github.com/sympy/sympy/blob/35fe74cdd23f53a38c5b1f0ade556d49d4e98c66/sympy/functions/elementary/complexes.py#L524-L525
> That's due to this

I figured it was there somehow but didn't have time to sleuth. Nice find. This can be removed since functions can now carry assumptions.
An example from a gitter user: `(y**(1/(1 - alpha))**(1 - alpha)`. It should simplify if `y` is positive and `0 < alpha < 1`, but there's no way to tell powdenest the second assumption. It would be useful if force=True just did a structural replacement, ignoring the assumptions requirements. If the user does force=True, it is on them to verify the mathematical correctness of the replacement. 
A simple workaround is to manually denest with a pattern and `replace`:

```py
>>> expr = ((y**(1/(1 - alpha)))**(1 - alpha))
>>> a, b, c = Wild('a'), Wild('b'), Wild('c')
>>> expr.replace((a**b)**c, a**(b*c))
y
```
and while we are at it here is a more complicated example highlighting the same issue with exp()
```
from sympy import *
var("y, alpha, x, beta, delta",positive = True,real=True)
a, b, c, d, e, f = Wild('a'), Wild('b'), Wild('c'), Wild('d'), Wild('e'), Wild('f')
expr = (exp(delta/(1-alpha))*x**(beta/(1-alpha))*y**((1-beta)/(1-alpha)))**(1-alpha)

exp_trial = powdenest(expr, force=True)
exp_trial2 = simplify(expr, force=True)

tmp  = expr.replace((a*exp(b))**c, a**c*exp(b*c)).replace((a*b**c)**d, a**d*b**(c*d))
while tmp != expr:
    tmp = expr
    expr = expr.replace((a*b**c)**d, a**d*b**(c*d))
    expr = expr.replace((a*exp(b))**c, a**c*exp(b*c))
```

it would be great if powdenest and simplify could handle this case with force=True. for now I will resort to the while loop to iron out these cases.

this problem is quite relevant for economics where many problems have exponents (e.g. production functions: `y=a*k**alpha*l**(1-alpha)`). Using sympy to solve systems of equations of such nature would be great. for now I guess I will have to do manual solving by hand with the while loop. do you have any other ideas?