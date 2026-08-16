Strictly enforce keyword arguments
I see folks quite often forget the s in the `scalars` argument for the `BasePlotter.add_mesh()` method. We should allow `scalar` as an alias much like how we allow `rng` and `clim` for the colorbar range/limits
