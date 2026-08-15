My (unverified) guess is that this is a regression due to https://github.com/matplotlib/matplotlib/pull/17107 and https://bugs.python.org/issue19364), hence milestoning as 3.5.
In 3.3.4 (ie. before #17107) this still errors, but with a different message:
```python
NotImplementedError: TransformNode instances can not be copied. Consider using frozen() instead.
```

@tovrstra do you know if this has ever worked in Matplotlib?
I only ran into this recently. (beginning of October this year) I'm not sure what would have happened with earlier versions of matplotlib.

I'm also wondering if the operation should be supported. Would the deepcopy result in two different `Figure` instances with the same figure number? I'm not sure if that would make sense.
Good catch @dstansby; I guess this may have never worked, sorry for the wrong alert.