Thanks @mdickinson for reporting and looking into this.

I think that the simple fix is that we should reduce the threshold to 4503599761588224 and check the result before returning it with
```
if s**2 <= n and (s+1)**2 > n:
    return s
# Fall back to integer_nthroot
```
Using sqrt as a potential speed-boost is fine but the correctness of integer calculations in SymPy should not depend in any way on the underlying floating point configuration.

It might also be worth using a sqrt-specific integer root finder if timings show that it can be faster than integer_nthroot (for large or small integers):
https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division