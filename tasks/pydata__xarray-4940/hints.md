Thanks for the issue and clear example @kjfergu . Agree that's not robust.

Is this specific case fixed by passing `dim=` rather than `axis=`?

`dim` gives you all the advantages of xarray. Is there a reason the example passes `axis`? 

That said, we should be consistent, or raise on passing `axis`...
@max-sixty I can confirm that using `dim='x'` (for example) does work as expected.

Honestly, I just used axis because that's the form I'm used to passing when using various other operations that act on an array with numpy - I admittedly did not make a point to look closely at the docs for that particular case and just assumed because `axis` worked that I was doing it correctly.

Interestingly, as a side note, I did initially try `axis='x'` (which didn't work) before submitting this bug. So - maybe it was an education thing on my part. The fact that `dim` was a possible argument didn't occur to me, but that I could maybe use labeled coordinates did.
Thanks @kjfergu 

I think that's a fairly common 'misuse'. Solving the coords problem here doesn't solve the larger problem of an easier learning curve where xarray is helpful quickly—which likely involves using `dim` rather than `axis`.

We could raise on `axis` but potentially that's too restrictive: any thoughts from anyone? What are good reasons to use `axis`?
> We could raise on axis but potentially that's too restrictive: any thoughts from anyone? What are good reasons to use axis?

I don't know of any. I didn't know it was possible! 

But since we don't guarantee that all DataArrays in a Dataset have the same order-of-dimensions, this is just asking for trouble.
What about raising a warning when `axis` is used? Something like `Using the axis keyword results in lost information about coordinates, etc. Use the dim keyword to suppress this warning`?
Can someone explain why we even allow axis as a valid argument? I can't think of any good reasons why we should keep it, and it's inconsistent with the API in most places I think.
I agree with removing. We could raise an error saying `please use 'dim' instead`