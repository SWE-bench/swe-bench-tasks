Seems like the issue is coming up in the `set_cmap` function: https://github.com/matplotlib/matplotlib/blob/bb75f737a28f620fe023742f59dc6ed4f53b094f/lib/matplotlib/pyplot.py#L2072-L2078
The name you pass to that function is only used to grab the colormap, but this doesn't account for the fact that in the internal list of colormaps (`cmap_d` in cm.py) the name can be different than the name associated with the colormap object. A workaround is to just set the rcParam `image.cmap` yourself:
```python
plt.rcParams['image.cmap']='my_cmap_name'
```
This issue has been marked "inactive" because it has been 365 days since the last comment. If this issue is still present in recent Matplotlib releases, or the feature request is still wanted, please leave a comment and this label will be removed. If there are no updates in another 30 days, this issue will be automatically closed, but you are free to re-open or create a new issue if needed. We value issue reports, and this procedure is meant to help us resurface and prioritize issues that have not been addressed yet, not make them disappear.  Thanks for your help!
This is still broken. Current `main` warns about the deprecated `cm.register_cmap`, but changing it to `colormaps.register` just suppresses the warning and not the error.

The linked PR above was closed in favour of #18503 which introduced those new names, but it does not appear to have corrected this issue.

I'm going to ping @timhoffm and @greglucas who were working on that refactor whether they have opinions for how to proceed here.
Yeah, this seems like a corner case for whether we want to allow differing registered names from colormap names. I think we probably do, as evidenced by the test case I gave, where maybe I want to get `viridis` back, update over/under and then register it under `mycmap` but I didn't bother updating the `cmap.name` attribute.

I think @ianhi was correct and the issue was setting the rc parameters to the incorrect value. I just pushed up a new PR with a quick fix to allow that. I think the validation in other parts of the colormap update is still correct and the new PR just uses a different way to set the rc parameter.