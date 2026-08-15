@smichr could you please comment on this issue?

Only saw this now. No good reason not to error:
```diff
diff --git a/sympy/combinatorics/permutations.py b/sympy/combinatorics/permutations.py
index 6d687c7..d5d652b 100644
--- a/sympy/combinatorics/permutations.py
+++ b/sympy/combinatorics/permutations.py
@@ -900,6 +900,9 @@ def __new__(cls, *args, **kwargs):
             if isinstance(a, Cycle):  # f
                 return cls._af_new(a.list(size))
             if not is_sequence(a):  # b
+                if size is not None and a + 1 > size:
+                    raise ValueError(
+                        'size is too small when max is %s' % a)
                 return cls._af_new(list(range(a + 1)))
             if has_variety(is_sequence(ai) for ai in a):
                 ok = False
@@ -929,10 +932,14 @@ def __new__(cls, *args, **kwargs):
             raise ValueError('there were repeated elements.')
         temp = set(temp)
 
-        if not is_cycle and \
-                any(i not in temp for i in range(len(temp))):
-            raise ValueError("Integers 0 through %s must be present." %
-                             max(temp))
+        if not is_cycle:
+            if any(i not in temp for i in range(len(temp))):
+                raise ValueError(
+                    "Integers 0 through %s must be present." %
+                    max(temp))
+            if size is not None and temp and max(temp) + 1 > size:
+                raise ValueError(
+                    'max element should not exceed %s' % (size - 1))
 
         if is_cycle:
             # it's not necessarily canonical so we won't store
diff --git a/sympy/combinatorics/tests/test_permutations.py b/sympy/combinatorics/tests/test_permutations.py
index 637e272..7b9ce1b 100644
--- a/sympy/combinatorics/tests/test_permutations.py
+++ b/sympy/combinatorics/tests/test_permutations.py
@@ -31,6 +31,9 @@ def test_Permutation():
     assert list(p) == list(range(4))
     assert Permutation(size=4) == Permutation(3)
     assert Permutation(Permutation(3), size=5) == Permutation(4)
+    # issue 11130
+    raises(ValueError, lambda: Permutation(3, size=3))
+    raises(ValueError, lambda: Permutation([1, 2, 0, 3], size=3))
     # cycle form with size
     assert Permutation([[1, 2]], size=4) == Permutation([[1, 2], [0], [3]])
     # random generation
```