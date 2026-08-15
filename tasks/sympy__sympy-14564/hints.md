It should mean  "set of all x in S for which condition(x) is True". The role of `x` is comparable to the role of an integration variable in a definite integral: It can be replaced by another symbol but it does not make sense to replace it by a number.

I think `ConditionSet(x,x>5,Interval(1,3))` should evaluate to `EmptySet`.
So it's like a filter? If so, then ConditionSet(x, x> 5, S.Reals) -> Interval.open(5, oo). If I understand correctly, it is similar to ImageSet. We could write `ImageSet(Lambda(x, 2*x), S.Integers)` or `ConditionSet(x, Eq(Mod(x, 2), 0), S.Integers)` to mean "the set of even integers". A difference, however, is that the former is iterable:

```
>>> it = iter(ImageSet(Lambda(x, 2*x), S.Integers))
>>> [next(it) for i in range(5)]
[0, 2, −2, 4, −4]
```
`ConditionSet(x,x>5,Interval(1,7)).subs(x, 8)` should be S.EmptySet
`ConditionSet(x,x>5,Interval(1,7)).subs(x, Symbol('n', negative=True)` should be unchanged: the dummy is not there to help with the condition, only to test idientify where the element from the `base_set` should be tested in the condition.
