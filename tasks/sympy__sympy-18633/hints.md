I thought this was fixed in be4c2b1daebfe267bf5414922ad8bcbcf315a325 but you are right. A diff that passes tensor tests is:
```diff
diff --git a/sympy/tensor/tests/test_tensor_operators.py b/sympy/tensor/tests/test_tensor_operators.py
index e2f3447..2aacc3c 100644
--- a/sympy/tensor/tests/test_tensor_operators.py
+++ b/sympy/tensor/tests/test_tensor_operators.py
@@ -230,6 +230,9 @@ def test_expand_partial_derivative_full_linearity():

     # check full linearity

+    p = PartialDerivative(42, D(j))
+    assert p and not p._expand_partial_derivative()
+
     expr3a = PartialDerivative(nneg*A(i) + pos*B(i), D(j))
     assert expr3a._expand_partial_derivative() ==\
         nneg*PartialDerivative(A(i), D(j))\
diff --git a/sympy/tensor/toperators.py b/sympy/tensor/toperators.py
index 40702bf..18a23e5 100644
--- a/sympy/tensor/toperators.py
+++ b/sympy/tensor/toperators.py
@@ -74,7 +74,7 @@ def _contract_indices_for_derivative(cls, expr, variables):
                 variables_opposite_valence.append(i)

         args, indices, free, dum = TensMul._tensMul_contract_indices(
-            [expr] + variables_opposite_valence, replace_indices=True)
+            [S(expr)] + variables_opposite_valence, replace_indices=True)

         for i in range(1, len(args)):
             args_i = args[i]
@@ -104,7 +104,9 @@ def _expand_partial_derivative(self):

         result = obj

-        if isinstance(obj.expr, TensAdd):
+        if not args[0].free_symbols:
+            return S.Zero
+        elif isinstance(obj.expr, TensAdd):
             # take care of sums of multi PDs
             result = obj.expr.func(*[
                     self.func(a, *obj.variables)._expand_partial_derivative()
```
I am working on this issue.