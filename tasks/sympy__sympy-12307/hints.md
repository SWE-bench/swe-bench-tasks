The x=0 case probably matters, because SymPy could return an expression that uses `sign` assuming that meaning. Does Fortran have ternary expressions? 
Looks like fortran does support ternary expressions though `merge`:
https://en.wikipedia.org/wiki/%3F:#Fortran
@bjodah 
I would like to work in this issue. Could you please help me out?
Is the following code correct?
`sp.sign(x) = merge(0, sp.sign(x), x is 0)`
@mamakancha no not quite. Fortran knows nothing about `sp.`. You can look at the C version:
```
$ grep -A1 --include "*.py" _print_sign -R sympy/
```
@**bjodah** I think the changes should be done in `doprint()` of codeprinter.py but not quite sure where and what the code should be 
@SatyaPrakashDwibedi I don't think that's needed. Simply adding a method to the printer class for fortran code should be enough (in analogy with the `_print_sign` method in the `CCodePrinter` class).
With a recent version a `gfortran`, I can confirm that
```fortran
merge(0, sign(1, x), x == 0)
```
```fortran
merge(0e0, sign(1e0, x), x == 0e0)
```
and
```fortran
merge(0d0, sign(1d0, x), x == 0d0)
```
work as expected, for respectively integer, real and double precision `x`.

Note that [`merge`](https://gcc.gnu.org/onlinedocs/gfortran/MERGE.html) is only defined for Fortran 95 standard (or later). Another solution might be needed for the legacy Fortran 77 standard.
Yes, I noticed that `merge` is a rather "new" addition. I don't know of an easy fix for fortran 77, there I think one would have to implement it using if statements. But supporting "only" F95+ is still a step in the right direction.
@bjodah will this work?
`>>> def p(func):
...   if func.args[0].is_positive:
...     return '(SIGN(1,{0})'.format((func.args[0]))
...   elif func.args[0].is_negative:
...     return '(SIGN(-1,{0})'.format((func.args[0]))
...   else:
...     return '(SIGN(0,{0})'.format((func.args[0]))
...`
@SatyaPrakashDwibedi no that will not work. The argument might be symbolic and its sign is not known prior to runtime (or we would obviously not need to generate any call at all). You should look at `test_fcode.py` and write a test for sign checking that generated code looks like @Franjov suggested, then run `./bin/test sympy/printing/tests/test_fcode.py` and watch it fail. Then edit `sympy/printing/fcode.py` to give the code printer a printing method analogous to the one in `ccode.py`. If done right the test should now pass. You should then verify that generated code actually compiles using e.g. `gfortran`. Then just commit and push and open a PR.
@bjodah Will this work for test_fcode.py
`def test_sign():`
    ` x=symbols('x',Integer=True)`
 `    y=symbols('y',real=True)`
 `    z=symbols('z',Double=True)`
 `    assert fcode(sign(x))=="      merge(0, sign(1, x), x == 0)"`
 `    assert fcode(sign(y))=="      merge(0e0, sign(1e0, x), x == 0e0)"`
 `    assert fcode(sign(z))=="      merge(0d0, sign(1d0, x), x == 0d0)" `
@SatyaPrakashDwibedi, that looks quite good, I'd suggest some minor changes:
```
def test_sign():
    x=symbols('x')
    y=symbols('y', integer=True)
    assert fcode(sign(x), source_format='free') == "merge(0d0, dsign(1d0, x), x == 0d0)"
    assert fcode(sign(y), source_format='free') == "merge(0, isign(1, x), x == 0)"
```
maybe we should handle more cases, but I don't write that much fortran so it's hard for me to be sure, @Franjov what do you think?
@bjodah Should I move to `fcode.py`
@bjodah I think there should be a check in `fcode.py` for type of variables to return right type of string , and how should I implement that.
You could also deal with the complex case. Something like
```fortran
merge( cmplx(0d0, 0d0), z/abs(z), abs(z) == 0d0)
```
(not tested in Fortran yet).

Actually, it is probably safer to code `x == 0d0` as something like `abs(x) < epsilon`.
But `epsilon` might be too dependent of the problem for a code generator without more context.