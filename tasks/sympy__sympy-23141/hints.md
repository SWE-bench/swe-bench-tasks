I think that this is an issue with some fragile implementation for treating list than a single expression
I'm not familiar with the stuff under the hood, but simply iterating over each individual expressions can be a temporary workaround.

```
polygon = Polygon(Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 0))
polys = [1, x, y, x*y, x**2*y, x*y**2]

for poly in polys:
    print(polytope_integrate(polygon, poly)) 
```
Thanks!
@oscarbenjamin I made some changes that fixes this and some related issues .

Current state of master -
```
>>> from sympy import *
>>> from sympy.integrals.intpoly import *
>>> polygon = Polygon(Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 0))
>>> polys =  [ 1,x, y, x*y, x**2*y, x*y**2]
>>> polytope_integrate(polygon, polys,max_degree = 3)
{1: 1, x: 1/2, y: 1/2, x*y: 1/4, x**2*y: 1/6, x*y**2: 1/6}
>>> polytope_integrate(polygon, polys,max_degree = 2)   # Only maximum degree is a valid input which doesn't make sense for user input.
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Users\kunni\sympy\sympy\sympy\integrals\intpoly.py", line 126, in polytope_integrate
    integral_value += result_dict[m] * coeff
KeyError: x**2*y
>>> polytope_integrate(polygon, polys)   # If maximum degree is not given all available degrees should be returned since max_degree is optional input.
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "C:\Users\kunni\sympy\sympy\sympy\integrals\intpoly.py", line 134, in polytope_integrate
    return main_integrate(expr, facets, hp_params)
  File "C:\Users\kunni\sympy\sympy\sympy\integrals\intpoly.py", line 302, in main_integrate
    value_over_boundary = integration_reduction(facets,
  File "C:\Users\kunni\sympy\sympy\sympy\integrals\intpoly.py", line 476, in integration_reduction
    expr = _sympify(expr)
  File "C:\Users\kunni\sympy\sympy\sympy\core\sympify.py", line 528, in _sympify
    return sympify(a, strict=True)
  File "C:\Users\kunni\sympy\sympy\sympy\core\sympify.py", line 449, in sympify
    raise SympifyError(a)
sympy.core.sympify.SympifyError: SympifyError: [1, x, y, x*y, x**2*y, x*y**2]
```

After the change -
```
>>> from sympy import *
>>> from sympy.integrals.intpoly import *
>>> polygon = Polygon(Point(0, 0), Point(0, 1), Point(1, 1), Point(1, 0))
>>> polys =  [ 1,x, y, x*y, x**2*y, x*y**2]
>>> polytope_integrate(polygon, polys)
{1: 1, x: 1/2, y: 1/2, x*y: 1/4, x**2*y: 1/6, x*y**2: 1/6}
>>> polytope_integrate(polygon, polys,max_degree=2)
{1: 1, x: 1/2, y: 1/2, x*y: 1/4}
>>> polytope_integrate(polygon, polys,max_degree =1)
{1: 1, x: 1/2, y: 1/2}
```
I was unsure of the diff so I have added it here ,do you suggest I open up a pr for the given issue ?

```
--- a/sympy/integrals/intpoly.py
+++ b/sympy/integrals/intpoly.py
@@ -100,6 +100,14 @@ def polytope_integrate(poly, expr=None, *, clockwise=False, max_degree=None):

     if max_degree is not None:
         result = {}
+        f_expr = []
+        for exp in expr:
+            if list((decompose(exp)).keys())[0] == 0:
+                f_expr.append(exp)
+            elif sum(degree_list(exp)) <= max_degree:
+                f_expr.append(exp)
+
+        expr = f_expr
         if not isinstance(expr, list) and expr is not None:
             raise TypeError('Input polynomials must be list of expressions')

@@ -294,21 +302,42 @@ def main_integrate(expr, facets, hp_params, max_degree=None):
                                 (b / norm(a)) / (dim_length + degree)
         return result
     else:
-        polynomials = decompose(expr)
-        for deg in polynomials:
-            poly_contribute = S.Zero
-            facet_count = 0
-            for hp in hp_params:
-                value_over_boundary = integration_reduction(facets,
-                                                            facet_count,
-                                                            hp[0], hp[1],
-                                                            polynomials[deg],
-                                                            dims, deg)
-                poly_contribute += value_over_boundary * (hp[1] / norm(hp[0]))
-                facet_count += 1
-            poly_contribute /= (dim_length + deg)
-            integral_value += poly_contribute
-    return integral_value
+        if not isinstance(expr,list):
+            polynomials = decompose(expr)
+            for deg in polynomials:
+                poly_contribute = S.Zero
+                facet_count = 0
+                for hp in hp_params:
+                    value_over_boundary = integration_reduction(facets,
+                                                                facet_count,
+                                                                hp[0], hp[1],
+                                                                polynomials[deg],
+                                                                dims, deg)
+                    poly_contribute += value_over_boundary * (hp[1] / norm(hp[0]))
+                    facet_count += 1
+                poly_contribute /= (dim_length + deg)
+                integral_value += poly_contribute
+
+            return integral_value
+        else:
+            result = {}
+            for polynomial in expr:
+                polynomials = decompose(polynomial)
+                for deg in polynomials:
+                    poly_contribute = S.Zero
+                    facet_count = 0
+                    for hp in hp_params:
+                        value_over_boundary = integration_reduction(facets,
+                                                                    facet_count,
+                                                                    hp[0], hp[1],
+                                                                    polynomials[deg],
+                                                                    dims, deg)
+                        poly_contribute += value_over_boundary * (hp[1] / norm(hp[0]))
+                        facet_count += 1
+                    poly_contribute /= (dim_length + deg)
+                    result.update({polynomials[deg] : poly_contribute})
+
+            return result
```
@oscarbenjamin All tests seem to pass ,I'll open a pr in some time if there are no particular doubts .Thanks !