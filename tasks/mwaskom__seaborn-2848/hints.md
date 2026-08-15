The following workarounds seem to work:
```
g.map(sns.scatterplot, hue=iris["species"], hue_order=iris["species"].unique())
```
or
```
g.map(lambda x, y, **kwargs: sns.scatterplot(x=x, y=y, hue=iris["species"]))
```
> ```
> g.map(sns.scatterplot, hue=iris["species"], hue_order=iris["species"].unique())
> ```

The workaround fixes the problem for me.
Thank you very much!

@mwaskom Should I close the Issue or leave it open until the bug is fixed?
That's a good workaround, but it's still a bug. The problem is that `PairGrid` now lets `hue` at the grid-level delegate to the axes-level functions if they have `hue` in their signature. But it's not properly handling the case where `hue` is *not* set for the grid, but *is* specified for one mapped function. @jhncls's workaround suggests the fix.

An easier workaround would have been to set `PairGrid(..., hue="species")` and then pass `.map(..., hue=None)` where you don't want to separate by species. But `regplot` is the one axis-level function that does not yet handle hue-mapping internally, so it doesn't work for this specific case. It would have if you wanted a single bivariate density over hue-mapped scatterplot points (i.e. [this example](http://seaborn.pydata.org/introduction.html#classes-and-functions-for-making-complex-graphics) or something similar.