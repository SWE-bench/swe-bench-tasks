Thank you for that thorough explanation (and of course we all know and respect David Clunie 😄 )!
I understand the specific problem with `Exposure Time` (for a similar reason, there exists the tag `Exposure in μAs` additionally to `Exposure`, but no such thing exists for `Exposure Time`), and I am aware that this is not the only case where float values are written into `IS`. 

I think a similar issue came up before, and my preference would be to make this behavior dependent on the validation mode. The default validation mode for reading is to issue a warning, while for writing new data it is to raise an exception. This would not resolve the problem, though. The real problem is in the implementation of the tag class: the class representing `IS` values is derived from `int`. In my opinion, it would make sense to change that, though I'm not sure if we can do this consistently in a backwards-compatible way.

@darcymason - I'm quite sure that we have discussed this before, I will try to find the respective issue. Anyway, what are your current thoughts here? 

CC @dclunie

Ah ok, @gsmethells has already [commented](https://github.com/pydicom/pydicom/issues/1643#issuecomment-1180789608) in the respective issue #1643.
> I'm quite sure that we have discussed this before

Yes, it has come up several times.

A new thought has come to me (maybe not thought through properly, or maybe someone has mentioned this before and I'm just thinking it is new): maybe we could create an ISFloat class, operating similarly to the DSFloat idea.  Then, just have an allow_IS_float config flag, perhaps even true by default (return an ISFloat only if it is not an exact int).  Python allows mixed math anyway, so I don't see any real problem in returning a non-int if further math is done.   Only problem might be code that did an `isinstance` check against `IS` but that should be very rare.
> maybe we could create an ISFloat class, operating similarly to the DSFloat idea

My preference would be to change the `IS` class to support both `int` and `float`. We cannot always use float, as that could decrease the precision of integers, but in the case that float numbers are written in the tag, I would prefer to return a float. Not sure what problems this would bring, though... 
Additionally, I think we can still couple the behavior to the validation mode, but I'm not completely sure here.
> My preference would be to change the `IS` class to support both `int` and `float`.

Is that actually possible to do, without recreating all the class methods for `int` (or `float`) for math operations?
> Is that actually possible to do, without recreating all the class methods for int (or float) for math operations?

I guess not - that would be the downside of that approach. Also an `isinstance(int)` would fail, of course. It is probably better to use `ISFloat` as you proposed and dynamically decide which class to use.
> It is probably better to use ISFloat as you proposed and dynamically decide which class to use.

Actually that is what you have proposed - sorry, I misread that, I understood that you wanted to configure which class to use. Yes, I like your proposal!
> Is that actually possible to do, without recreating all the class methods for int (or float) for math operations?

Actually, I feel like we did return a different class from `__new__` somewhere, or at least talked about it.  It turns out that it is possible to [return a different class from `__new__`](https://stackoverflow.com/questions/20221858/python-new-method-returning-something-other-than-class-instance).  I'm not sure it is advisable, though, that is really not being explicit to the user.
> Actually, I feel like we did return a different class from `__new__` somewhere

Yes, we actually use this to return either a string or an int/float from `IS`/`DS`. This is also a common pattern in Python (they use it for example in `pathlib`), so I think it would not be unexpected.
Thank you for taking the time to discuss ideas and consider this. I understand wanting to adhere tightly to the standard (we do so for edge cases the majority of the time ourselves for our ortho PACS). I also understand the desire to listen to the "import this" zen of "Simple is better than complex" and, yes, I understand all too well how a large system can grow complicated.

My usual pause comes when my design desires run up against DICOM files in the field where there is a common violation of the standard. We maintain petabytes of DICOM images and this issue is common. I would be happy if reading/writing `dataset`s from/to files via pydicom continued to support maintaining existing values, regardless of whether those values violate the standard, (it does now, but is that an intentional design decision? A `dataset` only raises a `TypeError` when the value is directly attempted to be read out, whether via `__iter__` or otherwise) and also provided a (new/existing?) preference for reading `int` VR tag values as `float`.

My two cents.
> reading/writing `dataset`s from/to files via pydicom continued to support maintaining existing values, regardless of whether those values violate the standard

Any other position would become a deal breaker for our use of the library if it were ever otherwise, simply due to the realities of supporting customers. Especially when it comes to the need to update tags (e.g., a misspelled PatientName) while keeping other unrelated tags the same (i.e., no side-effects).
Setting 2.4 milestone to at least consider this for the release.