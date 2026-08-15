This is not a possible solution i feel , since some of the tests are failing and also weirdly `solve_poly_system([2*x - 3, y*Rational(3, 2) - 2*x, z - 5*y], x, y, z)`  is throwing a `NotImplementedError` .
Hmm. Well, they should yield similar results: an error or a solution. Looks like maybe a solution, then, should be returned? I am not sure. Maybe @jksuom would have some idea.
It seems that the number of polynomials in the Gröbner basis should be the same as the number of variables so there should be something like
```
    if len(basis) != len(gens):
        raise NotImplementedError(...)
> It seems that the number of polynomials in the Gröbner basis should be the same as the number of variables

This raises a `NotImplementedError` for `solve_poly_system([x*y - 2*y, 2*y**2 - x**2], x, y)` but which isn't the case since it has a solution.
It looks like the test could be `if len(basis) < len(gens)` though I'm not sure if the implementation can handle all cases where `len(basis) > len(gens)`.
Yes this works and now `solve_poly_system((y - 1,), x, y)` also returns `NotImplementedError` , I'll open a PR for this.
I'm not sure but all cases of `len(basis) > len(gens)` are being handled.