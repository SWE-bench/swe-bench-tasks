Bbox_inches tight basically changes the size of the canvas every frame.  I guess a todo might be to lock that option out, but the work around is to not do that. 
Can we resize the size for first frame and then fix to that size?
I do not have FFMpeg installed to try, but 
```
fig, ax = plt.subplots(layout='tight')
```
*may* work.

Edit: possibly `layout='compressed'` may be more well behaved.
Thanks, @oscargus 

`layout='tight'` or `layout='compressed'` will change sizes of axes, I have multiple axes and do not want to change their sizes and the alyout.
The example works for me if I replace `FFMpegWriter` with `FFMpegFileWriter`.  Is that any good to you?
> `layout='tight'` or `layout='compressed'` will change sizes of axes, I have multiple axes and do not want to change their sizes and the layout.

`bbox_inches='tight'` makes the figure bigger, which changes the layout as well.  If you are using a manual layout, is there any reason you cannot make it fit inside the figure to start with?  

> FFMpegFileWriter

Tahnks, @rcomer 

It works for the example, but it won't work if I add something out of bounds, e.g.:
```python
import matplotlib.pyplot as plt
from matplotlib.animation import FFMpegFileWriter
import numpy as np

fig, ax = plt.subplots()
moviewriter = FFMpegFileWriter()
moviewriter.setup(fig, 'movie.mp4', dpi=200)

line = ax.plot([], [])[0]
ax.text(1.5,1.5,'helloworld',)
    
x = np.linspace(0,2*np.pi,20)
ax.set(xlim=[0, 2*np.pi], ylim=[-1.1, 1.1])
for t in np.linspace(0,2*np.pi,20):    
    line.set_data(x, np.sin(x-t))
    moviewriter.grab_frame(bbox_inches='tight')
    
moviewriter.finish()
```
> > `layout='tight'` or `layout='compressed'` will change sizes of axes, I have multiple axes and do not want to change their sizes and the layout.
> 
> `bbox_inches='tight'` makes the figure bigger, which changes the layout as well. If you are using a manual layout, is there any reason you cannot make it fit inside the figure to start with?

I am creating a plotting tool that user can add new axes to canvas (figure) with new locations. They can sit outside the existing canvas and this works with `figsave(bbox_inches='tight')`  as it crops to the minimum extent of all artists


The core of the problem is that when you set up the writer it looks at how big the figure is when rendered (NxM pixels as RGBA).  Those values are passed to ffmpeg and it then expects NxMx4 byets per-frame to be pushed into stdin.   If you then pass frames that are either bigger or smaller ffmpeg does not know that, it is just wrapping the linear sequence of bytes into the size your promised to send it.

If there are are a different number of columns than you started with then the extra (missing) pixels will be wrapped and each row will be shifted right (left) relative to the row above.  This is why in the bad video it looks skewed.

If there are more (or less) rows that we told ffmeg the extra rows either get put at the top of the next frame are are added to the previous frame until the frame is full.   This is the source of the vertically moving black line line (that is likely the top or bottom of the Axes).

Even if we managed to get `setup(...)` to be aware of `bbox_inches='tight'` it would not be generically safe to use because if an animation frame adds something out side / removes something then the animation will break because the rendered size of the frame changed.  I do not think that zero-padding the resulting image or cropping it make much sense to try because it would both be complicated and you would have to decide were to pad/crop.  This might save you from a "starflake" movie, but your animation could jump around.

We actually have a fair amount of logic in `grab_frame(...)` to make sure that we resize the figure back to the size it was when we called `setup(...)` however all of that is defeated by `bbox_inches='tight'`: https://github.com/matplotlib/matplotlib/blob/8ca75e445d136764bbc28d8db7346c261e8c6c41/lib/matplotlib/animation.py#L352-L360

Unfortunately I think the right course of action here is for `grab_frame` to raise if `bbox_inches` is passed at all (even a fixed bounding box will be problematic if `setup(...)` did not know about it.

I think all of `bbox_inches`, `dpi`, and `format` need to be forbidden (and some will fail with `TypeError` now on some of the MovieWriters.