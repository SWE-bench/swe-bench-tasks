I have added some handling for this instance in this [PR](https://github.com/sympy/sympy/pull/12320).  I did put thought into generalizing this even more for any integer divisor, but because we don't have the factorizations for the symbols, this does not seem easily possible.
Can you add some tests (based on the other tests, it looks like `sympy/core/tests/test_arit.py` is the proper file). 
@asmeurer , [here](https://github.com/mikaylazgrace/sympy/blob/Working-on-issue-8648/sympy/core/mul.py) is the updated work (line 1266) incorporating some of the ideas we discussed above.  I'm unsure if I am calling the functions .fraction() and .as_coeff_mul() correctly.

An error raised by Travis in the original PR said that when I called the functions (around line 90 in mul.py), "self is not defined".  Any ideas on how to call the functions?  Below is how I did it (which didn't work):

```
class Mul(Expr, AssocOp):

    __slots__ = []

    is_Mul = True
    is_odd = self._eval_is_odd()
    is_even = self._eval_is_even()
```



self is only defined inside of methods (where self is the first argument). There's no need to define is_odd or is_even. SymPy defines those automatically from _eval_is_odd and _eval_is_even.
@asmeurer , Travis is giving me this error:       
```
File "/home/travis/virtualenv/python2.7.9/lib/python2.7/site-packages/sympy/core/mul.py", line 1291, in _eval_is_odd
        symbols = list(chain.from_iterable(symbols)) #.as_coeff_mul() returns a tuple for arg[1] so we change it to a list
    TypeError: 'exp_polar' object is not iterable
```

I'm a bit unsure how to approach/fix this.  The added symbols = list... was in response to the fact that .as_coeff_mul() returns a tuple in arg[1] which isn't iterable.
I'm not clear what you are trying to do on that line. You should be able to just have 

```
coeff, args = self.as_coeff_mul()
for arg in args:
    ...
```
I had some equivalent of that, but Travis said that I was trying to iterate over a tuple. I thought .as_coeff_mul() returned a tuple for the second part? Maybe I'm incorrect there. 
I just made a small change that might solve it:  I'm looping over symbols instead of symbols.arg[1].  

I also changed .as_coeff_mul() per your suggestion (around line 1288):
```
        if is_integer:
            coeff,symbols = self.as_coeff_mul()
            if coeff == 1 or coeff == -1:
                r = True
                for symbol in symbols:
                ...
```

@mikaylazgrace Are you still interested to work on it?
I will takeover and come up with a PR soon.