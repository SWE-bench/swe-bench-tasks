The error disappears in 3.6.0 by following the error message and passing `cax=ax.inset_axes([0.95, 0.1, 0.05, 0.8])`.
If it is ambiguous what axes to use, pass in the axes directly: 

```
cbar = plt.colorbar(
    plt.cm.ScalarMappable(cmap=color_map),
    ax=plt.gca()
)
```

You _could_ make an axes, and use that, but you will lose some layout convenience. 
Good to know I can keep auto-layout for the color bar.

> If it is ambiguous what axes to use, pass in the axes directly:

What changed between 3.5.1 and 3.6.0? Why wasn't it ambiguous before?
This happened in https://github.com/matplotlib/matplotlib/pull/23740.   However, I think we were under the impression this was deprecated, but it sounds like perhaps that was not the case?
I had the problem when trying to use create a simple SHAP plot using the [shap package](https://shap.readthedocs.io/en/latest/index.html). 

```python
import shap

# use SHAP (SHapley Additive exPlanations) to explain the output of the generated model
explainer = shap.TreeExplainer(model)
shap_values = explainer.shap_values(X)
shap.summary_plot(shap_values[1], X, feature_names=X.columns, show=False, max_display=20, plot_size=(15, 10))
```

`ValueError: Unable to determine Axes to steal space for Colorbar. Either provide the cax argument to use as the Axes for the Colorbar, provide the ax argument to steal space from it, or add mappable to an Axes.`

I had to downgrade to matplotlib 3.5.1 to fix the issue.
Please report to shap

I will put on the agenda for next weeks call what we should do about this.  It seems we screwed up the deprecation warning somehow, or a lot of downstream packages didn't see it.  


There was a deprecation warning here, but it was only triggered if the mappable had an axes that was different from the current axes:

https://github.com/matplotlib/matplotlib/blob/a86271c139a056a5c217ec5820143dca9e19f9b8/lib/matplotlib/figure.py#L1182-L1191

In the OP's case, I think the mappable has no axes.
I guess this should get fixed for the bug release, though maybe not the most critical thing in the world.  But we have probably broken a few libraries by doing this with no notice.