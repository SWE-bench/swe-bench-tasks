No need for sympification:

```
>>> n = 28300421052393658575
>>> sqrt(n)**2
13718090670089025
```

There's a problem with factorization:

```
>>> n = 28300421052393658575
>>> factorint(n)
{3: 1, 5: 2, 11: 2, 43: 1, 2063: 1, 4127: 1, 4129: 1}
```

The correct result would be `{3: 1, 5: 2, 11: 2, 43: 1, 2063: 2, 4127: 1, 4129: 1}` (missing a factor of 2063).
A smaller example is

```
>>> n = 2063**2 * 4127**1 * 4129**1
>>> n
72523341796127
>>> sqrt(n)**2 == n
False
>>> factorint(n)
{2063: 1, 4127: 1, 4129: 1}
```
Seems that there is an issue whenever "Close factors satisfying Fermat condition found" happens before "Trial division with ints [2 ... 32768] and fail_max=600" succeeds, based on the output from verbose=True
```
>>> factorint(2063**2*4127*4129,verbose=True)
Factoring 72523341796127
Trial division with ints [2 ... 32768] and fail_max=600
Close factors satisying Fermat condition found.
Factoring 8514001
Trial division with ints [2 ... 32768] and fail_max=600
Check for termination
Trial division with primes [1805 ... 2918]
        2063 ** 1
Check for termination
Factorization is complete.
Factoring 8518127
Trial division with ints [2 ... 32768] and fail_max=600
Check for termination
Trial division with primes [1805 ... 2919]
        2063 ** 1
Check for termination
Factorization is complete.
Factorization is complete.
{2063: 1, 4127: 1, 4129: 1}
```
Another example:
```
>>> factorint(2347**2*7039*7043,verbose=True)
Factoring 273083105367893
Trial division with ints [2 ... 32768] and fail_max=600
Close factors satisying Fermat condition found.
Factoring 16520533
Trial division with ints [2 ... 32768] and fail_max=600
Check for termination
Trial division with primes [1805 ... 3610]
        2347 ** 1
Check for termination
Factorization is complete.
Factoring 16529921
Trial division with ints [2 ... 32768] and fail_max=600
Check for termination
Trial division with primes [1805 ... 3610]
        2347 ** 1
Check for termination
Factorization is complete.
Factorization is complete.
{2347: 1, 7039: 1, 7043: 1}
```
I'm new here and not familiar with the code, but my guess is that it has something to do with the dictionary update on line 1181?
https://github.com/sympy/sympy/blob/5138712daf66fde7050c7fabdcec7bdc5d02d047/sympy/ntheory/factor_.py#L1172-L1181
It goes wrong here:
https://github.com/sympy/sympy/blob/5138712daf66fde7050c7fabdcec7bdc5d02d047/sympy/core/numbers.py#L2365
```
(Pdb) p dict
{2063: 1, 4127: 1, 4129: 1}
(Pdb) p 2063*4127*4129
35154310129
(Pdb) p b_pos
72523341796127
```
A more direct test:
```julia
In [1]: S(72523341796127).factors()                                                                                                                           
Out[1]: {2063: 1, 4127: 1, 4129: 1}
```
That takes us here:
https://github.com/sympy/sympy/blob/master/sympy/ntheory/factor_.py#L1274
And then to factorint:
https://github.com/sympy/sympy/blob/5138712daf66fde7050c7fabdcec7bdc5d02d047/sympy/ntheory/factor_.py#L861
```julia
In [1]: factorint(72523341796127)                                                                                                                             
Out[1]: {2063: 1, 4127: 1, 4129: 1}
```
Then it goes wrong somewhere starting here:
https://github.com/sympy/sympy/blob/5138712daf66fde7050c7fabdcec7bdc5d02d047/sympy/ntheory/factor_.py#L1162
So I tried replacing line 1181 in factor_.py
https://github.com/sympy/sympy/blob/5138712daf66fde7050c7fabdcec7bdc5d02d047/sympy/ntheory/factor_.py#L1181
with the following code:
```
for fac in facs:
    if fac in factors:
        factors[fac] += facs[fac]
    else:
        factors.update({fac:facs[fac]})
```
and that seems to solve the problem--the original dictionary update was overwriting factor information from previous Fermat factors instead of properly summing factor exponents. All wrong examples currently in this thread are corrected under this modification.

Could somebody else verify this? Should I submit a pull request? 
Yes, if you think you have a solution a pull request would be great.
OK I'll do some more testing and submit a pull request in the next few days
You can copy my fac branch or apply this diff, if you want:

```diff
diff --git a/sympy/ntheory/factor_.py b/sympy/ntheory/factor_.py
index 0cc90a6..8a07346 100644
--- a/sympy/ntheory/factor_.py
+++ b/sympy/ntheory/factor_.py
@@ -1178,7 +1178,8 @@ def factorint(n, limit=None, use_trial=True, use_rho=True, use_pm1=True,
                     facs = factorint(r, limit=limit, use_trial=use_trial,
                                      use_rho=use_rho, use_pm1=use_pm1,
                                      verbose=verbose)
-                    factors.update(facs)
+                    for k, v in facs.items():
+                        factors[k] = factors.get(k, 0) + v
                 raise StopIteration
 
             # ...see if factorization can be terminated
diff --git a/sympy/ntheory/tests/test_factor_.py b/sympy/ntheory/tests/test_factor_.py
index 34cd6b8..7725c73 100644
--- a/sympy/ntheory/tests/test_factor_.py
+++ b/sympy/ntheory/tests/test_factor_.py
@@ -1,5 +1,5 @@
 from sympy import (Mul, S, Pow, Symbol, summation, Dict,
-    factorial as fac)
+    factorial as fac, sqrt)
 from sympy.core.evalf import bitcount
 from sympy.core.numbers import Integer, Rational
 from sympy.core.compatibility import long, range
@@ -619,3 +619,8 @@ def test_is_amicable():
     assert is_amicable(173, 129) is False
     assert is_amicable(220, 284) is True
     assert is_amicable(8756, 8756) is False
+
+
+def test_issue_17676():
+    n = 28300421052393658575
+    assert sqrt(n)**2 == n

```