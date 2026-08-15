Ping @asmeurer @smichr .
Caution: the change is easy (define `converter[dict] = lambda d: Dict(d)` after `class Dict`...but the implications are manifold. Many errors will go away as you find the root cause of processing only dict instead of Dict and or dict.
```console
#### doctest

sympy/series/fourier.py[8] FFFFF...                                       [FAIL]
sympy/integrals/heurisch.py[3] F..                                        [FAIL]
sympy/core/sympify.py[4] ...F                                             [FAIL]
sympy/core/function.py[26] .F........................                     [FAIL]
________________________________________________________________________________
_____________________ sympy.series.fourier.fourier_series ______________________
File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/series/fourier.py", line 594, in sympy.series.fourier.fourier_series
Failed example:
    s = fourier_series(x**2, (x, -pi, pi))
Exception raised:
    Traceback (most recent call last):
      File "/opt/python/3.7.1/lib/python3.7/doctest.py", line 1329, in __run
        compileflags, 1), test.globs)
      File "<doctest sympy.series.fourier.fourier_series[2]>", line 1, in <module>
        s = fourier_series(x**2, (x, -pi, pi))
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/series/fourier.py", line 654, in fourier_series
        a0, an = fourier_cos_seq(f, limits, n)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/series/fourier.py", line 25, in fourier_cos_seq
        formula = 2 * cos_term * integrate(func * cos_term, limits) / L
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/integrals.py", line 1487, in integrate
        return integral.doit(**doit_flags)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/integrals.py", line 541, in doit
        function, xab[0], **eval_kwargs)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/integrals.py", line 998, in _eval_integral
        h = heurisch_wrapper(g, x, hints=[])
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/heurisch.py", line 166, in heurisch_wrapper
        degree_offset, unnecessary_permutations)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/heurisch.py", line 702, in heurisch
        solution = _integrate('Q')
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/integrals/heurisch.py", line 693, in _integrate
        solution = solve_lin_sys(numer.coeffs(), coeff_ring, _raw=False)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/polys/solvers.py", line 60, in solve_lin_sys
        v = (echelon[i, p + 1:]*vect)[0]
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/decorators.py", line 129, in binary_op_wrapper
        return func(self, other)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/matrices/common.py", line 2199, in __mul__
        return self._eval_matrix_mul(other)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/matrices/dense.py", line 202, in _eval_matrix_mul
        new_mat[i] = Add(*vec)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/cache.py", line 94, in wrapper
        retval = cfunc(*args, **kwargs)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/operations.py", line 47, in __new__
        c_part, nc_part, order_symbols = cls.flatten(args)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/add.py", line 230, in flatten
        newseq.append(Mul(c, s))
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/cache.py", line 94, in wrapper
        retval = cfunc(*args, **kwargs)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/operations.py", line 47, in __new__
        c_part, nc_part, order_symbols = cls.flatten(args)
      File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/core/mul.py", line 186, in flatten
        r, b = b.as_coeff_Mul()
    AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
**********************************************************************
File "/home/travis/virtualenv/python3.7.1/lib/python3.7/site-packages/sympy-1.5.dev0-py3.7.egg/sympy/series/fourier.py", line 595, in sympy.series.fourier.fourier_series
Failed example:
    s.truncate(n=3)
Exception raised:
    Traceback (most recent call last):
      File "/opt/python/3.7.1/lib/python3.7/doctest.py", line 1329, in __run
        compileflags, 1), test.globs)
      File "<doctest sympy.series.fourier.fourier_series[3]>", line 1, in <module>
        s.truncate(n=3)
    NameError: name 's' is not defined

#### part1
_____ sympy/functions/elementary/tests/test_piecewise.py:test_issue_12557 ______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/geometry/tests/test_curve.py:test_length ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____________ sympy/holonomic/tests/test_holonomic.py:test_integrate ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______ sympy/integrals/tests/test_heurisch.py:test_heurisch_polynomials _______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________ sympy/integrals/tests/test_heurisch.py:test_heurisch_fractions ________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_heurisch.py:test_heurisch_log ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_heurisch.py:test_heurisch_exp ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
______ sympy/integrals/tests/test_heurisch.py:test_heurisch_trigonometric ______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______ sympy/integrals/tests/test_heurisch.py:test_heurisch_hyperbolic ________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
__________ sympy/integrals/tests/test_heurisch.py:test_heurisch_mixed __________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________ sympy/integrals/tests/test_heurisch.py:test_heurisch_radicals _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_____ sympy/integrals/tests/test_heurisch.py:test_heurisch_symbolic_coeffs _____
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'cancel'
________________________________________________________________________________
__ sympy/integrals/tests/test_heurisch.py:test_heurisch_symbolic_coeffs_1130 ___
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_________ sympy/integrals/tests/test_heurisch.py:test_heurisch_hacking _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_________ sympy/integrals/tests/test_heurisch.py:test_heurisch_wrapper _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____________ sympy/integrals/tests/test_heurisch.py:test_issue_3609 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____________ sympy/integrals/tests/test_heurisch.py:test_pmint_rat _____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____________ sympy/integrals/tests/test_heurisch.py:test_pmint_trig ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
__________ sympy/integrals/tests/test_heurisch.py:test_pmint_LambertW __________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/integrals/tests/test_heurisch.py:test_RR ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____ sympy/integrals/tests/test_integrals.py:test_transcendental_functions _____
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_8623 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_9569 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_13749 ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4052 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___ sympy/integrals/tests/test_integrals.py:test_integrate_returns_piecewise ___
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4403 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
__________ sympy/integrals/tests/test_integrals.py:test_issue_4403_2 ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4100 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4890 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_________ sympy/integrals/tests/test_integrals.py:test_heurisch_option _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4234 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_8901 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_4968 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/integrals/tests/test_integrals.py:test_issue_14064 ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_____ sympy/integrals/tests/test_risch.py:test_integrate_hyperexponential ______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/core/tests/test_count_ops.py:test_count_ops_visual ___________
Traceback (most recent call last):
AssertionError

#### part2
________________________________________________________________________________
________________ sympy/polys/tests/test_ring_series.py:test_log ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_____________ sympy/polys/tests/test_ring_series.py:test_nth_root ______________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_______________ sympy/polys/tests/test_ring_series.py:test_atan ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
________________ sympy/polys/tests/test_ring_series.py:test_tan ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/polys/tests/test_ring_series.py:test_sin ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/polys/tests/test_ring_series.py:test_cos ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/polys/tests/test_ring_series.py:test_atanh _______________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/polys/tests/test_ring_series.py:test_sinh ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/polys/tests/test_ring_series.py:test_cosh ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/polys/tests/test_ring_series.py:test_tanh ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/polys/tests/test_rings.py:test_PolyElement___add__ ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/polys/tests/test_rings.py:test_PolyElement___sub__ ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/polys/tests/test_rings.py:test_PolyElement___mul__ ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_________ sympy/polys/tests/test_solvers.py:test_solve_lin_sys_4x7_inf _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_________ sympy/polys/tests/test_solvers.py:test_solve_lin_sys_5x5_inf _________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
____________ sympy/series/tests/test_fourier.py:test_FourierSeries _____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/series/tests/test_fourier.py:test_FourierSeries_2 ____________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
______ sympy/series/tests/test_fourier.py:test_FourierSeries__operations _______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
__________ sympy/series/tests/test_fourier.py:test_FourierSeries__neg __________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______ sympy/series/tests/test_fourier.py:test_FourierSeries__add__sub ________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/solvers/tests/test_ode.py:test_1st_linear ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_______________ sympy/solvers/tests/test_ode.py:test_separable4 ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______ sympy/solvers/tests/test_ode.py:test_1st_homogeneous_coeff_ode2 ________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
_______________ sympy/solvers/tests/test_ode.py:test_issue_7093 ________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
___________ sympy/solvers/tests/test_ode.py:test_nth_order_reducible ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
______ sympy/solvers/tests/test_pde.py:test_pde_1st_linear_constant_coeff ______
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
__________ sympy/stats/tests/test_continuous_rv.py:test_single_normal __________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_______________ sympy/stats/tests/test_continuous_rv.py:test_cdf _______________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
__________ sympy/stats/tests/test_continuous_rv.py:test_ContinuousRV ___________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_numer_denom'
________________________________________________________________________________
_________________ sympy/utilities/tests/test_wester.py:test_V7 _________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/utilities/tests/test_wester.py:test_V10 _________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/utilities/tests/test_wester.py:test_V11 _________________
Traceback (most recent call last):
AttributeError: 'Dict' object has no attribute 'as_coeff_Mul'
________________________________________________________________________________
________________ sympy/polys/tests/test_ring_series.py:test_exp ________________

________________________________________________________________________________
_________ sympy/polys/tests/test_solvers.py:test_solve_lin_sys_3x3_inf _________

________________________________________________________________________________
___________ sympy/tensor/tests/test_indexed.py:test_IndexedBase_subs ___________

```
Perhaps Dict needs to subclass the Mapping collections abc so that it has the same (immutable) methods as dict. 
@smichr 
Is it possible to do the following. If not then what is the reason?
```
diff --git a/sympy/core/sympify.py b/sympy/core/sympify.py
index 17e8508ee..b2db606f2 100644
--- a/sympy/core/sympify.py
+++ b/sympy/core/sympify.py
@@ -347,8 +347,8 @@ def sympify(a, locals=None, convert_xor=True, strict=False, rational=False,
             pass
     if isinstance(a, dict):
         try:
-            return type(a)([sympify(x, locals=locals, convert_xor=convert_xor,
-                rational=rational) for x in a.items()])
+            from .containers import Dict
+            return Dict(a)
         except TypeError:
             # Not all iterables are rebuildable with their type.
             pass

``` 
@asmeurer I am working on your suggestion of subclassing Mapping from collections.abc. The following conflict is arising due to this,
`TypeError: metaclass conflict: the metaclass of a derived class must be a (non-strict) subclass of the metaclasses of all its bases`

> what is the reason

It's the same as defining a converter. You will get lots of error because the codebase is not looking for Dict.
@smichr I was expecting the same as you said. 
However, when I tried the doctest for `sympy/series/fourier.py` after making the change, all the examples are passing as shown below conflicting with the failures in [this comment](https://github.com/sympy/sympy/issues/16769#issuecomment-488878857).
This compelled me to think that there is a difference and hence, I asked.
```
Python 3.6.7 (default, Oct 22 2018, 11:32:17) 
[GCC 8.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import sympy
>>> sympy.doctest('sympy/series/fourier.py')
============================= test process starts ==============================
executable:         /usr/bin/python3  (3.6.7-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              1.15.3
hash randomization: on (PYTHONHASHSEED=1519573050)

sympy/series/fourier.py[8] ........                                         [OK]

================== tests finished: 8 passed, in 4.96 seconds ===================
True
```
@smichr Moreover I observed that there a lot of places where we will be needing to include `dict` and `Dict` in `isinstance` checks. 
Therefore, I am working on @asmeurer 's suggestion.
> all the examples are passing

hmm...not sure why that would be. But if you make the change there then the flags will not be respected when producing the sympified output. Alternatively, we can say that those flags only apply to string input that does not appear in a container.
Passing strings to anything other than sympify is not really supported, but I don't see an issue with fixing just N() for this, since it's clear that it could help. However, there could be side effects for evaluate=False, since that also prevents evaluation of symbols expressions (like `N('x - x', 30)`). 
Maybe sympify() should gain a flag to change the precision of automatic evaluation. I wonder how difficult that would be to achieve. 
I also worried about side effects, so maybe the `evaluate=False` thing is indeed a bad idea.

Re: changing `sympify`: this sounds reasonable, maybe something like `sympify('2*0.1', default_float_dps=30)`.  l poked around; looks like `sympy.parsing.sympy_parser.auto_number` is where the `Float` is.  So this *might* be an easy fix, just need to ensure the new kwarg gets to `auto_number`.

Note: `sympify('0.12345678901234567890123456789')` already uses a high precision automatically (b/c Float does so).  So the default for `default_float_dps` should be `None` rather than 16).
Can I get more info on this?
So first of all, I'm not *sure* its "Easy to Fix", I only say it might be...

1.  Try `srepr(sympify('2*0.1'))`.  Note result has double precision (16 digits, 53 bits).

2.  Try `Float(sympify('2*0.1'), 32)`.  Note result has higher precision but is half-full of garbage.  Think about and understand why approach will never work.

3.  Implement `sympify('2*0.1'), default_float_dps=32)` which uses `Float(<str>, 32)` at the time the Float is first created.
@cbm755 @asmeurer  can I work on this issue?
Is it still open?

I believe it is still open. 

Another possible solution to this is for `N` to use `parse_expr`, and to add a flag that gets passed through to `auto_number` that sets the precision on the `Float` token. The way the tokenize transformations are designed this isn't particularly easy to do, though. Probably the simplest way would be for it to be its own transformation, which gets added after `auto_number`. 
then I'll start working on it...
@cbm755, @asmeurer   Could you explain what exactly is required in this issue ?
sorry if this is tedious for you but I'm a beginner, so your help will be highly appreciated.
Please explain what exactly is needed to be done in simple language as that will allow me to understand the problem correctly.
I'm not really sure what fix should be applied here. I'm partly thinking it should just be "won't fix", as string inputs to things other than `sympify` isn't really supported. But maybe the token transformer idea that adds the precision to `Float` calls could be useful, even if it isn't used directly by `N`. 
@asmeurer I agree.  I played with it a bit, take a look at #14824

@avishrivastava11 sorry for the misleading "easy-to-fix" label.  In general, if you're read over an issue, sunk a couple hours into the code a bit and still don't understand, then its probably not the right place to start!  Having said all that, do feel free to play with #14824 if you're interested in this topic.
@cbm755 
>@avishrivastava11 sorry for the misleading "easy-to-fix" label. In general, if you're read over an issue, sunk a couple hours into the code a bit and still don't understand, then its probably not the right place to start! Having said all that, do feel free to play with #14824 if you're interested in this topic.

Thanks for the comment. Do you mind if I make a PR using some ideas and code from your PR #14824 (you mentioned that the PR was only for discussion, and not for merging). I think I can solve this issue once and for all. Do you mind?

@avishrivastava11 you might want to discuss what you plan to do here first, to avoid wasting time implementing something that we would end up rejecting. I'm of the opinion that very little should be done here, as most of the proposed changes add a lot of complexity for a very marginal benefit. 
> Do you mind if I make a PR using some ideas and code from your PR ...

To answer this question in general: a good workflow is to checkout my branch, and make additional commits (on top of my existing commits).  This ensures appropriate attribution.
@cbm755 @asmeurer  I'll do that. Thanks.

> there could be side effects for evaluate=False, since that also prevents evaluation of symbols expressions (like `N('x - x', 30)`).

The evalf will release the expression and 0 will be returned. Test added in #16780 
If one wants arbitrary precision it is best to sympify with `rational=True` and not use `N` to sympify and evaluate:
```python
>>> S('2**.5', rational=True)
sqrt(2)
```
 The partial fix that I added to #16780 will only allow exact base-2 decimals but can't help the non-exact values:
```python
>>> (N('pi*.1', 22)*10-pi).n()
1.74393421862262e-16
>>> (N('pi/10', 22)*10-pi).n()
-2.11259981339749e-23
>>> (S('pi/10').n(22)*10-pi).n()
-2.11259981339749e-23
```