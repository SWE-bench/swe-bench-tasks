@bassdx: The python contour code has been due a refactor for some time; in fact I seem to have half-heartedly promised to do that about a year ago! (see https://github.com/matplotlib/matplotlib/issues/367).  The idea is to separate out the calculation/storage of the polygons from all the graphical stuff like colours, etc.  This will allow users to perform contour calculations without any GUI overhead, plus the graphical-aware ContourSet class can inherit from Artist for improved consistency with other plotting operations.  So in the long run we will get clipping from the Artist inheritance.

However, I won't be able to do this for a few months.  In the meantime, if you want to write a temporary solution then go for the one that is consistent with the other plotting functions as this is how it will end up.

@ianthomas23 Did this get dealt with in your most recent triangulation work?

@tacaswell: No, the two are unrelated.

Doesn't seem like there has been any movement on this since the last update. Seems like two options are listed in the OP:

+ Add a set_clip_path method directly to ContourSet https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/contour.py#L737
+ Thoroughly rework kwarg handling in ContourSet

Recommend looking at the first while the broader contour discussion can continue.

Recommend labeling as Difficulty: Medium.