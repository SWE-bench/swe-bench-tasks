Could you provide a minimal and self-contained example? In general, checking for exact equality of floating point numbers is usually not what you want to do.
> Could you provide a minimal and self-contained example? In general, checking for exact equality of floating point numbers is usually not what you want to do.

I am working on producing a minimal example.
And I can understand that comparing can be faulty. However, if you look at the resulting matrices, they are entirely different. If we were talking about a floating point precision error (or something of the like), we'd be looking at two similar results, not ones that are completely different.
OK, I've not got a self-contained example. However, I went as deep as I could.
Is there any way to "serialize" my existing expression any further than _srepr_?

In any case, I've seen that for some reason, in this isolated case, a _Matrix_ times _2_ works correctly, yet a _Matrix_ times _2.0_ does not.
(Mostly the same code, slight modifications in the end and still a part of some larger script):
```
            if _debug:
                print 'sol', sol
                print 'srepr', sp.srepr(sol)
                print 'u0N', u0N, type(u0N)
                sol_1 = sol.subs('u0None', u0N)
                sol_2 = sol.subs('u0None', u0N.evalf())
                print 'are they the same?\n %s\n vs \n%s'%(sol_1, sol_2)
                print 'equal?', sol_1 == sol_2

                print "what about when I sympify it?"
                sol_symp = sp.sympify(str(sol))
                print 'new', sol_symp
                print 'new srepr', sp.srepr(sol_symp)
                print 'equal?', sol_symp.subs('u0None', u0N) == sol_symp.subs('u0None', u0N.evalf())
                print 'preorder_traversal'
                for el in sp.preorder_traversal(sol):
                    t1 = el.subs('u0None', u0N)
                    t2 = el.subs('u0None', u0N.evalf())
                    equal = t1 == t2
                    if not equal:
                        print 'el', el, u0N, u0N.evalf()
                        print 'sp.srepr', sp.srepr(el)
                        print 'subs', t1, t2, t1 == t2
```
And the result:
```
sol Matrix([[1, 1, 1, 1]])*u0None + Matrix([[-0.222222222222222, -0.617283950617284, -0.924554183813443, -1.16354214296601]])
srepr Add(Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None')), ImmutableDenseMatrix([[Float('-0.22222222222222221', precision=53), Float('-0.61728395061728392', precision=53), Float('-0.92455418381344312', precision=53), Float('-1.1635421429660113', precision=53)]]))
u0N 2 <class 'sympy.core.numbers.Integer'>
are they the same?
 Matrix([[1.77777777777778, 1.38271604938272, 1.07544581618656, 0.836457857033989]])
 vs 
Matrix([[0.777777777777778, 0.382716049382716, 0.0754458161865569, -0.163542142966011]])
equal? False
what about when I sympify it?
new Matrix([[u0None - 0.222222222222222, u0None - 0.617283950617284, u0None - 0.924554183813443, u0None - 1.16354214296601]])
new srepr MutableDenseMatrix([[Add(Symbol('u0None'), Float('-0.22222222222222199', precision=53)), Add(Symbol('u0None'), Float('-0.61728395061728403', precision=53)), Add(Symbol('u0None'), Float('-0.92455418381344301', precision=53)), Add(Symbol('u0None'), Float('-1.16354214296601', precision=53))]])
equal? True
preorder_traversal
el Matrix([[1, 1, 1, 1]])*u0None + Matrix([[-0.222222222222222, -0.617283950617284, -0.924554183813443, -1.16354214296601]]) 2 2.00000000000000
sp.srepr Add(Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None')), ImmutableDenseMatrix([[Float('-0.22222222222222221', precision=53), Float('-0.61728395061728392', precision=53), Float('-0.92455418381344312', precision=53), Float('-1.1635421429660113', precision=53)]]))
subs Matrix([[1.77777777777778, 1.38271604938272, 1.07544581618656, 0.836457857033989]]) Matrix([[0.777777777777778, 0.382716049382716, 0.0754458161865569, -0.163542142966011]]) False
# This is where I've got a Matrix times u0None and it gets 2 wholly different results for 2 and 2.0 
el Matrix([[1, 1, 1, 1]])*u0None 2 2.00000000000000
sp.srepr Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None'))
# on the left is the expected result with 2 and next to it the wrong result with 2.0
subs Matrix([[2, 2, 2, 2]]) Matrix([[1, 1, 1, 1]]) False
```

It seems that `sol` contains the symbol `u0None` but not the string `'u0None'`.  Therefore the substitution should be `sol.subs(u0None, u0N)` instead of `sol.subs('u0None', u0N)`.
> It seems that `sol` contains the symbol `u0None` but not the string `'u0None'`. Therefore the substitution should be `sol.subs(u0None, u0N)` instead of `sol.subs('u0None', u0N)`.

You're right, there is the symbol not the string. As this little program demonstrates, either will work:
```
import sympy

if __name__ == '__main__':
    eq = sympy.sympify('x^2 + 2*x + 4 * u0None')
    print 'eq', eq
    t1 = eq.subs('u0None', 3)
    t2 = eq.subs(sympy.Symbol('u0None'), 3)
    print 'with string: %s \nwith symbol: %s'%(t1, t2)
```
Outputting:
```
eq 4*u0None + x**2 + 2*x
with string: x**2 + 2*x + 12 
with symbol: x**2 + 2*x + 12
```
The same can be seen in the example I provided. In both cases the symbol vanishes after calling the _subs_ method.

Furthermore, even if I replace the string with a symbol, the result is the very same:
```
            if _debug:
                u0None = sp.Symbol('u0None')
                print 'sol', sol
                print 'srepr', sp.srepr(sol)
                print 'u0N', u0N, type(u0N)
                sol_1 = sol.subs(u0None, u0N)
                sol_2 = sol.subs(u0None, u0N.evalf())
                print 'are they the same?\n %s\n vs \n%s'%(sol_1, sol_2)
                print 'equal?', sol_1 == sol_2

                print "what about when I sympify it?"
                sol_symp = sp.sympify(str(sol))
                print 'new', sol_symp
                print 'new srepr', sp.srepr(sol_symp)
                print 'equal?', sol_symp.subs(u0None, u0N) == sol_symp.subs(u0None, u0N.evalf())
                print 'preorder_traversal'
                for el in sp.preorder_traversal(sol):
                    t1 = el.subs(u0None, u0N)
                    t2 = el.subs(u0None, u0N.evalf())
                    equal = t1 == t2
                    if not equal:
                        print 'el', el, u0N, u0N.evalf()
                        print 'sp.srepr', sp.srepr(el)
                        print 'subs', t1, t2, t1 == t2
                print 'what about func and args?'
                sol_ = sol.func(*sol.args)
                t1 = sol_.subs(u0None, u0N)
                t2 = sol_.subs(u0None, u0N.evalf())
                print sol_
                print t1, t2
```
Outputting:
```
sol Matrix([[1, 1, 1, 1]])*u0None + Matrix([[-0.222222222222222, -0.617283950617284, -0.924554183813443, -1.16354214296601]])
srepr Add(Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None')), ImmutableDenseMatrix([[Float('-0.22222222222222221', precision=53), Float('-0.61728395061728392', precision=53), Float('-0.92455418381344312', precision=53), Float('-1.1635421429660113', precision=53)]]))
u0N 2 <class 'sympy.core.numbers.Integer'>
are they the same?
 Matrix([[1.77777777777778, 1.38271604938272, 1.07544581618656, 0.836457857033989]])
 vs 
Matrix([[0.777777777777778, 0.382716049382716, 0.0754458161865569, -0.163542142966011]])
equal? False
what about when I sympify it?
new Matrix([[u0None - 0.222222222222222, u0None - 0.617283950617284, u0None - 0.924554183813443, u0None - 1.16354214296601]])
new srepr MutableDenseMatrix([[Add(Symbol('u0None'), Float('-0.22222222222222199', precision=53)), Add(Symbol('u0None'), Float('-0.61728395061728403', precision=53)), Add(Symbol('u0None'), Float('-0.92455418381344301', precision=53)), Add(Symbol('u0None'), Float('-1.16354214296601', precision=53))]])
equal? True
preorder_traversal
el Matrix([[1, 1, 1, 1]])*u0None + Matrix([[-0.222222222222222, -0.617283950617284, -0.924554183813443, -1.16354214296601]]) 2 2.00000000000000
sp.srepr Add(Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None')), ImmutableDenseMatrix([[Float('-0.22222222222222221', precision=53), Float('-0.61728395061728392', precision=53), Float('-0.92455418381344312', precision=53), Float('-1.1635421429660113', precision=53)]]))
subs Matrix([[1.77777777777778, 1.38271604938272, 1.07544581618656, 0.836457857033989]]) Matrix([[0.777777777777778, 0.382716049382716, 0.0754458161865569, -0.163542142966011]]) False
el Matrix([[1, 1, 1, 1]])*u0None 2 2.00000000000000
sp.srepr Mul(ImmutableDenseMatrix([[Integer(1), Integer(1), Integer(1), Integer(1)]]), Symbol('u0None'))
subs Matrix([[2, 2, 2, 2]]) Matrix([[1, 1, 1, 1]]) False
what about func and args?
Matrix([[1, 1, 1, 1]])*u0None + Matrix([[-0.222222222222222, -0.617283950617284, -0.924554183813443, -1.16354214296601]])
Matrix([[1.77777777777778, 1.38271604938272, 1.07544581618656, 0.836457857033989]]) Matrix([[0.777777777777778, 0.382716049382716, 0.0754458161865569, -0.163542142966011]])
```
Minimal self-contained example:
```
import sympy

eq = sympy.Mul(sympy.ImmutableDenseMatrix([[sympy.Integer(1), sympy.Integer(1), sympy.Integer(1), sympy.Integer(1)]]), sympy.Symbol('u0None'))
print 'Equation:\n', eq
print 'Subbing 2\n', eq.subs('u0None', 2)
print 'Subbing 2.0\n', eq.subs('u0None', 2.0)
u0None = sympy.Symbol('u0None')
print 'Using Symbol:', u0None
print 'Subbing 2\n', eq.subs(u0None, 2)
print 'Subbing 2.0\n', eq.subs(u0None, 2.0)
```
Outputting:
```
Equation:
Matrix([[1, 1, 1, 1]])*u0None
Subbing 2
Matrix([[2, 2, 2, 2]])
Subbing 2.0
Matrix([[1, 1, 1, 1]])
Using Symbol: u0None
Subbing 2
Matrix([[2, 2, 2, 2]])
Subbing 2.0
Matrix([[1, 1, 1, 1]])
```
I can confirm this.

An even smaller example:
```
In [23]: Mul(Matrix([[3]]), x).subs(x, 2.0)
Out[23]: [3]

In [24]: Mul(Matrix([[3]]), x).subs(x, 2)
Out[24]: [6]
```
[This line](https://github.com/sympy/sympy/blob/master/sympy/core/mul.py#L280) allows the type of `coeff` become `Matrix` but that is not tested on [this line](https://github.com/sympy/sympy/blob/master/sympy/core/mul.py#L265) which results in the multiplier 2.0 being lost. Maybe the test should be changed to something like `coeff is not zoo`.
Actually, I think that `coeff` of `Mul.flatten` should not be a matrix at all. It is my understanding that the purpose of `coeff` is to collect all numerical factors and return their product as the first item of `c_part` (if it is not 1). Matrices are non-commutative by nature and should be placed in `nc_part` (preserving their order).
An issue I believe is linked to this.
When substituting the _e_ instead of the unknown and evaluating afterwards, we get the incorrect result:
`Mul(Matrix([[3]]), x).subs(x, exp(1)).evalf()`
Comes out to:
`Matrix([[3]])`
However, we should (obviously) be getting:
`Matrix([[8.15484548537714]])`

The workaround I've been using:
`Mul(Matrix([[3]]), x).subs(x, eye(1) * exp(1)).evalf()`
results in
`Matrix([[8.15484548537714]])`

EDIT: 
The original subs works just fine:
`Mul(Matrix([[3]]), x).subs(x, exp(1))`
Resulting:
`Matrix([[3]])*E`

I'm guessing `evalf` somehow works similar to `subs`.

EDIT2:
Same happens when you use `pi` instead of `E` (as expected, really).
Matrices are put in the `coeff` as part of a hack to keep them separate from the rest of the expression.  See the discussion at https://github.com/sympy/sympy/issues/15665 (unfortunately, the pull request https://github.com/sympy/sympy/pull/15666 doesn't not seem to fix this issue). 
The minimal example does work if you use `MatMul` instead of `Mul`. 

```py
>>> MatMul(Matrix([[3]]), x).subs(x, 2.0)
Matrix([[3]])*2.0
```

Maybe instead of using the `coeff` hack, if a matrix is seen in Mul we should just pass down to MatMul. I don't know if there are any clean ways to handle this because the API wasn't really designed around, but we should at least try to get something that avoids wrong results. 
I would like to fix this issue. @jksuom @asmeurer  Can you exactly tell me what to be fixed?
I don't think I can. That is something that has to be investigated. The use of MatMul appears promising to me.
:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v135). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* core
  * fixed a bug in the flatten function ([#15692](https://github.com/sympy/sympy/pull/15692) by [@jmig5776](https://github.com/jmig5776))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.4.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    …dd and MatMul

    <!-- Your title above should be a short description of what
    was changed. Do not include the issue number in the title. -->

    #### References to other Issues or PRs
    <!-- If this pull request fixes an issue, write "Fixes #NNNN" in that exact
    format, e.g. "Fixes #1234". See
    https://github.com/blog/1506-closing-issues-via-pull-requests .-->
    Fixes #15665 


    #### Brief description of what is fixed or changed
    Modified Mul.flatten such that it returns the correct return type in case of matrices i.e

    >>> A = MatrixSymbol("A", n, n)
    >>> B = MatrixSymbol("B", n, n)
    >>> type(Mul(A, B))
    <class 'sympy.matrices.expressions.matmul.MatMul'>
    >>> type(Mul(-1, Mul(A, B)))
    <class 'sympy.matrices.expressions.matmul.MatMul'>

    #### Other comments


    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->
    * core
           * fixed a bug in the flatten function


    <!-- END RELEASE NOTES -->


</details><p>

@asmeurer , @smichr  Please review it.
@smichr I think it can merge into master.
I'll take a look. Can you add tests. 
Yeah sure I will add some tests
@asmeurer I had added the test cases . 
This doesn't seem to fix the error from https://github.com/sympy/sympy/issues/15120 (you may need to merge in the branch from https://github.com/sympy/sympy/pull/15121 first). The following should work without giving an exception

```py
import sympy as sy
n = sy.symbols('n')
A = sy.MatrixSymbol("A",n,n)
B = sy.MatrixSymbol("B",n,n)
C = sy.MatrixSymbol("C",n,n)
M = A.inverse()*B.inverse() - A.inverse()*C*B.inverse()
a = B.inverse()*M.inverse()*A.inverse()
factor(a)
```
Ohh I was unaware about #15120 . Should I merge into branch of #15121 ?. Or I should work to solve this here explicitly.
Sorry, I mean to test merge against that branch to test, but don't actually push the merge up here. You could create a new branch first before merging, or use a detached HEAD. 
To clarify, merging my branch will be necessary to avoid other bugs unrelated to this one. 
> This doesn't seem to fix the error from #15120 (you may need to merge in the branch from #15121 first). The following should work without giving an exception
> 
> ```python
> import sympy as sy
> n = sy.symbols('n')
> A = sy.MatrixSymbol("A",n,n)
> B = sy.MatrixSymbol("B",n,n)
> C = sy.MatrixSymbol("C",n,n)
> M = A.inverse()*B.inverse() - A.inverse()*C*B.inverse()
> a = B.inverse()*M.inverse()*A.inverse()
> factor(a)
> ```

I tested the merge with your branch locally but it is does not seems to fix the exception occuring in above case.What do you think?