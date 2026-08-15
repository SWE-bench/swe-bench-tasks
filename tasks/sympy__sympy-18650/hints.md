```
>>> from sympy import sqrt, Rational, Pow
>>> sqrt(8, evaluate=False)**Rational(2, 3)
2
>>> p = Pow(8, Rational(1,2), evaluate=False)
>>> p.args
(8, 1/2)
>>> p = Pow(8, Rational(1,2))
>>> p.args
(2, sqrt(2))
```
I think it is because of `evaluate=False` which should be used in `as_base_exp(self)` to calculate `b, e`.
```
--- a/sympy/functions/elementary/miscellaneous.py
+++ b/sympy/functions/elementary/miscellaneous.py
@@ -56,7 +56,7 @@ def __new__(cls):
 ###############################################################################
 
 
-def sqrt(arg, evaluate=None):
+def sqrt(arg, evaluate=False):
     """Returns the principal square root.
 
     Parameters

```
This returns correct result
sqrt(8) does return `2*sqrt(2)`, but it should work even for `(2*sqrt(2))**Rational(2, 3)`. The core has an algorithm that simplifies products of rational powers of rational numbers that isn't being applied correctly here. 
```
>>> sqrt(8)**Rational(2, 3)
2**(1/3)*2**(2/3)
>>> powsimp(_)
2
```

> that isn't being applied correctly here.

or that isn't being applied ~correctly~ here. In `Mul._eval_power` this is not a special case of `b**(x/2)` so it is passed for power-base *expansion*. The reconstruction of commutative args `cargs` uses unevaluated `Pow(b,e, evaluate=False)` to reconstruct factors and then they are not recognized during Mul flattening as being able to combine.

This passes core without recursion errors:
```diff
diff --git a/sympy/core/power.py b/sympy/core/power.py
index dcdbf63..57544fe 100644
--- a/sympy/core/power.py
+++ b/sympy/core/power.py
@@ -1037,6 +1037,11 @@ def pred(x):
 
         rv = S.One
         if cargs:
+            if e.is_Rational:
+                npow, cargs = sift(cargs, lambda x: x.is_Pow and
+                    x.exp.is_Rational and x.base.is_number,
+                    binary=True)
+                rv = Mul(*[self.func(b.func(*b.args), e) for b in npow])
             rv *= Mul(*[self.func(b, e, evaluate=False) for b in cargs])
         if other:
             rv *= self.func(Mul(*other), e, evaluate=False)
diff --git a/sympy/core/tests/test_arit.py b/sympy/core/tests/test_arit.py
index 807048d..6b05362 100644
--- a/sympy/core/tests/test_arit.py
+++ b/sympy/core/tests/test_arit.py
@@ -1458,11 +1458,12 @@ def test_Pow_as_coeff_mul_doesnt_expand():
     assert exp(x + exp(x + y)) != exp(x + exp(x)*exp(y))
 
 
-def test_issue_3514():
+def test_issue_3514_18626():
     assert sqrt(S.Half) * sqrt(6) == 2 * sqrt(3)/2
     assert S.Half*sqrt(6)*sqrt(2) == sqrt(3)
     assert sqrt(6)/2*sqrt(2) == sqrt(3)
     assert sqrt(6)*sqrt(2)/2 == sqrt(3)
+    assert sqrt(8)**Rational(2, 3) == 2
 
 
 def test_make_args():
```
I'm having a weird situation: I edit `test_evaluate.py` but the edits don't show up in the git diff. Any ideas why this might be, @asmeurer ?

This test fails locally
```python
assert 10.333 * (S(1) / 2) == Mul(10.333, 2**-1)
```
I think it should be
```python
assert 10.333 * (S(1) / 2) == Mul(10.333, S(2)**-1)
```
When I run the tests they pass with this change but...the diff is not showing up.
The following also show as XPASSing in master:
```
________________________________ xpassed tests ____________
sympy\core\tests\test_arit.py: test_issue_3531
sympy\core\tests\test_arit.py: test_failing_Mod_Pow_nested
```
I think test_evaluate.py is some file that you have that isn't in master. I don't see it in the repo.
> The reconstruction of commutative args cargs uses unevaluated Pow(b,e, evaluate=False) to reconstruct factors and then they are not recognized during Mul flattening as being able to combine.

Why does it use evaluate=False? 
> Why does it use evaluate=False?

to avoid recursion errors. I didn't investigate deeply; I recall having these sort of issues in the past.

Ahh. `test_evaluate` was renamed in `8a0c402f71a1e91bc99f8fc91bb54cdd792c5be8`. I saw it in gitk but didn't notice the note indicating the rename.
`git clean -n` to the rescue. Thanks, @asmeurer 
Always having a local checkout with no untracked files has advantages, although I personally can't manage it myself with sympy because I have so many untracked scratch files. If you use the git prompt that comes with git it uses % at the end to indicate untracked files and you can choose to be aggressive about removing those with `git clean`.
@smichr are you of the opinion that this should auto-evaluate or not? I thought that Mul and Pow always fully canonicalized rational powers of rational numbers. But maybe what really happens is that they are split but not always necessarily combined.  
I tend to think it should. When Pow passes to Mul for the power-base expansion it isn't expecting that there would be things that will combine. The diff suggested allows numerical factors to reevaluate so they can be combined during Mul flattening.