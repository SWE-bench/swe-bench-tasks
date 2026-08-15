My first thought is that the following

```
202             if not old and (expr.is_Add or expr.is_Mul):
203                 if newexpr.count_ops() > expr.count_ops():
```

should be

```
if not old and (expr.is_Add or expr.is_Mul):
    len(expr.func.make_args(newexpr)) > len(expr.args):
```

Here is a pyinstrument profile of count_ops:

https://rawgit.com/moorepants/b92b851bcc5236f71de1caf61de98e88/raw/8e5ce6255971c115d46fed3d65560f427d0a44aa/profile_count_ops.html

I've updated the script so that it also calls `jacobian()` and found that for n>3 there are wildly different results. It seems that count_ops is called somewhere in jacobian if n>3.

Profile from n=3:

https://rawgit.com/moorepants/b92b851bcc5236f71de1caf61de98e88/raw/77e5f6f162e370b3a35060bef0030333e5ba3926/profile_count_ops_n_3.html

Profile from n=4 (had to kill this one because it doesn't finish):

https://rawgit.com/moorepants/b92b851bcc5236f71de1caf61de98e88/raw/77e5f6f162e370b3a35060bef0030333e5ba3926/profile_count_ops_n_4.html

This gist: https://gist.github.com/moorepants/b92b851bcc5236f71de1caf61de98e88

I'm seeing that _matches_commutative sympy/core/operations.py:127 is whats taking so much time. This calls some simplification routines in the fraction function and count_ops which takes for ever. I'm not sure why `_matches_commutative` is getting called.

The use of matches in the core should be forbidden (mostly):
```
>>> from timeit import timeit
>>> timeit('e.match(pat)','''
... from sympy import I, Wild
... a,b=Wild('a'),Wild('b')
... e=3+4*I
... pat=a+I*b
... ''',number=100)
0.2531449845839618
>>> timeit('''
... a, b = e.as_two_terms()
... b = b.as_two_terms()
... ''','''
... from sympy import I, Wild
... a,b=Wild('a'),Wild('b')
... e=3+4*I
... pat=a+I*b
... ''',number=100)
0.008118156473557292
>>> timeit('''
... pure_complex(e)''','''
... from sympy import I
... from sympy.core.evalf import pure_complex
... e = 3+4*I''',number=100)
0.001546217867016253
```
Could you run this again on my `n` branch?
Much improved. It finishes in a tolerable time:

```
In [1]: from pydy.models import n_link_pendulum_on_cart

In [2]: sys = n_link_pendulum_on_cart(3)

In [3]: x_dot = sys.eom_method.rhs()

In [5]: %time jac = x_dot.jacobian(sys.states)
CPU times: user 1.85 s, sys: 0 ns, total: 1.85 s
Wall time: 1.85 s

In [6]: sys = n_link_pendulum_on_cart(4)

In [7]: x_dot = sys.eom_method.rhs()

In [8]: %time jac = x_dot.jacobian(sys.states)
CPU times: user 22.6 s, sys: 8 ms, total: 22.6 s
Wall time: 22.6 s
```