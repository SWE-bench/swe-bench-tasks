That commit is from this PR https://github.com/sympy/sympy/pull/16864
This is a regression since 1.4
It goes wrong here:
https://github.com/sympy/sympy/blob/21183076095704d7844a832d2e7f387555934f0c/sympy/sets/handlers/intersection.py#L231
I'm not sure what that code is trying to do but we only hit that branch when calculating the intersection of the an ImageSet with Integers as base set and the Integers so ~~at that point the result of the intersection is just self~~.