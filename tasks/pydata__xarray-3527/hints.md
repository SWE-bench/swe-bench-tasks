while looking for related issues, I found #3018, so this seems to be known?
OK, fine to leave this open since that's closed
actually, I think the fix proposed in the old issue (move `DataArrayGroupBy.quantile` to `GroupBy`) should also silence the warnings, since the other methods in `GroupBy` work just fine?
That would be great if it's really that simple!
the warnings are still there, but at least the quantile works (assuming the tests cover it). I'll submit this as a PR.
Thank you!