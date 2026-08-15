I want to take this issue.Please guide me on how to proceed.
I want to take this issue. Should I work over the apart function present in partfrac.py?
I guess I should. Moreover, it would be really helpful if you can guide me a bit as I am totally new to sympy.
Thanks !!
Hello there ! I have been trying to solve the problem too, and what I understand is that the result is varying where the expression is being converted to polynomial by ` (P, Q), opt = parallel_poly_from_expr((P, Q),x, **options) ` where `P, Q = f.as_numer_denom()` and f is the expression, the div() function in this line: `poly, P = P.div(Q, auto=True) ` is giving different result.

So, if I manually remove 'x' from the expression ` (P, Q), opt = parallel_poly_from_expr((P, Q),x, **options) `, and run the code with each line, I am getting the correct answer. Unfortunately I am currently not able to implement this on the code as whole.

Hope this will helps ! 
I am eager to know what changes should be made to get the whole code run !


I've already been working on the issue for several days and going to make a pull request soon. The problem is that a domain of a fraction is identified as a ZZ[y] in this example:
`In [9]: apart((x+y)/(2*x-y), x)`
`Out[9]: 0`

If I manually change the automatically detected domain to a QQ[y], it works correctly, but I fail on several tests, e.g. `assert ZZ[x].get_field() == ZZ.frac_field(x)`. 
The problem is that a ZZ[y] Ring is converted to a ZZ(y) Field. The division using DMP algorithm is done correctly, however during following conversion to a basic polynomial non-integers (1/2, 3/2 in this case) are considered to be a 0.

I have also compared to different expressions: (x+1)/(2*x-4), (x+y)/(2*x-y) and apart them on x. The differences appear while converting a Ring to a Field: `get_field(self)` method is different for each class.
It simply returns QQ for the IntegerRing, which is mathematically correct; while for PolynomialRing the code is more complicated. It initializes a new PolyRing class, which preprocesses domain according to it’s options and returns a new class: Rational function field in y over ZZ with lex order. So the polynomial with a fractional result is never calculated.

I guess the ZZ[y] Ring should be converted to a QQ(y) Field, since division is only defined for the Fields, not Rings.
@ankibues Well, your solution simply converts a decomposition on one variable (t in this case) to a decomposition on two variables (a, t), which leads to `NotImplementedError: multivariate partial fraction decomposition` for the `bug.apart(t)` code. 
Moreover, the problem is not only in the apart() function, e.g.
`In [20]: Poly(x + y, x).div(Poly(2*x - y, x))`
`Out[20]: (Poly(0, x, domain='ZZ[y]'), Poly(0, x, domain='ZZ[y]'))`
In this case the division is also done incorrectly. The domain is still ZZ[y] here, while it should be QQ[y] for getting an answer.
By the way, this `In [21]: apart((x+y)/(2.0*x-y),x)` works well:
`Out[21]: 1.5*y/(2.0*x - 1.0*y + 0.5`
  
And if I change the default Field for each Ring to QQ, the result is correct:
`Out[22]: 3*y/(2*(2*x - y)) + 1/2`
@citizen-seven  Thanks for your reply ! I understood why my solution is just a make-shift arrangement for one case, but would give errors in other !!
I want to take this issue.Please guide me on how to proceed.
I want to take this issue. Should I work over the apart function present in partfrac.py?
I guess I should. Moreover, it would be really helpful if you can guide me a bit as I am totally new to sympy.
Thanks !!
Hello there ! I have been trying to solve the problem too, and what I understand is that the result is varying where the expression is being converted to polynomial by ` (P, Q), opt = parallel_poly_from_expr((P, Q),x, **options) ` where `P, Q = f.as_numer_denom()` and f is the expression, the div() function in this line: `poly, P = P.div(Q, auto=True) ` is giving different result.

So, if I manually remove 'x' from the expression ` (P, Q), opt = parallel_poly_from_expr((P, Q),x, **options) `, and run the code with each line, I am getting the correct answer. Unfortunately I am currently not able to implement this on the code as whole.

Hope this will helps ! 
I am eager to know what changes should be made to get the whole code run !


I've already been working on the issue for several days and going to make a pull request soon. The problem is that a domain of a fraction is identified as a ZZ[y] in this example:
`In [9]: apart((x+y)/(2*x-y), x)`
`Out[9]: 0`

If I manually change the automatically detected domain to a QQ[y], it works correctly, but I fail on several tests, e.g. `assert ZZ[x].get_field() == ZZ.frac_field(x)`. 
The problem is that a ZZ[y] Ring is converted to a ZZ(y) Field. The division using DMP algorithm is done correctly, however during following conversion to a basic polynomial non-integers (1/2, 3/2 in this case) are considered to be a 0.

I have also compared to different expressions: (x+1)/(2*x-4), (x+y)/(2*x-y) and apart them on x. The differences appear while converting a Ring to a Field: `get_field(self)` method is different for each class.
It simply returns QQ for the IntegerRing, which is mathematically correct; while for PolynomialRing the code is more complicated. It initializes a new PolyRing class, which preprocesses domain according to it’s options and returns a new class: Rational function field in y over ZZ with lex order. So the polynomial with a fractional result is never calculated.

I guess the ZZ[y] Ring should be converted to a QQ(y) Field, since division is only defined for the Fields, not Rings.
@ankibues Well, your solution simply converts a decomposition on one variable (t in this case) to a decomposition on two variables (a, t), which leads to `NotImplementedError: multivariate partial fraction decomposition` for the `bug.apart(t)` code. 
Moreover, the problem is not only in the apart() function, e.g.
`In [20]: Poly(x + y, x).div(Poly(2*x - y, x))`
`Out[20]: (Poly(0, x, domain='ZZ[y]'), Poly(0, x, domain='ZZ[y]'))`
In this case the division is also done incorrectly. The domain is still ZZ[y] here, while it should be QQ[y] for getting an answer.
By the way, this `In [21]: apart((x+y)/(2.0*x-y),x)` works well:
`Out[21]: 1.5*y/(2.0*x - 1.0*y + 0.5`
  
And if I change the default Field for each Ring to QQ, the result is correct:
`Out[22]: 3*y/(2*(2*x - y)) + 1/2`
@citizen-seven  Thanks for your reply ! I understood why my solution is just a make-shift arrangement for one case, but would give errors in other !!