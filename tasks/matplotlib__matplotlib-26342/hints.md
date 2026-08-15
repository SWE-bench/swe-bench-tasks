I'm actually a bit confused as to why Collection.set_paths raises NotImplementedError instead of setting self._paths (which is what Collection.get_paths already returns).
Thanks @anntzer.  So would it be enough to just copy what `PathCollection` has?

https://github.com/matplotlib/matplotlib/blob/2a4d905ff2e6493264190f07113dc7f2115a8c1c/lib/matplotlib/collections.py#L1004-L1006
Untested, but possibly yes?