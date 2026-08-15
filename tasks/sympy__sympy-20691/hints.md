:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v161). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* matrices
  * Solved a bug that prevented the use of the MatrixSymbol inversion. ([#20386](https://github.com/sympy/sympy/pull/20386) by [@jmgc](https://github.com/jmgc))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.8.

<details><summary>Click here to see the pull request description that was parsed.</summary>

    Fixes #19162

    #### Brief description of what is fixed or changed

    The present issue was detected when calculating the inverse of a MatrixSymbol. The reason came from the is_constant method that did not take into account the case of MatrixSymbol giving the error that the zero value is not subscriptable.

    #### Other comments

    A test has been added to test_matrices to check this case.

    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->

    * matrices
        * Solved a bug that prevented the use of the MatrixSymbol inversion. 

    <!-- END RELEASE NOTES -->

</details><p>

# [Codecov](https://codecov.io/gh/sympy/sympy/pull/20386?src=pr&el=h1) Report
> Merging [#20386](https://codecov.io/gh/sympy/sympy/pull/20386?src=pr&el=desc) (e83b757) into [master](https://codecov.io/gh/sympy/sympy/commit/9b613a56582f36421dea9e7720ad929630251741?el=desc) (9b613a5) will **increase** coverage by `0.012%`.
> The diff coverage is `100.000%`.

```diff
@@              Coverage Diff              @@
##            master    #20386       +/-   ##
=============================================
+ Coverage   75.747%   75.760%   +0.012%     
=============================================
  Files          673       673               
  Lines       174410    174411        +1     
  Branches     41205     41207        +2     
=============================================
+ Hits        132112    132135       +23     
+ Misses       36587     36563       -24     
- Partials      5711      5713        +2     
```

Does this work when it reaches random expression substitution cases like `expr._random(None, 1, 0, 1, 0)`?

It passes the different tests, however, I do not know if it reaches this specific line.
I think that this is not really the right approach to fixing the issue. I suggested something in https://github.com/sympy/sympy/issues/19162#issuecomment-620631559 that `MatrixElement` should check its arguments in the constructor.
> I suggested something in #19162 (comment) that MatrixElement should check its arguments in the constructor.

@jmgc Any thoughts on this? Please let us know if you are proceeding with this PR. Thanks for your contributions. 

Please do not close this PR.
My understanding is that if the solution proposed by @oscarbenjamin is more general, I think it is the one that should be used. However, the tests included in the present PR shall be kept to avoid new unexpected behaviour.

Thanks
