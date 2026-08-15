`.diff()` is running this internally:

```ipython
In [1]: import sympy as sm

In [2]: t = sm.symbols('t')

In [3]: x = sm.Function('x')(t)

In [4]: dx = x.diff(t)

In [19]: from sympy.tensor.array.array_derivatives import ArrayDerivative

In [26]: ArrayDerivative(sm.Matrix([sm.cos(x) + sm.cos(x)*dx]), x, evaluate=True)
Out[26]: Matrix([[-sin(x(t))]])

In [27]: ArrayDerivative(sm.cos(x) + sm.cos(x)*dx, x, evaluate=True)
Out[27]: -sin(x(t))*Derivative(x(t), t) - sin(x(t))
```

I tried this in SymPy 1.0 at it works as expected. The code for `Matrix.diff()` is:

```
Signature: A.diff(*args)
Source:   
    def diff(self, *args):
        """Calculate the derivative of each element in the matrix.

        Examples
        ========

        >>> from sympy.matrices import Matrix
        >>> from sympy.abc import x, y
        >>> M = Matrix([[x, y], [1, 0]])
        >>> M.diff(x)
        Matrix([
        [1, 0],
        [0, 0]])

        See Also
        ========

        integrate
        limit
        """
        return self._new(self.rows, self.cols,
                lambda i, j: self[i, j].diff(*args))
File:      ~/src/sympy/sympy/matrices/matrices.py
Type:      method

```

So I think that ArrayDerivative change has introduced this bug.
@Upabjojr This seems like a bug tied to the introduction of tensor code into the diff() of Matrix. I'm guessing that is something you added.
I'll assign this issue to myself for now. Will look into it when I have some time.
A quick fix it to switch back to the simple .diff of each element. I couldn't make heads or tails of the ArrayDerivative code with a quick look.
Switching it back causes A.diff(A) to fail:

```
________________________________________ sympy/matrices/tests/test_matrices.py:test_diff_by_matrix _________________________________________
Traceback (most recent call last):
  File "/home/moorepants/src/sympy/sympy/matrices/tests/test_matrices.py", line 1919, in test_diff_by_matrix
    assert A.diff(A) == Array([[[[1, 0], [0, 0]], [[0, 1], [0, 0]]], [[[0, 0], [1, 0]], [[0, 0], [0, 1]]]])
AssertionError

```
The problem lies in the expressions submodule of the matrices. Matrix expressions are handled differently from actual expressions.

https://github.com/sympy/sympy/blob/f9badb21b01f4f52ce4d545d071086ee650cd282/sympy/core/function.py#L1456-L1462

Every derivative requested expression passes through this point. The old variable is replaced with a new dummy variable (`xi`). Due to this some of the properties of the old symbol are lost. `is_Functon` being one of them. In the `old_v` (`x(t)`) this property is `True` but for `v` it is False. That is **not** an issue here as the old variable is substituted back after the computation of derivative. All the expressions pass through this point. The problem starts when we apply `doit()` on such dummy value expressions. Instead of treating the dummy variable as a `Function`, it is treated as regular `sympy.core.symbol.Symbol`. 

The best way to avoid this is to not use `doit()` on such expressions until the derivative is calculated and the old variable is substituted back. It is therefore nowhere used in the core expression module. However, in the matexpr module it is used twice and this is where the results deviate. 

```python
In [1]: from sympy import *
        from sympy import __version__ as ver
        t = symbols('t')
        x = Function('x')(t)
        ver
Out[1]: '1.8.dev'

In [2]: xi = Dummy("xi")
        new = x.xreplace({x: xi})
        print(Derivative(x, t).doit())
        print(Derivative(new, t).doit())
Out[2]: Derivative(x(t), t)
        0
```

https://github.com/sympy/sympy/blob/f9badb21b01f4f52ce4d545d071086ee650cd282/sympy/matrices/expressions/matexpr.py#L656

and 

https://github.com/sympy/sympy/blob/f9badb21b01f4f52ce4d545d071086ee650cd282/sympy/matrices/expressions/matexpr.py#L900

These two `doit()` reduce the `-sin(_xi)*Derivative(_xi, t)` part of the derivative computed to `0` (treating `_xi` as a symbol).

I removed the `.doit()` part from both the lines and it worked. My diff-

```diff
$ git diff
diff --git a/sympy/matrices/expressions/matexpr.py b/sympy/matrices/expressions/matexpr.py
index 6dc87b5754..e11946015c 100644
--- a/sympy/matrices/expressions/matexpr.py
+++ b/sympy/matrices/expressions/matexpr.py
@@ -653,7 +653,7 @@ def _matrix_derivative(expr, x):

     from sympy.tensor.array.expressions.conv_array_to_matrix import convert_array_to_matrix

-    parts = [[convert_array_to_matrix(j).doit() for j in i] for i in parts]
+    parts = [[convert_array_to_matrix(j) for j in i] for i in parts]

     def _get_shape(elem):
         if isinstance(elem, MatrixExpr):
@@ -897,7 +897,7 @@ def build(self):
         data = [self._build(i) for i in self._lines]
         if self.higher != 1:
             data += [self._build(self.higher)]
-        data = [i.doit() for i in data]
+        data = [i for i in data]
         return data

     def matrix_form(self):
```

I also ran all the tests and all the tests passed. Just to check that I was not anything wrong or ignoring some important purpose of that `.doit()` part. I tried with some of my own examples using both `expr.diff(x)` and `matrix.diff(x)` and the results were the same for both every single time. If `doit()` has some important purpose then please let me know. Also if everything is fine then should I open a PR?
> Also if everything is fine then should I open a PR?

Of course! It's easier to discuss edits in PRs because you can put comments on the code there.