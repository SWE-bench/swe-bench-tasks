I can confirm this bug on master. Looks like it's been there a while
https://github.com/sympy/sympy/blob/2d700c4b3c0871a26741456787b0555eed9d5546/sympy/printing/pretty/pretty.py#L1814

`1/E` is `exp(-1)` which has totally different arg structure than something like `1/pi`:

```
>>> (1/E).args
(-1,)
>>> (1/pi).args
(pi, -1)
```
@ethankward nice!  Also, the use of `str` there isn't correct:
```
>>> pprint(7**(1/(pi)))                                                                                                                                                          
pi___
╲╱ 7 

>>> pprint(pi**(1/(pi)))                                                                                                                                                        
pi___
╲╱ π 

>>> pprint(pi**(1/(EulerGamma)))                                                                                                                                                
EulerGamma___
        ╲╱ π 
```
(`pi` and `EulerGamma` were not pretty printed)
I guess str is used because it's hard to put 2-D stuff in the corner of the radical like that. But I think it would be better to recursively call the pretty printer, and if it is multiline, or maybe even if it is a more complicated expression than just a single number or symbol name, then print it without the radical like

```
  1
  ─
  e
π
```

or

```
 ⎛ -1⎞
 ⎝e  ⎠
π