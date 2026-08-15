None of these methods are abstract (as in `abc.abstractmethod`) which led to some head scratching, but it seems that pylint considers any method which raises `NotImplementedError` to be abstract.

`get_closest_marker` is only marked such because we use `raise NotImplementedError()` in `@overload`ed functions. Given how pylint treats these, we can change these to just use `pass  # pragma: no cover` instead. Though ideally pylint would learn to ignore the contents of functions decorated with `@overload`.

As for `gethookproxy` and `isinitpath`, they really are abstract in the sense that the `_collectfile()` function provided by `FSCollector` assumes they have been implemented. In the case of your `YamlFile` collector, you don't use `_collectfile` so it ends up not mattering. I suppose it is a less than ideal subclassing design. The `NotImplemented` were added in pytest 6.0.0 by commit be00e12d47c820f0a90d24cd76ada8a0366c5a67 which fixed some internal typing issues.

I will take a look at resolving this when I get the chance. However we may want to add a quick fix for pytest 6.0.x at least.