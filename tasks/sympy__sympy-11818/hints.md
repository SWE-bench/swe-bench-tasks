UniversalSet doesn't come into play here. It's just a formal set that always returns True for any containment check. `Union(FiniteSet(oo), S.Complexes)` giving `S.Complexes` is a bug. 

(Optimistically setting this as easy to fix. I suspect it isn't difficult, but there is a chance I am wrong)
