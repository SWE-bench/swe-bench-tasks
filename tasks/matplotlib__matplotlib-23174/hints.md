Not sure if one should add `self._cachedRenderer = None` to `FigureBase` (and remove in `Figure`) or to `SubFigure` init-functions, but that should fix it.

I thought it was a recent regression, but it doesn't look like it, so maybe should be labelled 3.6.0 instead?