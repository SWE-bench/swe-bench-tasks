https://github.com/matplotlib/matplotlib/blob/b86ebbafe4673583345d0a01a6ea205af34c58dc/lib/matplotlib/axes/_axes.py#L5413

So the fundamental thing here is that `transform` is not actually directly inspected in `fill_between`'s implementation (which is shared for x/y variants), instead that falls under the `**kwargs` that are passed straight to `Polygon`

But it _does_ call `self.update_datalim` (in the linked line above)

I think when you are doing things in the (default) data axes, you _do_ want to expand the lims.
But yes, when using axes limits (for either x or y) it should likely not.

One way to do that would be to manipulate the `update[xy]` parameters (they are passed explicitly despite being set to defaults and never passed in other similar calls). But not necessarily clear _when_ to do so.

Alternatively it could be treated like `axline`, which I think would be my leaning at the moment:

https://github.com/matplotlib/matplotlib/blob/b86ebbafe4673583345d0a01a6ea205af34c58dc/lib/matplotlib/axes/_axes.py#L910-L913

Ref #17781, #17586
> Alternatively it could be treated like axline, which I think would be my leaning at the moment:

That is probably the better option.