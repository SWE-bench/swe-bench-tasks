Will this resolve it in all cases?
```
diff --git a/sympy/logic/boolalg.py b/sympy/logic/boolalg.py
index e95c655..00107f7 100644
--- a/sympy/logic/boolalg.py
+++ b/sympy/logic/boolalg.py
@@ -2358,13 +2358,13 @@ def _finger(eq):
     """
     Assign a 5-item fingerprint to each symbol in the equation:
     [
-    # of times it appeared as a Symbol,
-    # of times it appeared as a Not(symbol),
-    # of times it appeared as a Symbol in an And or Or,
-    # of times it appeared as a Not(Symbol) in an And or Or,
-    sum of the number of arguments with which it appeared
-    as a Symbol, counting Symbol as 1 and Not(Symbol) as 2
-    and counting self as 1
+    # of times it appeared as a Symbol;
+    # of times it appeared as a Not(symbol);
+    # of times it appeared as a Symbol in an And or Or;
+    # of times it appeared as a Not(Symbol) in an And or Or;
+    a sorted list of tuples (i,j) where i is the number of arguments
+    in an And or Or with which it appeared as a Symbol and j is
+    the number of arguments that were Not(Symbol)
     ]

     >>> from sympy.logic.boolalg import _finger as finger
@@ -2372,14 +2372,16 @@ def _finger(eq):
     >>> from sympy.abc import a, b, x, y
     >>> eq = Or(And(Not(y), a), And(Not(y), b), And(x, y))
     >>> dict(finger(eq))
-    {(0, 0, 1, 0, 2): [x], (0, 0, 1, 0, 3): [a, b], (0, 0, 1, 2, 2): [y]}
+    {(0, 0, 1, 0, ((2, 0),)): [x],
+    (0, 0, 1, 0, ((2, 1),)): [a, b],
+    (0, 0, 1, 2, ((2, 0),)): [y]}
     >>> dict(finger(x & ~y))
-    {(0, 1, 0, 0, 0): [y], (1, 0, 0, 0, 0): [x]}
+    {(0, 1, 0, 0, ()): [y], (1, 0, 0, 0, ()): [x]}

     The equation must not have more than one level of nesting:

     >>> dict(finger(And(Or(x, y), y)))
-    {(0, 0, 1, 0, 2): [x], (1, 0, 1, 0, 2): [y]}
+    {(0, 0, 1, 0, ((2, 0),)): [x], (1, 0, 1, 0, ((2, 0),)): [y]}
     >>> dict(finger(And(Or(x, And(a, x)), y)))
     Traceback (most recent call last):
     ...
@@ -2388,24 +2390,25 @@ def _finger(eq):
     So y and x have unique fingerprints, but a and b do not.
     """
     f = eq.free_symbols
-    d = dict(list(zip(f, [[0] * 5 for fi in f])))
+    d = dict(list(zip(f, [[0]*4 + [[]] for fi in f])))
     for a in eq.args:
         if a.is_Symbol:
             d[a][0] += 1
         elif a.is_Not:
             d[a.args[0]][1] += 1
         else:
-            o = len(a.args) + sum(isinstance(ai, Not) for ai in a.args)
+            o = len(a.args), sum(isinstance(ai, Not) for ai in a.args)
             for ai in a.args:
                 if ai.is_Symbol:
                     d[ai][2] += 1
-                    d[ai][-1] += o
+                    d[ai][-1].append(o)
                 elif ai.is_Not:
                     d[ai.args[0]][3] += 1
                 else:
                     raise NotImplementedError('unexpected level of nesting')
     inv = defaultdict(list)
     for k, v in ordered(iter(d.items())):
+        v[-1] = tuple(sorted(v[-1]))
         inv[tuple(v)].append(k)
     return inv
```
At least it does so for the cases you give:
```python
>>> f1 = Xor(*var('b:3'))
>>> f2 = ~Xor(*var('b:3'))
>>> bool_map(f1, f2)
False
>>> f1 = Xor(*var('b:4'))
>>> f2 = ~Xor(*var('b:4'))
>>> bool_map(f1, f2)
False
```