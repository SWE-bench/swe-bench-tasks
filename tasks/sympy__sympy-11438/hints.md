I would like to work on this issue. Please guide me

It appears it is not checking even if they are even, ~~but only if their sum is even.~~
(Edit: I was mistaken, `total_degree` is not the sum.)

``` python
>>> eq = x**3 + y**3 + z**4 - (1 + 8 + 81)
>>> classify_diop(eq)
([x, y, z], {1: -90, y**3: 1, z**4: 1, x**3: 1}, 'general_sum_of_even_powers')
>>> diophantine(eq)
set()
```

Also, if the powers are supposed to be the same, I think the name `'general_sum_of_even_powers'` is very misleading.

The relevant file is sympy/solvers/diophantine.py. One could start by checking the function `classify_diop`.

@karthikkalidas Are you working on this issue or still want to?

Otherwise I would like to work on it.

No you go ahead!

On 28 Jul 2016 01:18, "Gabriel Orisaka" notifications@github.com wrote:

> The relevant file is sympy/solvers/diophantine.py. One could start by
> checking the function classify_diop.
> 
> @karthikkalidas https://github.com/karthikkalidas Are you working on
> this issue or still want to?
> 
> Otherwise I would like to work on it.
> 
> —
> You are receiving this because you were mentioned.
> Reply to this email directly, view it on GitHub
> https://github.com/sympy/sympy/issues/11418#issuecomment-235698771, or mute
> the thread
> https://github.com/notifications/unsubscribe-auth/ASBqq4iJzsR9jQwGPX98PctLrYBjqOPHks5qZ7XwgaJpZM4JR3U1
> .
