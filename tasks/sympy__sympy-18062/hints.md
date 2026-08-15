It works with `ImageSet`:
```
In [1]: ImageSet(Lambda(n, 1 + I*n), Integers)                                                                                    
Out[1]: {ⅈ⋅n + 1 | n ∊ ℤ}
```
There are already issues but the `imageset` function should be stripped: the logic should go into `ImageSet` so that `imageset` is more or less `ImageSet(...).doit()`.
```
In [8]: ImageSet(Lambda(n, 1 + I*n), Integers)
Out[8]: {ⅈ⋅n + 1 | n ∊ ℤ}

In [9]: _.doit()
Out[9]: {ⅈ⋅n | n ∊ ℤ}
```
I suppose the canonicalization code is similar for `imageset` and `.doit()`. (Didn't check)
`ImageSet.doit` hands over to `SetExpr` so I would guess the problem is there.
It goes wrong here:
https://github.com/sympy/sympy/blob/3d2537a0a774e2842562c1cd54f4acaab8054be3/sympy/sets/handlers/functions.py#L206
At that point b should be 1 but it is zero because of this
https://github.com/sympy/sympy/blob/3d2537a0a774e2842562c1cd54f4acaab8054be3/sympy/sets/handlers/functions.py#L198
Thanks for tracking it down, so what goes wrong here is that this block:
https://github.com/sympy/sympy/blob/3d2537a0a774e2842562c1cd54f4acaab8054be3/sympy/sets/handlers/functions.py#L193-L198
should remove integer addends from `b`in case the variable's coefficient is +1 or -1, but it's erroneously executed for complex numbers with modulus=1. So changing the check to `if match[a] in [1, -1]:` is the correct fix for the present issue. So far so good.

But I'm also wondering about the intent of the next block:
https://github.com/sympy/sympy/blob/3d2537a0a774e2842562c1cd54f4acaab8054be3/sympy/sets/handlers/functions.py#L199-L204
Is my understanding correct, that lines 201-203 should remove unevaluated Mods introduced by line 200? If so, a good start would be to not call `b % match[a]` for non-real `b` in the first place :-)

Finally, there's a test that actually asserts the following:
https://github.com/sympy/sympy/blob/3d2537a0a774e2842562c1cd54f4acaab8054be3/sympy/sets/tests/test_fancysets.py#L917-L919
But that's plain wrong?

I'll submit a PR.
> But that's plain wrong?

Looks plain wrong to me