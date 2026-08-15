Further investigation shows that this is not directly about the PDF backend. Rather, it occurs when _changing_ to the PDF backend to save as a `.pdf`. If you start directly with the PDF backend, then the Widget will see that the canvas doesn't support blitting and disable it. So this might affect anything which uses blitting, depending on what they do.
Defining `get_renderer` like this seems to work:
```patch
diff --git a/lib/matplotlib/backends/backend_pdf.py b/lib/matplotlib/backends/backend_pdf.py
index 7bd0afc456..d7adfdf53c 100644
--- a/lib/matplotlib/backends/backend_pdf.py
+++ b/lib/matplotlib/backends/backend_pdf.py
@@ -2796,6 +2796,12 @@ class FigureCanvasPdf(FigureCanvasBase):
     def get_default_filetype(self):
         return 'pdf'
 
+    def get_renderer(self):
+        if hasattr(self, '_renderer'):
+            return self._renderer
+        else:
+            raise ValueError('PDF must be saving to get a renderer')
+
     def print_pdf(self, filename, *,
                   bbox_inches_restore=None, metadata=None):
 
@@ -2808,12 +2814,15 @@ class FigureCanvasPdf(FigureCanvasBase):
             file = PdfFile(filename, metadata=metadata)
         try:
             file.newPage(width, height)
-            renderer = MixedModeRenderer(
+            self._renderer = MixedModeRenderer(
                 self.figure, width, height, dpi,
                 RendererPdf(file, dpi, height, width),
                 bbox_inches_restore=bbox_inches_restore)
-            self.figure.draw(renderer)
-            renderer.finalize()
+            try:
+                self.figure.draw(self._renderer)
+                self._renderer.finalize()
+            finally:
+                del self._renderer
             if not isinstance(filename, PdfPages):
                 file.finalize()
         finally:
```
Not sure if that's the best fix though.