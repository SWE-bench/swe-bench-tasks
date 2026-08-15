The fix for this is likely to relax the type checking in `plt.figure` to accept `FigureBase` and to make sure that top level `Figure` is still the one set as the current figure.

https://github.com/matplotlib/matplotlib/blob/89b21b517df0b2a9c378913bae8e1f184988b554/lib/matplotlib/pyplot.py#L755-L759 is the first place that needs to be updated to detect a `SubFigure` and try to make the top most `Figure` active (remember they can be deeply nested).

Once that is fixed there may need to be some additional work in https://github.com/matplotlib/matplotlib/blob/89b21b517df0b2a9c378913bae8e1f184988b554/lib/matplotlib/figure.py#L1506-L1510 but that looks correct to me.


Tasks 
 - fix `plt.figure` to deal with being passed a `SubFigure`
 - verify that `Figure.sca` works as expected on nested axes
 - add a test
Me and my colleague are going to try it!