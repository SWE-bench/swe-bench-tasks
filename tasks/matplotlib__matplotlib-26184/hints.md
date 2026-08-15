Try `ab.set_in_layout(False)` if you don't want an artist accounted for in constrained_layout.  

Probably an easy todo here is to be more explicit about `set_in_layout` in the constrained layout tutorial.  It is mentioned, but only in the context of a legend.

Edit:

sorry I see that you know about `set_in_layout(False).  What bug are you reporting then?  
Why does an annotation box _in_ an Axes who's content is also fully inside the Axes cause constrained layout to grow confused?
Not sure.  I assume AnnotationBox doesn't know it's bounding box until after a draw?  If you force a draw everything is fine.  Btw doubt this is unique to constrained_layout. 
If you do `ab.get_tightbbox()` before a draw you get `Bbox(x0=0.0, y0=-6.0, x1=142.125, y1=22.0)`; after a draw
`Bbox(x0=642.042, y0=523.467, x1=784.167, y1=551.467)` so `AnnotationBbox` indeed does not know its position until a draw is called.    I think OffsetBBox doesn't move the children until draw time, so in this case the text has an offset of 0, 0.  

I'll maintain these are pretty low-level artists, and obviously they do not conform to the standard tight_bbox and draw behaviour.  I'm not sure how far someone wants to go to fix that.    
Confirmed same result for `tight_layout`.  This is a long-standing behaviour.
ok, so the issue is that:

 - the the location is adjusted at draw time (which makes sense given that it is by definition an offset from something else)
 - the initialized bounding box (which is going to be junk) puts it outside of the Figure
 - this confuses auto-layout tools because they are being fed bogus information
 - excluding those artists from the layout avoids the problem

I agree that this is an edge case and it may not be worth the complexity required to solve this in a general way.  Maybe just a note in the `AnnotationBbox` docstring that it confuses the autolayout tools?
I think thats right.  We could factor the logic that does the placement out of the draw, and call that when the extent is asked for.  I think it's fair that the child doesn't know where it is, but the parent should be able to figure it out without having to do a whole draw.  But as it is, `draw` is necessary.  

We could add a comment about this until someone feels like fixing it. 
Wow, thanks a lot for the debate and the research. Really illuminating! 

Feel free to do whatever you think it's better with this issue (closing, leaving open until someone fixes it, changing title, etc). This appeared when someone reported an issue in a library I wrote https://github.com/tomicapretto/flexitext/issues/11 and internally we include text using `AnnotationBbox`
There seems to have been a change here for v3.6.  With the code from the OP, I get

v3.5.2 (no warnings)

![annotation_box_3 5](https://user-images.githubusercontent.com/10599679/203558617-73b19e90-8bda-40d2-ba49-f68a1d441be3.png)

v3.6.2 (warning as in OP)
![annotation_box_3 6](https://user-images.githubusercontent.com/10599679/203558725-9977948d-4d46-489c-88b7-a2a938100dc6.png)

The warning has been around for a while, but its trigger did change slightly in #22289. I have not checked, but possibly this PR introduced the change.
I just had my first go with `git bisect`, and I _think_ it's telling me the change was at #21935.
That seems like a likely place!
I can no longer reproduce the warning on `main`, and a `git bisect` points to #25713.  I have no clue how that changed it, but I can also report that, with v3.7.1, I see the warning with qtagg but not with agg.

Although we don't get the warning any more, we can still see from the plot that constrained layout is not being applied.
![annotation_box](https://github.com/matplotlib/matplotlib/assets/10599679/2ce62a83-7c22-447d-872f-d9265063d644)
