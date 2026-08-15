I think it should return nan instead of None so that `frac(zoo) -> nan`.
oo gives `AccumBounds(0, 1)` so an option may be `AccumBounds(0, 1) + I*AccumBounds(0, 1)` or something. Not sure when one would like to call it though. Even for oo.
I think that `nan` would be the best choice (for `oo` as well unless a "real nan" is implemented).