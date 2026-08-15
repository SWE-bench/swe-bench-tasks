not understood. please explain a bit.

The latex version looks like `x_A` and the pretty looks like `A_x`.
Apparently this is correct but the str printer (needing to give something that can be copied and pasted to reproduce the object) is the one with the reversed order. @jksuom notes,

> I think that the coordinate names (x, y, z) and the vector names (i, j, k) are the primary names and the system name (A) is an attribute that can can be represented by a subscript (or, possibly, a superscript).

If that is the case, then this diff may be in order:
```diff
diff --git a/sympy/printing/pretty/tests/test_pretty.py b/sympy/printing/pretty/tests/test_pretty.py
index 7e94282..dadc64d 100644
--- a/sympy/printing/pretty/tests/test_pretty.py
+++ b/sympy/printing/pretty/tests/test_pretty.py
@@ -6255,17 +6255,17 @@ def test_degree_printing():
 def test_vector_expr_pretty_printing():
     A = CoordSys3D('A')
 
-    assert upretty(Cross(A.i, A.x*A.i+3*A.y*A.j)) == u("(A_i)×((A_x) A_i + (3⋅A_y) A_j)")
-    assert upretty(x*Cross(A.i, A.j)) == u('x⋅(A_i)×(A_j)')
+    assert upretty(Cross(A.i, A.x*A.i+3*A.y*A.j)) == u("(i_A)×((x_A) i_A + (3⋅y_A) j_A)")
+    assert upretty(x*Cross(A.i, A.j)) == u('x⋅(i_A)×(j_A)')
 
-    assert upretty(Curl(A.x*A.i + 3*A.y*A.j)) == u("∇×((A_x) A_i + (3⋅A_y) A_j)")
+    assert upretty(Curl(A.x*A.i + 3*A.y*A.j)) == u("∇×((x_A) i_A + (3⋅y_A) j_A)")
 
-    assert upretty(Divergence(A.x*A.i + 3*A.y*A.j)) == u("∇⋅((A_x) A_i + (3⋅A_y) A_j)")
+    assert upretty(Divergence(A.x*A.i + 3*A.y*A.j)) == u("∇⋅((x_A) i_A + (3⋅y_A) j_A)")
 
-    assert upretty(Dot(A.i, A.x*A.i+3*A.y*A.j)) == u("(A_i)⋅((A_x) A_i + (3⋅A_y) A_j)")
+    assert upretty(Dot(A.i, A.x*A.i+3*A.y*A.j)) == u("(i_A)⋅((x_A) i_A + (3⋅y_A) j_A)")
 
-    assert upretty(Gradient(A.x+3*A.y)) == u("∇(A_x + 3⋅A_y)")
-    assert upretty(Laplacian(A.x+3*A.y)) == u("∆(A_x + 3⋅A_y)")
+    assert upretty(Gradient(A.x+3*A.y)) == u("∇(x_A + 3⋅y_A)")
+    assert upretty(Laplacian(A.x+3*A.y)) == u("∆(x_A + 3⋅y_A)")
     # TODO: add support for ASCII pretty.
 
 
diff --git a/sympy/vector/coordsysrect.py b/sympy/vector/coordsysrect.py
index abc9d9b..a7b0e91 100644
--- a/sympy/vector/coordsysrect.py
+++ b/sympy/vector/coordsysrect.py
@@ -200,7 +200,7 @@ def __new__(cls, name, transformation=None, parent=None, location=None,
         vector_names = list(vector_names)
         latex_vects = [(r'\mathbf{\hat{%s}_{%s}}' % (x, name)) for
                            x in vector_names]
-        pretty_vects = [(name + '_' + x) for x in vector_names]
+        pretty_vects = ['%s_%s' % (x, name) for x in vector_names]
 
         obj._vector_names = vector_names
 
@@ -216,7 +216,7 @@ def __new__(cls, name, transformation=None, parent=None, location=None,
         variable_names = list(variable_names)
         latex_scalars = [(r"\mathbf{{%s}_{%s}}" % (x, name)) for
                          x in variable_names]
-        pretty_scalars = [(name + '_' + x) for x in variable_names]
+        pretty_scalars = ['%s_%s' % (x, name) for x in variable_names]
 
         obj._variable_names = variable_names
         obj._vector_names = vector_names
diff --git a/sympy/vector/tests/test_printing.py b/sympy/vector/tests/test_printing.py
index 5b95813..5a1b9f6 100644
--- a/sympy/vector/tests/test_printing.py
+++ b/sympy/vector/tests/test_printing.py
@@ -38,14 +38,14 @@ def upretty(expr):
 upretty_v_8 = u(
 """\
       ⎛   2   ⌠        ⎞    \n\
-N_j + ⎜C_x  - ⎮ f(b) db⎟ N_k\n\
+j_N + ⎜x_C  - ⎮ f(b) db⎟ k_N\n\
       ⎝       ⌡        ⎠    \
 """)
 pretty_v_8 = u(
     """\
-N_j + /         /       \\\n\
+j_N + /         /       \\\n\
       |   2    |        |\n\
-      |C_x  -  | f(b) db|\n\
+      |x_C  -  | f(b) db|\n\
       |        |        |\n\
       \\       /         / \
 """)
@@ -56,13 +56,13 @@ def upretty(expr):
 upretty_v_11 = u(
 """\
 ⎛ 2    ⎞        ⎛⌠        ⎞    \n\
-⎝a  + b⎠ N_i  + ⎜⎮ f(b) db⎟ N_k\n\
+⎝a  + b⎠ i_N  + ⎜⎮ f(b) db⎟ k_N\n\
                 ⎝⌡        ⎠    \
 """)
 pretty_v_11 = u(
 """\
 / 2    \\ + /  /       \\\n\
-\\a  + b/ N_i| |        |\n\
+\\a  + b/ i_N| |        |\n\
            | | f(b) db|\n\
            | |        |\n\
            \\/         / \
@@ -74,23 +74,23 @@ def upretty(expr):
 upretty_s = u(
 """\
          2\n\
-3⋅C_y⋅N_x \
+3⋅y_C⋅x_N \
 """)
 pretty_s = u(
 """\
          2\n\
-3*C_y*N_x \
+3*y_C*x_N \
 """)
 
 # This is the pretty form for ((a**2 + b)*N.i + 3*(C.y - c)*N.k) | N.k
 upretty_d_7 = u(
 """\
 ⎛ 2    ⎞                                     \n\
-⎝a  + b⎠ (N_i|N_k)  + (3⋅C_y - 3⋅c) (N_k|N_k)\
+⎝a  + b⎠ (i_N|k_N)  + (3⋅y_C - 3⋅c) (k_N|k_N)\
 """)
 pretty_d_7 = u(
 """\
-/ 2    \\ (N_i|N_k) + (3*C_y - 3*c) (N_k|N_k)\n\
+/ 2    \\ (i_N|k_N) + (3*y_C - 3*c) (k_N|k_N)\n\
 \\a  + b/                                    \
 """)
 
@@ -126,20 +126,20 @@ def test_pretty_printing_ascii():
     assert pretty(d[10]) == u'(cos(a)) (C_i|N_k) + (-sin(a)) (C_j|N_k)'
 
 
-def test_pretty_print_unicode():
+def test_pretty_print_unicode_v():
     assert upretty(v[0]) == u'0'
-    assert upretty(v[1]) == u'N_i'
-    assert upretty(v[5]) == u'(a) N_i + (-b) N_j'
+    assert upretty(v[1]) == u'i_N'
+    assert upretty(v[5]) == u'(a) i_N + (-b) j_N'
     # Make sure the printing works in other objects
-    assert upretty(v[5].args) == u'((a) N_i, (-b) N_j)'
+    assert upretty(v[5].args) == u'((a) i_N, (-b) j_N)'
     assert upretty(v[8]) == upretty_v_8
-    assert upretty(v[2]) == u'(-1) N_i'
+    assert upretty(v[2]) == u'(-1) i_N'
     assert upretty(v[11]) == upretty_v_11
     assert upretty(s) == upretty_s
     assert upretty(d[0]) == u'(0|0)'
-    assert upretty(d[5]) == u'(a) (N_i|N_k) + (-b) (N_j|N_k)'
+    assert upretty(d[5]) == u'(a) (i_N|k_N) + (-b) (j_N|k_N)'
     assert upretty(d[7]) == upretty_d_7
-    assert upretty(d[10]) == u'(cos(a)) (C_i|N_k) + (-sin(a)) (C_j|N_k)'
+    assert upretty(d[10]) == u'(cos(a)) (i_C|k_N) + (-sin(a)) (j_C|k_N)'
 
 
 def test_latex_printing():
@@ -171,7 +171,7 @@ def test_custom_names():
                    variable_names=['i', 'j', 'k'])
     assert A.i.__str__() == 'A.i'
     assert A.x.__str__() == 'A.x'
-    assert A.i._pretty_form == 'A_i'
-    assert A.x._pretty_form == 'A_x'
+    assert A.i._pretty_form == 'i_A'
+    assert A.x._pretty_form == 'x_A'
     assert A.i._latex_form == r'\mathbf{{i}_{A}}'
     assert A.x._latex_form == r"\mathbf{\hat{x}_{A}}"
```
Hello,

I would like to work on this issue. Shold I make the diff as you showed it above?

Thank you!
@smichr Hello!
After looking at the file /sympy/vector/tests/test_printing.py, I noticed that maybe the BaseScalar symbol in the function test_pretty_printing_ascii() should be also changed to the format. Is that correct?
```
def test_pretty_printing_ascii():
    assert pretty(v[0]) == u'0'
    assert pretty(v[1]) == u'i_N'
    assert pretty(v[5]) == u'(a) i_N + (-b) j_N'
    assert pretty(v[8]) == pretty_v_8
    assert pretty(v[2]) == u'(-1) i_N'
    assert pretty(v[11]) == pretty_v_11
    assert pretty(s) == pretty_s
    assert pretty(d[0]) == u'(0|0)'
    assert pretty(d[5]) == u'(a) (i_N|k_N) + (-b) (j_N|k_N)'
    assert pretty(d[7]) == pretty_d_7
    assert pretty(d[10]) == u'(cos(a)) (i_C|k_N) + (-sin(a)) (j_C|k_N)'
```
Besides, while running the test for the printing module, there is an AssertionError in a line that I didn't change:
```
def test_issue_12675():
    from sympy.vector import CoordSys3D
    x, y, t, j = symbols('x y t j')
    e = CoordSys3D('e')

    ucode_str = \
u("""\
⎛   t⎞    \n\
⎜⎛x⎞ ⎟ e_j\n\
⎜⎜─⎟ ⎟    \n\
⎝⎝y⎠ ⎠    \
""")
    assert upretty((x/y)**t*e.j) == ucode_str
    ucode_str = \
u("""\
⎛1⎞    \n\
⎜─⎟ e_j\n\
⎝y⎠    \
""")
    assert upretty((1/y)*e.j) == ucode_str
```
And the error is 
`sympy\sympy\printing\pretty\tests\test_pretty.py", line 6215, in test_issue_12675
    assert upretty((x/y)**t*e.j) == ucode_str
AssertionError`
I think the problem is that this syntax(with 'u' at the beginning of a line) make it difficult to define the end of the function, so the assert line gets out of the def bloc. But I am not sure about this inference because other functions work quite well. 
Plus, this function is named test_issue_12675. After checking the issue 12675, I didn't find information tells me that this test function is mandatory. So I don't know if it is necessairy to keep it there since it is a test. How do you think about it?
