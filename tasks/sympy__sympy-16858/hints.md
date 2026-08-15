:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v147). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* stats
  * missing checks and attributes added to sympy.stats for distributions. ([#16571](https://github.com/sympy/sympy/pull/16571) by [@czgdp1807](https://github.com/czgdp1807))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.5.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    <!-- Your title above should be a short description of what
    was changed. Do not include the issue number in the title. -->

    #### References to other Issues or PRs
    <!-- If this pull request fixes an issue, write "Fixes #NNNN" in that exact
    format, e.g. "Fixes #1234". See
    https://github.com/blog/1506-closing-issues-via-pull-requests . Please also
    write a comment on that issue linking back to this pull request once it is
    open. -->
    N/A


    #### Brief description of what is fixed or changed
    Missing checks for parameters and set
    attributes have been added to various
    distributions to enhance consistency
    and correctness.


    #### Other comments
    These changes are made for enhancement of the code. This PR is made for receiving regular feedback on the code additions.
    Status - Work In Progress
    Please discuss with me on the changes I have made, so that I can present my view if I haven't made satisfactory changes. 

    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->
    * stats
      * missing checks and attributes added to sympy.stats for distributions.
    <!-- END RELEASE NOTES -->


</details><p>

# [Codecov](https://codecov.io/gh/sympy/sympy/pull/16571?src=pr&el=h1) Report
> Merging [#16571](https://codecov.io/gh/sympy/sympy/pull/16571?src=pr&el=desc) into [master](https://codecov.io/gh/sympy/sympy/commit/fa19fc79ed1053b67c761962b1c13d22806c5de8?src=pr&el=desc) will **increase** coverage by `0.07%`.
> The diff coverage is `94.871%`.

```diff
@@             Coverage Diff              @@
##            master    #16571      +/-   ##
============================================
+ Coverage   73.748%   73.819%   +0.07%     
============================================
  Files          619       619              
  Lines       158656    159426     +770     
  Branches     37185     37400     +215     
============================================
+ Hits        117006    117687     +681     
- Misses       36236     36282      +46     
- Partials      5414      5457      +43
```

@czgdp1807 
I have also added some tests for the same module in  #16557
Also done some documentation work. Currently, improving the documentation 
but do check thos  out.
We can improve the tests for the module togather. It will be more effective.

@jksuom Any reviews/comments on my additions, [this](https://github.com/sympy/sympy/pull/16571/commits/7586750516e43c9c07cd8041e54a177838624c84) and [this](https://github.com/sympy/sympy/pull/16571/commits/6bbb90102e5e68290434ee53263ae94c9999fb72). I am adding commits in chunks so that it's easier to review.
I have corrected the tests for sampling according to [#16741 (comment)](https://github.com/sympy/sympy/issues/16741#issuecomment-487299356) in [the latest commit](https://github.com/sympy/sympy/pull/16571/commits/8ce1aa8ffcb87cd684f1bf5ae643820916448340). Please let me know if any changes are required.
@jksuom Please review the [latest commit](https://github.com/sympy/sympy/pull/16571/commits/cdc6df358644c2c79792e75e1b7e03f883592d3b). 
Note:
I cannot add `set` property to `UnifromDistribution` because it results in the following `NotImplemented` error. It would be great if you can tell me the reason behind this. I will be able to investigate only after a few days.
```
>>> from sympy import *
>>> from sympy.stats import *
>>> l = Symbol('l', real=True, finite=True)
>>> w = Symbol('w', positive=True, finite=True)
>>> X = Uniform('x', l, l + w)
>>> P(X < l)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/gagandeep/sympy/sympy/stats/rv.py", line 756, in probability
    return result.doit()
  File "/home/gagandeep/sympy/sympy/integrals/integrals.py", line 636, in doit
    evalued_pw = piecewise_fold(Add(*piecewises))._eval_interval(x, a, b)
  File "/home/gagandeep/sympy/sympy/functions/elementary/piecewise.py", line 621, in _eval_interval
    return super(Piecewise, self)._eval_interval(sym, a, b)
  File "/home/gagandeep/sympy/sympy/core/expr.py", line 887, in _eval_interval
    B = self.subs(x, b)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 997, in subs
    rv = rv._subs(old, new, **kwargs)
  File "/home/gagandeep/sympy/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 1109, in _subs
    rv = self._eval_subs(old, new)
  File "/home/gagandeep/sympy/sympy/functions/elementary/piecewise.py", line 873, in _eval_subs
    c = c._subs(old, new)
  File "/home/gagandeep/sympy/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 1111, in _subs
    rv = fallback(self, old, new)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 1083, in fallback
    arg = arg._subs(old, new, **hints)
  File "/home/gagandeep/sympy/sympy/core/cache.py", line 94, in wrapper
    retval = cfunc(*args, **kwargs)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 1111, in _subs
    rv = fallback(self, old, new)
  File "/home/gagandeep/sympy/sympy/core/basic.py", line 1088, in fallback
    rv = self.func(*args)
  File "/home/gagandeep/sympy/sympy/core/relational.py", line 637, in __new__
    r = cls._eval_relation(lhs, rhs)
  File "/home/gagandeep/sympy/sympy/core/relational.py", line 916, in _eval_relation
    return _sympify(lhs.__ge__(rhs))
  File "/home/gagandeep/sympy/sympy/core/sympify.py", line 417, in _sympify
    return sympify(a, strict=True)
  File "/home/gagandeep/sympy/sympy/core/sympify.py", line 339, in sympify
    raise SympifyError(a)
sympy.core.sympify.SympifyError: SympifyError: NotImplemented

``` 
@supreet11agrawal @smichr Thanks for the comments and reviews. I will complete it after few clarifications in other PRs.