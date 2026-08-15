If `x` and `y` denote `Symbol`s and not `Number`s, they remain in the set `a` when any numbers are removed. The result will be different when they denote numbers, e.g, `x = 5`, `y = 12`.
@jksuom @gxyd I Wish to solve this issue. Can you please tell me from where should i start?
Thank You.
I'd start by studying how the complement is computed in different cases.
@ayush1999 Are you still working on the issue?

It affects other types of sets than intervals as well
```python
>>> x,y = symbols("x y")
>>> F = FiniteSet(x, y, 3, 33)
>>> I = Interval(0, 10)
>>> C = ComplexRegion(I * I)
>>> Complement(F, C)
{33}
```
However in this case seems to be an issue with `contains` as
```python
>>> C.contains(x)
True
```
Another problem with symbols in sets
```python
>>> a, b, c = symbols("a b c")
>>> F1 = FiniteSet(a, b)
>>> F2 = FiniteSet(a, c)
>>> Complement(F1, F2)
{b} \ {c}
```
Which is incorrect if ``a = b``