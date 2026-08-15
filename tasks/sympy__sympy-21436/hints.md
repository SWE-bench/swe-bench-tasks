@angadhn I've opened an issue for this topic that we discussed last night.
A minimum enhancement here would be to explain in the various `.orient*()` documentation that any call to `X.orient*()` will remove any prior relationships to `X` and that to construct a chain or tree of relative oriented reference frames requires that only un-oriented  frames can be added to the ends of the chain/branches.
I'm adding a reference to a previously closed/rejected pull request here. #13824
It is very similar, however, the solution there was to allow loops in a graph.

> Or if a user tries to do a loop:
> 
> ```python
> B.orient(A)
> C.orient(B)
> A.orient(C)
> ```
> 
> The last line should raise an error and say something like "Loops in graph not allowed", but what it does is overwrites all relationships to `A` in the last line, effectively undoing the first line.
> 
> The alternative use case should work. There is no reason we shouldn't allow construction of the graph in any sequence. Overwriting the relationships to `self` in calls to `orient()` is unnecessary. I think it was implemented like that because it was easier than checking the graph for consistency in a more thorough way.
> 
> I think the relationships between points do not have this issue and you can establish them in any order you like. It would be nice if frames also allowed that.


#21271 fixed almost all of the problems mentioned here. Only this part is left to be done.
@moorepants I was wondering if instead of giving error in case of loops in frames, shouldn't we raise `warning`  as we did in velocity.
> @moorepants I was wondering if instead of giving error in case of loops in frames, shouldn't we raise `warning`  as we did in velocity.

@moorepants So it should be a warning or an error?
I guess we should be consistent with what we did with point relationships.