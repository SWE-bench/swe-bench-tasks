
After some experimenting i observed that the issue is arising because the following is false

``` start
In [31]: st = ImageSet(Lambda(x,x),S.Naturals)

In [32]: st == S.Naturals
Out[32]: False
```

is_subset uses intersect function which creates this ImageSet as range and when comparing it to S.Naturals it returns False.

Why do you think the following should be `True`?

```
In [32]: st == S.Naturals
Out[32]: False
```

set of all Natural Numbers is mathematically {x for x in N} . I tried 

``` start
In [33]: S.Reals.intersect(squares)
Out[33]: 
⎧ 2                   ⎫
⎨x  | x ∊ {1, 2, …, ∞}⎬
⎩                     ⎭

In [34]: squares
Out[34]: 
⎧ 2        ⎫
⎨x  | x ∊ ℕ⎬
⎩          ⎭

In [35]: squares == S.Reals.intersect(squares)
Out[35]: False
```

> set of all Natural Numbers is mathematically {x for x in N}

Yeah, it is. But `st` & `S.Naturals` are instances of different classes.
Though you are right, we need to establish their equivalence in some way.

yeah is_subset compares the interesection of S.Reals with squares returns a set whose range is an ImageSet {x for x in N} . But squares have S.Naturals as their range hence we are getting the output as False . So we need to establish their equivalence in some way. 
I am thinking maybe writing a separate function for equality when S.Naturals ,S.Reals and S.Integers is involved

> I am thinking maybe writing a separate function for equality when S.Naturals ,S.Reals and S.Integers is involved

That may work, but I am not sure how far it would go.

In that case we have a lot of possibilities to handle, I do not think that would work. 
Consider

```
>>> imageset(Lambda(x, Abs(x-S(1)/2)), S.Naturals) == imageset(Lambda(x, Abs(x-S(1)/2)), S.Integers)
False.             # though they are same, but not easy to check
```

I thing possibilities are numerous.
Now but we can do one thing that check the domain first then if the domains are same only then check for equality in functions provided, I guess. 

@gxyd Can you elaborate on your idea of checking domains beforehand ?
What exactly do you mean by checking `S.Naturals` and `S.Integers` ?

This example at least is fixed:
```
In [14]: st = ImageSet(Lambda(x,x),S.Naturals)                                                           

In [15]: st == S.Naturals                                                                                
Out[15]: True
```