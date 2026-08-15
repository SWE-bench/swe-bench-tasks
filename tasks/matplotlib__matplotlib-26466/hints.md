I guess that a simple patch to _AnnotationBase init should work, but I'd check for more places where the a similar bug can be hidden:

Maybe changing:
https://github.com/matplotlib/matplotlib/blob/89fa0e43b63512c595387a37bdfd37196ced69be/lib/matplotlib/text.py#L1332
for
`self.xy=np.array(xy)`
is enough. This code works with tuples, lists, arrays and any valid argument I can think of (maybe there is  a valid 'point' class I am missing here)
A similar issue is maybe present in the definition of OffsetFrom helper class. I will check and update the PR.
