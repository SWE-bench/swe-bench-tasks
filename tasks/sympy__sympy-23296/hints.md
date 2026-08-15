
:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v161). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* physics.units
  * Fixed dimensional evaluation for expressions containing predefined mathematical functions. ([#20333](https://github.com/sympy/sympy/pull/20333) by [@theanshm](https://github.com/theanshm))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.8.

<details><summary>Click here to see the pull request description that was parsed.</summary>

    …al functions

    <!-- Your title above should be a short description of what
    was changed. Do not include the issue number in the title. -->

    #### References to other Issues or PRs
    <!-- If this pull request fixes an issue, write "Fixes #NNNN" in that exact
    format, e.g. "Fixes #1234" (see
    https://tinyurl.com/auto-closing for more information). Also, please
    write a comment on that issue linking back to this pull request once it is
    open. -->
    Fixes #20288 

    #### Brief description of what is fixed or changed
    Fixed the return value for the function _collect_factor_and_dimension(). Previous return value led to wrong dimensional evaluation for expressions containing predefined mathematical functions.

    #### Other comments


    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->
    * physics.units
        * Fixed dimensional evaluation for expressions containing predefined mathematical functions. 
    <!-- END RELEASE NOTES -->

</details><p>

# [Codecov](https://codecov.io/gh/sympy/sympy/pull/20333?src=pr&el=h1) Report
> Merging [#20333](https://codecov.io/gh/sympy/sympy/pull/20333?src=pr&el=desc) (deeddbd) into [master](https://codecov.io/gh/sympy/sympy/commit/7f189265b46a0295a60f8cfe2ed449193e630852?el=desc) (7f18926) will **increase** coverage by `0.043%`.
> The diff coverage is `0.000%`.

```diff
@@              Coverage Diff              @@
##            master    #20333       +/-   ##
=============================================
+ Coverage   75.717%   75.761%   +0.043%     
=============================================
  Files          671       673        +2     
  Lines       174211    174389      +178     
  Branches     41117     41200       +83     
=============================================
+ Hits        131908    132119      +211     
+ Misses       36557     36553        -4     
+ Partials      5746      5717       -29     
```

Hi! Thanks for your contribution.

In SymPy we usually add at least one assertion to the unit tests to make sure that the issue has been fixed and won't be broken again in the future. Can you do that?
Sure. 
@Upabjojr there are some tests now. Does this look good to you?