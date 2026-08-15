I am working on it. Any tips are welcome :)

I found that ccode function can perform similar function. 

```
sympy.printing.ccode(Or(A, B))
A || B 
```

So, this issue can be resolved quickly. Thanks

ccode uses C operators, but the str printer should use Python operators (single `|` instead of `||`). Also, ccode will print all subexpressions as C code, which may not be desired. 

Hi, I'm a new contributor interested in working on this issue. I think that I should be able to fix it, and I've read through the previous pull request and understand why that approach did not work.

hi @aheyman11 , you can go ahead if you have fix for the bug.

Thanks @parsoyaarihant, working on it now.

@asmeurer  @parsoyaarihant 
Is this still open ? Can i work on this ? Kindly help me getting started,i am new here
I want to work on this.  Kindly let me know if this is still open? 