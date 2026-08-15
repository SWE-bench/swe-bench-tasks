At a glance, I don't see any version change in numpy, hypothesis, etc. Is this transient? 🤔 (Restarted the failed job.)
OK passed now. Sorry for the noise.
Looks to me like a genuine failing example, where the computed error is different depending on the order of the arguments:

```python
@example(f1=-3.089785075544792e307, f2=1.7976931348623157e308)
@given(st.floats(), st.floats())
def test_two_sum_symmetric(f1, f2):
    f1_f2 = two_sum(f1, f2)
    f2_f1 = two_sum(f2, f1)
    note(f"{f1_f2=}")
    note(f"{f2_f1=}")
    numpy.testing.assert_equal(f1_f2, f2_f1)
```
```python-traceback
---------------------------------------------- Hypothesis ----------------------------------------------- 
Falsifying explicit example: test_two_sum_symmetric(
    f1=-3.089785075544792e+307, f2=1.7976931348623157e+308,
)
f1_f2=(1.4887146273078366e+308, nan)
f2_f1=(1.4887146273078366e+308, -9.9792015476736e+291)
```

This might have been latent for a while, since it looks like it only fails for args *very* close to the maximum finite float64, but there you are.  You might also take this as an argument in favor of persisting the database between CI runs, to avoid losing rare failures once you find them.
Thanks for the clarification, @Zac-HD ! I re-opened the issue and marked it as a real bug.