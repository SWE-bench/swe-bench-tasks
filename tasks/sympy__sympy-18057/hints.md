See also #12524
Safe flag or no, == should call _sympify since an expression shouldn't equal a string. 

I also think we should deprecate the string fallback in sympify. It has led to serious performance issues in the past and clearly has security issues as well. 
Actually, it looks like we also have

```
>>> x == 'x'
True
```

which is a major regression since 1.4. 

I bisected it to 73caef3991ca5c4c6a0a2c16cc8853cf212db531. 

The bug in the issue doesn't exist in 1.4 either. So we could consider doing a 1.5.1 release fixing this. 
The thing is, I could have swore this behavior was tested. But I don't see anything in the test changes from https://github.com/sympy/sympy/pull/16924 about string comparisons. 