Aha: There is
```
c.allsegs
```
which can be manipulated instead.
Hi @nschloe, has your problem been resolved?
Interesting between 3.4.2 and the default branch this has changed from a `LineCollection` to a `PathCollection` which notable does not even _have_ a `get_segments`.
`get_segments()` was wrong apparently, so problem solved for me.
@nschloe You identified a _different_ bug which is why does `lc.get_segments()` aggressively simplify the curve ?!

Internally all `Collection` flavors boil down to calling `renderer.draw_path_collection` and all of the sub-classes primarily provide nicer user-facing APIs to fabricate the paths that will be passed down to the renderer.  In `LineCollection` rather than tracking both the user supplied data and the internal `Path` objects, we just keep the `Path` objects and re-extract segments on demand.  To do this we use `Path.iter_segments` with defaults to asking the path if it should simplify the path (that is drop points that do not matter which is in turn defined by if the deflection away from "straight" is greater than some threshold).  The `Path` objects we are holding have values in data-space, but the default value of "should simplify" and "what is the threshold for 'not mattering'" are both set so that they make sense once the path has been converted to pixel space (`True` and `1/9`).  In `LineCollection.get_segments` we are not passing anything special so we are cleaning the path to only include points that make the path deviate by ~0.1111 (which eye-balling looks about right).  I think the fix here is to pass `simplify=False` in `LineColleciton.get_segments()`.
And the change from LineCollection -> PathCollection was 04f4bb6d1206d283a572f108e95ecec1a47123ca and is justified.