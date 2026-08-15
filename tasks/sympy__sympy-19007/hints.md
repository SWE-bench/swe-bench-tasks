I was aware of the problem that the coordinates were loosely handled even if the matrix had symbolic dimensions
I also think that `C[3, 0]` should be undefined because there is no guarantee that n is sufficiently large to contain elements.
`C[3, 0]` should just stay unevaluated, since it might be valid (I assume that's what you mean by 'undefined'). It should be possible to handle some cases properly, for example `C[n, 0]` should return `B[n - 1, 0]`.

If I get some time I might have a go at it, seems to be a nice first PR.

**EDIT:** Sorry that's not even true. If `n` is zero, then `C[n, 0]` is not `B[n - 1, 0]`.