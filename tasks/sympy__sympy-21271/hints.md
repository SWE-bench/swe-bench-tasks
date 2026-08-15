I can fix this. I want to work on this issue.

I think I found a fix  , if I succeed I'll make a PR.
@sidhu1012 What do you think the issue is?
It's worth noting that this passes:

```
bin/doctest sympy/physics/vector/functions.py sympy/physics/vector/frame.py
```

and this fails:

```
bin/doctest sympy/physics/vector/dyadic.py sympy/physics/vector/frame.py
```

So it depends on what your run before frame.py.

EDIT: If the other modules happen to run before frame.py.
I tried this script which adds the doctests from dyadic.py in front of the doctests from `orient_space_fixed` and it passes. I'm not sure what bin/doctest does different.

```python
import sympy as sm
import sympy.physics.mechanics as me

# code from dyadic.py's doctests
N = me.ReferenceFrame('N')
D1 = me.outer(N.x, N.y)
D2 = me.outer(N.y, N.y)
D1.dot(D2)
D1.dot(N.y)
5*D1
me.cross(N.y, D2)
q = me.dynamicsymbols('q')
B = N.orientnew('B', 'Axis', [q, N.z])
d = me.outer(N.x, N.x)
d.express(B, N)
Ixx, Iyy, Izz, Ixy, Iyz, Ixz = sm.symbols('Ixx, Iyy, Izz, Ixy, Iyz, Ixz')
N = me.ReferenceFrame('N')
inertia_dyadic = me.inertia(N, Ixx, Iyy, Izz, Ixy, Iyz, Ixz)
inertia_dyadic.to_matrix(N)
beta = sm.symbols('beta')
A = N.orientnew('A', 'Axis', (beta, N.x))
inertia_dyadic.to_matrix(A)
B = N.orientnew('B', 'Axis', [q, N.z])
d = me.outer(N.x, N.x)
d.dt(B)
s = sm.Symbol('s')
a = s*me.outer(N.x, N.x)
a.subs({s: 2})
D = me.outer(N.x, N.x)
x, y, z = sm.symbols('x y z')
((1 + x*y) * D).xreplace({x: sm.pi})
((1 + x*y) * D).xreplace({x: sm.pi, y: 2})
((x*y + z) * D).xreplace({x*y: sm.pi})
((x*y*z) * D).xreplace({x*y: sm.pi})


# failing doctest from orient_space_fixed()
q1, q2, q3 = sm.symbols('q1, q2, q3')

N = me.ReferenceFrame('N')
B = me.ReferenceFrame('B')
B.orient_space_fixed(N, (q1, q2, q3), '312')
expected = B.dcm(N)

N2 = me.ReferenceFrame('N2')
B1 = me.ReferenceFrame('B1')
B2 = me.ReferenceFrame('B2')
B3 = me.ReferenceFrame('B3')

B1.orient_axis(N2, N2.z, q1)
B2.orient_axis(B1, N2.x, q2)
B3.orient_axis(B2, N2.y, q3)
obtained = B3.dcm(N2).simplify()

assert (obtained - expected) == sm.zeros(3, 3)
```
> and this fails:
> 
> ```
> bin/doctest sympy/physics/vector/dyadic.py sympy/physics/vector/frame.py
> ```
For me that passes. Actually the frame doctests are run first:
```console
$ bin/doctest sympy/physics/vector/dyadic.py sympy/physics/vector/frame.py
====================================================== test process starts =======================================================
executable:         /Users/enojb/current/sympy/38venv/bin/python  (3.8.5-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.19.4
hash randomization: on (PYTHONHASHSEED=2672944533)

sympy/physics/vector/frame.py[15] ...............                                                                             [OK]
sympy/physics/vector/dyadic.py[10] ..........                                                                                 [OK]

========================================== tests finished: 25 passed, in 32.70 seconds ===========================================
```

For me this fails though:
```console
$ bin/doctest sympy/physics/vector
====================================================== test process starts =======================================================
executable:         /Users/enojb/current/sympy/38venv/bin/python  (3.8.5-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.19.4
hash randomization: on (PYTHONHASHSEED=692765549)

sympy/physics/vector/functions.py[9] .........                                                                                [OK]
sympy/physics/vector/vector.py[14] ..............                                                                             [OK]
sympy/physics/vector/point.py[13] .............                                                                               [OK]
sympy/physics/vector/frame.py[15] .....F.........                                                                           [FAIL]
sympy/physics/vector/fieldfunctions.py[7] .......                                                                             [OK]
sympy/physics/vector/dyadic.py[10] ..........                                                                                 [OK]
sympy/physics/vector/printing.py[4] ....                                                                                      [OK]

__________________________________________________________________________________________________________________________________
__________________________________ sympy.physics.vector.frame.ReferenceFrame.orient_space_fixed __________________________________
File "/Users/enojb/current/sympy/sympy/sympy/physics/vector/frame.py", line 838, in sympy.physics.vector.frame.ReferenceFrame.orient_space_fixed
Failed example:
    B.dcm(N).simplify()
Expected:
    Matrix([
    [ sin(q1)*sin(q2)*sin(q3) + cos(q1)*cos(q3), sin(q1)*cos(q2), sin(q1)*sin(q2)*cos(q3) - sin(q3)*cos(q1)],
    [-sin(q1)*cos(q3) + sin(q2)*sin(q3)*cos(q1), cos(q1)*cos(q2), sin(q1)*sin(q3) + sin(q2)*cos(q1)*cos(q3)],
    [                           sin(q3)*cos(q2),        -sin(q2),                           cos(q2)*cos(q3)]])
Got:
    Matrix([
    [ sin(q1)*sin(q2)*sin(q3) + cos(q1)*cos(q3), sin(q1)*cos(q2),                                                                                sin(q1)*sin(q2)*cos(q3) - sin(q3)*cos(q1)],
    [-sin(q1)*cos(q3) + sin(q2)*sin(q3)*cos(q1), cos(q1)*cos(q2), sin(-q1 + q2 + q3)/4 - sin(q1 - q2 + q3)/4 + sin(q1 + q2 - q3)/4 + sin(q1 + q2 + q3)/4 + cos(q1 - q3)/2 - cos(q1 + q3)/2],
    [                           sin(q3)*cos(q2),        -sin(q2),                                                                                                          cos(q2)*cos(q3)]])

===================================== tests finished: 71 passed, 1 failed, in 13.80 seconds ======================================
DO *NOT* COMMIT!
```
To be clear I am testing this on current master 4aa3cd6c7c689fbe4e604082fb44e2136fa4224d with the following diff
```diff
diff --git a/sympy/physics/vector/frame.py b/sympy/physics/vector/frame.py
index 565a99c626..d3866df2e8 100644
--- a/sympy/physics/vector/frame.py
+++ b/sympy/physics/vector/frame.py
@@ -835,7 +835,7 @@ def orient_space_fixed(self, parent, angles, rotation_order):
         >>> B1.orient_axis(N, N.z, q1)
         >>> B2.orient_axis(B1, N.x, q2)
         >>> B.orient_axis(B2, N.y, q3)
-        >>> B.dcm(N).simplify() # doctest: +SKIP
+        >>> B.dcm(N).simplify()
         Matrix([
         [ sin(q1)*sin(q2)*sin(q3) + cos(q1)*cos(q3), sin(q1)*cos(q2), sin(q1)*sin(q2)*cos(q3) - sin(q3)*cos(q1)],
         [-sin(q1)*cos(q3) + sin(q2)*sin(q3)*cos(q1), cos(q1)*cos(q2), sin(q1)*sin(q3) + sin(q2)*cos(q1)*cos(q3)],
```
> @sidhu1012 What do you think the issue is?

Sorry for the delay, had a marriage to attend. I think the issue is that frame `B` is already rotated but tests works as if frame is a fresh variable.

https://github.com/sympy/sympy/blob/65f5d2a8be5d6508ff7245fcd5f8ad9cb046f097/sympy/physics/vector/frame.py#L826-L838
I don't think that's it. I've tried making all the variable names unique and not reusing any and it still errors. It has something to do with the fact that pytest runs some code before the doctests in frame.py (from other modules). I wonder if the dcm_cache is somehow corrupted. I also don't know how to open a debugger in the doctest so I can see what the cache looks like.
#20966 passed though. I think it's the correct fix