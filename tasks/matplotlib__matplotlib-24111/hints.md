If folks agree it's a regression error (& I think it kinda is) the fix is I think add something like

```python
 if item is None: 
     item = mpl.rcParams['image.cmap'] 
```
which is a direct port of the `get_cmap` code 
https://github.com/matplotlib/matplotlib/blob/a152851669b9df06302d3a133c7413b863f00283/lib/matplotlib/cm.py#L270-L271

before the try in:

https://github.com/matplotlib/matplotlib/blob/a152851669b9df06302d3a133c7413b863f00283/lib/matplotlib/cm.py#L91-L95

@mroeschke What is your use case? Are you passing in `None` as a literal or is it the value of some variable you have? Is this in library code or do you expect this to be needed in an interactive console.

We have discussed this on the last dev call and are not yet clear how to handle the default colormap case in the new API. Logically, `colormaps` itself was designed as a mapping of all explicit colormaps. The default colormap notion does not fit in there very well. It depends on the anticipated usage how we would handle that API-wise.

The use case would be for library code. In pandas, there are some APIs with matplotlib functionality that accept `cmap` that default to `None` and were passed into `matplotlib.cm.get_cmap`: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.io.formats.style.Styler.bar.html

We're happy to start using `matplotlib.colormaps` instead just noting in https://github.com/matplotlib/matplotlib/issues/23981#issue-1381487093 that I had to dig into what `get_cmap(None)` did before to maintain the prior behavior.  
@mroeschke I was going to suggest that you do something like

```
cmap = cmap in cmap is not None else mpl.rcparams['image.cmap']
```

which should work on all versions of Matplotlib and leaves you an escape hatch if you want to make the default colormap controllable indepently.  However, that probably is not enough for you as if you take `str` or `ColorMap` and actually want the color map (rather than passing through to some mpl function) you'll also have to have the logic to decide if you need to look up the color map or if the user directly gave you one.


When we decided to move to the registry model we mostly had end-users in mind, however this issues highlights that we did not take into account the library case enough.  We have https://github.com/matplotlib/matplotlib/blob/0517187b9c91061d2ec87e70442615cf4f47b6f3/lib/matplotlib/cm.py#L686-L708 for internal use (which is a bit more complicated than it needs to be to preserve exact error types).  It is not clear to me if we should make that public or document the pattern of:

```python
if isinstance(inp, mcolors.Colormap):
    cmap = inp
else:
    cmap = mpl.colormaps[inp if inp is not None else mpl.rcParams["image.cmap"]]

```
There is just enough complexity in there it probably be a function we provide. I think this has to be a function/method rather than shoehorned into `__getitem__` or `get` on the registry because that would be getting too far away from the `Mapping` API

If we have a registry method for this I propose

```python
def ensure_colormap(self, cmap: str|Colormap, * default=None):
    if isinstance(cmap, mcolors.Colormap):
       return cmap

    default = default if default is not None else mpl.rcParams["image.cmap"]
    cmap = cmap if cmap is not None else default
    return self[cmap]
```
which could also live as a free method and use the global registry.
Yeah in pandas we used a similar workaround for translating `cm.cmap(None)` to remove the deprecation warning.

I don't have any strong opinions personally on `colormaps[None]` being valid. I mainly wanted to highlighting that the deprecation message wasn't entirely clear for the `name=None` case.
Discussed on the call, we are going to put the method on the registery class for 3.6.1 on the reasoning that this is not a new feature, but completing something that should have been in 3.6.1 as part of the deplication. 