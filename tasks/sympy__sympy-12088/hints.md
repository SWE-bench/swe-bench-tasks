It looks like `Float.__new__` is the culprit. There is even a comment. After including the precision
```
diff --git a/sympy/core/numbers.py b/sympy/core/numbers.py
index 09501fa..ddbf562 100644
--- a/sympy/core/numbers.py
+++ b/sympy/core/numbers.py
@@ -851,7 +851,7 @@ def __new__(cls, num, prec=None):
                 _mpf_ = mpf_norm(_mpf_, prec)
         else:
             # XXX: We lose precision here.
-            _mpf_ = mpmath.mpf(num)._mpf_
+            _mpf_ = mpmath.mpf(num, prec=prec)._mpf_
 
         # special cases
         if _mpf_ == _mpf_zero:
```
I get
```
In [1]: Poly(pi.evalf(1000)*x, domain=RealField(prec=1000))
Out[1]: 
Poly(3.14159265358979323846264338327950288419716939937510582097494459230781640
628620899862803482534211706798214808651328230664709384460955058223172535940812
848111745028410270193852110555964462294895493038196442881097566593344612847564
823378678316527120190914564856692346034861045432664821339360726024914127*x, x,
 domain='RR')
```
To get the full precision the keyword `dps` should be used:
```
In [3]: Poly(pi.evalf(1000)*x, domain=RealField(dps=1000))
Out[3]: 
Poly(3.14159265358979323846264338327950288419716939937510582097494459230781640
628620899862803482534211706798214808651328230664709384460955058223172535940812
848111745028410270193852110555964462294895493038196442881097566593344612847564
823378678316527120190914564856692346034861045432664821339360726024914127372458
700660631558817488152092096282925409171536436789259036001133053054882046652138
414695194151160943305727036575959195309218611738193261179310511854807446237996
274956735188575272489122793818301194912983367336244065664308602139494639522473
719070217986094370277053921717629317675238467481846766940513200056812714526356
082778577134275778960917363717872146844090122495343014654958537105079227968925
892354201995611212902196086403441815981362977477130996051870721134999999837297
804995105973173281609631859502445945534690830264252230825334468503526193118817
101000313783875288658753320838142061717766914730359825349042875546873115956286
3882353787593751957781857780532171226806613001927876611195909216420198*x, x, d
omain='RR')
```
The comment was added by me at 8a7e07992. This was the case where I couldn't figure out how the `else` clause would actually be hit at https://github.com/sympy/sympy/pull/11862. I guess the unknown type in this case is the polys `RealElement`? 
> I guess the unknown type in this case is the polys RealElement?

Yes, that is the type in `RealField`.
Your fix looks good. We should really unify our conventions and rename the `prec` argument to `Float` to `dps`. 
`mps` can use both `prec` and `dps` taking the latter if it is given. Internally it will use `prec`.
```
        if kwargs:
            prec = kwargs.get('prec', prec)
            if 'dps' in kwargs:
                prec = dps_to_prec(kwargs['dps'])
```
So `dps=dps` could also be used. I'm not sure which keyword should be preferred in `Float`?

To clarify: Maybe the fix should rather be `mpmath.mpf(num, dps=dps)._mpf_`?
I mean we should change it from `Float.__new__(num, prec=None)` to `Float.__new__(num, dps=None, prec='deprecated')`, to unify the terminology (and also to make the code of `Float.__new__` easier to read, since it changes the meaning of `prec` midway through). I can make a PR tomorrow. 
That is what I thought, too. My comment about the keywords in `mpmath.mpf` was probably a little confusing.
I think your original fix is right. Float already converts the precision to binary precision earlier in the code and uses that everywhere. 
I am working on a PR for this fix. It also fixes things like `nsimplify(pi.evalf(100)*x)` (although I'm caught on https://github.com/sympy/sympy/issues/12045 for writing a test). 