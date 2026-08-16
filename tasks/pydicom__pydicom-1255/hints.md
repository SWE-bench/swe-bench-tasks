I ran into multiple other errors and would suggest removing `py.typed` until the type annotations have been properly tested. 
@hackermd, just for my education, since I have only dabbled in 'typing'  so far - does this break your workflow somehow?  Is it not possible to exclude pydicom from forcing errors? (other than removing `py.typed`)

Hmm, maybe we should just use `Any` for the element values rather than `object`. The problem is the element value type will be/is so broad users are pretty much going to have to `cast` everything no matter what we do.
@darcymason 

> does this break your workflow somehow

We are running mypy on all our Pyhon code and our unit test pipelines are failing. I have fixed the pydicom version to `2.0.0`, but I would like to avoid doing that moving forward.

>  Is it not possible to exclude pydicom from forcing errors? (other than removing py.typed)

One can add `#type: ingore` to exclude individual lines from type checks, but at the moment we are getting hundreds of errors.

Instead of removing `py.typed`, one could also remove the type hints from problematic functions. `object` or `Any` are not that useful and seem to cause more trouble than benefit.
@scaramallion 

> The problem is the element value type will be/is so broad users are pretty much going to have to cast everything no matter what we do

Agreed. The return value of these "magic" methods will be difficult to type. It's basically a Union of all Python types corresponding to any of the DICOM Value Representations.
@hackermd, thanks for the explanations.

I suggest doing a patch release for this if @scaramallion is in agreement.  We could just remove the `py.typed`, as suggested, and do it quickly (and push 'typing' to v2.2),  or perhaps within a few days/couple of weeks if removal of `object` can be a better solution. @scaramallion, your thoughts?  

@hackermd, would you be able to test on master if we try the correction route?

> would you be able to test on master if we try the correction route

Yes, happy to help with that. 
Yeah, lets do it. Fix #1253 and #1254 while we're at it. Pushing typing back to at least v2.2 is probably the way to go, too. 
New in 3.6.2, well that's annoying