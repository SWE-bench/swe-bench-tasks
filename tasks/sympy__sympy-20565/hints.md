Under the assumptions system, Float.is_rational intentionally gives None. I think the sets should follow the same strict rules. The issue is that while it is true that floating point numbers are represented by a rational number, they are not rational numbers in the sense that they do not follow the behavior of rational numbers. 

IMO this should be "wont fix". 
If `Float.is_rational` gives `None` then I would expect `Rational.contains` to give something like an unevaluated `Contains` rather than `False`.

The way I would see this is that a Float represents a number that is only known approximately. The precise internal representation is always rational but we think of it as representing some true number that lies in an interval around that rational number. On that basis we don't know if it is really rational or not because irrational numbers are always arbitrarily close to any rational number. On that reasoning it makes sense that `is_rational` gives `None` because neither `True` or `False` are known to be correct. Following the same reasoning `Rational.contains` should also be indeterminate rather than `False`.
I naïvely thought that this was simply a bug. Thanks @asmeurer and @oscarbenjamin for your insights. There are three cases then for the result of the `Rational.contains`.

1. False (the current result)

I would still argue that this is wrong. False means that a float is not rational. This would mean that it is either irrational or complex. I think we could rule out a float being complex so then it has to be irrational. I believe that this is clearly not true.

2. Indeterminate

The arguments given above for this are pretty strong and I think this is better than option 1. Indeterminate would mean that it is unknown whether it is rational or irrational. Given the argument from @oscarbenjamin that a float represents an approximation of an underlying number it is clear that we don't know if it is irrational or rational.

3. True

If we instead see the float as the actual exact number instead of it being an approximation of another underlying number it would make most sense to say that all floats are rationals. It is indeed impossible to represent any irrational number as a float. In my example the 0.5 meant, at least to me, the exact number 0.5, i.e. one half, which is clearly rational. It also doesn't feel useful to keep it as unresolved or indeterminate because no amount of additional information could ever resolve this. Like in this example:

```python
import sympy

x = sympy.Symbol('x')
expr = sympy.Rationals.contains(x)
# expr = Contains(x, Rationals)
expr.subs({x: 1})
sympy.Rationals.contains(x)
# True
```

I  would argue that option 3 is the best option and that option 2 is better than option 1.
> In my example the 0.5 meant, at least to me, the exact number 0.5, i.e. one half

This is a fundamental conceptual problem in sympy. Most users who use floats do not intend for them to have the effect that they have.
I found an argument for the current False result:

If we see a float as an approximation of an underlying real number it could make sense to say that a float is (at least most likely) irrational since most real numbers are irrational. So it turns out that cases could be made for all three options.

I agree with the last comment from @oscarbenjamin. A float does not behave as you think.

I guess we could close this issue if not someone else thinks that `True` or `Indeterminate` would be better options. I am not so certain any longer.
I think that at least the results for `is_rational` and `contains` are inconsistent so there is an issue here in any case.
I can work on making `contains` and `is_rational` both indeterminate. I think that could be a good first step for conformity and then the community can continue the discussion on the underlying assumption.
I think that the fix is just:
```diff
diff --git a/sympy/sets/fancysets.py b/sympy/sets/fancysets.py
index 844c9ee9c1..295e2e7e7c 100644
--- a/sympy/sets/fancysets.py
+++ b/sympy/sets/fancysets.py
@@ -42,8 +42,6 @@ class Rationals(Set, metaclass=Singleton):
     def _contains(self, other):
         if not isinstance(other, Expr):
             return False
-        if other.is_Number:
-            return other.is_Rational
         return other.is_rational
 
     def __iter__(self):
```
There is at least one test in sets that would need to be updated though.
When comparing sympy thinks that 0.5 and 1/2 are equal.

```python
> sympy.Eq(sympy.Rational(1, 2), 0.5)
True
```

To be consistent this should also be indeterminate. Or by letting floats be rational.
There's discussion about this at #20033, but to be sure, `==` in SymPy means strict structural equality, not mathematical equality. So it shouldn't necessarily match the semantics here. Eq is more mathematical so there is perhaps a stronger argument to make it unevaluated. 