:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v160). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* matrices
  - `MatrixSymbol` will store Str in its first argument. ([#19715](https://github.com/sympy/sympy/pull/19715) by [@sylee957](https://github.com/sylee957))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.7.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    <!-- Your title above should be a short description of what
    was changed. Do not include the issue number in the title. -->

    #### References to other Issues or PRs
    <!-- If this pull request fixes an issue, write "Fixes #NNNN" in that exact
    format, e.g. "Fixes #1234" (see
    https://tinyurl.com/auto-closing for more information). Also, please
    write a comment on that issue linking back to this pull request once it is
    open. -->


    #### Brief description of what is fixed or changed


    #### Other comments


    #### Release Notes

    <!-- Write the release notes for this release below. See
    https://github.com/sympy/sympy/wiki/Writing-Release-Notes for more information
    on how to write release notes. The bot will check your release notes
    automatically to see if they are formatted correctly. -->

    <!-- BEGIN RELEASE NOTES -->
    - matrices
      - `MatrixSymbol` will store Str in its first argument.
    <!-- END RELEASE NOTES -->

</details><p>

I missed the introduction of `Str`. I don't see anything in the release notes about it. 
@sylee957 Any news on this?
This needs progress in #19841 to resolve the failing tests