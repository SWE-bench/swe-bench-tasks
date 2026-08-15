Generally in SymPy `is_` properties return fuzzy-bools which use 3-way logic: True, False or None. None means that the the answer to the question is not known. Often that is because the code to answer the question has not been written/implemented.

Right now the `is_closed` property returns `self.boundary.is_subset(self)` and for rationals we have
```
In [1]: Rationals                                                                                                                                             
Out[1]: ℚ

In [2]: Rationals.boundary                                                                                                                                    
Out[2]: ℚ

In [3]: Rationals.boundary.is_subset(Rationals)                                                                                                               
Out[3]: True
```
Either Rationals.boundary should not be the Rationals or the `is_closed`
 method should be changed in general.

The `is_open` method returns True if `Intersection(self, self.boundary)` gives the empty set and None otherwise. That's why we get a None in this case.
> Either Rationals.boundary should not be the Rationals or the `is_closed`
> method should be changed in general.

I'd have expected the open/closed answers for subsets of the reals to be based on the topology on R. Otherwise (i.e. if the Rationals, Integers etc. were considered to be their own topological spaces) they'd all simply have to be considered open and closed by definition.

So that would mean `Rationals.boundary == Reals` (difference of closure(Q)=R and interior(Q)=empty).
It follows that Q is neither open nor closed.

I'm not a topologist though and my topology courses date back some time...

Do note that the docs for `is_open` and `is_closed` don't actually specify the topology, so that should be amended too.
@oscarbenjamin thx. 

>Generally in SymPy is_ properties return fuzzy-bools which use 3-way logic

i knew for first time. is it written in doc?



because of being different whether the set is closed or open  by universal set,  
may be have to change there properties to methods with arg `universal_set`. 
Generally in SymPy `is_` properties return fuzzy-bools which use 3-way logic: True, False or None. None means that the the answer to the question is not known. Often that is because the code to answer the question has not been written/implemented.

Right now the `is_closed` property returns `self.boundary.is_subset(self)` and for rationals we have
```
In [1]: Rationals                                                                                                                                             
Out[1]: ℚ

In [2]: Rationals.boundary                                                                                                                                    
Out[2]: ℚ

In [3]: Rationals.boundary.is_subset(Rationals)                                                                                                               
Out[3]: True
```
Either Rationals.boundary should not be the Rationals or the `is_closed`
 method should be changed in general.

The `is_open` method returns True if `Intersection(self, self.boundary)` gives the empty set and None otherwise. That's why we get a None in this case.
> Either Rationals.boundary should not be the Rationals or the `is_closed`
> method should be changed in general.

I'd have expected the open/closed answers for subsets of the reals to be based on the topology on R. Otherwise (i.e. if the Rationals, Integers etc. were considered to be their own topological spaces) they'd all simply have to be considered open and closed by definition.

So that would mean `Rationals.boundary == Reals` (difference of closure(Q)=R and interior(Q)=empty).
It follows that Q is neither open nor closed.

I'm not a topologist though and my topology courses date back some time...

Do note that the docs for `is_open` and `is_closed` don't actually specify the topology, so that should be amended too.
@oscarbenjamin thx. 

>Generally in SymPy is_ properties return fuzzy-bools which use 3-way logic

i knew for first time. is it written in doc?



because of being different whether the set is closed or open  by universal set,  
may be have to change there properties to methods with arg `universal_set`. 