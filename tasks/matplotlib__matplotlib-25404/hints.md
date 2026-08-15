The properties for `LassoSelector` is applied to the line stored as `self._selection_artist`. As such `self._props` is not defined in the constructor.

I *think* the correct solution is to redefine `set_props` for `LassoSelector` (and in that method set the props of the line), but there may be someone knowing better.
From a quick look, I'd perhaps try to just get rid of the _props attribute and always store the properties directly in the instantiated artist (creating it as early as possible).
It appears that the artist _is_ generally used, and the only real need for `_SelectorWidget._props` is in `SpanSelector.new_axes`, which needs to know the properties when attaching a new `Axes`.