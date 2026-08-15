I think I might have figured out what the problem is.

Here is a snippet from `def _repr_compare` function of `class ApproxNumpy`, there is a check for when the `other_value` (which is the divisor) is 0.0
https://github.com/pytest-dev/pytest/blob/857e34ef8555c48cb5c44f143a0d6692efb6c60f/src/_pytest/python_api.py#L186-L195

Here is a snippet from `def _repr_compare` function of `class ApproxMapping`, there is no such check for the case  when  `approx_value.expected` (which is the divisor) is 0.0
https://github.com/pytest-dev/pytest/blob/857e34ef8555c48cb5c44f143a0d6692efb6c60f/src/_pytest/python_api.py#L268-L276

Here is my suggested change
```python
         if approx_value != other_value:
              max_abs_diff = max(
                  max_abs_diff, abs(approx_value.expected - other_value)
              )
              if approx_value.expected == 0.0:
                  max_rel_diff = math.inf
              else:
                  max_rel_diff = max(
                      max_rel_diff,
                      abs((approx_value.expected - other_value) / approx_value.expected),
                  )
              different_ids.append(approx_key)
```


I would like to fix this.