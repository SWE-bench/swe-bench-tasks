The problem is with `Abs`:
```python
In [7]: e = S("im(acos(-i + acosh(-g + i)))")                                                        

In [8]: abs(e)
```
That leads to this:
https://github.com/sympy/sympy/blob/126f80578140e752ad5135aac77b8ff887eede3e/sympy/functions/elementary/complexes.py#L616-L621
and then `sqrt` leads here:
https://github.com/sympy/sympy/blob/126f80578140e752ad5135aac77b8ff887eede3e/sympy/core/power.py#L336
which goes to here:
https://github.com/sympy/sympy/blob/126f80578140e752ad5135aac77b8ff887eede3e/sympy/core/power.py#L418
And then that's trying to compute the same abs again.

I'm not sure where the cycle should be broken but the code in `Abs.eval` seems excessively complicated.

> That leads to this:

The test should be changed to:
```python
_arg = signsimp(arg, evaluate=False)
if _arg != conj or _arg != -conj:
```
 We should probably never come to this test when the argument is real. There should be something like `if arg.is_extended_real` before `conj` is computed.
There are tests for nonnegative, nonpositive and imaginary. So an additional test before coming to this part would be
```python
if arg.is_extended_real:
    return
...
_arg = signsimp(arg, evaluate=False)
if _arg not in (conj, -conj):
...
```