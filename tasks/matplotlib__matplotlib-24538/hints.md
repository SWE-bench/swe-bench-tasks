attributes should be documented if possible, though I'm always a little confused how we document them.
They go in the class docstring:
https://github.com/matplotlib/matplotlib/blob/a0306bdcb8633f21c2e127099ec4b1008ed8bb7d/lib/matplotlib/figure.py#L2108-L2126
Since this is not documented, it's probably not widely used. Therefore, I suggest normalizing the name to `legend_handles` (with deprecation) before making this more public.