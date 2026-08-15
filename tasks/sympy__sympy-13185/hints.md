Can you create a very simple example using MatrixSymbol and the expected output that you'd like to see?
I think one would expect the output to be similar to the following (except for the expression returned by CSE being a matrix where the individual elements are terms as defined by matrix multiplication, that is, unchanged by `cse()`).

```py
import sympy as sp
from pprint import pprint
import sympy.printing.ccode


def print_ccode(assign_to, expr):
    constants, not_c, c_expr = sympy.printing.ccode(
        expr,
        human=False,
        assign_to=assign_to,
    )
    assert not constants, constants
    assert not not_c, not_c
    print "%s" % c_expr


a = sp.MatrixSymbol("a", 4, 4)
b = sp.MatrixSymbol("b", 4, 4)

# Set up expression. This is a just a simple example.
e = a * b
print "\nexpr:"
print e

cse_subs, cse_reduced = sp.cse(e)
print "\ncse(expr):"
pprint((cse_subs, cse_reduced))

# Codegen.
print "\nccode:"
for sym, expr in cse_subs:
    print_ccode(sympy.printing.ccode(sym), expr)
assert len(cse_reduced) == 1
print_ccode(sympy.printing.ccode(sp.symbols("result")), cse_reduced[0])
```

Gives the output:

```
expr:
a*b

cse(expr):
([], [a*b])

ccode:
result[0] = a[0]*b[0] + a[1]*b[4] + a[2]*b[8] + a[3]*b[12];
result[1] = a[0]*b[1] + a[1]*b[5] + a[2]*b[9] + a[3]*b[13];
result[2] = a[0]*b[2] + a[1]*b[6] + a[2]*b[10] + a[3]*b[14];
result[3] = a[0]*b[3] + a[1]*b[7] + a[2]*b[11] + a[3]*b[15];
result[4] = a[4]*b[0] + a[5]*b[4] + a[6]*b[8] + a[7]*b[12];
result[5] = a[4]*b[1] + a[5]*b[5] + a[6]*b[9] + a[7]*b[13];
result[6] = a[4]*b[2] + a[5]*b[6] + a[6]*b[10] + a[7]*b[14];
result[7] = a[4]*b[3] + a[5]*b[7] + a[6]*b[11] + a[7]*b[15];
result[8] = a[8]*b[0] + a[9]*b[4] + a[10]*b[8] + a[11]*b[12];
result[9] = a[8]*b[1] + a[9]*b[5] + a[10]*b[9] + a[11]*b[13];
result[10] = a[8]*b[2] + a[9]*b[6] + a[10]*b[10] + a[11]*b[14];
result[11] = a[8]*b[3] + a[9]*b[7] + a[10]*b[11] + a[11]*b[15];
result[12] = a[12]*b[0] + a[13]*b[4] + a[14]*b[8] + a[15]*b[12];
result[13] = a[12]*b[1] + a[13]*b[5] + a[14]*b[9] + a[15]*b[13];
result[14] = a[12]*b[2] + a[13]*b[6] + a[14]*b[10] + a[15]*b[14];
result[15] = a[12]*b[3] + a[13]*b[7] + a[14]*b[11] + a[15]*b[15];
```
Thanks. Note that it doesn't look like cse is well tested (i.e. designed) for MatrixSymbols based on the unit tests: https://github.com/sympy/sympy/blob/master/sympy/simplify/tests/test_cse.py#L315. Those tests don't really prove that it works as desired. So this definitely needs to be fixed.
The first part works as expected:

```
In [1]: import sympy as sm

In [2]: M = sm.MatrixSymbol('M', 3, 3)

In [3]: B = sm.MatrixSymbol('B', 3, 3)

In [4]: M * B
Out[4]: M*B

In [5]: sm.cse(M * B)
Out[5]: ([], [M*B])
```
For the ccode of an expression of MatrixSymbols, I would not expect it to print the results as you have them. MatrixSymbols should map to a matrix algebra library like BLAS and LINPACK. But Matrix, on the other hand, should do what you expect. Note how this works:

```
In [8]: M = sm.Matrix(3, 3, lambda i, j: sm.Symbol('M_{}{}'.format(i, j)))

In [9]: M
Out[9]: 
Matrix([
[M_00, M_01, M_02],
[M_10, M_11, M_12],
[M_20, M_21, M_22]])

In [10]: B = sm.Matrix(3, 3, lambda i, j: sm.Symbol('B_{}{}'.format(i, j)))

In [11]: B
Out[11]: 
Matrix([
[B_00, B_01, B_02],
[B_10, B_11, B_12],
[B_20, B_21, B_22]])

In [12]: M * B
Out[12]: 
Matrix([
[B_00*M_00 + B_10*M_01 + B_20*M_02, B_01*M_00 + B_11*M_01 + B_21*M_02, B_02*M_00 + B_12*M_01 + B_22*M_02],
[B_00*M_10 + B_10*M_11 + B_20*M_12, B_01*M_10 + B_11*M_11 + B_21*M_12, B_02*M_10 + B_12*M_11 + B_22*M_12],
[B_00*M_20 + B_10*M_21 + B_20*M_22, B_01*M_20 + B_11*M_21 + B_21*M_22, B_02*M_20 + B_12*M_21 + B_22*M_22]])

In [13]: sm.cse(M * B)
Out[13]: 
([], [Matrix([
  [B_00*M_00 + B_10*M_01 + B_20*M_02, B_01*M_00 + B_11*M_01 + B_21*M_02, B_02*M_00 + B_12*M_01 + B_22*M_02],
  [B_00*M_10 + B_10*M_11 + B_20*M_12, B_01*M_10 + B_11*M_11 + B_21*M_12, B_02*M_10 + B_12*M_11 + B_22*M_12],
  [B_00*M_20 + B_10*M_21 + B_20*M_22, B_01*M_20 + B_11*M_21 + B_21*M_22, B_02*M_20 + B_12*M_21 + B_22*M_22]])])

In [17]: print(sm.ccode(M * B, assign_to=sm.MatrixSymbol('E', 3, 3)))
E[0] = B_00*M_00 + B_10*M_01 + B_20*M_02;
E[1] = B_01*M_00 + B_11*M_01 + B_21*M_02;
E[2] = B_02*M_00 + B_12*M_01 + B_22*M_02;
E[3] = B_00*M_10 + B_10*M_11 + B_20*M_12;
E[4] = B_01*M_10 + B_11*M_11 + B_21*M_12;
E[5] = B_02*M_10 + B_12*M_11 + B_22*M_12;
E[6] = B_00*M_20 + B_10*M_21 + B_20*M_22;
E[7] = B_01*M_20 + B_11*M_21 + B_21*M_22;
E[8] = B_02*M_20 + B_12*M_21 + B_22*M_22;
```
But in order to get a single input argument from codegen it cannot be different symbols, and if you replace each symbol with a `MatrixSymbol[i, j]` then `cse()` starts doing the above non-optiimizations for some reason.
As far as I know, `codegen` does not work with Matrix or MatrixSymbol's in any meaningful way. There are related issues:

#11456
#4367
#10522

In general, there needs to be work done in the code generators to properly support matrices.

As a work around, I suggest using `ccode` and a custom template to get the result you want.