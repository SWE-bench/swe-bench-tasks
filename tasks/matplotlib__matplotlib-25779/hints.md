I don't think we would add this to a low level patch like ellipse.  It's certainly possible to get the effect you want with an annotation arrow and a basic ellipses. If you need help with that discourse.Matplotlib.org is a good place to ask. 
I agree that this is probably too specific to put into the core library, but I would be open to a PR adding that as an example or tutorial (I think there is a way to build up that figure step-by-step that would fit in the divio "tutorial" definition). 
Here is an example I created. 

```
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(1, 1, subplot_kw={"aspect": "equal"})

ax.axvline(c="grey", lw=1)
ax.axhline(c="grey", lw=1)

xVec = 0.5+0.5j
yVec = 0.2+0.5j

sampling = 101
n = np.linspace(0, sampling, sampling)

x = np.real(xVec * np.exp(1j * 2 * np.pi * n / sampling))
y = np.real(yVec * np.exp(1j * 2 * np.pi * n / sampling))
ax.plot(x, y)

dx = x[-1] - x[-2]
dy = y[-1] - y[-2]
ax.arrow(x=x[-1], y=y[-1], dx=dx, dy=dy, head_width=0.05)

ax.grid()
ax.set_xlim((-1, 1))
ax.set_ylim((-1, 1))
plt.show()
```

I don't think we would add this to a low level patch like ellipse.  It's certainly possible to get the effect you want with an annotation arrow and a basic ellipses. If you need help with that discourse.Matplotlib.org is a good place to ask. 
I agree that this is probably too specific to put into the core library, but I would be open to a PR adding that as an example or tutorial (I think there is a way to build up that figure step-by-step that would fit in the divio "tutorial" definition). 
Here is an example I created. 

```
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(1, 1, subplot_kw={"aspect": "equal"})

ax.axvline(c="grey", lw=1)
ax.axhline(c="grey", lw=1)

xVec = 0.5+0.5j
yVec = 0.2+0.5j

sampling = 101
n = np.linspace(0, sampling, sampling)

x = np.real(xVec * np.exp(1j * 2 * np.pi * n / sampling))
y = np.real(yVec * np.exp(1j * 2 * np.pi * n / sampling))
ax.plot(x, y)

dx = x[-1] - x[-2]
dy = y[-1] - y[-2]
ax.arrow(x=x[-1], y=y[-1], dx=dx, dy=dy, head_width=0.05)

ax.grid()
ax.set_xlim((-1, 1))
ax.set_ylim((-1, 1))
plt.show()
```
