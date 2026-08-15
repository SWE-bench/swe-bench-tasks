@smichr I would like to start working the issue

I would like to work on this as well
The diff is not right since it will indicate that `Mod(var('e',even=True)/2,2)==0` but that should remain unevaluated. So check the math and assumptions, first. If there is any merit to this idea, go ahead and open a PR. Maybe this can only be done if there is no denominator?
@smichr can you explain why it should remain unevaluated when the variable is constrained to be even? It makes sense to me that the result is 0.
@vdasu there is a `/2` there. An even number divided by 2 may or may not be even. 
Yes, the diff concerned me too. Many functions commute with Mod, but not all (division being a prime example). If we want to deal just with polynomials or even rational functions, it may be more robust to make use of the polys. 
i would like to work on this as well

> The diff is not right since it will indicate that `Mod(var('e',even=True)/2,2)==0` but that should remain unevaluated. So check the math and assumptions, first. If there is any merit to this idea, go ahead and open a PR. Maybe this can only be done if there is no denominator?

It is not returning True but return False for `Mod(var('e',even=True)/2,2)==0` as `Mod(e/2, 2) is not 0`. If I am missing something then please point. 
I would like to work on this issue as well
:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v134). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* functions
  * fixed a bug in mod ([#15505](https://github.com/sympy/sympy/pull/15505) by [@m-agboola](https://github.com/m-agboola) and [@smichr](https://github.com/smichr))

  * added a test ([#15505](https://github.com/sympy/sympy/pull/15505) by [@m-agboola](https://github.com/m-agboola) and [@smichr](https://github.com/smichr))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.4.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    modified the mod.py to return correct answer to Mod(3*i, 2).
    added a test (All as suggested by @smichr )

    Fixes #15493 

    Earlier
    ` sympify(3*k%2)
    Mod(3*k,2)`

    Now
    ` sympify(3*k%2)
    Mod(k,2)`

     **Release Notes**
    <!-- BEGIN RELEASE NOTES -->
    * functions
      * fixed a bug in mod 
      * added a test
    <!-- END RELEASE NOTES -->

</details><p>

@m-agboola  
The changes you have made will indicate that `Mod(var('e',even=True)/2,2)==0` but that should remain unevaluated. Make sure you make that work correctly before going ahead further.
Please add the test, 
```
e = symbols('e', even=True)
assert Mod(e/2, 2).subs(e, 6) == Mod(3, 2)
```
Hi, I just implemented the suggested changes stated above.
After adding the test I suggested, now take a look at the results of split 3 and 4 (the Travis results) and 

1. see what the modified code is giving, e.g. what does `(x - 3.3) % 1` given now; it was formerly `Mod(1.*x + 1-.3, 1)`
1. see if it makes sense or if it represents another corner case that should be avoided by the code and 
1. make the appropriate update to test or code
`(x - 3.3) % 1` still gives `Mod(1.*x + .7, 1)` which is equivalent to `Mod(1.*x + 1-.3, 1)`. I'm not sure I understand why Travis is failing.
> still gives `Mod(1.*x + .7, 1)`

Make sure you are in your branch and not master; if you are using Windows and switched branch then you have to restart the interactive session (if that is how you are checking this).