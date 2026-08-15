From the wikipedia article you cited:

In number theory http://en.wikipedia.org/wiki/Number_theory, _Euler's
totient_ or _phi function_, φ(_n_), is an arithmetic function
http://en.wikipedia.org/wiki/Arithmetic_function that counts the totatives
http://en.wikipedia.org/wiki/Totative of _n_, that is, the positive
integers less than or equal to _n_ that are relatively prime
http://en.wikipedia.org/wiki/Relatively_prime to _n_. Thus, if _n_
is a positive
integer http://en.wikipedia.org/wiki/Positive_integer, then φ(_n_) is the
number of integers _k_ in the range 1 ≤ _k_ ≤ _n_ for which the greatest
common divisor gcd http://en.wikipedia.org/wiki/Greatest_common_divisor(
_n_, _k_) = 1.[1]
http://en.wikipedia.org/wiki/Euler%27s_totient_function#cite_note-1[2]
http://en.wikipedia.org/wiki/Euler%27s_totient_function#cite_note-2 The
totient function is a multiplicative function
http://en.wikipedia.org/wiki/Multiplicative_function, meaning that if two
numbers _m_ and _n_ are relatively prime (with respect to each other), then
φ(_mn_) = φ(_m_)φ(_n_).[3]
http://en.wikipedia.org/wiki/Euler%27s_totient_function#cite_note-3[4]
http://en.wikipedia.org/wiki/Euler%27s_totient_function#cite_note-4

It looks like the issue is the "relatively prime" requirement, since it is
only defined for integers ( http://en.wikipedia.org/wiki/Coprime_integers
). Certainly, getting a list of integers less than or equal to n doesn't
require n to be a real number.
The requirement to get the number of integers k in the range 1 ≤ k ≤ n
doesn't require n to be an integer. I don't know if calculating the
greatest common divisor is defined for non-integers.  I'm unclear about the
efficacy or applicability of the totient function being a multiplicative
function.

David

On Fri, Jan 23, 2015 at 12:40 PM, Gaurav Dhingra notifications@github.com
wrote:

> According to the Totient function definition on wikipedia
> http://en.wikipedia.org/wiki/Euler%27s_totient_function, the totient of
> non-integer numbers is not there. But in sympy:
> 
>  totient(2.3)
> totient(2.3)
> 
>  the value is returned, instead of an error.
> 
> —
> Reply to this email directly or view it on GitHub
> https://github.com/sympy/sympy/issues/8875.

I don't get you completely, but The wolframalpha also raise an error, http://www.wolframalpha.com/input/?i=totient%282.3%29

In number theory, Euler's totient or phi function, φ(n), is an arithmetic function that counts the totatives of n,
and In number theory, a totative of a given positive integer n is an integer k

And in sympy/ntheory/factor_.py toitent class is also defined this way
class totient(Function):
    """
    Calculate the Euler totient function phi(n)

```
>>> from sympy.ntheory import totient
>>> totient(1)
1
>>> totient(25)
20

See Also
========

divisor_count
"""
@classmethod
def eval(cls, n):
    n = sympify(n)
    if n.is_Integer:
        if n < 1:
            raise ValueError("n must be a positive integer")
        factors = factorint(n)
        t = 1
        for p, k in factors.items():
            t *= (p - 1) * p**(k - 1)
        return t
```

it checks if n is a integer

So i think that gxyd is right and this should fix it:-
        else:
            raise ValueError("n must be a positive integer")

@smichr  plz. take a look at this issue, i think earlier you were discussing about the totient function's output but i think the input to the function should only be a positive integer.

@darkcoderrises i think adding the code you are suggesting i.e.(else: raise ValueError("n must be positive") would not work, since this totient function should still be returned unevaluated for an instance of Symbol. Ex.

> > > x = Symbol('x')
> > > totient(x)
> > > totient(x)              # should be returned as it is
> > > totient(oo)    # should raise an error

@gxyd Ya sorry for that we can do something like elif n is number(real and complex)

@smichr  please have a look at the reference i have given for this issue( #8875 ) .

I have added test cases for this as well.
Please review it.
https://github.com/sympy/sympy/pull/8923
