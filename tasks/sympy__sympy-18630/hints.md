It seems that `hyper` (and other special functions) should have a private `_eval_nseries` method implemented.
I would like to work on this. Could someone please guide where should i start.
I would start by studying the existing implementations. Those can be found by running `git grep 'def _eval_nseries'`.
Why are the following limits taken and how are conditions which decide whether `super()._eval_nseries()` or `self._eval_nseries()` will be called determined ?
https://github.com/sympy/sympy/blob/c31a29a77a8b405d19ef79193ff0878345c62189/sympy/functions/elementary/trigonometric.py#L1136

https://github.com/sympy/sympy/blob/c31a29a77a8b405d19ef79193ff0878345c62189/sympy/functions/special/gamma_functions.py#L195-L196
@jksuom will something like this work:
```
def _eval_nseries(self, x, n, logx, ap, bq):

	from sympy.functions import factorial, RisingFactorial

	x0 = self.args[0].limit(x, 0)

	if not(x0==0):
	return super(gamma, self)._eval_nseries(x, n, logx)

	Rf1 = 1
	Rf2 = 1
	sum = 0

	for i in range(n):
		for p in range(len(ap)):
			Rf1 *= RisingFactorial(a,p+1)
		
		for q in range(len(bq)):
			Rf2 *= RisingFactorial(b,q+1)

		sum += ((Rf1/Rf2)*(x**i))/factorial(i)

	return sum
```
Another idea I had was to use an approach similar to ` _eval_rewrite_as_Sum()` but instead of taking a dummy variable a loop could be implemented
> def _eval_nseries(self, x, n, logx, ap, bq)

`_eval_nseries` has no parameters `ap`, `bq`. If this is for `hyper` (as I assume), then these are the first two arguments of `self`: `self.args[0]` and `self.args[1]`. `x0` will be obtained from `self.args[2]`. This can be seen from the code where instances of `hyper` are created: https://github.com/sympy/sympy/blob/a8a3a3b026cc55aa14010fc7cd7909806b6e116c/sympy/functions/special/hyper.py#L185-L187

`not(x0==0)` is usually written `x0 != 0`.
`return super(gamma, self)._eval_nseries(x, n, logx)`  should not contain gamma if this is for hyper. In fact, I think that `super()` should suffice as Python 2 need not be supported.

Otherwise, the series expansion looks correct (though I did not check carefully).
@jksuom I made the following changes but there are some tests failing locally.
```
--- a/sympy/functions/special/hyper.py
+++ b/sympy/functions/special/hyper.py
@@ -220,6 +220,32 @@ def _eval_rewrite_as_Sum(self, ap, bq, z, **kwargs):
         return Piecewise((Sum(coeff * z**n / factorial(n), (n, 0, oo)),
                          self.convergence_statement), (self, True))

+    def _eval_nseries(self, x, n, logx):
+
+        from sympy.functions import factorial, RisingFactorial
+
+        x0 = self.args[2].limit(x, 0)
+        ap = self.args[0]
+        bq = self.args[1]
+
+        if x0 != 0:
+            return super()._eval_nseries(x, n, logx)
+
+        Rf1 = 1
+        Rf2 = 1
+        series = 0
+
+        for i in range(n):
+            for a in ap:
+                Rf1 *= RisingFactorial(a, i)
+
+            for b in bq:
+                Rf2 *= RisingFactorial(b, i)
+
+            series += ((Rf1 / Rf2) * (x ** i)) / factorial(i)
+
+        return series
+
     @property
     def argument(self):
         """ Argument of the hypergeometric function. """

```
```
________________________________________________________________________________
_______ sympy\functions\special\tests\test_elliptic_integrals.py:test_K ________
Traceback (most recent call last):
  File "c:\users\mendiratta\sympy\sympy\functions\special\tests\test_elliptic_integrals.py", line 41, in test_K
    25*pi*z**3/512 + 1225*pi*z**4/32768 + 3969*pi*z**5/131072 + O(z**6)
AssertionError
________________________________________________________________________________
_______ sympy\functions\special\tests\test_elliptic_integrals.py:test_E ________
Traceback (most recent call last):
  File "c:\users\mendiratta\sympy\sympy\functions\special\tests\test_elliptic_integrals.py", line 111, in test_E
    5*pi*z**3/512 - 175*pi*z**4/32768 - 441*pi*z**5/131072 + O(z**6)
AssertionError
________________________________________________________________________________
___________ sympy\functions\special\tests\test_hyper.py:test_limits ____________
Traceback (most recent call last):
  File "c:\users\mendiratta\sympy\sympy\functions\special\tests\test_hyper.py", line 347, in test_limits
    O(k**6) # issue 6350
AssertionError

 tests finished: 441 passed, 3 failed, 12 skipped, 10 expected to fail,
in 146.80 seconds
DO *NOT* COMMIT!
```
I can't understand why

