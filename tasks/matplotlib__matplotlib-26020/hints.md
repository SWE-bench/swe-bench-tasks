This could probably be made to work by:

 a) renaming the `axis` property on `.mpl_axes.Axes` to something that does not collide with an existing method
 b) doing on-the-fly multiple inheritance in AxesGrid if the input axes class does not already inherit from the said Axes extension
Ok. It this begs the question of why one would use axes grid for cartopy axes?
An alternative change here would be to put is the type check and raise an informative error that it is not going to work.
OTOH it may be nice to slowly move axes_grid towards an API more consistent with the rest of mpl.  From a very, very quick look, I guess its `axis` dict could be compared to normal axes' `spines` dict?  (an AxisArtist is vaguely like a Spine, I guess).
> Ok. It this begs the question of why one would use axes grid for cartopy axes?

There's an [example in the Cartopy docs](https://scitools.org.uk/cartopy/docs/latest/gallery/axes_grid_basic.html).
For that example I get `TypeError: 'tuple' object is not callable`
So, I'm confused, is `axes_grid` the only way to make an array of axes from an arbitrary axes subclass?  I don't see the equivalent of `axes_class=GeoAxes` for `fig.add_subplot` or `fig.subplots` etc. 
Sorry for the above, I see now.  That example could be changed to 

```python
    fig, axgr = plt.subplots(3, 2, constrained_layout=True,
                             subplot_kw={'projection':projection})
    axgr = axgr.flat
...
   fig.colorbar(p, ax=axgr, shrink=0.6, extend='both')
```
@jklymak the reason why I went to use AxesGrid was because it seemed the easiest for me to create multiple GeoAxes instances flexibly (i.e. with or without colorbar axes, and with flexible location of those) and with an easy control of both horizonal and vertical padding of GeoAxis instances and independently, of the colorbar axes, also because the aspect of maps (lat / lon range) tends to mess with the alignment. 
I know that this can all be solved via subplots or GridSpec, etc., but I found that AxisGrid was the most simple way to do this (after trying other options and always ending up having overlapping axes ticklabels or too large padding between axes, etc.). AxesGrid seems to be made for my problem and it was very easy for me to set up a subplot grid meeting my needs for e.g. plotting 12 monthly maps of climate model data with proper padding, etc. 
![multimap_example](https://user-images.githubusercontent.com/12813228/78986627-f310dc00-7b2b-11ea-8d47-a5c90b68171d.png)

The code I used to create initiate this figure is based on the example from the cartopy website that @QuLogic mentions above:

```python
fig = plt.figure(figsize=(18, 7))
axes_class = (GeoAxes, dict(map_projection=ccrs.PlateCarree()))
axgr = AxesGrid(fig, 111, axes_class=axes_class,
                    nrows_ncols=(3, 4),
                    axes_pad=(0.6, 0.5), # control padding separately for e.g. colorbar labels, axes titles, etc.
                    cbar_location='right',
                    cbar_mode="each",
                    cbar_pad="5%",
                    cbar_size='3%',
                    label_mode='') 

# here follows the plotting code of the displayed climate data using pyaerocom by loading a 2010 monthly example model dataset, looping over the (GeoAxes, cax) instances of the grid and calling pyaerocom.plot.mapping.plot_griddeddata_on_map on the monthly subsets.
```

However, @jklymak I was not aware of the `constrained_layout` option in `subplots` and indeed, looking at [the constrained layout guide](https://matplotlib.org/3.2.1/tutorials/intermediate/constrainedlayout_guide.html), this seems to provide the control needed to not mess with padding / spacing etc. I will try this out for my problem. Nonetheless, since cartopy refers to the AxesGrid option, it may be good if this issue could be fixed in any case.

Also, constrained layout itself is declared experimental in the above guide and may be deprecated, so it may be a bit uncertain for users and developers that build upon matplotlib, what option to go for.


@jgliss Yeah, I think I agree that `axes_grid` is useful to pack subplots together that have a certain aspect ratio.  Core matplotlib takes the opposite approach and puts the white space between the axes, `axes_grid` puts the space around the axes.  

I agree with @anntzer comment above (https://github.com/matplotlib/matplotlib/issues/17069#issuecomment-611635018), but feel that we should move axes_grid into core matplotlib and change the API as we see fit when we do so.  

I also agree that its time `constrained_layout` drops its experimental tag. 

Back on topic, though, this seems to be a regression and we should fix it.  
Re-milestoned to 3.2.2 as this seems like it is a regression, not "always broken"?
Right after I re-milestoned I see that this is with 3.1.2 so I'm confused if this ever worked?
I re-milestoned this to 3.4 as I don't think this has ever worked without setting the kwarg `label_mode=''` (it is broken at least as far back as 2.1.0).
Actually, looks simple enough to just check what kind of object ax.axis is:
```patch
diff --git i/lib/mpl_toolkits/axes_grid1/axes_grid.py w/lib/mpl_toolkits/axes_grid1/axes_grid.py
index 2b1b1d3200..8b947a5836 100644
--- i/lib/mpl_toolkits/axes_grid1/axes_grid.py
+++ w/lib/mpl_toolkits/axes_grid1/axes_grid.py
@@ -1,5 +1,6 @@
 from numbers import Number
 import functools
+from types import MethodType

 import numpy as np

@@ -7,14 +8,20 @@ from matplotlib import _api, cbook
 from matplotlib.gridspec import SubplotSpec

 from .axes_divider import Size, SubplotDivider, Divider
-from .mpl_axes import Axes
+from .mpl_axes import Axes, SimpleAxisArtist


 def _tick_only(ax, bottom_on, left_on):
     bottom_off = not bottom_on
     left_off = not left_on
-    ax.axis["bottom"].toggle(ticklabels=bottom_off, label=bottom_off)
-    ax.axis["left"].toggle(ticklabels=left_off, label=left_off)
+    if isinstance(ax.axis, MethodType):
+        bottom = SimpleAxisArtist(ax.xaxis, 1, ax.spines["bottom"])
+        left = SimpleAxisArtist(ax.yaxis, 1, ax.spines["left"])
+    else:
+        bottom = ax.axis["bottom"]
+        left = ax.axis["left"]
+    bottom.toggle(ticklabels=bottom_off, label=bottom_off)
+    left.toggle(ticklabels=left_off, label=left_off)


 class CbarAxesBase:
```
seems to be enough.