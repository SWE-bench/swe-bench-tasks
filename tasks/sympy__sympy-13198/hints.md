Oh, just another example why Float's are dangerous for CAS.

No issue if coefficients from the field of rationals:

``` python
In [29]: z_r = Rational(0.0001) * (x * (x + (Rational(4.0) * y))) + Rational(0.0001) * (y * (x + (Rational(4.0) * y)))

In [30]: w_r = expand(z_r); w_r
Out[30]: 
                  2                                              2 
7378697629483821⋅x     36893488147419105⋅x⋅y   7378697629483821⋅y  
──────────────────── + ───────────────────── + ────────────────────
73786976294838206464    73786976294838206464   18446744073709551616

In [31]: v_r = factor(w_r); v_r
Out[31]: 
7378697629483821⋅(x + y)⋅(x + 4⋅y)
──────────────────────────────────
       73786976294838206464       

In [32]: expand(v_r)
Out[32]: 
                  2                                              2 
7378697629483821⋅x     36893488147419105⋅x⋅y   7378697629483821⋅y  
──────────────────── + ───────────────────── + ────────────────────
73786976294838206464    73786976294838206464   18446744073709551616

In [33]: _.n()
Out[33]: 
        2                        2
0.0001⋅x  + 0.0005⋅x⋅y + 0.0004⋅y 
```

i would like to work on this

The `denom` is being mishandled. The following "fixes" the problem but I would have expected the solution to be `0.0001*(x + y)*(x + 4*y)`

```
10000.0*(0.0001*x + 0.0001*y)*(0.0001*x + 0.0004*y)
>>> ^Z


$ git diff
diff --git a/sympy/polys/factortools.py b/sympy/polys/factortools.py
index ce49142..81df7f8 100644
--- a/sympy/polys/factortools.py
+++ b/sympy/polys/factortools.py
@@ -1306,7 +1306,7 @@ def dmp_factor_list(f, u, K0):
                     f = dmp_convert(f, u, K0, K0_inexact)
                     factors[i] = (f, k)

-                coeff = K0_inexact.convert(coeff, K0)
+                coeff = K0_inexact.convert(coeff, K0)*denom
```

`factor()` seems to be the problem.

```python
>>> expr = (1.0*cos(q_2) + 0.5*cos(q_2 + q_3))**2*sin(q_1)**2 + (1.0*cos(q_2) + 0.5*cos(q_2 + q_3))**2*cos(q_1)**2 + 0.25*sin(q_1)**2*cos(q_2)**2 + 0.25*cos(q_1)**2*cos(q_2)**2
>>> expand(expr)
1.25*sin(q_1)**2*cos(q_2)**2 + 1.0*sin(q_1)**2*cos(q_2)*cos(q_2 + q_3) + 0.25*sin(q_1)**2*cos(q_2 + q_3)**2 + 1.25*cos(q_1)**2*cos(q_2)**2 + 1.0*cos(q_1)**2*cos(q_2)*cos(q_2 + q_3) + 0.25*cos(q_1)**2*cos(q_2 + q_3)**2
>>> expand(factor(expr))
0.3125*sin(q_1)**2*cos(q_2)**2 + 0.25*sin(q_1)**2*cos(q_2)*cos(q_2 + q_3) + 0.0625*sin(q_1)**2*cos(q_2 + q_3)**2 + 0.3125*cos(q_1)**2*cos(q_2)**2 + 0.25*cos(q_1)**2*cos(q_2)*cos(q_2 + q_3) + 0.0625*cos(q_1)**2*cos(q_2 + q_3)**2
```
I've been looking more through the issues, and there are also #12506 and #12140. Not sure if related, but both have to do with errors in simplify().