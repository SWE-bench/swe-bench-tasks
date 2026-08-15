Agreed, fractional power logic should not apply to noncommutatives. Does your patch result in `x` or `x**3` for the substitution?
It results to `x**3`, so there's room for improvement.
If you're happy with `x**3` you can use `xreplace` instead of `subs` as a workaround. `xreplace` just does exact substitution, no mathematical manipulation. 