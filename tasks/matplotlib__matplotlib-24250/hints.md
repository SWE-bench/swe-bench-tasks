(As I have some issues with my Qt install, I tried it with tk and wx and get None for both types of events... Also on CentOS 7.)
@oscargus 
Thanks for the response! That's even worse 😅  Do you have any idea what's going on here?
(as far as I know this is the correct way of determining if a key is pressed while a mouse-button is clicked...)
Oh, I wouldn't trust my statement so much...

Ler me fet back tomorrow (left the office now) with the proper outcome.

No, I do not really know what is going on, but I seem to recall that there is something with Wayland not reporting keys correctly. Will try to dig up that issue.
Managed to reproduce this issue on EndeavourOS.
@oscargus the issue happens also on X11, not only Wayland
@oscargus It took me a while to sort out, you have to hold down '1" (or really any key) as this is looking at the key board key not the mouse button).  I was also thrown using 1, 2, 3 as those are the names of the mouse buttons.  If I hold 'a' down I get


```
pick_event None
button_press_event a
pick_event None
button_press_event a
```

which matches the OP. 

This a regression from 3.5, likely due to the refactoring of the event tracking done in https://github.com/matplotlib/matplotlib/pull/16931 but have not bisected to be sure.

attn @anntzer 
Indeed, this occurs because both (1) attaching the key attribute to the mouseevent and (2) emitting the pick_event are now done by callbacks, and we just need to ensure that callback (1) comes before callback (2), i.e.
```patch
diff --git i/lib/matplotlib/figure.py w/lib/matplotlib/figure.py
index 1636e20101..2bbd5254b9 100644
--- i/lib/matplotlib/figure.py
+++ w/lib/matplotlib/figure.py
@@ -2444,10 +2444,6 @@ class Figure(FigureBase):
         # pickling.
         self._canvas_callbacks = cbook.CallbackRegistry(
             signals=FigureCanvasBase.events)
-        self._button_pick_id = self._canvas_callbacks._connect_picklable(
-            'button_press_event', self.pick)
-        self._scroll_pick_id = self._canvas_callbacks._connect_picklable(
-            'scroll_event', self.pick)
         connect = self._canvas_callbacks._connect_picklable
         self._mouse_key_ids = [
             connect('key_press_event', backend_bases._key_handler),
@@ -2458,6 +2454,10 @@ class Figure(FigureBase):
             connect('scroll_event', backend_bases._mouse_handler),
             connect('motion_notify_event', backend_bases._mouse_handler),
         ]
+        self._button_pick_id = self._canvas_callbacks._connect_picklable(
+            'button_press_event', self.pick)
+        self._scroll_pick_id = self._canvas_callbacks._connect_picklable(
+            'scroll_event', self.pick)
 
         if figsize is None:
             figsize = mpl.rcParams['figure.figsize']
```
fixes the issue AFAICT.

Feel free to pick up the patch, or I'll make a PR if no one else does.