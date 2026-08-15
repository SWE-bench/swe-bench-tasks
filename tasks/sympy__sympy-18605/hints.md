I think it should be okay to use something that is possibly an integer like a plain `Symbol('n')`. So this is correct:
```julia
In [4]: x = Symbol('x', integer=False)                                                                                                         

In [5]: Idx('i', (x, y))                                                                                                                       
---------------------------------------------------------------------------
TypeError
```
What should be fixed is that this should not raise:
```julia
In [8]: Idx('i', Symbol('x'))                                                                                                                  
---------------------------------------------------------------------------
TypeError
```
The check for `range.is_integer` needs to take account of the case where `range.is_integer` gives None. Perhaps it should use `fuzzy_not/and`.
I am working on this.