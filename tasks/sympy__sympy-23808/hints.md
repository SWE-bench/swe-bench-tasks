Nevermind, I should've looked closer at the problem...
The problem is that the function `sum_of_squares` calls `power_representation`, which then calls `pow_rep_recursive`, which is a simple recursive bruteforce algorithm. This can be fixed by generating the representations using the factorisation of `n` instead of bruteforcing.
The example that fails should be
```python
In [8]: list(SOS(588693170, 2))
---------------------------------------------------------------------------
RecursionError
```
The `sum_of_squares` function is not supposed to be the public interface though. How would you reproduce this with `diophantine`?

I tried this and it works fine:
```python
In [9]: diophantine(x**2 + y**2 - 588693170)
Out[9]: 
{(-24263, -1), (-24263, 1), (-24251, -763), (-24251, 763), (-24247, -881), (-24247, 881), (-24241, 
-1033), ...
```
Ohhh I see, thank you for the comment, I did not know that. It seems that calling `diophantine` should work as intended, as it uses the `cornacchia` algorithm which seems to be really quick.
This one does fail though:
```python
In [4]: diophantine(x**2 + y**2 + z**2 - 588693170)
---------------------------------------------------------------------------
RecursionError
```
Yes, since the equation type is `GeneralSumOfSquares` (see [here](https://github.com/sympy/sympy/blob/68bd36271334d7bf0ede9beea4bef494bceaacab/sympy/solvers/diophantine/diophantine.py#L1642)), which eventually calls `sum_of_squares` -> `power_representation` -> `pow_rep_recursive` on line 3880 and calls the recursive bruteforce. I am not aware of better methods for 3 squares or more, since for 2 squares you have a math formula

$$
(a^2+b^2)(c^2+d^2)=(ac+bd)^2+(ad-bc)^2=(ad+bc)^2+(ac-bd)^2
$$

Which is how we can "combine" solutions by factoring, but I am not aware of a similar formula for 3 or more squares. However, the implementation of `pow_rep_recursive` is really weird, as it should use around `k` recursion frames when coded correctly, but right not it uses `n^(1/p)` recursion frames.