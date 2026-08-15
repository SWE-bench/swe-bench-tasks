A can confirm this behavior, but removing and recreating the objects that host the callbacks in the callbacks is definitely on the edge of the intended usage.  

Why are you doing this?  In your application can you get away with not destroying your slider?
I think there could be a way to not destroy the slider. But I don't have the time to test that currently.
My workaround for the problem was using a button to redraw everything. With that everything is working fine.

That was the weird part for me as they are both callbacks, but in one everything works fine and in the other one all inputs are blocked. If what I'm trying doing is not the intended usage, that's fine for me. 
Thanks for the answer.
The idiomatic way to destructively work on widgets that triggered an event in a UI toolkit is to do the destructive work in an idle callback:
```python
def redraw():
    pyplot.clf()
    addElements()
    pyplot.draw()
    return False

def onchanged(values):
    print("on changed")
    print(values)
    pyplot.gcf().canvas.new_timer(redraw)
```
Thanks for the answer. I tried that with the code in the original post.
The line:

```python
pyplot.gcf().canvas.new_timer(redraw)
```
doesn't work for me. After having a look at the documentation, I think the line should be:

```python
pyplot.gcf().canvas.new_timer(callbacks=[(redraw, tuple(), dict())])
```

But that still didn't work. The redraw callback doesn't seem to trigger.
Sorry, I mean to update that after testing and before posting, but forgot to. That line should be:
```
    pyplot.gcf().canvas.new_timer(callbacks=[redraw])
```
Sorry for double posting; now I see that it didn't actually get called!

That's because I forgot to call `start` as well, and the timer was garbage collected at the end of the function. It should be called as you've said, but stored globally and started:
```
import matplotlib.pyplot as pyplot
import matplotlib.widgets as widgets


def redraw():
    print("redraw")
    pyplot.clf()
    addElements()
    pyplot.draw()
    return False


def onchanged(values):
    print("on changed")
    print(values)
    global timer
    timer = pyplot.gcf().canvas.new_timer(callbacks=[(redraw, (), {})])
    timer.start()


def onclick(e):
    print("on click")
    global timer
    timer = pyplot.gcf().canvas.new_timer(callbacks=[(redraw, (), {})])
    timer.start()


def addElements():
    ax = pyplot.axes([0.1, 0.45, 0.8, 0.1])
    global slider
    slider = widgets.RangeSlider(ax, "Test", valmin=1, valmax=10, valinit=(1, 10))
    slider.on_changed(onchanged)
    ax = pyplot.axes([0.1, 0.30, 0.8, 0.1])
    global button
    button = widgets.Button(ax, "Test")
    button.on_clicked(onclick)


addElements()

pyplot.show()
```
Thanks for the answer, the code works without errors, but I'm still able to break it when using the range slider. Then it results in the same problem as my original post. It seems like that happens when triggering the onchanged callback at the same time the timer callback gets called.
Are you sure it's not working, or is it just that it got replaced by a new one that is using the same initial value again? For me, it moves, but once the callback runs, it's reset because the slider is created with `valinit=(1, 10)`.
The code redraws everything fine, but when the onchanged callback of the range slider gets called at the same time as the redraw callback of the timer, I'm not able to give any new inputs to the widgets. You can maybe reproduce that with changing the value of the slider the whole time, while waiting for the redraw.
I think what is happening is that because you are destroying the slider every time the you are also destroying the state of what value you changed it to.  When you create it you re-create it at the default value which produces the effect that you can not seem to change it.  Put another way, the state of what the current value of the slider is is in the `Slider` object.   Replacing the slider object with a new one (correctly) forgets the old value.

-----

I agree it fails in surprising ways, but I think that this is best case "undefined behavior" and worst case incorrect usage of the tools.  In either case there is not much we can do upstream to address this (as if the user _did_ want to get fresh sliders that is not a case we should prevent from happening or warn on).
The "forgetting the value" is not the problem. My problem is, that the input just blocks for every widget in the figure. When that happens, you can click on any widget, but no callback gets triggered. That problem seems to happen when a callback of an object gets called that is/has been destroyed, but I don't know for sure.

But if that is from the incorrect usage of the tools, that's fine for me. I got a decent workaround that works currently, so I just have to keep that in my code for now.