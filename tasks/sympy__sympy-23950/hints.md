My understanding of `p.as_set()` for a boolean `p` is that it should return a set representing {x | p}, where `x` is the free variable in `p`. It isn't implemented yet for more than one variable, and I'm not even sure what it would do in that case; I guess it should take the variables as arguments and return `{(x1, x2, ...) | p}`. 

So in short, if `x` is a symbol, `Contains(x, set).as_set()` should just return `set`.

More generally, the superclass Boolean should define as_set to return a ConditionSet so that it always works (at least for booleans with one free variable). 
> should just return `set`.

...unless contains is False in which case EmptySet should be returned, so
```python
Piecewise((set, Contains(x, set)), (EmptySet, True))
```
We shouldn't return a literal Piecewise. Piecewise doesn't have any of the methods of Set, so it won't work in any of the places that normal sets will. 

But yes, a false Boolean should give the empty set. I think if we return the general ConditionSet(var, boolean) then it will automatically reduce to the empty set when necessary. Or at least that logic belongs in ConditionSet if it isn't there already. 