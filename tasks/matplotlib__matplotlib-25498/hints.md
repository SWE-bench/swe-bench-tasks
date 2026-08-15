You have run into a big bug in imshow, not colorbar.  As a workaround, after setting `plot.norm`, call `plot.autoscale()`.  Then the `update_bruteforce` will work.
When the norm is changed, it should pick up the vmax, vmin values from the autoscaling; but this is not happening.  Actually, it's worse than that; it fails even if the norm is set as a kwarg in the call to imshow. I haven't looked beyond that to see why.  I've confirmed the problem with master.

In ipython using `%matplotlib` setting the norm the first time works, changing it back later to
`Normalize()` or something other blows up:

```
--> 199         self.pixels.autoscale()
    200         self.update(force=True)
    201 

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cm.py in autoscale(self)
    323             raise TypeError('You must first set_array for mappable')
    324         self.norm.autoscale(self._A)
--> 325         self.changed()
    326 
    327     def autoscale_None(self):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cm.py in changed(self)
    357         callbackSM listeners to the 'changed' signal
    358         """
--> 359         self.callbacksSM.process('changed', self)
    360 
    361         for key in self.update_dict:

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cbook.py in process(self, s, *args, **kwargs)
    560             for cid, proxy in list(six.iteritems(self.callbacks[s])):
    561                 try:
--> 562                     proxy(*args, **kwargs)
    563                 except ReferenceError:
    564                     self._remove_proxy(proxy)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cbook.py in __call__(self, *args, **kwargs)
    427             mtd = self.func
    428         # invoke the callable and return the result
--> 429         return mtd(*args, **kwargs)
    430 
    431     def __eq__(self, other):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in on_mappable_changed(self, mappable)
    915         self.set_cmap(mappable.get_cmap())
    916         self.set_clim(mappable.get_clim())
--> 917         self.update_normal(mappable)
    918 
    919     def add_lines(self, CS, erase=True):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in update_normal(self, mappable)
    946         or contour plot to which this colorbar belongs is changed.
    947         '''
--> 948         self.draw_all()
    949         if isinstance(self.mappable, contour.ContourSet):
    950             CS = self.mappable

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in draw_all(self)
    346         X, Y = self._mesh()
    347         C = self._values[:, np.newaxis]
--> 348         self._config_axes(X, Y)
    349         if self.filled:
    350             self._add_solids(X, Y, C)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in _config_axes(self, X, Y)
    442         ax.add_artist(self.patch)
    443 
--> 444         self.update_ticks()
    445 
    446     def _set_label(self):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in update_ticks(self)
    371         """
    372         ax = self.ax
--> 373         ticks, ticklabels, offset_string = self._ticker()
    374         if self.orientation == 'vertical':
    375             ax.yaxis.set_ticks(ticks)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in _ticker(self)
    592         formatter.set_data_interval(*intv)
    593 
--> 594         b = np.array(locator())
    595         if isinstance(locator, ticker.LogLocator):
    596             eps = 1e-10

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/ticker.py in __call__(self)
   1533         'Return the locations of the ticks'
   1534         vmin, vmax = self.axis.get_view_interval()
-> 1535         return self.tick_values(vmin, vmax)
   1536 
   1537     def tick_values(self, vmin, vmax):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/ticker.py in tick_values(self, vmin, vmax)
   1551             if vmin <= 0.0 or not np.isfinite(vmin):
   1552                 raise ValueError(
-> 1553                     "Data has no positive values, and therefore can not be "
   1554                     "log-scaled.")
   1555 

ValueError: Data has no positive values, and therefore can not be log-scaled.
```

Any news on this? Why does setting the norm back to a linear norm blow up if there are negative values?

``` python
In [2]: %matplotlib
Using matplotlib backend: Qt4Agg

In [3]: # %load minimal_norm.py
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import Normalize, LogNorm


x, y = np.meshgrid(np.linspace(0, 1, 10), np.linspace(0, 1, 10))
z = np.random.normal(0, 5, size=x.shape)

fig = plt.figure()
img = plt.pcolor(x, y, z, cmap='viridis')
cbar = plt.colorbar(img)
   ...: 

In [4]: img.norm = LogNorm()

In [5]: img.autoscale()

In [7]: cbar.update_bruteforce(img)

In [8]: img.norm = Normalize()

In [9]: img.autoscale()
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-9-e26279d12b00> in <module>()
----> 1 img.autoscale()

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cm.py in autoscale(self)
    323             raise TypeError('You must first set_array for mappable')
    324         self.norm.autoscale(self._A)
--> 325         self.changed()
    326 
    327     def autoscale_None(self):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cm.py in changed(self)
    357         callbackSM listeners to the 'changed' signal
    358         """
--> 359         self.callbacksSM.process('changed', self)
    360 
    361         for key in self.update_dict:

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cbook.py in process(self, s, *args, **kwargs)
    561             for cid, proxy in list(six.iteritems(self.callbacks[s])):
    562                 try:
--> 563                     proxy(*args, **kwargs)
    564                 except ReferenceError:
    565                     self._remove_proxy(proxy)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/cbook.py in __call__(self, *args, **kwargs)
    428             mtd = self.func
    429         # invoke the callable and return the result
--> 430         return mtd(*args, **kwargs)
    431 
    432     def __eq__(self, other):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in on_mappable_changed(self, mappable)
    915         self.set_cmap(mappable.get_cmap())
    916         self.set_clim(mappable.get_clim())
--> 917         self.update_normal(mappable)
    918 
    919     def add_lines(self, CS, erase=True):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in update_normal(self, mappable)
    946         or contour plot to which this colorbar belongs is changed.
    947         '''
--> 948         self.draw_all()
    949         if isinstance(self.mappable, contour.ContourSet):
    950             CS = self.mappable

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in draw_all(self)
    346         X, Y = self._mesh()
    347         C = self._values[:, np.newaxis]
--> 348         self._config_axes(X, Y)
    349         if self.filled:
    350             self._add_solids(X, Y, C)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in _config_axes(self, X, Y)
    442         ax.add_artist(self.patch)
    443 
--> 444         self.update_ticks()
    445 
    446     def _set_label(self):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in update_ticks(self)
    371         """
    372         ax = self.ax
--> 373         ticks, ticklabels, offset_string = self._ticker()
    374         if self.orientation == 'vertical':
    375             ax.yaxis.set_ticks(ticks)

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/colorbar.py in _ticker(self)
    592         formatter.set_data_interval(*intv)
    593 
--> 594         b = np.array(locator())
    595         if isinstance(locator, ticker.LogLocator):
    596             eps = 1e-10

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/ticker.py in __call__(self)
   1536         'Return the locations of the ticks'
   1537         vmin, vmax = self.axis.get_view_interval()
-> 1538         return self.tick_values(vmin, vmax)
   1539 
   1540     def tick_values(self, vmin, vmax):

/home/maxnoe/.local/anaconda3/envs/ctapipe/lib/python3.5/site-packages/matplotlib/ticker.py in tick_values(self, vmin, vmax)
   1554             if vmin <= 0.0 or not np.isfinite(vmin):
   1555                 raise ValueError(
-> 1556                     "Data has no positive values, and therefore can not be "
   1557                     "log-scaled.")
   1558 

ValueError: Data has no positive values, and therefore can not be log-scaled
```

This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!