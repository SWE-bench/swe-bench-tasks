I would like to work on fixing this issue.
> 
> 
> I would like to work on fixing this issue.

Are you still working on this issue?

I am sorry, did not manage to work on this yet, trying to resume.
I believe that the issue is being cause by `Factors.div`, where the behvaior for `a*2` and `a/2` changes:
https://github.com/sympy/sympy/blob/aefdd023dc4f73c441953ed51f5f05a076f0862f/sympy/simplify/radsimp.py#L618-L621
```python
>>> Factors(a/2)
Factors({1/2: 1, a: 1})
>>> Factors(2*a)
Factors({2: 1, a: 1})
>>> Factors(1/2)
Factors({0.500000000000000: 1})
>>> Factors(2)
Factors({2: 1})
>>> Factors(1/2*a).div(Factors(1/2))
(Factors({a: 1}), Factors({}))
>>> Factors(2*a).div(Factors(1/2))
(Factors({2: 1, a: 1}), Factors({0.500000000000000: 1}))
>>> Factors(a/2).div(Factors(1/2))
(Factors({1/2: 1, a: 1}), Factors({0.500000000000000: 1}))
```
I don't know if this will take changes to the `Factors` class or the `collect_const()` function.
Please do tell me what the expected behavior for both these functions should be, and if everything here looks OK.
> Factors({1/2: 1, a: 1})

I think that this is expected to be `Factors({2: -1, a: 1})`, in the same way as `Factors(S(1)/2)` becomes `Factors({2: -1})`.
This is what I wanna do to fix the issue, the problem is that the Number Half is not a rational, any way around this issue?
```python
factors = dict(Mul._from_args(c).as_powers_dict())
# Handle all rational Coefficients
for f in factors.keys():
    if type(f) is Rational:
        factors[f.p] = (factors[f.p] if f.p in factors else 0) + factors[f]
        factors[f.q] = (factors[f.q] if f.q in factors else 0) - factors[f]
        factors.pop(f)
```
After this, I think that the original issue would be solved, as when I make this change, `1/3` gets collected as a constant outside the brackets, as desired. I have just put in a special case for `1/2 (S.Half)`, currently solving the issue.
```python
>>> var('a:d')
(a, b, c, d)
>>> f = a + b + c / 3 + d / 3
>>> print(collect_const(f, Rational(1, 3), Numbers=True))
a + b + (c + d)/3
```