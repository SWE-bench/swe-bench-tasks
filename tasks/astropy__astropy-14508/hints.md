Agreed this is a bug. As far as I know, python floats by default now have reprs that use the right number of digits to be reproducible. So I think replacing this by `value_str = str(value)` should be totally fine. Do you want to try that and run the tests, to see if it works?  If so, I think we should make that change (i.e., make it into a PR).

If there isn't a test already, we should add one.  E.g.,

`value = (1-2**-53) * 2 ** exp` with `exp=[-60, 0, 60]` should give decent coverage.
Hi @mhvk thank you for the answer. I will try to create a PR today.
Agreed, and already discussed in #5449 where we came to the same conclusion, using `str` seems the best option. 