I'll work on this issue.
What if `Float(s, prec='b54')` is treated to refer to binary precision and `Float(s, prec=54)` to 54 decimal digits.Would that be a decent workaround ?
That would make it more annoying for the user, who has to do `'b' + str(prec)`. The API I suggested above would match other functions (like RealField), and the mpmath API