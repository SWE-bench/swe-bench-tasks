Thanks for the bug report. A pull request with a fix is welcome
Will take this
In the file `sklearn/metrics/ranking.py`. I added the following lines.

<img width="977" alt="Screen Shot 2019-03-10 at 2 46 53 PM" src="https://user-images.githubusercontent.com/17526499/54089811-70738700-4343-11e9-89d5-a045c5a58326.png">

*negate the score we added above (typo in comment)

but it is NOT passing the checks that involve some unittests. Given that this is a bug, shouldn't it FAIL some unittests after fixing the bug? or am I interpreting the 'x' mark below COMPLETELY wrong?

<img width="498" alt="Screen Shot 2019-03-10 at 2 50 22 PM" src="https://user-images.githubusercontent.com/17526499/54089853-f2fc4680-4343-11e9-8510-37b0547738f5.png">

Since I see a 'x' mark, I haven't submitted a pull request. 
Can I submit a pull request for a bug despite the 'x' mark?
The point is that this case was not tested. So it won't fail any unit
tests, but any fix requires new tests or extensions to existing tests

I don't think this is quite the fix we want.  The edge case is not that the sample weight is zero (I just used that in the example to make the impact easy to see).  The problem is to account for any kind of non-default sample weight in the case of constant labels for all classes.

I'll work on a solution and some tests.