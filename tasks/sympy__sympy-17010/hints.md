Actually I just thought of a much simpler way. Look at the numeric term (the `coeff` from `as_coeff_Add`), and canonicalize based on whichever is closer to 0. If the numeric term is -1 (so that the term in -n - 2 is also -1), then use `(n + 1).could_extract_minus_sign()`. 

@smichr what do you think? 
> so that the term in -n - 2 is also -1

I am not following how this might be so -- can you tell me what the `n` is?

Also, what was `n` that cause the recursion error?
> I am not following how this might be so -- can you tell me what the n is?

```
>>> -(n - 1) - 2
-n - 1
```

Sorry for the confusion for `n` the arg name of `chebyshevu` and `Symbol('n')`. I should probably use a different symbol name for the example. 

> Also, what was n that cause the recursion error?

`chebyshevu(n - 1, x)`, but only in my branch, which has changed up the args ordering for Add and Mul. However, it seems you could probably find an example for master too, since `n.could_extract_minus_sign() == True` is no guarantee that `(-n - 2).could_extract_minus_sign() == False`. 
Here's an example that works in master: `chebyshevu(n - x - 2, x)`
So I'm suggesting 

```py
coeff, rest = n.as_coeff_Add()
if coeff > -1:
    n = -n - 2
elif coeff == -1:
    n = -n - 2 if rest.could_extract_minus_sign() else n
```

And similar logic for the other places in the file that have this problem. That will produce an arg with constant term closest to 0, using could_extract_minus_sign for the split case. 
Other instances of this I found in the file:

[`legendre`](https://github.com/sympy/sympy/blob/dceb708ca035c568c816d9457af1b7ca9e57c0a5/sympy/functions/special/polynomials.py#L790): `n` -> `-n - 1`

[`laguerre`](https://github.com/sympy/sympy/blob/dceb708ca035c568c816d9457af1b7ca9e57c0a5/sympy/functions/special/polynomials.py#L1088): `n` -> `n - 1`

For legendre the split case is `coeff == -S.Half`. For laguerre there is no split case, so we can just pick the original if the `coeff` is negative and `n - 1` otherwise. 
> no guarantee

What you are proposing in terms of keeping track of the split point makes sense. And I agree that could_extract makes no guarantee about a new expression derived from n.