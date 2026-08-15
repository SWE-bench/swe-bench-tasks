Okay I can replicate on 3.6.0.rc0 in a notebook with just:
```
%matplotlib widget
import matplotlib.pyplot as plt
fig, ax = plt.subplots()
```

<details>
<summary>Traceback</summary>

```
---------------------------------------------------------------------------
TraitError                                Traceback (most recent call last)
Input In [1], in <cell line: 3>()
      1 get_ipython().run_line_magic('matplotlib', 'widget')
      2 import matplotlib.pyplot as plt
----> 3 fig, ax = plt.subplots()

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/pyplot.py:1430, in subplots(nrows, ncols, sharex, sharey, squeeze, width_ratios, height_ratios, subplot_kw, gridspec_kw, **fig_kw)
   1284 def subplots(nrows=1, ncols=1, *, sharex=False, sharey=False, squeeze=True,
   1285              width_ratios=None, height_ratios=None,
   1286              subplot_kw=None, gridspec_kw=None, **fig_kw):
   1287     """
   1288     Create a figure and a set of subplots.
   1289 
   (...)
   1428 
   1429     """
-> 1430     fig = figure(**fig_kw)
   1431     axs = fig.subplots(nrows=nrows, ncols=ncols, sharex=sharex, sharey=sharey,
   1432                        squeeze=squeeze, subplot_kw=subplot_kw,
   1433                        gridspec_kw=gridspec_kw, height_ratios=height_ratios,
   1434                        width_ratios=width_ratios)
   1435     return fig, axs

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/_api/deprecation.py:454, in make_keyword_only.<locals>.wrapper(*args, **kwargs)
    448 if len(args) > name_idx:
    449     warn_deprecated(
    450         since, message="Passing the %(name)s %(obj_type)s "
    451         "positionally is deprecated since Matplotlib %(since)s; the "
    452         "parameter will become keyword-only %(removal)s.",
    453         name=name, obj_type=f"parameter of {func.__name__}()")
--> 454 return func(*args, **kwargs)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/pyplot.py:771, in figure(num, figsize, dpi, facecolor, edgecolor, frameon, FigureClass, clear, **kwargs)
    761 if len(allnums) == max_open_warning >= 1:
    762     _api.warn_external(
    763         f"More than {max_open_warning} figures have been opened. "
    764         f"Figures created through the pyplot interface "
   (...)
    768         f"Consider using `matplotlib.pyplot.close()`.",
    769         RuntimeWarning)
--> 771 manager = new_figure_manager(
    772     num, figsize=figsize, dpi=dpi,
    773     facecolor=facecolor, edgecolor=edgecolor, frameon=frameon,
    774     FigureClass=FigureClass, **kwargs)
    775 fig = manager.canvas.figure
    776 if fig_label:

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/pyplot.py:347, in new_figure_manager(*args, **kwargs)
    345 """Create a new figure manager instance."""
    346 _warn_if_gui_out_of_main_thread()
--> 347 return _get_backend_mod().new_figure_manager(*args, **kwargs)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/backend_bases.py:3505, in _Backend.new_figure_manager(cls, num, *args, **kwargs)
   3503 fig_cls = kwargs.pop('FigureClass', Figure)
   3504 fig = fig_cls(*args, **kwargs)
-> 3505 return cls.new_figure_manager_given_figure(num, fig)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/ipympl/backend_nbagg.py:487, in _Backend_ipympl.new_figure_manager_given_figure(num, figure)
    485 if 'nbagg.transparent' in rcParams and rcParams['nbagg.transparent']:
    486     figure.patch.set_alpha(0)
--> 487 manager = FigureManager(canvas, num)
    489 if is_interactive():
    490     _Backend_ipympl._to_show.append(figure)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/ipympl/backend_nbagg.py:459, in FigureManager.__init__(self, canvas, num)
    458 def __init__(self, canvas, num):
--> 459     FigureManagerWebAgg.__init__(self, canvas, num)
    460     self.web_sockets = [self.canvas]
    461     self.toolbar = Toolbar(self.canvas)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/backends/backend_webagg_core.py:434, in FigureManagerWebAgg.__init__(self, canvas, num)
    432 def __init__(self, canvas, num):
    433     self.web_sockets = set()
--> 434     super().__init__(canvas, num)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/backend_bases.py:2796, in FigureManagerBase.__init__(self, canvas, num)
   2791 self.toolmanager = (ToolManager(canvas.figure)
   2792                     if mpl.rcParams['toolbar'] == 'toolmanager'
   2793                     else None)
   2794 if (mpl.rcParams["toolbar"] == "toolbar2"
   2795         and self._toolbar2_class):
-> 2796     self.toolbar = self._toolbar2_class(self.canvas)
   2797 elif (mpl.rcParams["toolbar"] == "toolmanager"
   2798         and self._toolmanager_toolbar_class):
   2799     self.toolbar = self._toolmanager_toolbar_class(self.toolmanager)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/backends/backend_webagg_core.py:397, in NavigationToolbar2WebAgg.__init__(self, canvas)
    395 self.message = ''
    396 self._cursor = None  # Remove with deprecation.
--> 397 super().__init__(canvas)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/matplotlib/backend_bases.py:2938, in NavigationToolbar2.__init__(self, canvas)
   2936 def __init__(self, canvas):
   2937     self.canvas = canvas
-> 2938     canvas.toolbar = self
   2939     self._nav_stack = cbook.Stack()
   2940     # This cursor will be set after the initial draw.

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/traitlets/traitlets.py:712, in TraitType.__set__(self, obj, value)
    710     raise TraitError('The "%s" trait is read-only.' % self.name)
    711 else:
--> 712     self.set(obj, value)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/traitlets/traitlets.py:686, in TraitType.set(self, obj, value)
    685 def set(self, obj, value):
--> 686     new_value = self._validate(obj, value)
    687     try:
    688         old_value = obj._trait_values[self.name]

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/traitlets/traitlets.py:718, in TraitType._validate(self, obj, value)
    716     return value
    717 if hasattr(self, "validate"):
--> 718     value = self.validate(obj, value)  # type:ignore[attr-defined]
    719 if obj._cross_validation_lock is False:
    720     value = self._cross_validate(obj, value)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/traitlets/traitlets.py:2029, in Instance.validate(self, obj, value)
   2027     return value
   2028 else:
-> 2029     self.error(obj, value)

File ~/opt/miniconda3/envs/mne/lib/python3.10/site-packages/traitlets/traitlets.py:824, in TraitType.error(self, obj, value, error, info)
    818 else:
    819     e = "The '{}' trait expected {}, not {}.".format(
    820         self.name,
    821         self.info(),
    822         describe("the", value),
    823     )
--> 824 raise TraitError(e)

TraitError: The 'toolbar' trait of a Canvas instance expected a Toolbar or None, not the NavigationToolbar2WebAgg at '0x10f474310'.
```

</details>
I have seen this error and even remember debugging it, but I do not remember if I found the problem or if I switch to an older environment with the plan to come back (because I was under time pressure for something else).  It is quite frustrating....
https://github.com/matplotlib/ipympl/issues/426 and https://github.com/matplotlib/matplotlib/pull/22454 look related, but this has apparent come back?
9369769ea7b4692043233b6f1463326a93120315 via https://github.com/matplotlib/matplotlib/pull/23498 un-did the fix in #22454 .

Looking how to address both this issue and `examples/user_interfaces/embedding_webagg_sgskip.py`
The facts here are:

 - we re-organized the backends to pull as much of the toolbar initialization logic into one place as possible
 - the `Toolbar` class to used is controlled by the `_toolbar2_class` private attribute which if None the backend_bases does not try to make a toolbar
 - `ipympl` inherits from webagg_core and does not (yet) set this private attribute
 - the Canvas in ipympl uses traitlets and type-checks the toolbar to be its toolbar (which is in turn also a `DOMWidget` and has all of the sync mechanics with the js frontend)
 - therefor webagg_core's classes must not set `FigureManager._toolbar2_class` (this is what #22454 did)
 - that fix in turn broke an example which is what #23498 fixed 