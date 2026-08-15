This is a  flaw in the _finger 5-item fingerprint:

>  Assign a 5-item fingerprint to each symbol in the equation:
    [
    # of times it appeared as a Symbol,
    # of times it appeared as a Not(symbol),
    # of times it appeared as a Symbol in an And or Or,
    # of times it appeared as a Not(Symbol) in an And or Or,
    sum of the number of arguments with which it appeared,
    counting Symbol as 1 and Not(Symbol) as 2
    ]

```
from sympy import *
from sympy.logic.boolalg import _finger
from pprint import pprint

A1,A2 = symbols('A1,A2')
a = _finger((A1 & A2) | (~A1 & ~A2))
b = _finger((A1 & ~A2) | (~A1 & A2))

pprint(a)
pprint(b)
```
results in identical fingerprints for A1 and A2:

```
defaultdict(<class 'list'>, {(0, 0, 1, 1, 6): [A1, A2]})
defaultdict(<class 'list'>, {(0, 0, 1, 1, 6): [A1, A2]})
```

which is why A1 and A2 appear interchangeable
I would like to work on it. I am doing a course on Digital Logic and Design. It's a great opportunity to apply here. :-)
I'm very interested in the origination of the _finger heuristic.  Is it some classically known method? or was it a hack in place of a more compute intensive truth-table or formal approach?

An escape like this would be TERRIBLE in a Logical Equivalence Checking tool for digital circuit design!  Keep me posted on your suggestion for an alternate solution.
GitHub history shows that it was introduced in https://github.com/sympy/sympy/pull/1619.
Formal equivalence checking looks like a fascinating topic: https://en.wikipedia.org/wiki/Formal_equivalence_checking
If I had time, I think it would be fun to implement something like BDD https://en.wikipedia.org/wiki/Binary_decision_diagram into sympy

> GitHub history shows that it was introduced in #1619.

Wow, it's been in there for 6 years, and nobody noticed it can't differentiate XOR/XNOR?
Trying to stay true to the idea presented in the docstring, I would make this change:

```diff
diff --git a/sympy/logic/boolalg.py b/sympy/logic/boolalg.py
index dfdec57..ce165fa 100644
--- a/sympy/logic/boolalg.py
+++ b/sympy/logic/boolalg.py
@@ -2024,8 +2024,9 @@ def _finger(eq):
     # of times it appeared as a Not(symbol),
     # of times it appeared as a Symbol in an And or Or,
     # of times it appeared as a Not(Symbol) in an And or Or,
-    sum of the number of arguments with which it appeared,
-    counting Symbol as 1 and Not(Symbol) as 2
+    sum of the number of arguments with which it appeared
+    as a Symbol, counting Symbol as 1 and Not(Symbol) as 2
+    and counting self as 1
     ]
 
     >>> from sympy.logic.boolalg import _finger as finger
@@ -2033,7 +2034,18 @@ def _finger(eq):
     >>> from sympy.abc import a, b, x, y
     >>> eq = Or(And(Not(y), a), And(Not(y), b), And(x, y))
     >>> dict(finger(eq))
-    {(0, 0, 1, 0, 2): [x], (0, 0, 1, 0, 3): [a, b], (0, 0, 1, 2, 8): [y]}
+    {(0, 0, 1, 0, 2): [x], (0, 0, 1, 0, 3): [a, b], (0, 0, 1, 2, 2): [y]}
+    >>> dict(finger(x & ~y))
+    {(0, 1, 0, 0, 0): [y], (1, 0, 0, 0, 0): [x]}
+
+    The equation must not have more than one level of nesting:
+
+    >>> dict(finger(And(Or(x, y), y)))
+    {(0, 0, 1, 0, 2): [x], (1, 0, 1, 0, 2): [y]}
+    >>> dict(finger(And(Or(x, And(a, x)), y)))
+    Traceback (most recent call last):
+    ...
+    NotImplementedError: unexpected level of nesting
 
     So y and x have unique fingerprints, but a and b do not.
     """
@@ -2050,9 +2062,10 @@ def _finger(eq):
                 if ai.is_Symbol:
                     d[ai][2] += 1
                     d[ai][-1] += o
-                else:
+                elif ai.is_Not:
                     d[ai.args[0]][3] += 1
-                    d[ai.args[0]][-1] += o
+                else:
+                    raise NotImplementedError('unexpected level of nesting')
     inv = defaultdict(list)
     for k, v in ordered(iter(d.items())):
         inv[tuple(v)].append(k)
@@ -2110,9 +2123,9 @@ def match(function1, function2):
 
         # do some quick checks
         if function1.__class__ != function2.__class__:
-            return None
+            return None  # maybe simplification would make them the same
         if len(function1.args) != len(function2.args):
-            return None
+            return None  # maybe simplification would make them the same
         if function1.is_Symbol:
             return {function1: function2}
 
@@ -2140,4 +2153,4 @@ def match(function1, function2):
     m = match(a, b)
     if m:
         return a, m
-    return m is not None
+    return m
diff --git a/sympy/logic/tests/test_boolalg.py b/sympy/logic/tests/test_boolalg.py
index 798da58..bb3d8c9 100644
--- a/sympy/logic/tests/test_boolalg.py
+++ b/sympy/logic/tests/test_boolalg.py
@@ -285,6 +285,7 @@ def test_bool_map():
     function2 = SOPform([a,b,c],[[1, 0, 1], [1, 0, 0]])
     assert bool_map(function1, function2) == \
         (function1, {y: a, z: b})
+    assert bool_map(Xor(x, y), ~Xor(x, y)) == False
 
 
 def test_bool_symbol():
```


> Is it some classically known method

The intent is not to check for digital equivalence, it is to detect when two expressions are structurally the same but having a different set of symbols. Two expressions should be able to pass this to be considered as a candidate for mapping:
```python
def match(a, b):
    if len(a.args) != len(b.args):
        return False
    if not isinstance(a, b.func) and not isinstance(b, a.func):
        return False
    return all(match(*z) for z in zip(*map(ordered, (a.args, b.args))))
```
There are methods like `dummy_eq` that do this for objects that create a single dummy symbol in the result, e.g. 
```
>>> Sum(x,(x,1,3)) == Sum(y,(y,1,3))
False
>>> Sum(x,(x,1,3)).dummy_eq(Sum(y,(y,1,3)))
True
>>>
```
but not every object has this implemented:
```
>>> Derivative(f(x),x) == Derivative(f(y),y)
False
>>> Derivative(f(x),x).dummy_eq(Derivative(f(y),y))
False
```