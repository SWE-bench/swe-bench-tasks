@mhvk, I encountered this while looking to see how Masked and Distribution combine. They sort of do, but the subclass generation is not very robust.
@nstarman - does `Masked` work with a regular structured array? (It really should!) If this is `Distribution` specific, I think the issue is the rather lame override of `__repr__` in `Distribution`. Really, `Distribution` should have `__array_function__` defined so this could be done correctly.

Bit more generally, for cases like this I think we are forced to make a choice of which one goes on top. Since a `distribution` has a shape that excludes the samples, the mask in naive usage would just be for each set of samples. I think that a mask for each sample is likely more useful, but that may be tricky...
It does not appear to be Distribution specific. The following fails

```python
q = ((np.random.beta(2,5, 100)-(2/7))/2 + 3) * u.kpc
new_dtype = np.dtype({'names': ['samples'],
                      'formats': [(q.dtype, (q.shape[-1],))]})
q = q.view(new_dtype)
Masked(q)
```

I think it's related to ``q.shape == ()``.
OK, thanks, that is helpful!
The problem is the array-valued field. It is clear I never tested that...