Using assumptions sounds like a neat idea, but I would be careful about conflating finite numbers with finite ordinals. I would also use the new assumptions only, as the old assumptions cannot be extended without modifying the core. 

On the other hand I don't think the core currently supports `n*2 != 2*n`.

I must admit that I still haven't fully understood the difference between the "old" and the "new" assumptions.

And about your last comment: do you mean that the core always assume that `Mul` is commutative? How does it handle matrix multiplication if this is the case?

I wrote a python class for ordinal numbers less than epsilon_0 which has natural addition and natural multiplication, and I happened upon this issue. Might this code be useful as something to use as a base for a solution to this issue?

It uses natural (Hessenberg) operations, so `__mul__` is commutative for it (as is `__add__` ), so I don't know if it would serve the same purposes as well, but it also wouldn't have the problems mentioned above with `n*2 != 2*n` .

I hope I'm not going against any norms by responding to an old issue or anything like that. Just thought it might be possible that what I wrote could be helpful, and wanted to share it if it could be. It is fairly short, so it should be relatively easy to extend I think.

I haven't put it in any repository of mine yet, but I will do so shortly.

edit: I have since found another implementation by someone else which is more complete than what I wrote, and supports uncountable ordinals, at https://github.com/ajcr/py-omega .
Also, theirs uses the usual ordinal addition and multiplication, rather than the hessenberg natural operations, which looks like more what was in mind when this issue was made.

... and I just realized that there was a link to a different one in the original post. Now I feel silly. Whoops.

Sorry to bother you all.

> Now I feel silly. Whoops

Activity on an issue raises it to the top of the "recently updated" listing, so all is not lost. If nobody responds to an old issue it gets stale. Now...whether anything will happen or not is another issue ;-)

@jksuom can this be implemented? I want to take this up. Can you please tell me more about it.
It is hard to find easily accessible references where ordinal arithmetic is discussed in detail. The [wikipedia article](https://en.wikipedia.org/wiki/Ordinal_arithmetic) is probably the best starting point. It shows that there are (at least) two kinds of *ordinal arithmetic*, the 'classical' operations (defined by Cantor, I think) and 'natural' operations. The former are easier to understand but neither addition nor multiplication is commutative. The natural operations are commutative, but harder to construct.

It seems that Taranowsky ([referred to](http://web.mit.edu/dmytro/www/other/OrdinalArithmetic.py) in OP above) is using the natural operations. He has developed a new [notational system](http://web.mit.edu/dmytro/www/other/OrdinalNotation.htm) for the implementation. It looks rather complicated to me.

If I were to implement ordinal arithmetic, I would probably choose the classical operations. Ordinals could be constructed recursively and represented in Cantor's normal form. Ordinal could possibly be a subclass of Basic but not one of Expr as the addition is non-commutative. I see no need for using the Symbol class. Named ordinals can be defined as special (singleton) subclasses. The order relations should not be hard to implement, and it should also be possible to define `is_limit_ordinal` as a property. I'm not sure if assumptions are necessary, but they could be added later if desired.
@jksuom - I tend to agree with what you wrote.
thanks @jksuom  @pelegm  , I will try to implement it and soon open a PR.