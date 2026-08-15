Looks like the printer has the precedence order wrong for - and %
A more direct reproduction

```py
>>> pycode(-Mod(x, y))
'-x % y'
```
hi @asmeurer i  should i please take this up !!

please do reply ..
thanks:-)
Hello anyone working on this?? I would like to help.

I want to contribute on this issue. Is this issue still open?
Is this issue still open? I would like to contribute.
Can i work on this one...or someone's already working on it?
It seems to me that all that should be done is just add the key 'Mod' with its value smaller than that of 'Mul' to the map objects PRECEDENCE and PRECEDENCE_VALUES in sympy/sympy/printer/precedence.py. Being new in Sympy, though, I might be missing some viewpoints. Do any tutor agree with this idea? And if so, how much should the value be (maybe 45 or 49, given that of 'Add' is 40 and that of 'Mul' is 50?)
Oops! I found this doesn't work in cases like -Mod(x, y), because the precedence of Mul object drops to 40 if the coefficient is negative. What is this rule for? I'm thinking of just doing away with this rule.
@kom-bu I was doing this change of PRECEDENCE for MOD (to be a little bit less), but it eventually caused failings on many tests (cause some of the printing uses Mod(x,y) and some x % y and so the PRECEDENCE changes with each printing method). I have added a predefined PRECEDENCE for each printing method to fix this, and maybe it resolves #18788 too.
i want to work in this issue,,,or someone is working on this issue or not?


@itsamittomar I have a PR for this issue, but I'm not sure what is the status of this PR right now.
@danil179 so can I  solve this issue
I suppose, the issue is not `Mod` itself.
I found [this line](https://github.com/sympy/sympy/blob/8a64de4322db8b1195e930e86fabd925e85e19ea/sympy/utilities/lambdify.py#L740):
```
if modules is None:
    ... # adding standard modules to list
```

As we can see, there is no check if `modules` is an empty list -- we only check if it's `None`.
I came up with a solution: we could check if `modules` is None or if `len(modules) == 0`.

I think I'll write it right now and link the PR to this issue. 
Is someone working on this issue? I would like to work on this.
@hardikkat24, I sent a PR a couple of days ago. It is still not approved nor rejected. I think, that we should wait for feedback on that.
I want to work on #17737 issue. May be the precedence causes the error . Allow me to work on this issue.
There is a PR #20507 that seems to fix this but has merge conflicts. I'm not sure if it fixes the precedence issue with `pycode` though.
I resolved the merge conflicts from #20507 and added a small additional check that the values are not only the same, but also correct. This is now #22032.

The `pycode` issue is still not correct though.