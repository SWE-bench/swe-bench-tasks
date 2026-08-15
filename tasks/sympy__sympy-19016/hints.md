Also,
```
>>> n = Symbol('n', integer=True)
>>> Range(n, -oo).size
oo
```
Even though the size should be zero, because since n is an integer, it must be greater than -oo, therefore Range(n, -oo) would be empty.
The previous problem arises because in Range.size, it says:
```
if dif.is_infinite:
    return S.Infinity
```
We should change this to:
```
if dif.is_infinite:
    if dif.is_positive:
        return S.Infinity
    if dif.is_negative:
        return S.Zero
```
I probed into the previous error a little further, and realized that
```
>>> a = -oo
>>> a.is_negative
False
>>> a.is_positive
False
```
Is this a choice of convention or something?
