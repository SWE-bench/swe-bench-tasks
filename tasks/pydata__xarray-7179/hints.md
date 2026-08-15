Thanks for the report. I think one resaon is that we import all the io libraries non-lazy (I think since the backend refactor). And many of the dependecies still use pkg_resources instead of importlib.metadata (which is considetably slower).

We'd need to take a look at the lazy loader. 
Useful for debugging:
`python -X importtime -c "import xarray"`
I just had another look at this using
```bash
python -X importtime -c "import llvmlite" 2> import.log
```
and [tuna](https://github.com/nschloe/tuna) for the visualization.

- pseudoNETCDF adds quite some overhead, but I think only few people have this installed (could be made faster, but not sure if worth it)
- llmvlite (required by numba) seems the last dependency relying on pkg_resources but this is fixed in the new version which [should be out soonish](https://github.com/conda-forge/llvmlite-feedstock/pull/62)  
- dask recently merged a PR that avoids a slow import dask/dask/pull/9230 (from which we should profit)

This should bring it down a bit by another 0.25 s, but I agree it would be nice to have it even lower.



Some other projects are considering lazy imports as well: https://scientific-python.org/specs/spec-0001/
I think we could rework our backend solution to do the imports lazy:
To check if a file might be openable via some backend we usually do not need to import its dependency module.
I just checked, many backends are importing their external dependencies at module level with a try-except block.
This could be replaced by `importlib.util.find_spec`.

However, many backends also check for ImportErrors (not ModuleNotFoundError) that occur when a library is not correctly installed. I am not sure if in this case the backend should simply be disabled like it is now (At least cfgrib is raising a warning instead)?
Would it be a problem if this error is only appearing when actually trying to open a file? If that is the case, we could move to lazy external lib loading for the backends.

Not sure how much it actually saves, but should be ~0.2s (at least on my machine, but depends on the number of intalled backends, the fewer are installed the faster the import should be).
> his could be replaced by importlib.util.find_spec.

Nice. Does it work on python 3.8?

> However, many backends also check for ImportErrors (not ModuleNotFoundError) that occur when a library is not correctly installed. I am not sure if in this case the backend should simply be disabled like it is now (At least cfgrib is raising a warning instead)?

> Would it be a problem if this error is only appearing when actually trying to open a file

Sounds OK to error when trying to use the backend.

> Nice. Does it work on python 3.8?

according to the docu it exists since 3.4.
In developing https://github.com/pydata/xarray/pull/7172, there are also some places where class types are used to check for features:
https://github.com/pydata/xarray/blob/main/xarray/core/pycompat.py#L35

Dask and sparse and big contributors due to their need to resolve the class name in question.

Ultimately. I think it is important to maybe constrain the problem.

Are we ok with 100 ms over numpy + pandas? 20 ms?

On my machines, the 0.5 s that xarray is close to seems long... but everytime I look at it, it seems to "just be a python problem".
