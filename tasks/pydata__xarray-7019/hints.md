This sounds great! We should finish up https://github.com/pydata/xarray/pull/4972 to make it easier to test.
Another parallel framework would be [Ramba](https://github.com/Python-for-HPC/ramba) 

cc @DrTodd13
Sounds good to me. The challenge will be defining a parallel computing API that works across all these projects, with their slightly different models.
at SciPy i learned of [fugue](https://github.com/fugue-project/fugue) which tries to provide a unified API for distributed DataFrames on top of Spark and Dask. it could be a great source of inspiration. 
Thanks for opening this @TomNicholas 

> The challenge will be defining a parallel computing API that works across all these projects, with their slightly different models.

Agreed. I feel like there's already an implicit set of "chunked array" methods that xarray expects from Dask that could be formalised a bit and exposed as an integration point.