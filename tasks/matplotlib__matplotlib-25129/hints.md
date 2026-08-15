I can't get this to work on `macosx` backend either.
Bisects to 733fbb092e1fd5ed9c0ea21fbddcffcfa32c738f
Something similar (with raw multicursor) was actually noticed prior to merge and merged despite this issue: https://github.com/matplotlib/matplotlib/pull/19763#pullrequestreview-657017782

Also reference to https://github.com/matplotlib/matplotlib/pull/24845 for where the precise issue was fixed, and is likely similar to the fix needed here.
Simply adding the preceding `_` in the example subclass does fix the issue.

<details>
<summary> Git diff </summary>

```diff

diff --git a/examples/widgets/annotated_cursor.py b/examples/widgets/annotated_cursor.py
index eabec859fe..42af364686 100644
--- a/examples/widgets/annotated_cursor.py
+++ b/examples/widgets/annotated_cursor.py
@@ -105,7 +105,7 @@ class AnnotatedCursor(Cursor):
         # The position at which the cursor was last drawn
         self.lastdrawnplotpoint = None
 
-    def onmove(self, event):
+    def _onmove(self, event):
         """
         Overridden draw callback for cursor. Called when moving the mouse.
         """
@@ -124,7 +124,7 @@ class AnnotatedCursor(Cursor):
         if event.inaxes != self.ax:
             self.lastdrawnplotpoint = None
             self.text.set_visible(False)
-            super().onmove(event)
+            super()._onmove(event)
             return
 
         # Get the coordinates, which should be displayed as text,
@@ -152,7 +152,7 @@ class AnnotatedCursor(Cursor):
         # Baseclass redraws canvas and cursor. Due to blitting,
         # the added text is removed in this call, because the
         # background is redrawn.
-        super().onmove(event)
+        super()._onmove(event)
 
         # Check if the display of text is still necessary.
         # If not, just return.
@@ -255,7 +255,7 @@ class AnnotatedCursor(Cursor):
         # Return none if there is no good related point for this x position.
         return None
 
-    def clear(self, event):
+    def _clear(self, event):
         """
         Overridden clear callback for cursor, called before drawing the figure.
         """
@@ -263,7 +263,7 @@ class AnnotatedCursor(Cursor):
         # The base class saves the clean background for blitting.
         # Text and cursor are invisible,
         # until the first mouse move event occurs.
-        super().clear(event)
+        super()._clear(event)
         if self.ignore(event):
             return
         self.text.set_visible(False)
@@ -274,7 +274,7 @@ class AnnotatedCursor(Cursor):
 
         Passes call to base class if blitting is activated, only.
         In other cases, one draw_idle call is enough, which is placed
-        explicitly in this class (see *onmove()*).
+        explicitly in this class (see *_onmove()*).
         In that case, `~matplotlib.widgets.Cursor` is not supposed to draw
         something using this method.
         """
```
</details>



Ultimately, the problem is that the subclass is overriding behavior using previously public methods that are called internally, but the internal calls use the `_` prefixed method, so the overrides don't get called.


If not, should we undo that deprecation?

(It was also merged without updating the deprecation version, but that was remedied in #24750)
(accidental close while commenting)
Looking at it again,
1) I think that onmove and clear actually need to be public APIs (technically, publically overriddable) on Cursor for that widget to be useful (well, other than just displaying a crosshair with absolutely no extra info, which seems a bit pointless); 
2) OTOH, even with these as public API, the overriding done in annotated_cursor.py is just extremely complicated (and tightly coupled to the class internals, as this issue shows); compare with cursor_demo.py which implements essentially the same features in ~4x fewer lines and is much easier to follow (true, the snapping is to the closest point and not only decided by x/y, but that could easily be changed).

Therefore, I would suggest 1) restoring onmove() and clear() as public APIs (grandfathering an essentially frozen version of the Cursor class in, as it goes all the way back to 2005), and 2) getting rid of annotated_cursor.py (because we really don't want to encourage users to do that, and should rather point them to cursor_demo.py).  If really desired we could augment cursor_demo to implement tracking and text positioning as in annotated_cursor, but I think it's optional.