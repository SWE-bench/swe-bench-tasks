I think the correct fix is to specifically check for BoundaryNorm there and implement special logic to determine the positions of the neighboring intervals (on the BoundaryNorm) for that case.
I tried returning the passed in `value` instead of the exception at https://github.com/matplotlib/matplotlib/blob/b2bb7be4ba343fcec6b1dbbffd7106e6af240221/lib/matplotlib/colors.py#L1829

```python
return value
```
and it seems to work. At least the error is gone and the values displayed in the plot (bottom right) when hovering with the mouse seem also right. But the numbers are rounded to only 1 digit in sci notation. So 19, 20 or 21 become 2.e+01.
Hope this helps.

Maybe a more constructive suggestion for a change in https://github.com/matplotlib/matplotlib/blob/b2bb7be4ba343fcec6b1dbbffd7106e6af240221/lib/matplotlib/artist.py#L1280 that tries to fix the error:
```python
ends = self.norm(np.array([self.norm.vmin, self.norm.vmax]))
if np.isfinite(normed) and np.allclose(ends, 0.5, rtol=0.0, atol=0.5):
```
This way, because `BoundaryNorm` doesn't map to 0...1 range but to the indices of the colors, the call to `BoundaryNorm.inverse()` is skipped and the default value for `g_sig_digits=3` is used.
But I'm not sure if there can be a case where `BoundaryNorm` actually maps its endpoints to 0...1, in which case all breaks down.
hey, I just ran into this while plotting data... (interactivity doesn't stop but it plots a lot of issues)  any updates?
@raphaelquast no, this still needs someone to work on it.

Labeled as a good first issue as there in no API design here (just returning an empty string is better than the current state).
I can give a PR, that is based on my [last comment](https://github.com/matplotlib/matplotlib/issues/21915#issuecomment-992454625) a try. But my concerns/questions from then are still valid.
As this is all internal code, I think we should just do an `isinstance(norm, BoundaryNorm)` check and then act accordingly.  There is already a bunch of instances of this in the colorbar code as precedence. 
After thinking about my suggestion again, I now understand why you prefer an `isinstace` check.
(In my initial suggestion one would have to check if `ends` maps to (0,1) and if `normed` is in [0, 1] for the correct way to implement my idea. But these conditions are taylored to catch `BoundaryNorm` anyway, so why not do it directly.)

However, I suggest using a try block after https://github.com/matplotlib/matplotlib/blob/c33557d120eefe3148ebfcf2e758ff2357966000/lib/matplotlib/artist.py#L1305
```python
# Midpoints of neighboring color intervals.
try:
    neighbors = self.norm.inverse(
        (int(normed * n) + np.array([0, 1])) / n)
except ValueError:
    # non-invertible ScalarMappable
```
because `BoundaryNorm` raises a `ValueError` anyway and I assume this to be the case for all non-invertible `ScalarMappables`.
(And the issue is the exception raised from `inverse`).

The question is:
What to put in the `except`? So what is "acting accordingly" in this case?
If `BoundaryNorm` isn't invertible, how can we reliably get the data values of the midpoints of neighboring colors?

I think it should be enough to get the boundaries themselves, instead of the midpoints (though both is possible) with something like:
```python
cur_idx = np.argmin(np.abs(self.norm.boundaries - data))
cur_bound = self.norm.boundaries[cur_idx]
neigh_idx = cur_idx + 1 if data > cur_bound else cur_idx - 1
neighbors = self.norm.boundaries[
    np.array([cur_idx, neigh_idx])
]
```
Problems with this code are:
- `boundaries` property is specific to `BoundaryNorm`, isn't it? So we gained nothing by using `try .. except`
- more checks are needed to cover all cases for `clip` and `extend` options of `BoundaryNorm` such that `neigh_idx` is always in bounds
- for very coarse boundaries compared to data (ie: `boundaries = [0,1,2,3,4,5]; data = random(n)*5) the displayed values are always rounded to one significant digit. While in principle, this is expected (I believe), it results in inconsistency. In my example 0.111111 would be given as 0.1 and 0.001 as 0.001 and 1.234 would be just 1.
> boundaries property is specific to BoundaryNorm, isn't it? So we gained nothing by using try .. except

This is one argument in favor of doing the `isinstance` check because then you can assert we _have_ a BoundaryNorm and can trust that you can access its state etc.   One on hand, duck typeing is in general a Good Thing in Python and we should err on the side of being forgiving on input, but sometimes the complexity of it is more trouble than it is worth if you really only have 1 case that you are trying catch!  

>  I assume this to be the case for all non-invertible ScalarMappables.

However we only (at this point) are talking about a way to recover in the case of BoundaryNorm.  Let everything else continue to fail and we will deal with those issues if/when they get reported.
I think the correct fix is to specifically check for BoundaryNorm there and implement special logic to determine the positions of the neighboring intervals (on the BoundaryNorm) for that case.
I tried returning the passed in `value` instead of the exception at https://github.com/matplotlib/matplotlib/blob/b2bb7be4ba343fcec6b1dbbffd7106e6af240221/lib/matplotlib/colors.py#L1829

```python
return value
```
and it seems to work. At least the error is gone and the values displayed in the plot (bottom right) when hovering with the mouse seem also right. But the numbers are rounded to only 1 digit in sci notation. So 19, 20 or 21 become 2.e+01.
Hope this helps.

Maybe a more constructive suggestion for a change in https://github.com/matplotlib/matplotlib/blob/b2bb7be4ba343fcec6b1dbbffd7106e6af240221/lib/matplotlib/artist.py#L1280 that tries to fix the error:
```python
ends = self.norm(np.array([self.norm.vmin, self.norm.vmax]))
if np.isfinite(normed) and np.allclose(ends, 0.5, rtol=0.0, atol=0.5):
```
This way, because `BoundaryNorm` doesn't map to 0...1 range but to the indices of the colors, the call to `BoundaryNorm.inverse()` is skipped and the default value for `g_sig_digits=3` is used.
But I'm not sure if there can be a case where `BoundaryNorm` actually maps its endpoints to 0...1, in which case all breaks down.
hey, I just ran into this while plotting data... (interactivity doesn't stop but it plots a lot of issues)  any updates?
@raphaelquast no, this still needs someone to work on it.

Labeled as a good first issue as there in no API design here (just returning an empty string is better than the current state).
I can give a PR, that is based on my [last comment](https://github.com/matplotlib/matplotlib/issues/21915#issuecomment-992454625) a try. But my concerns/questions from then are still valid.
As this is all internal code, I think we should just do an `isinstance(norm, BoundaryNorm)` check and then act accordingly.  There is already a bunch of instances of this in the colorbar code as precedence. 
After thinking about my suggestion again, I now understand why you prefer an `isinstace` check.
(In my initial suggestion one would have to check if `ends` maps to (0,1) and if `normed` is in [0, 1] for the correct way to implement my idea. But these conditions are taylored to catch `BoundaryNorm` anyway, so why not do it directly.)

However, I suggest using a try block after https://github.com/matplotlib/matplotlib/blob/c33557d120eefe3148ebfcf2e758ff2357966000/lib/matplotlib/artist.py#L1305
```python
# Midpoints of neighboring color intervals.
try:
    neighbors = self.norm.inverse(
        (int(normed * n) + np.array([0, 1])) / n)
except ValueError:
    # non-invertible ScalarMappable
```
because `BoundaryNorm` raises a `ValueError` anyway and I assume this to be the case for all non-invertible `ScalarMappables`.
(And the issue is the exception raised from `inverse`).

The question is:
What to put in the `except`? So what is "acting accordingly" in this case?
If `BoundaryNorm` isn't invertible, how can we reliably get the data values of the midpoints of neighboring colors?

I think it should be enough to get the boundaries themselves, instead of the midpoints (though both is possible) with something like:
```python
cur_idx = np.argmin(np.abs(self.norm.boundaries - data))
cur_bound = self.norm.boundaries[cur_idx]
neigh_idx = cur_idx + 1 if data > cur_bound else cur_idx - 1
neighbors = self.norm.boundaries[
    np.array([cur_idx, neigh_idx])
]
```
Problems with this code are:
- `boundaries` property is specific to `BoundaryNorm`, isn't it? So we gained nothing by using `try .. except`
- more checks are needed to cover all cases for `clip` and `extend` options of `BoundaryNorm` such that `neigh_idx` is always in bounds
- for very coarse boundaries compared to data (ie: `boundaries = [0,1,2,3,4,5]; data = random(n)*5) the displayed values are always rounded to one significant digit. While in principle, this is expected (I believe), it results in inconsistency. In my example 0.111111 would be given as 0.1 and 0.001 as 0.001 and 1.234 would be just 1.
> boundaries property is specific to BoundaryNorm, isn't it? So we gained nothing by using try .. except

This is one argument in favor of doing the `isinstance` check because then you can assert we _have_ a BoundaryNorm and can trust that you can access its state etc.   One on hand, duck typeing is in general a Good Thing in Python and we should err on the side of being forgiving on input, but sometimes the complexity of it is more trouble than it is worth if you really only have 1 case that you are trying catch!  

>  I assume this to be the case for all non-invertible ScalarMappables.

However we only (at this point) are talking about a way to recover in the case of BoundaryNorm.  Let everything else continue to fail and we will deal with those issues if/when they get reported.