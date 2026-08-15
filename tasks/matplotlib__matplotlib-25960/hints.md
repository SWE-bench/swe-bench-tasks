Thanks for the report @maurosilber.  The problem is clearer if we set a facecolor for each subfigure:

```python
import matplotlib.pyplot as plt

for space in [0, 0.2]:
    figs = plt.figure().subfigures(2, 2, hspace=space, wspace=space)
    for fig, color in zip(figs.flat, 'cmyw'):
        fig.set_facecolor(color)
        fig.subplots().plot([1, 2])
plt.show()
```

With `main`, both figures look like
![test](https://user-images.githubusercontent.com/10599679/226331428-3969469e-fee7-4b1d-95da-8d46ab2b31ee.png)

Just to add something, it looks like it works when using 'constrained' layout.
The relevant code is https://github.com/matplotlib/matplotlib/blob/0b4e615d72eb9f131feb877a8e3bf270f399fe77/lib/matplotlib/figure.py#L2237
This didn't break - it never worked.  I imagine the position logic could be borrowed from Axes....  
I am a first time contributer, and would like to attempt to work on this if possible! Will get a PR in the coming days
I have been trying to understand the code associated with this and have run into some issues.
In the function _redo_transform_rel_fig (linked above), I feel that I would have to be able to access all of the subfigures within this figure in order to give the correct amount of space based on the average subfigure width/height. Would this be possible? 
I have been looking to this function as inspiration for the logic, but I am still trying to understand all the parameters as well:
https://github.com/matplotlib/matplotlib/blob/0b4e615d72eb9f131feb877a8e3bf270f399fe77/lib/matplotlib/gridspec.py#L145

There is a `fig.subfigs` attribute which is a list of the `SubFigures` in a `Figure`.
Apologies for the slow progress, had a busier week than expected.
Below is the code I am running to test.

```
import matplotlib.pyplot as plt

figs = plt.figure().subfigures(2, 2, hspace=0.2, wspace=0.2)
for fig, color in zip(figs.flat, 'cmyw'):
    fig.set_facecolor(color)
    fig.subplots().plot([1, 2])
# plt.show()

figs = plt.figure(constrained_layout=True).subfigures(2, 2, hspace=0.2, wspace=0.2)
for fig, color in zip(figs.flat, 'cmyw'):
    fig.set_facecolor(color)
    fig.subplots().plot([1, 2])
plt.show()
```

This creates two figures, one with constrained layout and one without. Below is my current output.
On the right is the constrained layout figure, and the left is the one without.
<img width="1278" alt="Screenshot 2023-04-04 at 6 20 33 PM" src="https://user-images.githubusercontent.com/90582921/229935570-8ec26074-421c-4b78-a746-ce711ff6bea9.png">

My code currently fits the facecolors in the background to the correct spots, however the actual graphs do not match. They seem to need resizing to the right and upwards in order to match the constrained layout. Would a non-constrained layout figure be expected to resize those graphs to fit the background? I would assume so but I wanted to check since I couldn't find the answer in the documentation I looked at.
> My code currently fits the facecolors in the background to the correct spots, however the actual graphs do not match. They seem to need resizing to the right and upwards in order to match the constrained layout. Would a non-constrained layout figure be expected to resize those graphs to fit the background? I would assume so but I wanted to check since I couldn't find the answer in the documentation I looked at.

I'm not quite sure what you are asking here?  Constrained layout adjusts the axes sizes to fit in the figure.  If you don't do constrained layout the axes labels can definitely spill out of the figure if you just use default axes positioning.  

I've been digging into this.  We have a test that adds a subplot and a subfigure using the same gridspec, and the subfigure is expected to ignore the wspace on the gridspec.

https://github.com/matplotlib/matplotlib/blob/ffd3b12969e4ab630e678617c68492bc238924fa/lib/matplotlib/tests/test_figure.py#L1425-L1439

 <img src="https://github.com/matplotlib/matplotlib/blob/main/lib/matplotlib/tests/baseline_images/test_figure/test_subfigure_scatter_size.png?raw=true"> 

The use-case envisioned in the test seems entirely reasonable to me, but I'm struggling to see how we can support that while also fixing this issue.
Why do you say the subfigure is expected to ignore the wspace?  I don't see that wspace is set in the test. 
Since no _wspace_ is passed, I assume the gridspec will have the default from rcParams, which is 0.2.
Sure, but I don't understand what wouldn't work in that example with `wspace` argument. Do you just mean that the default would be too large for this case? 
Yes, I think in the test example, if both subfigure and subplot were respecting the 0.2 wspace then the left-hand subplots would be narrower and we’d have more whitespace in the middle.  Currently in this example the total width of the two lefthand subplots looks about the same as the width of the righthand one, so overall the figure seems well-balanced.

Another test here explicitly doesn’t expect any whitespace between subfigures, though in this case there are no subplots so you could just pass `wspace=0, hspace=0` to the gridspec and retain this result.
https://github.com/matplotlib/matplotlib/blob/8293774ba930fb039d91c3b3d4dd68c49ff997ba/lib/matplotlib/tests/test_figure.py#L1368-L1388


Can we just make the default wspace for subfigures be zero?
`wspace` is a property of the gridspec.  Do you mean we should have a separate property for subfigures, e.g. `GridSpec.subfig_wspace`, with its own default?
`gridspec` is still public API, but barely, as there are usually more elegant ways to do the same things that folks used to use gridspecs for.  

In this case, as you point out, it is better if subplots and subfigures get different wspace values, even if they are the same grid spec level.  I'm suggesting that subfigures ignores the grid spec wspace (as it currently does) and if we want a wspace for a set of subfigures that be a kwarg of the subfigure call.  

However, I never use wspace nor hspace, and given that all these things work so much better with constrained layout, I'm not sure what the goal of manually tweaking the spacing is.  