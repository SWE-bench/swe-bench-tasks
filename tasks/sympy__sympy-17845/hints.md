But may be I mistaken about of this printing policy. It is possible that this policy (as I described above) is outdated.

But I note, that only the `repr` must return valid code.
For `str` ( which prints for the user reading) it is not obligatory.

At least it is written in the docstrings of modules, as I understand.

**Labels:** Printing  

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c1
Original author: https://code.google.com/u/109448925098397033296/

Another idea, for the classes which can take Intervals as arguments, it is possible to use the short construction string.
```
In [3]: x = Symbol('x', real=True)

In [4]: Intersection(Interval(1, 3), Interval(x, 6))
Out[4]: [1, 3] ∩ [x, 6]

In [5]: str(Intersection(Interval(1, 3), Interval(x, 6)))
Out[5]: Intersection([1, 3], [x, 6])

The Out[5] can be valid not only as:
Out[5]: Intersection(Interval(1, 3), Interval(x, 6))
```
but and as
```
Out[5]: Intersection((1, 3), (x, 6))
```
if Intersection constructor can accept tuple and understand that it is Interval and parse correctly.

This case is only of the ends are not open. (Or for open? As it will be confused and strange that (1, 3) --> [1, 3] for `pprint`)

Unfortunately it is not possiblely to use `Intersection([1, 3], [x, 6])`, because 
arguments must be immutable.

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c2
Original author: https://code.google.com/u/109448925098397033296/

I think it is better not to connect Intersection and Interval too strongly.

Intersection will be used for many different kinds of classes, not just Interval. (1,2) could equally well refer to Interval(1,2) or FiniteSet(1,2). 

I think that creating the special syntax will create problems in the future. 

If, as you say in your first comment, it is not important for str(object) to be valid code to produce object then I think that this issue is not important.

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c3
Original author: https://code.google.com/u/109882876523836932473/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c4
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
We have moved issues to GitHub https://github.com/sympy/sympy/issues .

**Labels:** Restrict-AddIssueComment-Commit  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c5
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
We have moved issues to GitHub https://github.com/sympy/sympy/issues .
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3166#c6
Original author: https://code.google.com/u/asmeurer@gmail.com/

Is this issue still worth fixing? The printing of both FiniteSet and Interval has been unchanged for some time now. It would seem gratuitous to fix at at this point...
```python
>>> S(str(Interval(0,1)) )
Interval(0, 1)
>>> type(S(str(FiniteSet(0,1)) ))
<class 'set'>
```

Perhaps `set`, like `dict`, is just not handled yet by `sympify`.
Sympify will convert a `set` to a `FiniteSet` but doesn't recognise a set literal and passes that on to eval.
For the original issue this has already been changed for Interval but not FiniteSet:
```julia
In [1]: str(Interval(0, 1))                                                                                                                                   
Out[1]: 'Interval(0, 1)'

In [2]: str(FiniteSet(1))                                                                                                                                     
Out[2]: '{1}'
```
Changing this for FiniteSet does not seem problematic. PR underway...