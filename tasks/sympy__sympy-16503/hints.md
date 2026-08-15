```
>>> pprint(Sum(x**2, (x, 1, oo)) + 3)
 ∞         
 ___        
 ╲          
  ╲    2    
  ╱   x  + 3
 ╱          
 ‾‾‾        
x = 1
```
This works well. So, I suppose that `x`, in the above case should be lower.
Could you tell me, how I can correct it?
The issue might be with the way adjustments are calculated, and this definitely works for simpler expressions:
```diff
diff --git a/sympy/printing/pretty/pretty.py b/sympy/printing/pretty/pretty.py
index 7a3de3352..07198bea4 100644
--- a/sympy/printing/pretty/pretty.py
+++ b/sympy/printing/pretty/pretty.py
@@ -575,7 +575,7 @@ def adjust(s, wid=None, how='<^>'):
                 for i in reversed(range(0, d)):
                     lines.append('%s%s%s' % (' '*i, vsum[4], ' '*(w - i - 1)))
                 lines.append(vsum[8]*(w))
-                return d, h + 2*more, lines, more
+                return d, h + 2*more, lines, more // 2
 
         f = expr.function
```
as in
```python
>>> pprint(Sum(x ** n, (n, 1, oo)) + x)
      ∞     
     ___    
     ╲      
      ╲    n
x +   ╱   x 
     ╱      
     ‾‾‾    
    n = 1   

>>> pprint(Sum(n, (n, 1, oo)) + x)
      ∞    
     ___   
     ╲     
      ╲    
x +   ╱   n
     ╱     
     ‾‾‾   
    n = 1   
```

but this leads to test failures for more complex expressions. However, many of the tests look like they expect the misaligned sum.
The ascii printer also has this issue:
```
In [1]: pprint(x + Sum(x + Integral(x**2 + x + 1, (x, 0, n)), (n, 1, oo)), use_unicode=False)
       oo                            
    ______                           
    \     `                          
     \      /      n                \
      \     |      /                |
       \    |     |                 |
x +     \   |     |  / 2        \   |
        /   |x +  |  \x  + x + 1/ dx|
       /    |     |                 |
      /     |    /                  |
     /      \    0                  /
    /_____,                          
     n = 1                           

```