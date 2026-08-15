Interval should represent a real interval. I think we decided in another issue that Interval should always be open for infinite boundaries, because it should always be a subset of S.Reals. So 

```
>>> Interval(oo, oo)
{oo}
```

is wrong.  I'm going to modify the issue title to make this clearer. 

Regarding your other points, note that `in` means "is contained in", not "is subset of". So `<set of numbers> in <set of numbers>` will always give False. I'm really not following your other points, but note that both `S.Reals` and `S.Naturals` (the latter is a subset of the former) contain only _finite_ numbers, so `oo` is not contained in either). 
