I want to fix this bug :) May I?
ping @smichr  please nudge me in the right direction so I may work on this :)
What are we expecting `>>>decompogen(Max(3,  x), x)` to return?
Would it be `[max(3,x)]` ?
The issue still persists on `master`.
:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v149). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* solvers
  *  Added `Min`/`Max` support for `decompogen`. ([#18517](https://github.com/sympy/sympy/pull/18517) by [@namannimmo10](https://github.com/namannimmo10))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.6.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    <!-- Your title above should be a short description of what
    was changed. Do not include the issue number in the title. -->

    #### References to other Issues or PRs
    <!-- If this pull request fixes an issue, write "Fixes #NNNN" in that exact
    format, e.g. "Fixes #1234" (see
    https://tinyurl.com/auto-closing for more information). Also, please
    write a comment on that issue linking back to this pull request once it is
    open. -->
    Fixes #13612 

    #### Brief description of what is fixed or changed
    Before addition ---
    ```
    >>> decompogen(Min(5, x), x)
    ....
    ....
    ....
    ....
    File "sympy\core\compatibility.py", line 462, in default_sort_key
        return item.sort_key(order=order)
      File "sympy\core\cache.py", line 93, in wrapper
        retval = cfunc(*args, **kwargs)
      File "sympy\core\compatibility.py", line 792, in wrapper
        key = make_key(args, kwds, typed) if kwds or typed else args
      File "sympy\core\compatibility.py", line 724, in _make_key
        return _HashedSeq(key)
      File "sympy\core\compatibility.py", line 702, in __init__
        self.hashvalue = hash(tup)
    RuntimeError: maximum recursion depth exceeded
    ```
    After addition --- 
    ```
    >>> decompogen(Min(5, x), x)
    [Min, 5, x]
    ```
    #### Other comments


    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->
    *  solvers
        *  Added `Min`/`Max` support for `decompogen`. 
    <!-- END RELEASE NOTES -->

</details><p>

@smichr please review this
# [Codecov](https://codecov.io/gh/sympy/sympy/pull/18517?src=pr&el=h1) Report
> Merging [#18517](https://codecov.io/gh/sympy/sympy/pull/18517?src=pr&el=desc) into [master](https://codecov.io/gh/sympy/sympy/commit/cdef3e1a21bafcd4d0c789d19d38319615fee01d&el=desc) will **decrease** coverage by `21.719%`.
> The diff coverage is `n/a`.

```diff
@@              Coverage Diff               @@
##            master    #18517        +/-   ##
==============================================
- Coverage   75.320%   53.601%   -21.720%     
==============================================
  Files          637       640         +3     
  Lines       167069    167182       +113     
  Branches     39416     39429        +13     
==============================================
- Hits        125838     89612     -36226     
- Misses       35689     71735     +36046     
- Partials      5542      5835       +293     
```

The associated issue is still not fixed in `master`. Are you still working on it? @namannimmo10 
oops, I forgot about this one. I'm working on my project right now, I can pick this up later.. but if you want, feel free to move with it? 