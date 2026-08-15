```diff
diff --git a/sympy/solvers/diophantine.py b/sympy/solvers/diophantine.py
index 6092e35..b43f5c1 100644
--- a/sympy/solvers/diophantine.py
+++ b/sympy/solvers/diophantine.py
@@ -182,7 +182,7 @@ def diophantine(eq, param=symbols("t", integer=True), syms=None,
             if syms != var:
                 dict_sym_index = dict(zip(syms, range(len(syms))))
                 return {tuple([t[dict_sym_index[i]] for i in var])
-                            for t in diophantine(eq, param)}
+                            for t in diophantine(eq, param, permute=permute)}
         n, d = eq.as_numer_denom()
         if n.is_number:
             return set()
```
Based on a cursory glance at the code it seems that `permute=True` is lost when `diophantine` calls itself:
https://github.com/sympy/sympy/blob/d98abf000b189d4807c6f67307ebda47abb997f8/sympy/solvers/diophantine.py#L182-L185.
That should be easy to solve; I'll include a fix in my next PR (which is related).
Ah, ninja'd by @smichr :-)
```diff
diff --git a/sympy/solvers/diophantine.py b/sympy/solvers/diophantine.py
index 6092e35..b43f5c1 100644
--- a/sympy/solvers/diophantine.py
+++ b/sympy/solvers/diophantine.py
@@ -182,7 +182,7 @@ def diophantine(eq, param=symbols("t", integer=True), syms=None,
             if syms != var:
                 dict_sym_index = dict(zip(syms, range(len(syms))))
                 return {tuple([t[dict_sym_index[i]] for i in var])
-                            for t in diophantine(eq, param)}
+                            for t in diophantine(eq, param, permute=permute)}
         n, d = eq.as_numer_denom()
         if n.is_number:
             return set()
```
Based on a cursory glance at the code it seems that `permute=True` is lost when `diophantine` calls itself:
https://github.com/sympy/sympy/blob/d98abf000b189d4807c6f67307ebda47abb997f8/sympy/solvers/diophantine.py#L182-L185.
That should be easy to solve; I'll include a fix in my next PR (which is related).
Ah, ninja'd by @smichr :-)