I think, you can do same for other combinatorics classes.  For example, see XFAILed test test_sympy__combinatorics__prufer__Prufer in test_args.py.

I had a look at other combinatorics classes, but I feel that my knowledge of sympy's combinatorics module is not sufficient to edit the Prufer class.

This PR is needed by some refactory on the tensor module I am working on.

With this PR the following is 3x slower. I am -1 on this PR.

```
def test1():
    S = SymmetricGroup(9)
    c = 0
    for element in S.generate_dimino(af=False):
        c += 1
    print 'c=', c

test1()
```

> With this PR the following is 3x slower. I am -1 on this PR.

That's bad news. Unfortunately this PR adds a conversion from `list` to `Tuple` upon object creation. I suppose that data gets copied. Moreover, python's `int` are converted to sympy `Integer`, that also makes things slower.

Why do you need to use a Tuple for the args? The elements of the permutation should be the args.

And internally it can use whatever. I don't know why list would be 3x faster than Tuple, unless the benchmark is artificial. 

This seems like an old issue, but I think that this issue can be related to some errors like  `FiniteSet(*AlternatingGroup(4).generate())` failing because of unhashable contents.