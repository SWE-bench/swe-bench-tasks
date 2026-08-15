Hm. I wonder if there's a place in the I/O registry for readers/writers to provide some means of listing what data formats they can accept--or at least rejecting formats that they don't accept.  Maybe something to think about as part of #962 ?

I should add--I think the current behavior is "correct"--any convention for storing arbitrary Python objects in a FITS file would be ad-hoc and not helpful.  I think it's fine that this is currently rejected.  But I agree that it should have been handled differently.

I agree with @embray that the best solution here is just to provide a more helpful error message.  In addition `io.ascii` should probably check the column dtypes and make sure they can reliably serialized.  The fact that `None` worked was a bit of an accident and as @embray said not very helpful because it doesn't round trip back to `None`.

Agreed! I wouldn't have posted the issue had there been a clear error message explaining that object X isn't supported by FITS.

We could also consider skipping unsupported columns and raising a warning.

I would be more inclined to tell the user in the exception which columns need to be removed and how to do it.  But just raising warnings doesn't always get peoples attention, e.g. in the case of processing scripts with lots of output.

Not critical for 1.0 so removing milestone (but if someone feels like implementing it in the next few days, feel free to!)
