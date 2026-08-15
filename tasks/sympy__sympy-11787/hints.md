Using a different solver gives the right answer:

``` py
>>> nsolve(diff(E.subs(sols[0]), t), (.5, 0.9), solver='bisect')
mpf('0.70295119676297064')
```

`nsolve` only uses the numerator of the expression...and the numerator is close to zero at the reported root so it fools the solver.

So we should probably make it not just use the numerator. Numerically, the denominator can be significant if it is near 0 where the numerator is. 

It's probably better to make nsolve just use whatever function it is given and leave the choice of what function to use (numerator or rational expression) up to the user. The problem with leaving a denominator is that the singularities often cause problems for root solvers. But sometimes, as here, you get problems if you ignore the denominator.
