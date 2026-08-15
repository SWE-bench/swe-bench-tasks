(I think we should just reject (with deprecation, yada yada) any non-1D input (and yes, that includes (n, 1) and (1, n) input).)
The `ravel` that we do is a considerable convenience for common use cases such as working with gridded data for ocean or atmospheric fields.
I dunno - it all seems pretty inconsistent to me, like whoever wrote `scatter` never looked at what `plot` does, or visce versa, whereas I think they are the same thing.  

```python
plt.plot(np.arange(12).reshape(3, 4), np.arange(12).reshape(3, 4))
plt.scatter(np.arange(12).reshape(3, 4), np.arange(12).reshape(3, 4))
```
are pretty shockingly different.  I'm fine w/ them being different, but I'm somewhat against `scatter` just flattening the array without comment.  I think I'd go with @anntzer's proposal so the difference is explicit.  Its not like `scatter(X.flat, Y.flat)` is so hard...
