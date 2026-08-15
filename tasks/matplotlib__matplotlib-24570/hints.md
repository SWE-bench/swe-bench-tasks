This indeed seems incorrect, however, I'm not sure what the path to fixing it is even that it's likely been that way for quite a while and swapping back will break anyone who had corrected for the mistake.  

I can't see that we use this internally, and it's obviously untested.  
> This indeed seems incorrect, however, I'm not sure what the path to fixing it is even that it's likely been that way for quite a while and swapping back will break anyone who had corrected for the mistake.

There's no easy migration path. Probably the simplest thing is

1. Introduce a flag `fixed_api`. Default `False`. When true use the correct alignment interpretation. Warn if not set.
2. Wait some releases (*migration phase*)
3. Change the default to True and error out on False.
4. Wait some releases (*stabilization phase*) - This is necessary to buffer the migration and the cleanup phase. There's a certain overlap in versions in the installed base. A code that uses HPacker may need to support more than one matplotlib version.
5. Deprecate the flag.
6. Wait some releases (*cleanup phase*)
7. Remove the flag.

This is a bit annoying on the user-side because they need two steps (1) invert their logic and add the flag (2) remove the flag. But one cannot do it any simpler if one does not want to make a hard break, which is not an option.
I guess the fact we never use this internally, and no one has complained so far, indicates to me that this isn't used much externally?  If so, perhaps we just fix it?  
Why doesn't this count as a behavior change API change? We do it rarely but we have kinda  documented process for it? 
For reference, the `VPacker`'s `align='left'` or `align='right'` does work in the expected manner.
Introducing a flag like fixed_api and later removing it is quite a bit of work both for us and on the end user's side; one option that would be a bit less annoying (requiring handing this over fewer versions on our side and requiring fewer changes from the end users) would be to

1. e.g. in 3.7 introduce instead e.g. "TOP"/"BOTTOM" with the fixed meanings, and deprecate "top"/"bottom"; then later
2. in 3.9 remove the deprecation on "top"/"bottom" and at the same time change them to have the new fixed meanings. 
3. A possible step 3. is then to deprecate again "TOP"/"BOTTOM" and enforce again lowercase align, but that's not even really needed (we can just undocument them).
That works and is a shorter route at the cost of having subtle and IMHO ugly replacement values.

A somewhat drastic approach is write new layout classes and deprecate the packers. In the basic form that could be the same content but with fixed behavior and a new class name. Or we could use the occasion to create more capable alignment, c.f. https://github.com/matplotlib/matplotlib/pull/23140#issuecomment-1148048791.
During the call it was also suggested by @greglucas (IIRC) that this should just be considered a plain bugfix, which is also an option I'm warming up to... (perhaps that's also @jklymak's opinion stated just above.)
My argument is that if we make a mistake and accidentally redefine something like: `left, right = right, left`, and downstream users say "oh that looks like a simple bug, they just reversed the order and I can reverse it back again myself", then they are knowingly relying on flaky behavior, rather than notifying the source about the issue.

We have a user here who identified this bug and would find use in us fixing it properly, so why dance around fixing it with a long deprecation that this user will now have to work around themselves before the proper fix is in by default?

I don't think this is a clear-cut case either way for how to proceed, but I did want to bring up this option of calling this a bug rather than a "feature" that someone else has relied upon.

This code goes way back to svn in 2008 https://github.com/matplotlib/matplotlib/commit/3ae92215dae8f55903f6bc6c8c063e5cb7498bac, and perhaps doesn't get used in the bottom/top mode much because our offsetbox and legend test cases don't fail when moving the bottom/top definitions around. Just to be clear, I _think_ this is the patch we are all talking about:

```diff
diff --git a/lib/matplotlib/offsetbox.py b/lib/matplotlib/offsetbox.py
index 89bd3550f3..fcad63362b 100644
--- a/lib/matplotlib/offsetbox.py
+++ b/lib/matplotlib/offsetbox.py
@@ -170,10 +170,10 @@ def _get_aligned_offsets(hd_list, height, align="baseline"):
         descent = max(d for h, d in hd_list)
         height = height_descent + descent
         offsets = [0. for h, d in hd_list]
-    elif align in ["left", "top"]:
+    elif align in ["left", "bottom"]:
         descent = 0.
         offsets = [d for h, d in hd_list]
-    elif align in ["right", "bottom"]:
+    elif align in ["right", "top"]:
         descent = 0.
         offsets = [height - h + d for h, d in hd_list]
     elif align == "center":
```