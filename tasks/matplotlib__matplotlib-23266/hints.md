Should the current `linestyles` kwarg be used to accomplish this or should a new kwarg be added? I have a simple solution adding a new kwarg (though it would need a little more work before it is ready).

The following code snippet and images will show a solution with an added kwarg, but I expect this is not exactly what you had in mind.


```
import numpy as np
import matplotlib.pyplot as plt

delta = 0.025
x = np.arange(-3.0, 3.0, delta)
y = np.arange(-2.0, 2.0, delta)
X, Y = np.meshgrid(x, y)
Z1 = np.exp(-X**2 - Y**2)
Z2 = np.exp(-(X - 1)**2 - (Y - 1)**2)
Z = (Z1 - Z2) * 2

# Negative contour defaults to dashed
fig, ax = plt.subplots()
CS = ax.contour(X, Y, Z, 6, colors='k')
ax.clabel(CS, fontsize=9, inline=True)
ax.set_title('Single color - negative contours dashed (default)')

# Set negative contours to be solid instead of dashed (default)
# using negative_linestyle='solid'
fig2, ax2 = plt.subplots()
CS = ax2.contour(X, Y, Z, 6, colors='k', negative_linestyles='solid')
ax2.clabel(CS, fontsize=9, inline=True)
ax2.set_title('Single color - negative contours solid')
```

### Default
![image](https://user-images.githubusercontent.com/28690153/168208633-7e0ca845-e218-445c-a19a-850f279a15ec.png)

### `negative_linestyles='solid'`
![image](https://user-images.githubusercontent.com/28690153/168208620-88c3a5eb-7bb4-4f6a-8890-b23c76a30928.png)
> Should the current `linestyles` kwarg be used to accomplish this or should a new kwarg be added?

How would we squeeze this into the current `linestyles` parameter? The only thing I could imagine is something like `linestyles={'positive': 'solid', 'negative': 'dotted'}`, which I find a bit cumbersome. I suppose an extra kwarg is simpler.
> How would we squeeze this into the current linestyles parameter?

I had no good solution for this either, but thought I would ask just in case.

The next question is: 
1. should this be a boolean (the rcParams method seems to be)
2. or should the kwarg accept a separate entry for negative linestyles?

I think the latter makes a lot more sense, but I don't work with contour plots regularly.
I think since the rcParam is separate, its fine to keep the (potential) kwarg separate.  BTW I'm not wedded to this idea, but it does seem strange to have a feature only accessible by rcParam.  

As for bool vs string, I'd say both?   right now the rcParam defaults to "dashed" - I think that's fine for a kwarg as well, but being able to say *False* to skip the behaviour would be nice as well.  
> BTW I'm not wedded to this idea

I can mock-up a basic solution. Maybe we can get opinions from other contributors and maintainers in the meantime.

I think this would add value because it would make customization of negative contours more straightforward. Since this doesn't require removing any current functionality, I don't see any cons to adding the kwarg.