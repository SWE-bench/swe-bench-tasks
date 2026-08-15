Even `Range(n).sup` throws the same exception.
Here is a possible solution
```diff
diff --git a/sympy/sets/handlers/functions.py b/sympy/sets/handlers/functions.py
index d492bb9655..eb58eaa95b 100644
--- a/sympy/sets/handlers/functions.py
+++ b/sympy/sets/handlers/functions.py
@@ -148,11 +148,15 @@ def _set_function(f, x): # noqa:F811
 @dispatch(FunctionUnion, Range)  # type: ignore # noqa:F811
 def _set_function(f, self): # noqa:F811
     from sympy.core.function import expand_mul
-    if not self:
+    try:
+        n = self.size
+    except ValueError:
+        n = None
+    if n == 0:
         return S.EmptySet
     if not isinstance(f.expr, Expr):
         return
-    if self.size == 1:
+    if n == 1:
         return FiniteSet(f(self[0]))
     if f is S.IdentityFunction:
         return self
```
In Range(args), args only take values, I think it can take symbolic arguments only if start is also provided, here if you specified a value for "n" which is in Range(n) before the expression, it wouldn't give an error. @albertz, please verify @smichr 
I'm adding a picture for 
**when n is symbolic** and
![image](https://user-images.githubusercontent.com/73388412/120929756-e6741d80-c707-11eb-9f37-b6ee483306fa.png)
**when n is an integer**
![image](https://user-images.githubusercontent.com/73388412/120929786-0c012700-c708-11eb-834a-eada2efc2e19.png)

Having `size` raise an error like this just seems awkward e.g. even pretty printing is broken in isympy:
```python
In [14]: r = Range(n)

In [15]: r
Out[15]: ---------------------------------------------------------------------------
ValueError
...
~/current/sympy/sympy/sympy/sets/fancysets.py in size(self)
    759             return S.Infinity
    760         if not n.is_Integer or not all(i.is_integer for i in self.args):
--> 761             raise ValueError('invalid method for symbolic range')
    762         return abs(n)
    763 

ValueError: invalid method for symbolic range
```
It could just return `n` so why does that raise an exception in the first place?

If there are good reasons for `.size` to raise an exception then there should be another method for getting the symbolic size.

It would be better to have an explicit check rather than catching an exception e.g.:
```python
if not r.size.is_Integer:
    return
```
Not setting any assumptions on n gives the (actually slightly better):
`ValueError: cannot tell if Range is null or not`

With `n = Symbol('n', positive=True, integer=True)` we still get
`ValueError: invalid method for symbolic range`

What about changing `n.is_Integer` to `n.is_integer` on line 760, possibly with the addition of `n.is_positive` or `n.is_nonnegative`?

That will produce: `ImageSet(Lambda(x, 2*x), Range(0, n, 1))` or 
![image](https://user-images.githubusercontent.com/8114497/130431956-bf352bb4-0ee4-43e3-b44f-9adf280e14d0.png)
(assuming the assumption that n is an integer, an error message may be crafted to tell the problem when it is not)

(Better printing of Range is an option here...)

Not sure if it will break anything else though.