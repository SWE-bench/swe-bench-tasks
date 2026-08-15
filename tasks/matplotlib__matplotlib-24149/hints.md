This is the PR in question: https://github.com/matplotlib/matplotlib/pull/23751 (although I have not checked is that is causing it).
Thanks @oscargus that indeed looks like the culprit: it asks for the "next" finite value and does not handle the `StopIteration` exception that you get if there isn't one.
> which draws and then removes a "phantom" bar to trip the color cycle

We should definitely fix this regression, but is there a better way for seaborn to be managing the colors that does not require adding and removing artists?  I assume you use `np.nan` to avoid triggering any of the autoscaling?
> We should definitely fix this regression, but is there a better way for seaborn to be managing the colors that does not require adding and removing artists?

Definitely open to that but none that I am aware of! I don't think there's a public API for advancing the property cycle? AFAIK one would need to do something like `ax._get_patches_for_fill.get_next_color()`.

> I assume you use np.nan to avoid triggering any of the autoscaling?

Yep, exactly. Actually in most cases I just pass empty data, but `ax.bar([], [])` doesn't return an artist (just an empty `BarContainer` so it doesn't work with that pattern. See here for more details: https://github.com/mwaskom/seaborn/blob/5386adc5a482ef3d0aef958ebf37d39ce0b06b88/seaborn/utils.py#L138
Just as a meta comment I guess this should not have been milestones so aggressively?  The pr fixed a bug, but an old one so maybe could have waited for 3.7?
If I understand correctly, it did work in 3.6.0 for the all-nan case, but not for a leading nan (and other non-nan values). So although a bug was fixed in 3.6.1, this was introduced there as well.

(If my understanding is wrong then it could for sure have waited.)
```diff
✔ 15:28:08 $ git diff
diff --git a/lib/matplotlib/axes/_axes.py b/lib/matplotlib/axes/_axes.py
index fdac0f3560..de4a99f71d 100644
--- a/lib/matplotlib/axes/_axes.py
+++ b/lib/matplotlib/axes/_axes.py
@@ -2182,11 +2182,19 @@ class Axes(_AxesBase):
                 x0 = cbook._safe_first_finite(x0)
             except (TypeError, IndexError, KeyError):
                 pass
+            except StopIteration:
+                # this means we found no finite element, fall back to first
+                # element unconditionally
+                x0 = cbook.safe_first_element(x0)

             try:
                 x = cbook._safe_first_finite(xconv)
             except (TypeError, IndexError, KeyError):
                 x = xconv
+            except StopIteration:
+                # this means we found no finite element, fall back to first
+                # element unconditionally
+                x = cbook.safe_first_element(xconv)

             delist = False
             if not np.iterable(dx):

```

I think this is the fix, need to commit it and add a test.

-----


My memory of this was that this was a 3.6 regression from 3.5 but looking at the linked issue that was clearly wrong.