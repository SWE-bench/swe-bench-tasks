Which test fails? Can you show the output?
I get this:
```julia
In [3]: test('sympy/integrals/tests/test_integrals.py')                                                                           
====================================================== test process starts =======================================================
executable:         /Users/enojb/current/sympy/38venv/bin/python3  (3.8.1-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.18.1
random seed:        60973393
hash randomization: on (PYTHONHASHSEED=1425060088)

sympy/integrals/tests/test_integrals.py[170] .........................................w...........................................
.w.................................ww..w.................w...........................                                         [OK]

_________________________________________________________ slowest tests __________________________________________________________
test_issue_14709b - Took 15.659 seconds
test_issue_15494 - Took 158.030 seconds
test_heurisch_option - Took 1853.602 seconds
test_issue_15292 - Took 1904.802 seconds
==================================== tests finished: 164 passed, 6 skipped, in 387.00 seconds ====================================
Out[3]: True
```
> Which test fails? Can you show the output?

It originally failed on the travis in my PR, without any obvious correlation. I tried it out on master and it failed.
https://travis-ci.org/github/sympy/sympy/jobs/678494834
I got a MaxRecursionDepthExceeded error locally
lemme check now.
```python3
(sympy-dev-py35) mosespaul@eiphohch0aYa sympy2 % git checkout master
Switched to branch 'master'
Your branch is up to date with 'upstream/master'.
(sympy-dev-py35) mosespaul@eiphohch0aYa sympy2 % 
(sympy-dev-py35) mosespaul@eiphohch0aYa sympy2 % python             
Python 3.5.5 | packaged by conda-forge | (default, Jul 23 2018, 23:45:11) 
[GCC 4.2.1 Compatible Apple LLVM 6.1.0 (clang-602.0.53)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from sympy import *
>>> test('sympy/integrals/tests/test_integrals.py')
============================================== test process starts ==============================================
executable:         /Users/mosespaul/opt/anaconda3/envs/sympy-dev-py35/bin/python  (3.5.5-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              1.18.2
random seed:        26459015
hash randomization: on (PYTHONHASHSEED=3435787296)

sympy/integrals/tests/test_integrals.py[170] .........................................w..........................
..................w.................................ww..w.................w...............EEEEEEE..EE.     [FAIL]

_________________________________________________ slowest tests _________________________________________________
test_issue_4326 - Took 10.348 seconds
test_principal_value - Took 14.216 seconds
test_issue_14709b - Took 24.464 seconds
test_heurisch_option - Took 26.285 seconds
_________________________________________________________________________________________________________________
___________________________ sympy/integrals/tests/test_integrals.py:test_issue_14709b ___________________________
Traceback (most recent call last):
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 454, in getit
    return self._assumptions[fact]
KeyError: 'zero'

During handling of the above exception, another exception occurred:
```

Idk how the travis test passes now tho 😅 !
The particular test passes fine for me:
```
$ bin/test sympy/integrals/tests/test_integrals.py -k test_issue_14709b
====================================================== test process starts =======================================================
executable:         /Users/enojb/current/sympy/38venv/bin/python  (3.8.1-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.18.1
random seed:        54449122
hash randomization: on (PYTHONHASHSEED=1089598020)

sympy/integrals/tests/test_integrals.py[1] .                                                                                  [OK]

_________________________________________________________ slowest tests __________________________________________________________
test_issue_14709b - Took 17.960 seconds
=========================================== tests finished: 1 passed, in 18.62 seconds ===========================================
```
Unfortunately you haven't included the interesting part of the traceback.
It's pretty long ... a Max Recursion Error
here's the gist https://gist.github.com/iammosespaulr/8acb42e9c79a126d582d66ef6c595635
and it miraculously works now 🤣 
```python3
sympy/integrals/tests/test_integrals.py[1] .                                                                 [OK]

_________________________________________________ slowest tests _________________________________________________
test_issue_14709b - Took 25.064 seconds
================================== tests finished: 1 passed, in 25.85 seconds ===================================
```
I'm so confused
Does it still work if you run all the tests the same way you did before?

The interesting part of the traceback is this:
```
Traceback (most recent call last):
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/tests/test_integrals.py", line 1619, in test_issue_14709b
    i = integrate(x*acos(1 - 2*x/h), (x, 0, h))
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 1553, in integrate
    return integral.doit(**doit_flags)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 490, in doit
    did = self.xreplace(reps).doit(**hints)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 602, in doit
    function, xab[0], **eval_kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 1100, in _eval_integral
    for arg in result.args
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 1100, in <listcomp>
    for arg in result.args
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/operations.py", line 378, in doit
    terms = [term.doit(**hints) for term in self.args]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/operations.py", line 378, in <listcomp>
    terms = [term.doit(**hints) for term in self.args]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 602, in doit
    function, xab[0], **eval_kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/integrals.py", line 1077, in _eval_integral
    h = meijerint_indefinite(g, x)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/meijerint.py", line 1622, in meijerint_indefinite
    res = _meijerint_indefinite_1(f.subs(x, x + a), x)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/integrals/meijerint.py", line 1688, in _meijerint_indefinite_1
    r = hyperexpand(r.subs(t, a*x**b), place=place)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 2491, in hyperexpand
    return f.replace(hyper, do_replace).replace(meijerg, do_meijer)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/basic.py", line 1494, in replace
    rv = bottom_up(self, rec_replace, atoms=True)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/simplify.py", line 1152, in bottom_up
    rv = F(rv)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/basic.py", line 1475, in rec_replace
    new = _value(expr, result)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/basic.py", line 1423, in <lambda>
    _value = lambda expr, result: value(*expr.args)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 2488, in do_meijer
    allow_hyper, rewrite=rewrite, place=place)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 2373, in _meijergexpand
    t, 1/z0)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 2346, in do_slater
    t, premult, au, rewrite=None)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 2056, in _hyperexpand
    r = carryout_plan(formula, ops) + p
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 1977, in carryout_plan
    make_derivative_operator(f.M.subs(f.z, z0), z0))
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 1507, in apply_operators
    res = o.apply(res, op)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 986, in apply
    diffs.append(op(diffs[-1]))
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/simplify/hyperexpand.py", line 1494, in doit
    r = z*C.diff(z) + C*M
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/matrices/common.py", line 2387, in __mul__
    return self.multiply(other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/matrices/common.py", line 2412, in multiply
    m = self._eval_matrix_mul(other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/matrices/dense.py", line 159, in _eval_matrix_mul
    vec = [mat[a]*other_mat[b] for a, b in zip(row_indices, col_indices)]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/matrices/dense.py", line 159, in <listcomp>
    vec = [mat[a]*other_mat[b] for a, b in zip(row_indices, col_indices)]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 251, in _func
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/expr.py", line 198, in __mul__
    return Mul(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/operations.py", line 52, in __new__
    c_part, nc_part, order_symbols = cls.flatten(args)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 603, in flatten
    if any(c.is_finite == False for c in c_part):
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 603, in <genexpr>
    if any(c.is_finite == False for c in c_part):
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 458, in getit
    return _ask(fact, self)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 501, in _ask
    a = evaluate(obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/add.py", line 615, in _eval_is_odd
    l = [f for f in self.args if not (f.is_even is True)]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/add.py", line 615, in <listcomp>
    l = [f for f in self.args if not (f.is_even is True)]
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 458, in getit
    return _ask(fact, self)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 501, in _ask
    a = evaluate(obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 1466, in _eval_is_even
    is_integer = self.is_integer
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 458, in getit
    return _ask(fact, self)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 501, in _ask
    a = evaluate(obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 1259, in _eval_is_integer
    _self = n/d
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 251, in _func
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/expr.py", line 235, in __div__
    return Mul(self, Pow(other, S.NegativeOne))
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/power.py", line 317, in __new__
    obj = b._eval_power(e)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 639, in _eval_power
    Pow(Mul._from_args(nc), e, evaluate=False)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 251, in _func
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/expr.py", line 198, in __mul__
    return Mul(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/operations.py", line 52, in __new__
    c_part, nc_part, order_symbols = cls.flatten(args)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 197, in flatten
    if not a.is_zero and a.is_Rational:
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 458, in getit
    return _ask(fact, self)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 513, in _ask
    _ask(pk, obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 501, in _ask
    a = evaluate(obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 1466, in _eval_is_even
    is_integer = self.is_integer
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 458, in getit
    return _ask(fact, self)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/assumptions.py", line 501, in _ask
    a = evaluate(obj)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 1259, in _eval_is_integer
    _self = n/d
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 89, in __sympifyit_wrapper
    return func(a, b)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/numbers.py", line 1766, in __div__
    return Number.__div__(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 89, in __sympifyit_wrapper
    return func(a, b)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/numbers.py", line 765, in __div__
    return AtomicExpr.__div__(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 251, in _func
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/expr.py", line 235, in __div__
    return Mul(self, Pow(other, S.NegativeOne))
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/power.py", line 317, in __new__
    obj = b._eval_power(e)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/mul.py", line 639, in _eval_power
    Pow(Mul._from_args(nc), e, evaluate=False)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 251, in _func
    return func(self, other)
  File "/Users/mosespaul/Desktop/Coding/GSoC/sympy2/sympy/core/decorators.py", line 127, in binary_op_wrapper
```
> Does it still work if you run all the tests the same way you did before?

No it doesn't, only individually
I can reproduce this with Python 3.5 (not 3.8).
Running under pytest I see a bunch of failures and the the interpreter crashes:
```
$ pytest sympy/integrals/tests/test_integrals.py
====================================================== test session starts =======================================================
platform darwin -- Python 3.5.7, pytest-4.3.1, py-1.8.0, pluggy-0.9.0
hypothesis profile 'default' -> database=DirectoryBasedExampleDatabase('/Users/enojb/current/sympy/sympy/.hypothesis/examples')
architecture: 64-bit
cache:        yes
ground types: gmpy 2.0.8

rootdir: /Users/enojb/current/sympy/sympy, inifile: pytest.ini
plugins: xdist-1.27.0, instafail-0.4.1, forked-1.0.2, doctestplus-0.3.0, cov-2.7.1, hypothesis-4.32.3
collected 170 items                                                                                                              

sympy/integrals/tests/test_integrals.py .................................................................................. [ 48%]
.......................................F.FFF..FFF.F...FF.FFFAbort trap: 6
```
Truly strange, any idea how the CI test seems to pass ?
It seems to depend on running the tests in a particular order like `test_x` fails if run after `test_y` but not otherwise. It's possible that travis doesn't run both tests in the same split or that it ends up doing them in a different order. The fact that this happens on Python 3.5 also hints at the possibility that dict ordering is involved since 3.5 has non-deterministic dict ordering.
Bisected to e092acd6d9ab083479a96ce1be7d0de89c7e6367 from #19155 @smichr 
I'd guess that this leads to infinite recursion:
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L1260-L1261
Probably `A.is_integer` leads to `B.is_integer` which leads back to `A.is_integer`.

We need to identify the object that is `self` at that line in the infinite recursion.
@oscarbenjamin Now I remember!
@smichr and I worked on that together, we were getting infinite recursions earlier in the tests, thought we fixed those.
IIRC it was with retrieving the assumptions for something. possibly `rational` or `integer`
Actually this is the line that leads infinite recursion:
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L1259
This is why we should avoid evaluating new objects during an assumptions query. It's very hard to know what other assumptions query that evaluation can lead to.
This is what I get from the debugger:
```
(Pdb) p self
1/(5*_t**3)
(Pdb) p n
1
(Pdb) p d
5*_t**3
(Pdb) p n/d
*** RecursionError: maximum recursion depth exceeded while calling a Python object
```
There are no assumptions on `_t` (except `commutative=True`). I can't reproduce that outside though so it somehow depends on what has happened in the previous tests that have run.

My guess is that this is an interaction between the assumptions system and the cache.
is there like a shortcut to search through the thread on a PR @oscarbenjamin . There are a couple comments related to this on PR #18960 .They might help but I can't seem to find em, lots of comments.
This line is also involved:
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L1442

There are two basic principles broken here:
1. Assumptions queries should not evaluate new objects
2. An assumption query for `self.is_x` should not directly use `self.is_y` (only properties of args should be queried in this way).
So like, 
```python3
>>> srepr(n/d)
"Mul(Symbol('n'), Pow(Symbol('d'), Integer(-1)))"
```
which is again `Mul`
so `(n/d).is_integer` calls `Mul.is_integer` again and so on right ?
When we get to here in `Mul._eval_is_integer`
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L1257-L1259
self is `1/(35*_t**2)` which is `Mul(Rational(1, 35), Pow(_t, -2))` so `n` becomes `1` and `d` becomes `35*_t**2`. Dividing those leads to
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/expr.py#L234-L235
at which points `self` is `1` and `other` is `35*_t**2`. Evaluating the Pow leads to
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/power.py#L317
at which point `b` is `35*_t**2` and `e` is `-1`. The leads through to `Mul._eval_power` here
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L637-L639
In this product the first term is `1/(35*_t**2)` (the expression we started with) and the other is `Pow(1, -1, evaluate=False)` i.e. `1/1`. Multiplying them leads to a `Mul` which leads to `Mul.flatten` and this line:
https://github.com/sympy/sympy/blob/8c94b6428b4d5783077cea1afe9fcbad2be3ec91/sympy/core/mul.py#L197
At this point `a` is `1/(35*t**2)` which is the same expression we start with and we query `a.is_zero`. Since `a._eval_is_zero()` gives None the assumptions resolver tries other facts to make the determination which ultimately leads to `_eval_Is_integer` completing the recursion.
@oscarbenjamin I might've found a fix
```python3
sympy/integrals/tests/test_integrals.py[170] .........................................w.............................
...............w.................................ww..w.................w...........................             [OK]

__________________________________________________ slowest tests ___________________________________________________
test_issue_8614 - Took 10.107 seconds
test_issue_4326 - Took 10.391 seconds
test_issue_17671 - Took 17.036 seconds
test_issue_14709b - Took 26.858 seconds
test_principal_value - Took 26.942 seconds
test_heurisch_option - Took 26.991 seconds
test_issue_15494 - Took 343.391 seconds
============================= tests finished: 164 passed, 6 skipped, in 697.33 seconds =============================
True
>>> Mul(pi, 1/E, 2*E, 3/pi, evaluate=False).is_integer
True
```
the simplification works too!
Does the fix remove the `n/d`?
Something like this ...
```python3
        is_rational = self._eval_is_rational()
        if is_rational is False:
            return False

        n, d = fraction(self)
        if is_rational:
            if d is S.One:
                return True
            elif d == S(2):
                return n.is_even
        # if d is even -- 0 or not -- the
        # result is not an integer
        if n.is_odd and d.is_even:
            return False
        if not is_rational:
            if n.has(d):
                _self = Mul(n, Pow(d, -1))
                if _self != self:
                    return _self.is_integer
```
> Does the fix remove the `n/d`?

kinda ? like it only does the n/d if it's worth it ?
I think that evaluating `n/d` is flakey and will lead to other problems. It's basically recreating `self` and then calling `is_integer` on it again which is asking for infinite recursion.
> I think that evaluating `n/d` is flakey and will lead to other problems. It's basically recreating `self` and then calling `is_integer` on it again which is asking for infinite recursion.

Ahhhh, in that case, How you do suggest approaching this ?
This was discussed here https://github.com/sympy/sympy/pull/19130#discussion_r410687628

The assumptions code (e.g. `_eval_is_integer`) should avoid creating *any* new objects. In exceptional cases where objects are created it should only be "smaller" objects.
What is the reason for using `n/d` in the first place?
> What is the reason for using `n/d` in the first place?

checking is_integer for expr like these, without evaluating
```python3
Mul(pi**2, 1/(E*pi), 2*E, 3/pi, evaluate=False)
```
Originally we had other reasons, I can't seem to remember 😅.

> without evaluating

Using `n, d = fraction(self); _self = n/d` *is* evaluating the expression.

Sometimes it isn't possible to resolve a query like `is_integer` without evaluating but that just means it should remain unresolved until the user chooses to evaluate. If the user wants to evaluate then they shouldn't use `evaluate=False`.
Okay I found the reason we upgraded `Mul.is_integer`
https://github.com/sympy/sympy/pull/18960#issuecomment-608410521
we had a stress testing script for the new multinomial function with this line
```python3
assert multinomial(*t).is_integer == multinomial(*s).is_integer
```
where `*t` were the original values and `*s` were dummies built using the assumptions of `*t` and we tested em.

there were a lot of places where Mul.is_integer wouldn't evaluate to True, even in a lot of obvious cases. hence the upgrade
> there were a lot of places where Mul.is_integer wouldn't evaluate to True, even in a lot of obvious cases. hence the upgrade

It is expected that `is_integer` will not always resolve.

I tried the following diff from master:
```diff
diff --git a/sympy/core/mul.py b/sympy/core/mul.py
index 0bbd2fb67a..31fd0890d6 100644
--- a/sympy/core/mul.py
+++ b/sympy/core/mul.py
@@ -1256,9 +1256,7 @@ def _eval_is_integer(self):
 
         n, d = fraction(self)
         if not is_rational:
-            _self = n/d
-            if _self != self:
-                return _self.is_integer
+            pass
         if is_rational:
             if d is S.One:
                 return True
```
Running all of the core tests the only failure I got was
```
    def test_Mul_is_irrational():
        expr = Mul(1, 2, 3, evaluate=False)
        assert expr.is_irrational is False
        expr = Mul(1, I, I, evaluate=False)
>       assert expr.is_rational is True # I * I = -1
E       assert None is True
E        +  where None = I*I.is_rational
```
That particular test was changed in the commit e092acd leading to this issue.

Does anything else in the code depend on this?
> It is expected that `is_integer` will not always resolve.

This is the earlier version of the code we changed in `test_arit.py` @ https://github.com/sympy/sympy/commit/e092acd6d9ab083479a96ce1be7d0de89c7e6367

```python3
     expr = Mul(1, I, I, evaluate=False) 
     assert expr.is_irrational is not False 
```
This was Wrong. `-1 is def not irrational`

---

btw I the patch I pushed also failed that same test