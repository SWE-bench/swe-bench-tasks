```
**Labels:** Mechanics  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c1
Original author: https://code.google.com/u/101069955704897915480/

```
**Cc:** gilbertg...@gmail.com hazelnu...@gmail.com  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
One way to fix this would be to add kwargs to orientnew and passing them to the constructor of the new reference frame, line 958 of essential.py

A cleaner solution would be to add a class member variable (static class member?  not sure of terminology here) that you set once at the beginning of your script, like:

>>> ReferenceFrame.indices = ('1', '2', '3')

and then these would be used for the remainder of your script and you wouldn't have to constantly be passing in the indices argument.

However, this approach could get tricky if you have some frames you want to index with the 'x', 'y', 'z' convention and others which you want to use the '1', '2', '3' convention.  Requiring the user to specify indices all the time would avoid this but be a bit more typing and visual noise for derivations that use a single set of indices other than the 'x', 'y', 'z' ones.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c3
Original author: https://code.google.com/u/118331842568896227320/

```
I don't think that it is too much typing and visual noise for the user to type out the indices each time a reference frame is created. It would be the easier of the two solutions to simply implement the kwargs. You don't create that many reference frames in a typical script, and if you did need to create lots of reference frames you'd probably create them with a loop and store them in a list or something. Then it is easy to supply the same indices to each reference frame.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c4
Original author: https://code.google.com/u/110966557175293116547/

```
Did https://github.com/sympy/sympy/pull/706 fix this? (It is referenced in the pull blurb.)
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c5
Original author: https://code.google.com/u/117933771799683895267/

```
Yes, 706 fixed this.
Although now I realize that the docstring for orientnew wasn't updated properly. The Parameter list should include the two new optional parameters.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2781#c6
Original author: https://code.google.com/u/102887550923201014259/
