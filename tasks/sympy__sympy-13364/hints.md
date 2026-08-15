```
Issue 2728 has been merged into this issue.
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2616#c1
Original author: https://code.google.com/u/101069955704897915480/

```
**Status:** Valid  

```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2616#c2
Original author: https://code.google.com/u/asmeurer@gmail.com/

```
Mod has been implemented. So this can be implemented in general on Expr as efficiently on Integer (and probably Rational).  

I'm not clear what happens if a non-int is used in the second or third argument. Can that be defined?
```

Original comment: http://code.google.com/p/sympy/issues/detail?id=2616#c3
Original author: https://code.google.com/u/asmeurer@gmail.com/

Here is an implementation that includes support for negative exponents using some help with the <a href="http://stackoverflow.com/questions/4798654/modular-multiplicative-inverse-function-in-python">modular multiplicate inverse</a>.  Perhaps it can help folks in need until something official is ready.  Use as:

```
power_mod(67, 111, 101)
power_mod(67, -111, 101)
```

Of course, pow() would work for small positive integer examples, but when the args are sympy Integers, this will help.  And, pow() can't handle negative exponents while this one does.  This is a copy of what I posted for closed 5827.

```
def power_mod(base, exponent, n):
    base = sympy.Integer(base)
    exponent = sympy.Integer(exponent)
    is_neg = exponent < 0
    if is_neg:
        exponent = -exponent
    n = sympy.Integer(n)
    x = sympy.Integer(1)
    e = exponent
    c = sympy.Mod(base, n)
    vals = [c]
    x += 1
    while x <= exponent:
        c = sympy.Mod(c**2, n)
        vals.append(c)
        x *= 2

    x /= 2
    answer = sympy.Integer(1)
    while len(vals) > 0:
        nextv = vals.pop()
        if x <= e:
          answer = sympy.Mod(nextv*answer, n)
          e -= x
          if e == 0:
              break
        x /= 2
    if is_neg:
        answer = modinv(answer, n)
    return answer

def egcd(a, b):
    a = sympy.Integer(a)
    b = sympy.Integer(b)
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('modular inverse does not exist')
    else:
        return x % m
```

This is an old issue and I'm interested in working on it. I'd like to know if there is a reason why it hasn't been fixed yet, any organizational issues that I should be aware of? /cc @asmeurer 

I don't think so. I think it should be easy to implement. Call `pow()` if the arguments are numbers, and create the symbolic power mod n otherwise. 

@rd13123013 @asmeurer This can be fixed by simply allowing 3 arguments for `__pow__` in `Expr` class. However, it looks as if `_sympifyit`, allows only one argument. `_sympifyit` should be more flexible towards multiple args, I guess. Same is the case with `call_highest_priority`.  
