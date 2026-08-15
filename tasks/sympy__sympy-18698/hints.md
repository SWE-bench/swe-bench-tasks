I guess correct can be either the first or the second. But we should stick to it.

This [SO post](https://stackoverflow.com/questions/57536689/sympys-sqf-and-sqf-list-give-different-results-once-i-use-poly-or-as-pol) highlights another problem, too:

```python
>>> v = (x1 + 2) ** 2 * (x2 + 4) ** 5
>>> sqf(v)
(x1 + 2)**2*(x2 + 4)**5
>>> sqf(v.expand())
(x1 + 2)**2  <-- where is the x2 factor?
```
The documentation is incomplete. The docstrings for low level methods in `sqfreetools` show that they are for univariate polynomials only but that is missing from `polytools`. The docstrings should be amended.

The issue in OP is valid. The `Poly` method works as expected:
```
>>> Poly((x**2 + 1)*(x - 1)**2*(x - 2)**3*(x - 3)**3, x).sqf_list()
(1, [(Poly(x**2 + 1, x, domain='ZZ'), 1), (Poly(x - 1, x, domain='ZZ'), 2), (Poly(x**2 - 5*x + 6, x, domain='ZZ'), 3)])
```
The two factors of multiplicity 3 are combined as they should be.

The `sqf_list` function fails to do that.
```
>>> sqf_list((x**2 + 1)*(x - 1)**2*(x - 2)**3*(x - 3)**3, x)
(1, [(x**2 + 1, 1), (x - 1, 2), (x - 3, 3), (x - 2, 3)])
```
It should scan the generic factor list and combine factors of same multiplicity before returning the list.
https://github.com/sympy/sympy/blob/e4259125f63727b76d0a0c4743ba1cd8d433d3ea/sympy/polys/polytools.py#L6218
Hi, I am new to the sympy community and was looking to contribute to the project. I wanted to ask @akritas what's wrong in having 2 factors of multiplicity 3? Also, if the second issue (on SO) is still open, then I would like to work on it, @jksuom can you guide me from where I should start? 


Sent from my iPad

> On 15 Dec 2019, at 5:24 PM, Akhil Rajput <notifications@github.com> wrote:
> 
> ﻿
> Hi, I am new to the sympy community and was looking to contribute to the project. I wanted to ask @akritas what's wrong in having 2 factors of multiplicity 3?
> 
Hi, 

The square free algorithm should pull out all factors of _same_ degree and present them as one product of given multiplicity (in this case one factor with roots of multiplicity 3).
> Also, if the second issue (on SO) is still open, then I would like to work on it, @jksuom can you guide me from where I should start?
> 
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub, or unsubscribe.

I would start with the docstrings. The squarefree methods are intended for univariate polynomials. The generator should be given as an input parameter. It may be omitted if there is no danger of confusion (only one symbol in the expression). Otherwise the result may be indeterminate as shown by the [example above](https://github.com/sympy/sympy/issues/8695#issuecomment-522278244).
@jksuom, I'm still unclear. There is already an option to pass generators as an argument to sqf_list(). Should the function automatically find the generators present in the expression? Please guide me what should I do. 
If there is only one symbol in the expression, then the function can find the generator automatically. Otherwise I think that exactly one symbol should be given as the generator.

Moreover, I would like to change the implementations of `sqf_list()` and related functions so that they would be based on the corresponding `Poly` methods. Then they would start by converting the input expression into `p = Poly(f, *gens, **args)` and check that `p` has exactly one generator. Then `p.sqf_list()` etc, would be called.
Then what will happen in case of multiple generators? Just confirming, generators here refer to symbols/variables.
> generators here refer to symbols/variables.

Yes.
> Then what will happen in case of multiple generators?

I think that ValueError could be raised. It seems that some kind of result is currently returned but there is no documentation, and I don't know of any reasonable use where the ordinary factorization would not suffice.
> If there is only one symbol in the expression, then the function can find the generator automatically. Otherwise I think that exactly one symbol should be given as the generator.
> 
> Moreover, I would like to change the implementations of `sqf_list()` and related functions so that they would be based on the corresponding `Poly` methods. Then they would start by converting the input expression into `p = Poly(f, *gens, **args)` and check that `p` has exactly one generator. Then `p.sqf_list()` etc, would be called.

@jksuom  In the helper function __symbolic_factor_list_ of sqf_list, the expression is already being converted to polynomial and then corresponding _sqf_list_ function is called. So, I should just ensure if the number of generators passed is one?
> I should just ensure if the number of generators passed is one?

If there is exactly one generator passed, then it is possible to call `_generic_factor_list` with the given arguments. However, it is necessary to post-process the result. In the example above, it returns

    (1, [(x**2 + 1, 1), (x - 1, 2), (x - 3, 3), (x - 2, 3)])

while `sqf_list` should return only one polynomial for each power. Therefore the two threefold factors `x - 3` and `x - 2` should be combined to give a single `(x**2 - 5*x + 6, 3)`.

It is probably quite common that no generators are given, in particular, when the expression looks like a univariate polynomial. This should be acceptable but more work is then necessary to find the number of generators. I think that it is best to convert the expression to a `Poly` object to see the generators. If there is only one, then the `sqf_list` method can be called, otherwise a `ValueError` should be raised.

It is possible that the latter procedure will be more efficient even if a single generator is given.
@jksuom I have created a PR (#18307)for the issue. I haven't done anything for multiple generator case as it was ambiguous. It would be great if you could review it. Thank you. 
@jksuom what can be done in case if the expression given is a constant (without any generators)? For example:  `sqf_list(1)`. We won't be able to construct a polynomial and PolificationFailed error will be raised.
I think that the error can be raised. It is typical of many polynomial functions that they don't work with constant expressions.