Unfortunately, We are kind of at the mercy of the text rendering and the bounding box that gives us for things going through `mathtext`, and I'm not sure there is any way around that.

Since the symbols are designed to be incorporated into text rather than displayed independently, many of them are offset (though not all, and not all by the same amount, so not like there is an easy "shift it over by 2 pts" that can be applied).

For simple shapes, it is recommended to use the built in markers or paths rather than text, if that works for your use case. The mathtext markers are good in that they give a large number of symbols to choose from, but at the cost of rendering perfectly on the center, which is not a dealbreaker for all plots, but is for many.

Here is a script that can help identify where characters will anchor, some do better than others:

```python
import matplotlib.pyplot as plt
from matplotlib.widgets import TextBox
from matplotlib.transforms import IdentityTransform
import numpy as np

fig, (ax, widgetax) = plt.subplots(nrows=2, figsize=(6, 4), dpi=100)

def update(s):
    ax.clear()
    ax.set(xlim=(0, 1), ylim=(0, 1), xticks=[], yticks=[])
    ax.spines[:].set_visible(False)
    text = ax.text(0.5, 0.5, fr'${s}$', fontsize=128, ha='center', va='center', zorder=1)
    text.set_bbox({"facecolor":"C2", "alpha":.3, "pad":0})
    try:
        fig.draw_without_rendering()
    except:
        ax.clear()
        ax.set(xlim=(0, 1), ylim=(0, 1), xticks=[], yticks=[])
        ax.spines[:].set_visible(False)
        text = ax.text(0.5, 0.5, fr'$invalid$', fontsize=128, ha='center', va='center', zorder=1)

    bbox = text.get_window_extent()
    vert = ax.vlines((bbox.xmax+bbox.xmin)/2, bbox.ymin, bbox.ymax, transform=IdentityTransform())
    horiz = ax.hlines((bbox.ymax+bbox.ymin)/2, bbox.xmin, bbox.xmax, transform=IdentityTransform())
    fig.canvas.draw_idle()

update(r"\star")

widget = TextBox(widgetax, "text", initial=r"\star")
widget.on_submit(update)


plt.show()
```

(You can update by typing into the bottom and hitting enter)

The green box is the reported bounding box, the blue lines are added at the center for each horizontal and vertical directions, crossing at the center, which is the anchor point for the marker.

![Figure_1](https://github.com/matplotlib/matplotlib/assets/2501846/c432f4aa-bf00-4518-817f-09e277de3795)

We discussed this on a call, and coincidentally, I had found a bug about mathtext markers, but had not submitted any fix as it didn't seem related to the bug I _was_ fixing and I didn't have a way to prove it was wrong without any reproducer.

However, it turns out that _this_ issue is a perfect reproducer for the bug I found. Now I can put together the fix I already have into a PR.
@ksunden 
It's sad that there is no clear way, but thank you very much for providing above good codes :)
I'll try it out and use it for my project. thanks again!
@QuLogic 
I'm glad that you found the bug again. it doesn't seem related to this, bug could you explain more about the bug / PR?
@timegate as @QuLogic said, it actually looks like this is solvable after we looked at it closer (together). It may still not be absolutely perfect because it's based on a rectangle bounding box, but should be closer at least.
The technical details:

- paths are stored as two arrays: the xy points as an Nx2 float array and a length N 1D integer array describing how the points are connected

- one of the codes for the latter array is "close the shape" and thus it doesn't actually depend on the values in the xy array, but there still are some there to align the arrays

- however that point, which doesn't actually mean anything to the path, is still currently used to determine the bounding box

- the fix is to ignore such points in the bounding box computation 

- for a five pointed star there will still be a slight (~5%, I think) offset for the vertical component compared to the anchor point of the built in stars, which is the center of the circumscribing circle.

- this is because it is determined by the midpoint of the bounding rectangle, which cuts off the bottom of that circle since the path does not extend that far down.
@ksunden it's amazing! thanks for the detailed explanation. if there is an PR about above later, could you please post a pr link?