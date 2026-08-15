Log is here, https://travis-ci.org/sympy/sympy/jobs/163790187
Permanent link, https://gist.github.com/isuruf/9410c21df1be658d168727018007a63a

ping @smichr 

Seeing jobs failing frequently now
https://travis-ci.org/sympy/sympy/jobs/164977570
https://travis-ci.org/sympy/sympy/jobs/164880234

It seems that the failure is generated in the following way.

```
>>> from sympy import cse
>>> from sympy.abc import a, c, i, g, l, m
>>> p = [c*g*i**2*m, a*c*i*l*m, g*i**2*l*m]
>>> cse(p)
([(x0, g*i), (x1, i*m)], [c*x0*x1, a*l*(c*i*m), l*x0*x1])
```

`c*i*m` is recognized as a common factor of the first two expressions, and is marked as a candidate by writing it in the form `(c*i*m)**1` by [`update`](https://github.com/sympy/sympy/blob/master/sympy/simplify/cse_main.py#L316). It is later abandoned as a part of `c*g*i**2*m` and is left alone in `a*c*i*l*m`. When its expression tree is rebuilt, the following results.

```
>>> from sympy import Mul, Pow
>>> Mul(a, l, Pow(c*i*m, 1, evaluate=False))
a*l*(c*i*m)
```

(`x0*x1 = g*i**2*m` is not recognized as a common subexpression for some reason.)

Do we have a fix for this? If not, let's revert the PR. @smichr 

@smichr, ping.

Just seeing this now. I thought that there was a line of code to remove exponents of "`1". I may be able to look at this tomorrow, but it's more realistic to expect a delay up until Friday. I'll see what I can do but if this is really a hassle for tests it can be reverted and I'll try again later.

Thanks for looking into this. We can wait for a few more days.

I am working on this...perhaps can finish before Monday. I am getting 3 different possibilities, @jksuom for the test expression you gave:

```
============================= test process starts =============================
executable:         C:\Python27\python.exe  (2.7.7-final-0) [CPython]
architecture:       32-bit
cache:              yes
ground types:       python
random seed:        36014997
hash randomization: on (PYTHONHASHSEED=643787914)

sympy\simplify\tests\test_cse.py[1] ([(x0, g*i), (x1, i*m)], [c*x0*x1, a*c*l*x1, l*x0*x1])
.                                      [OK]

================== tests finished: 1 passed, in 0.48 seconds ==================
rerun 3
============================= test process starts =============================
executable:         C:\Python27\python.exe  (2.7.7-final-0) [CPython]
architecture:       32-bit
cache:              yes
ground types:       python
random seed:        30131441
hash randomization: on (PYTHONHASHSEED=2864749239)

sympy\simplify\tests\test_cse.py[1] ([(x0, g*i), (x1, c*i*m)], [x0*x1, a*l*x1, i*l*m*x0])
.                                      [OK]

================== tests finished: 1 passed, in 0.37 seconds ==================
rerun 4
============================= test process starts =============================
executable:         C:\Python27\python.exe  (2.7.7-final-0) [CPython]
architecture:       32-bit
cache:              yes
ground types:       python
random seed:        20393357
hash randomization: on (PYTHONHASHSEED=1323273449)

sympy\simplify\tests\test_cse.py[1] ([(x0, g*i**2*m)], [c*x0, (c*i)*(a*l*m), l*x0])
.                                      [OK]
```

So it looks like I have to make this canonical, too.