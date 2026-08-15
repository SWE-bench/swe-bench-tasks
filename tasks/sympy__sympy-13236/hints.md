This is more important (bug):

```
>>> (factorial(n) % n).equals(0)
False
```

#8681 

There's no real way to assume that k is between 0 and n, so that one will have to wait. 

So it all boils down to the same idea: why won't we have another, fairly simple, "assumptions" method for reals, which generalizes the assumptions "nonnegative", "negative", "nonpositive" and "positive", to a "best known lower bound" (which is a tuple, a number and a boolean, where's the boolean signifies whether this is a strict or non-strict lower bound), which is `-oo` by default, and a "best known upper bound", which is the symmetric case.

This way, we can replace:
- `nonnegative=True` -> `lbound=0, False`
- `negative=True` -> `ubound=0, True`
- `nonpositive=True` -> `ubound=0, False`
- `positive=True` -> `lbound=0, True`

Such a system can help:
- fixing this issue (by checking if it is known for an integer `k` to have a "best known upper bound at most `n`, non-strict")
- fixing #8632, #8633 and #8636 as the assumption `integer` together with the assumption `positive` would imply "best known lower bound is 1, non-strict", and together with `even` it would imply "best known lower bound is 2, non-strict"
- fixing #8670 (at least the `<2` case), as the `sign` function will have some kind of `_eval_lbound` and `_eval_ubound` methods, returning, without further knowledge, non-strict -1 and non-strict 1 respectively.
- fixing #8675, as the `prime` assumption will imply "best known lower bound: 2, non-strict", or, together with `odd`, would imply "best known lower bound: 3, non-strict"

What do you think?

@skirpichev, do you think I should report a new issue for the `equals(0)` bug?

sure @asmeurer , I would love to chip in by the way

@pelegm, see https://github.com/sympy/sympy/pull/8687

I think a simpler way to represent inequalities is with `a > b` == `Q.positive(a - b)`. 

or `(a - b).is_positive`...

I don't get it. How can you use `Q.positive(a - b)` to achieve this? For example, how can I let the `sign` function "know" that its value is at least -1 using such a method?

On Wed, Dec 31, 2014 at 01:53:39AM -0800, Peleg wrote:

>    I don't get it. How can you use Q.positive(a - b) to achieve this? For
>    example, how can I let the sign function "know" that its value is at least
>    -1 using such a method?

Q.positive(a + 1)

I apologize, but I still don't get it. What is `a`? What is the method / property that I have to add to the `sign` class in order to be able to see that `(sign(x)+1).is_nonnegative` for every real `x`? Where do I use `Q` to achieve this?

My proposition regarding the bounds can also help solving #8533. I agree with @asmeurer that doing so with inequalities is probably a better idea, but I was wondering **(a)** whether this is possible in the "old" assumptions system, and **(b)** how can I really implement it in the "new" assumptions system.
