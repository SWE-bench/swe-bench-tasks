> I think the most appropriate fix is to simply remove the caching, which I don't think is necessary really, and inline cached_eval into MarkEvaluator._istrue.

I agree:

* While it might have some performance impact with very large test suites which use marks with eval, the simple workaround is to not use the eval feature on those, which is more predictable anyway.
* I don't see a clean way to turn "globals" in some kind of cache key without having some performance impact and/or adverse effects.

So 👍 from me to simply removing this caching. 
As globals are dynamic, i would propose to drop the cache as well, we should investigate reinstating a cache later on 