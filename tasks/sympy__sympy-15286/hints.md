```
What is the actual integral being computed?

**Labels:** Integration  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3853#c1
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
**Labels:** Geometry  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3853#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Ellipse((0,0),3,1).circumference -> gives the integral
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3853#c3
Original author: https://code.google.com/u/117933771799683895267/

```
Integral.evalf is just slow. The whole thing should be audited. Even Integral.as_sum is often faster.

**Labels:** Evalf  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3853#c4
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
The code above is said to be a quadratically converging computation of the result so even if the general evalf improves, the above will likely be faster.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=3853#c5
Original author: https://code.google.com/u/117933771799683895267/

@smichr Is there a reason this hasn't been implemented if it's faster than the current method?

I think this issue is about taking care of such things everywhere.

I don't think anyone's done any work on `Integral.eval` in a long time. It needs some love. 

:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v132). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* geometry
  * added function `equation_using_slope` for finding equation of Ellipse using slope as parameter ([#15053](https://github.com/sympy/sympy/pull/15053) by [@Abdullahjavednesar](https://github.com/Abdullahjavednesar), [@NikhilPappu](https://github.com/NikhilPappu), [@Upabjojr](https://github.com/Upabjojr), [@asmeurer](https://github.com/asmeurer), [@avishrivastava11](https://github.com/avishrivastava11), [@cbm755](https://github.com/cbm755), [@czgdp1807](https://github.com/czgdp1807), [@grozin](https://github.com/grozin), [@isuruf](https://github.com/isuruf), [@jksuom](https://github.com/jksuom), [@maurogaravello](https://github.com/maurogaravello), [@moorepants](https://github.com/moorepants), [@raineszm](https://github.com/raineszm), [@rwbogl](https://github.com/rwbogl), [@smichr](https://github.com/smichr), [@sylee957](https://github.com/sylee957), and [@valglad](https://github.com/valglad))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.4.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    Added function for finding equation of Ellipse using slope as parameter.
    Added another method `Ellipse_Cirumference` for calculation of circumference of ellipse.
    Added a new method called `are_collinear`
    Pluralized the following methods
    `direction_ratio` -> `direction_ratios`
    `direction_cosine` -> `direction_cosines`

    Fixes #2815
    Fixes #6952
    Fixes #7713

    This PR uses the approach to finding equation of ellipse using slope, length of semi minor axis and length of semi major axis as inputs given [here](https://math.stackexchange.com/questions/108270/what-is-the-equation-of-an-ellipse-that-is-not-aligned-with-the-axis/646971#646971)
    This could be an added functionality to the equation finding method in class `Ellipse`.
    Thanks to @smichr  for providing the approach.

    Please take a look at this PR and suggest changes. I will be glad to implement them.
    Thanks.

    #### Release Notes

    <!-- BEGIN RELEASE NOTES -->
    * geometry
       * added function `equation_using_slope` for finding equation of Ellipse using slope as parameter
    <!-- END RELEASE NOTES -->


</details><p>

@smichr  Sir, since you were the one who brought up the idea of adding this functionality, can you take a look?

@jksuom  Sir can you take a look as well?
@smichr @jksuom 
I have added another method `Ellipse_Cirumference` for calculation of circumference of ellipse. This method is much faster as compared to the other method given already. This implementation is done on the lines given by @smichr  [here](https://github.com/sympy/sympy/issues/6952). So this PR can close issue #6952 also ( issue raised by @smichr ).

```
avi@avi-Aspire-A515-51G:~/sympy$ python3
Python 3.6.5 (default, Apr  1 2018, 05:46:30) 
[GCC 7.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from sympy import Ellipse
>>> e1 = Ellipse((0,0), 3, 1)
>>> e1.circumference.n()
13.3648932205553
>>> e1.Ellipse_Circumference()
13.3648932205553
```

@smichr  @jksuom  Can you please take a look?
@certik @jksuom  @smichr  Can you review this PR?

Also, please try to write proper git commit messages. The first line has a column limit, then an empty line, then explaining what the commit does. After the PR is finished, let's try to write it as a set of small, logical commits.
Just search online for some guidelines. Here is one: https://chris.beams.io/posts/git-commit/, with explanations + motivations.
We also have some stuff in our dev guide https://github.com/sympy/sympy/wiki/Development-workflow#writing-commit-messages. 
@certik 
>Also, please try to write proper git commit messages. The first line has a column limit, then an empty line, then explaining what the commit does. After the PR is finished, let's try to write it as a set of small, logical commits.

I will keep that in mind Sir, for sure.
@certik  I have addressed your reviews in this commit (3fb3f47). Please take a look. Also, please let me know if the commit message of this commit (3fb3f47) was fine or do I need to improve more. Thanks
@debugger22 @akshayah3  @smichr  Can you take a look at this PR? The latest commit (7a75f18) solves issue #7713.
@certik  Can you take a look now? I have added the fix for another issue namely #7713
@jksuom  Sir can you take a look?
@Abdullahjavednesar  I've addressed your review. Please take a look. Also, since I've addressed what you requested, could you remove the `author's turn` label, as it's misleading?
Algebraic-geometric mean is also implemented in `mpmath` ([agm](https://github.com/fredrik-johansson/mpmath/blob/master/mpmath/function_docs.py#L4972-L4984)) and used to compute complete elliptic integrals. The use of native `mpf` type makes it more efficient than an implementation with `Float` objects in SymPy.
```
In [1]: e = Ellipse(Point(0,0), 4, 3)

In [2]: %time e.circumference.n()
CPU times: user 82.5 ms, sys: 16.3 ms, total: 98.8 ms
Wall time: 86.6 ms
Out[2]: 22.1034921607095

In [3]: %time e.ellipse_circumference()
CPU times: user 196 ms, sys: 12.4 ms, total: 208 ms
Wall time: 202 ms
Out[3]: 22.1034921607095
```
Is there any reason to include this in SymPy?
@jksuom  Sorry, but I had initially thought that `.ellipse_circumference()` was faster than `.circumference` method. If it's the other way around, I'll remove that method (from the entire code of this PR).  Should I do that ?
Also, what do you think about the other methods I added namely `def equation_using_slope(self, slope):` and `def are_collinear(*args):` ?
@jksuom ping

`solve` is an expensive function. I would use the precomputed coefficients (as solved in the SO [comment](https://math.stackexchange.com/questions/108270/what-is-the-equation-of-an-ellipse-hat-is-not-aligned-with-the-axis/646971)) instead of repeatedly calling `solve`.
@jksuom  I've done that now sir. It turns out there was no need for even a single `solve` statement.
>I had initially thought that .ellipse_circumference() was faster than .circumference method. If it's the other way around, I'll remove that method

Should I remove it?
Please take a look.
@jksuom  ping

@certik Can you take a look?
@Abdullahjavednesar  Can you take a look?
Can someone restart the #28715.21 and #28715.22 test of ea3f48c commit. I think some http error has occurred and will be resolved by restarting the tests.
@Abdullahjavednesar @jksuom @smichr  Can you restart this failing test 28715.22 of ea3f48c i.e. the last commit ? (due to restarting 28715.21 passed, but 28715.22 still fails)
does this look good to merge now?
@certik @smichr does this look good to merge now?
@smichr  Looks like the commits got messed up somehow. I'll be opening up a new PR for this implementation (sort of a continuation) once [this](https://github.com/sympy/sympy/pull/15273) PR gets merged. Will that be fine?