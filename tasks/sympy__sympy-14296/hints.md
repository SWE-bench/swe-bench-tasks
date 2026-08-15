In the Diofant:
```python
n [11]: b = 1 - sqrt(2)

In [12]: a = to_number_field(b)

In [13]: a.root
Out[13]: 
    ___    
- ╲╱ 2  + 1

In [14]: a.minpoly
Out[14]: PurePoly(_x**2 - 2*_x - 1, _x, domain='ZZ')

In [15]: a.coeffs()
Out[15]: [1, 0]
```
I think, that's correct.  C.f. with Sympy:
```
In [7]: b = 1 - sqrt(2)

In [8]: a = to_number_field(b)

In [9]: a
Out[9]: -1 + √2

In [10]: a.root
Out[10]: -√2 + 1

In [11]: a.coeffs()
Out[11]: [-1, 0]

In [12]: a.minpoly
Out[12]: PurePoly(_x**2 - 2*_x - 1, _x, domain='QQ')
```
That looks like the sign change was removed? I think that the sign should be the ignored in SymPy as well.
I don't know in deep but yes. I think the sign should be ignored(but maybe this property is used somewhere) as the number must retain its original sign.

well I found
```
>>> a.args
(-sqrt(2) + 1, (-1, 0))
```
and as done [here](https://github.com/sympy/sympy/blob/master/sympy/core/numbers.py#L2406) the `minpoly` of `obj` (`a` here) is `minimal_polynomial` of `b`.

We can also check type of `a` [here](https://github.com/sympy/sympy/blob/master/sympy/polys/numberfields.py#L640) and then return the minimal polynomial of `a.args[0]*a.args[1][0]`.
```
>>> minimal_polynomial(a.args[0]*a.args[1][0])
_x**2 + 2*_x - 1
```
> That looks like the sign change was removed?

@jksuom, apparently so.

> We can also check type of a here and then return the minimal polynomial of a.args[0]*a.args[1][0]

Great idea!  But why not ``a.args[0]*a.args[1][42]``?
`a.args[1]` has only two index 0 and 1. `a.args[1][0]` will be 1 for positive root and -1 for negative root.([here](https://github.com/sympy/sympy/blob/master/sympy/polys/numberfields.py#L2390)) . 

Should I add a PR to remove the sign change?
> a.args[1] has only two index 0 and 1

How did you know that?
Yes! Sorry my fault `len(sarg)` [here](https://github.com/sympy/sympy/blob/master/sympy/core/numbers.py#L2399) could be more than 2 if `alias` is present.

@skirpichev the PR you referenced seem to be of 'diofant' repository. can I open a PR to remove sign change of `a` when it negative in sympy. ?
> Sorry my fault len(sarg) here could be more than 2 if alias is present.

Wow!

> can I open a PR

Sure.