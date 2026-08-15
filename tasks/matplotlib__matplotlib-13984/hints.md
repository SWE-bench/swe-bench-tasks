Something to do with https://github.com/matplotlib/matplotlib/blob/2c1cd6bb0f4037805011b082258c6c3923e4cf29/lib/mpl_toolkits/mplot3d/axis3d.py#L439

which overwrites the line color. This seems to be some external setting, but I'm not enough into the 3d toolkit to know how to fix it properly.
Ah, yes, I remember now.

Several years ago, mplot3d had just about everything hard-coded. Being new
to matplotlib at the time and wary of breaking anything, I decided that I
would at least consolidate all of the hard-coded stuff into a dictionary at
the top of the Axis3D class.

Feel free to make changes to whittle away at this dictionary.


On Sat, Dec 1, 2018 at 10:04 AM Tim Hoffmann <notifications@github.com>
wrote:

> Something to do with
> https://github.com/matplotlib/matplotlib/blob/2c1cd6bb0f4037805011b082258c6c3923e4cf29/lib/mpl_toolkits/mplot3d/axis3d.py#L439
>
> which overwrites the line color. This seems to be some external setting,
> but I'm not enough into the 3d toolkit to know how to fix it properly.
>
> —
> You are receiving this because you are subscribed to this thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/matplotlib/matplotlib/issues/12911#issuecomment-443432522>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AARy-E_LaoALSxthjCD3bXrLFkkQExgBks5u0pp9gaJpZM4Y7nF0>
> .
>

Removing this line will fix the issue at hand https://github.com/matplotlib/matplotlib/blob/2c1cd6bb0f4037805011b082258c6c3923e4cf29/lib/mpl_toolkits/mplot3d/axis3d.py#L439
but the bigger underlying problem is that the Axis3D class extends XAxis which breaks many things..

One example is changing default xtick colors will change colors for all axis ticks instead of just the x axis
```python
from matplotlib import pyplot as plt, rcParams

rcParams['xtick.color'] = 'red'

fig = plt.figure()

ax = plt.gca(projection='3d')

plt.show()
```

![image](https://user-images.githubusercontent.com/17525659/54079101-89c4f680-42a3-11e9-82db-a5e12228453f.png)
