The treatment of binomial was recently changed in #14019, it seems the docstring is out of date.
If I understand the discussion in #14019, `binomial` now uses Wolfram's gamma-limit rewrite, with some logic to handle edge-cases in the limit. In that case, shouldn't `binomial(n, k)` evaluate to 0 for negative integer `k`?

In either event, I do not think that #14019 modified the behavior for when `n` and `k` are equal. Both before and after its merging, `binomial(k, k)` would evaluate to 1.