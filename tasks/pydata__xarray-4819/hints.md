I don't know of an easy way (which does not mean that there is none). `drop_sel` could be adjusted to work with _dimensions without coordinates_ by replacing

https://github.com/pydata/xarray/blob/ff6b1f542e52dc330e294fd367f846e02c2955a2/xarray/core/dataset.py#L4038

by `index = self.get_index(dim)`. That would then be analog to `sel`. I think `drop_isel` would also be a welcome addition.
Can I work on this?
Sure. PRs are always welcome! 