xref matplotlib/cycler#27 matplotlib/cycler#8

Technically it is _possible_ to do indexing to the cycler object (though of course the itertools.cycle wrapper obscures this internally, as you mention, and it is not super pretty):

```python
next(iter(mpl.rcParams["axes.prop_cycle"][2:]))
```

- Slicing on cycler is only implemented currently for slice object, not integer indices
- `next(cycler)` raises, so we need `next(iter(cycler))`

That said, it does feel odd that a cycler object won't actually cycle on its own...
> That said, it does feel odd that a cycler object won't actually cycle on its own...

If they cycled on their own the composition would break
Currently, `Cycler` as a collection type implements `Iterable` and `Sized` (plus some non-canonical behavior). We may consider making it a more refined collection type such as `Sequence`. See https://docs.python.org/3/library/collections.abc.html#collections-abstract-base-classes
This may be better discussed on the cycler repo, but adding a `FiniteCycler` subclass that supports indexing may be the way to go.