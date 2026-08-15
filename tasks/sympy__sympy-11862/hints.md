Tracked down a bit: lambdify.py line 376 calls python's builtin `eval` from a string representation of the function.  This will convert the 64 digit float into a double precision.

Perhaps this is a design decision of `lambdify`: currently it cannot support more than double precision.  But then what is "module=mpmath" supposed to do here?

If you check the history of lambdify, someone refactored it long back and added the "modules" support. I personally never understood why the sympy or mpmath modules are necessary at all, because evalf and subs already give that functionality. I'd be fine with removing them because I've never heard of a use case.
