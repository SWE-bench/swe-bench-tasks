I can't reproduce (or I don't understand what is the issue). Can you confirm that the following gif is the expected behaviour and that you get something different?

![Peek 2021-07-19 08-46](https://user-images.githubusercontent.com/11851990/126122649-236a4125-84c7-4f35-8c95-f85e1e07a19d.gif)

The point is that in the gif you show, the lower xlim is 0 (minus margins) whereas it should be 10 (minus margins) -- this is independent of actually interacting with the spanselector.
Ok, I see, this is when calling `ss = SpanSelector(ax, print, "horizontal", interactive=True)` that the axis limit changes, not when selecting an range!
Yes. 