I think we should probably call this a bug and just drop the call to `utils.remove_incompatible_items()` -- see https://github.com/pydata/xarray/issues/1614.

`concat()` is the only operation for which we check variables for equality.
So this would mean `concat` would not retain any `.attrs`, right?
> So this would mean concat would not retain any .attrs, right?

concat would only retain `.attrs` from the first variable, ignoring all subsequent variables.
See my comment on #2060. I think we should probably drop this attribute check all together.

Any interest in putting together a PR?
See my comment on #2060. I think we should probably drop this attribute check all together.

Any interest in putting together a PR?