According to this line, that interface already exists:

https://github.com/astropy/astropy/blob/40ba5e4c609d2760152898b8d92a146e3e38c744/astropy/nddata/ccddata.py#L709

https://docs.astropy.org/en/latest/api/astropy.nddata.CCDData.html#astropy.nddata.CCDData.to_hdu
Maybe it just needs some tune up to write the HDU format that you want instead of a whole new interface. (Your Option A)
Yes, I know that `ccd_data.to_hdu()` already exists. My problem with it is that it returns the data as an `HDUList` with a `PrimaryHDU`, not as an `ImageHDU`. This is why I proposed adding an optional parameter to it (option A). Option B and C are basically inspired on the existing interfaces for converting `Tables` back to `BinTableHDU`s, which also seem good options to me. Any of these 3 options would be really useful to me, but I don't necessarily think we need all of them at the same time.
Yes, I replied before coffee kicked in, sorry. 😅 

My vote is Option A but we should wait to hear from @mwcraig .
Option A sounds very useful to me too.
I agree that Option A sounds good -- thanks for the detailed report and thoughtful suggestions, @kYwzor. Are you interested in writing a pull request to implement this? I would have some time this week to help you out if you are interested.

If not, I should be able to open a PR myself this week. 
I've never contributed to a big package like this, but I can give it a try.

There seems to be consensus for `ccd_data.to_hdu(as_image_hdu=True)`, but I'm not sure that we're all in agreement regarding what exactly this should return. I see essentially three options:

1. Return an `HDUList` where the first element is an empty `PrimaryHDU`, followed by an `ImageHDU` which contains data/headers coming from the `CCDData` object, possibly followed by `ImageHDU`s containing mask and/or uncertainty (if they are present in the `CCDData` object).
2. Same as option 1, but without the `PrimaryHDU` (the first element is an `ImageHDU`).
3. Return just an `ImageHDU` (not an `HDUList`), even if mask or uncertainty exist.

Option 1 is probably more consistent with the usual behavior when returning `HDUList`s (I think when Astropy builds an `HDUList` for the user, it's usually returned in a state that can be directly written to a file). The argument for option 2 is that if you're using `as_image_hdu` you probably don't intend on directly writing the returning `HDUList` to a file (otherwise you'd likely just use the default parameters), so adding a PrimaryHDU may be unnecessary bloat. Although I'm not a fan of option 3, it might be what someone expects from a parameter named "as_image_hdu"... but it would be pretty weird to completely drop mask/uncertainty and to return a different type of object, so maybe we could have a better name for this parameter.

I think option 1 is probably the best option because if you don't want the PrimaryHDU (option 2) you can easily do that with `hdus.pop(0)` and if you only want the ImageHDU (option 3) you can get it via `hdus[1]`, so it seems like it should fit everyone's needs.
> 1. Return an HDUList where the first element is an empty PrimaryHDU, followed by an ImageHDU which contains data/headers coming from the CCDData object, possibly followed by ImageHDUs containing mask and/or uncertainty (if they are present in the CCDData object).
> 2. Same as option 1, but without the PrimaryHDU (the first element is an ImageHDU).
> 3. Return just an ImageHDU (not an HDUList), even if mask or uncertainty exist.

I lean towards 2 since the keyword indicates you want the HDU as an `ImageHDU` -- it might be even clearer if the keyword were named `as_image_hdu_only` or something like that. Let's wait to see what @pllim and @saimn have to say too. 

Contributing follows a fairly standard set of steps, [detailed at length here](https://docs.astropy.org/en/latest/development/workflow/development_workflow.html). Boiled down to essentials, it is: fork the repo in github, clone your fork to your computer, *make a new branch* and then make your changes. Include a test of the new feature -- in this case it could be a straightforward one that makes sure an `ImageHDU` is returned if the keyword is used. Commit your changes, push to your fork, then open a pull request.

If you run into questions along the way feel free to ask here or in the #nddata channel in the [astropy slack](https://astropy.slack.com/) workspace.

From an "outsider" perspective (in terms of `CCDData` usage), I would prefer a solution that is the closest to what `.write()` would have done, but returns the object instead of writing it to a file. You can name the keyword whatever that makes sense to you in that regard. I think that behavior is the least surprising one.

Of course, I don't use it a lot, so I can be overruled.
I also lean towards 2 since I think the use case would to construct manually the HDUList with possibly more than 1 CCDData object. Having the PrimaryHDU could also be useful, but maybe that should be a different option in `CCDData.write`.