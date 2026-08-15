I can't easily test with cartopy 0.18.0 right now, but at least with 0.20, I cannot repro the issue.
Unfortunately also reproduces with cartopy 0.20.0 on my machine
Perhaps try attaching the eps file, so that we can check whether it's a problem on the viewer side?
The `mpl_3.4.3_bad.eps` is the only one without text rendered, the others are for reference

[results.zip](https://github.com/matplotlib/matplotlib/files/7452818/results.zip)
Thanks, at least I can see that your files do fail to render properly on my side too.  Now we need to figure out how to repro the whole thing...
Please let me know if I could gather some more debug information, maybe some intermediate representation.
Probably the most helpful would be a repro without cartopy.
I think I've found the root cause. The produced eps file has a number of shortcuts like `m` for `moveto`, `l` for `lineto` and (important) `ce` for `closepath eofill`.

When a clip path is defined in eps file it is also given a name so it can be reused later. It looks like
```(postscript)
/c1 {
721.386016 727.92 m
721.386016 7.2 l
7.2 7.2 l
7.2 727.92 l
721.386016 727.92 l

clip
newpath
} bind def
```
Well in my case this paths are not reused and the same path is defined again and again with names `c1`, `c2`, ..., `c9`, `ca`, `cb`, ..., and eventually `ce`.
So in fact the clip command shadows the closepath command and the rest of the document is screwed.

Well I see two problems here:
1. Obvious name clash that causes the bug
2. Redefinition of a same path again and again

Also I've played a bit with the script and noticed that eps output is not stable: that clipping paths are sometimes reused and sometimes are not. Everything else seems to be consistent (except for the header). I wrote a loop to save eps and in 7 cases of 20 the text was missing and it was present in 13 other cases.
Ah, thanks, that's a great investigation!  Here's a repro without cartopy, and where one indeed needs to define many clip paths:
```python
import matplotlib.pyplot as plt
fig, axs = plt.subplots(4, 4, subplot_kw=dict(projection="polar"))
for ax in axs.flat:
    ax.set(xticks=[], yticks=[])
    ax.plot([1, 2])
fig.suptitle("hello, world")
fig.savefig("/tmp/test.eps")
plt.show()
```
Replacing (4, 4) by (4, 3) (for example) avoids defining the "ce" path and doesn't show the problem.

I guess the shortest solution is to just not generate colliding clippath names, i.e.
```patch
diff --git i/lib/matplotlib/backends/backend_ps.py w/lib/matplotlib/backends/backend_ps.py
index 35c61b08f2..8c88bfa3c7 100644
--- i/lib/matplotlib/backends/backend_ps.py
+++ w/lib/matplotlib/backends/backend_ps.py
@@ -429,7 +429,7 @@ class RendererPS(_backend_pdf_ps.RendererPDFPSBase):
             key = (path, id(trf))
             custom_clip_cmd = self._clip_paths.get(key)
             if custom_clip_cmd is None:
-                custom_clip_cmd = "c%x" % len(self._clip_paths)
+                custom_clip_cmd = "c%d" % len(self._clip_paths)
                 self._pswriter.write(f"""\
 /{custom_clip_cmd} {{
 {self._convert_path(path, trf, simplify=False)}
@@ -570,7 +570,7 @@ grestore
         path_codes = []
         for i, (path, transform) in enumerate(self._iter_collection_raw_paths(
                 master_transform, paths, all_transforms)):
-            name = 'p%x_%x' % (self._path_collection_id, i)
+            name = 'p%d_%d' % (self._path_collection_id, i)
             path_bytes = self._convert_path(path, transform, simplify=False)
             self._pswriter.write(f"""\
 /{name} {{
```
(the second change is not needed, but is for consistency).