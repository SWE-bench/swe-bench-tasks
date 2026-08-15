```
In [14]: Poly(1.2*x*y*z, x)
Out[14]: Poly(1.2*y*z*x, x, domain='RR[y,z]')
```
I guess this is quite good

I mean why would we wanna do this
`In [15]: Poly(1.2*x*y*z, x, domain='RR[y,z]')`

BTW, Is this issue still on?
It is still a valid issue. The preprocessing of options should be extended to accept polynomial rings with real coefficients.
Hello, 
I would like to have this issue assigned to me. I want to start contributing, and reading the code I think I can fix this as my first issue.

Thanks
@3nr1c You don't need to have this issue assigned to you; if you have a solution, just send it a PR. Be sure to read [Development workflow](https://github.com/sympy/sympy/wiki/Development-workflow).