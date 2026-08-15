I'm not sure there is a need to handle this case. Users should know not to mutate something while iterating over it.
With regards to the above discussion, I believe it would indeed be helpful if modifying a passed list to ``uniq`` raises an error while iterating over it, because it does not immediately follow that ``uniq(f)`` would get updated if ``f`` gets updated, as the user might think something like ``uniq`` stores a copy of ``f``, computes the list of unique elements in it, and returns that list. The user may not know, that yield is being used internally instead of return.

I have a doubt regarding the implementation of ``uniq``:
[https://github.com/sympy/sympy/blob/5bfe93281866f0841b36a429f4090c04a0e81d21/sympy/utilities/iterables.py#L2109-L2124](url)
Here, if the first argument, ``seq`` in ``uniq`` does not have a ``__getitem__`` method, and a TypeError is raised somehow, then we call the ``uniq`` function again on ``seq`` with the updated ``result``, won't that yield ALL of the elements of ``seq`` again, even those which have already been _yielded_? 
So mainly what I wanted to point out was, that if we're assuming that the given ``seq`` is iterable (which we must, since we pass it on to the ``enumerate`` function), by definition, ``seq`` must have either ``__getitem__`` or ``__iter__``, both of which can be used to iterate over the **remaining elements** if the TypeError is raised. 
Also, I'm unable to understand the role of ``result`` in all of this, kindly explain.

So should I work on the error handling bit in this function?