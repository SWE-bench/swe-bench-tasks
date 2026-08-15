It seems that in rref the pivot is not fully cancelled due to a rounding error so e.g. we have something like:
```python
In [1]: M = Matrix([[1.0, 1.0], [3.1, 1.0]])

In [2]: M
Out[2]: 
⎡1.0  1.0⎤
⎢        ⎥
⎣3.1  1.0⎦
```
Then one step of row reduction gives:
```python
In [3]: M = Matrix([[1.0, 1.0], [1e-16, -2.1]])

In [4]: M
Out[4]: 
⎡  1.0    1.0 ⎤
⎢             ⎥
⎣1.0e-16  -2.1⎦
```
With exact arithmetic the 1e-16 would have been 0 but the rounding error makes it not zero and then it throws off subsequent steps. I think that the solution is to make it exactly zero:
```diff
diff --git a/sympy/polys/matrices/sdm.py b/sympy/polys/matrices/sdm.py
index cfa624185a..647eb6af3d 100644
--- a/sympy/polys/matrices/sdm.py
+++ b/sympy/polys/matrices/sdm.py
@@ -904,6 +904,8 @@ def sdm_irref(A):
             Ajnz = set(Aj)
             for k in Ajnz - Ainz:
                 Ai[k] = - Aij * Aj[k]
+            Ai.pop(j)
+            Ainz.remove(j)
             for k in Ajnz & Ainz:
                 Aik = Ai[k] - Aij * Aj[k]
                 if Aik:
```
That gives:
```python
In [1]: import sympy

In [2]: sympy.linsolve([sympy.Eq(y, x), sympy.Eq(y, 0.0215 * x)], (x, y))
Out[2]: {(0, 0)}

In [3]: sympy.linsolve([sympy.Eq(y, x), sympy.Eq(y, 0.0216 * x)], (x, y))
Out[3]: {(0, 0)}

In [4]: sympy.linsolve([sympy.Eq(y, x), sympy.Eq(y, 0.0217 * x)], (x, y))
Out[4]: {(0, 0)}
```
@tyler-herzer-volumetric can you try out that diff?
Haven't been able to replicate the issue after making that change. Thanks a lot @oscarbenjamin!
This example still fails with the diff:
```python
In [1]: linsolve([0.4*x + 0.3*y + 0.2, 0.4*x + 0.3*y + 0.3], [x, y])
Out[1]: {(1.35107988821115e+15, -1.8014398509482e+15)}
```
In this case although the pivot is set to zero actually the matrix is singular but row reduction leads to something like:
```python
In [3]: Matrix([[1, 1], [0, 1e-17]])
Out[3]: 
⎡1     1   ⎤
⎢          ⎥
⎣0  1.0e-17⎦
```
That's a trickier case. It seems that numpy can pick up on it e.g.:
```python
In [52]: M = np.array([[0.4, 0.3], [0.4, 0.3]])

In [53]: b = np.array([0.2, 0.3])

In [54]: np.linalg.solve(M, b)
---------------------------------------------------------------------------
LinAlgError: Singular matrix 
```
A slight modification or rounding error leads to the same large result though:
```python
In [55]: M = np.array([[0.4, 0.3], [0.4, 0.3-3e-17]])

In [56]: np.linalg.solve(M, b)
Out[56]: array([ 1.35107989e+15, -1.80143985e+15])
```
I'm not sure it's possible to arrange the floating point calculation so that cases like this are picked up as being singular without introducing some kind of heuristic threshold for the determinant. This fails in numpy with even fairly simple examples:
```python
In [83]: b
Out[83]: array([0.2, 0.3, 0.5])

In [84]: M
Out[84]: 
array([[0.1, 0.2, 0.3],
       [0.4, 0.5, 0.6],
       [0.7, 0.8, 0.9]])

In [85]: np.linalg.solve(M, b)
Out[85]: array([-4.50359963e+14,  9.00719925e+14, -4.50359963e+14])

In [86]: np.linalg.det(M)
Out[86]: 6.661338147750926e-18
```
Maybe the not full-rank case for float matrices isn't so important since it can't be done reliably with floats. I guess that the diff shown above is good enough then since it fixes the calculation in the full rank case.
There is another problematic case. This should have a unique solution but a parametric solution is returned instead:
```python
In [21]: eqs = [0.8*x + 0.8*z + 0.2, 0.9*x + 0.7*y + 0.2*z + 0.9, 0.7*x + 0.2*y + 0.2*z + 0.5]

In [22]: linsolve(eqs, [x, y, z])
Out[22]: {(-0.32258064516129⋅z - 0.548387096774194, 1.22033022161007e+16⋅z - 5.37526407137769e+15, 1.0⋅z)}
```
That seems to be another bug in the sparse rref routine somehow:
```python
In [34]: M = Matrix([
    ...: [0.8,   0, 0.8, -0.2],
    ...: [0.9, 0.7, 0.2, -0.9],
    ...: [0.7, 0.2, 0.2, -0.5]])

In [35]: from sympy.polys.matrices import DomainMatrix

In [36]: dM = DomainMatrix.from_Matrix(M)

In [37]: M.rref()
Out[37]: 
⎛⎡1  0  0  -0.690476190476191⎤           ⎞
⎜⎢                           ⎥           ⎟
⎜⎢0  1  0  -0.523809523809524⎥, (0, 1, 2)⎟
⎜⎢                           ⎥           ⎟
⎝⎣0  0  1  0.440476190476191 ⎦           ⎠

In [38]: dM.rref()[0].to_Matrix()
Out[38]: 
⎡1.0  5.55111512312578e-17    0.32258064516129      -0.548387096774194  ⎤
⎢                                                                       ⎥
⎢0.0          1.0           -1.22033022161007e+16  -5.37526407137769e+15⎥
⎢                                                                       ⎥
⎣0.0          0.0                    0.0                    0.0         ⎦

In [39]: dM.to_dense().rref()[0].to_Matrix()
Out[39]: 
⎡1.0  0.0  0.0  -0.69047619047619 ⎤
⎢                                 ⎥
⎢0.0  1.0  0.0  -0.523809523809524⎥
⎢                                 ⎥
⎣0.0  0.0  1.0   0.44047619047619 ⎦
```
The last one was a similar problem to do with cancelling above the pivot:
```diff
diff --git a/sympy/polys/matrices/sdm.py b/sympy/polys/matrices/sdm.py
index cfa624185a..7c4ad43660 100644
--- a/sympy/polys/matrices/sdm.py
+++ b/sympy/polys/matrices/sdm.py
@@ -904,6 +904,8 @@ def sdm_irref(A):
             Ajnz = set(Aj)
             for k in Ajnz - Ainz:
                 Ai[k] = - Aij * Aj[k]
+            Ai.pop(j)
+            Ainz.remove(j)
             for k in Ajnz & Ainz:
                 Aik = Ai[k] - Aij * Aj[k]
                 if Aik:
@@ -938,6 +940,8 @@ def sdm_irref(A):
             for l in Ainz - Aknz:
                 Ak[l] = - Akj * Ai[l]
                 nonzero_columns[l].add(k)
+            Ak.pop(j)
+            Aknz.remove(j)
             for l in Ainz & Aknz:
                 Akl = Ak[l] - Akj * Ai[l]
                 if Akl:
diff --git a/sympy/polys/matrices/tests/test_linsolve.py b/sympy/polys/matrices/tests/test_linsolve.py
index eda4cdbdf3..6b79842fa7 100644
--- a/sympy/polys/matrices/tests/test_linsolve.py
+++ b/sympy/polys/matrices/tests/test_linsolve.py
@@ -7,7 +7,7 @@
 from sympy.testing.pytest import raises
 
 from sympy import S, Eq, I
-from sympy.abc import x, y
+from sympy.abc import x, y, z
 
 from sympy.polys.matrices.linsolve import _linsolve
 from sympy.polys.solvers import PolyNonlinearError
@@ -23,6 +23,14 @@ def test__linsolve():
     raises(PolyNonlinearError, lambda: _linsolve([x*(1 + x)], [x]))
 
 
+def test__linsolve_float():
+    assert _linsolve([Eq(y, x), Eq(y, 0.0216 * x)], (x, y)) == {x:0, y:0}
+
+    eqs = [0.8*x + 0.8*z + 0.2, 0.9*x + 0.7*y + 0.2*z + 0.9, 0.7*x + 0.2*y + 0.2*z + 0.5]
+    sol = {x:-0.69047619047619047, y:-0.52380952380952395, z:0.44047619047619047}
+    assert _linsolve(eqs, [x,y,z]) == sol
+
+
 def test__linsolve_deprecated():
     assert _linsolve([Eq(x**2, x**2+y)], [x, y]) == {x:x, y:S.Zero}
     assert _linsolve([(x+y)**2-x**2], [x]) == {x:-y/2}
```
Another problem has emerged though:
```python
In [1]: eqs = [0.9*x + 0.3*y + 0.4*z + 0.6, 0.6*x + 0.9*y + 0.1*z + 0.7, 0.4*x + 0.6*y + 0.9*z + 0.5]

In [2]: linsolve(eqs, [x, y, z])
Out[2]: {(-0.5, -0.4375, -0.0400000000000001)}

In [3]: solve(eqs, [x, y, z])
Out[3]: {x: -0.502857142857143, y: -0.438095238095238, z: -0.04}
```
> Another problem has emerged though:
> 
> ```python
> In [1]: eqs = [0.9*x + 0.3*y + 0.4*z + 0.6, 0.6*x + 0.9*y + 0.1*z + 0.7, 0.4*x + 0.6*y + 0.9*z + 0.5]
> ```

In this case the problem is that something like `1e-17` is chosen (incorrectly) as a pivot. It doesn't look easy to resolve this because the `sdm_rref` routine doesn't have an easy way of incorporating pivoting and is really designed for exact domains.

Probably float matrices should be handled by mpmath or at least a separate routine.