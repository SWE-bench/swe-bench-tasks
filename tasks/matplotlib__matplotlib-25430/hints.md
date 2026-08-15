Ultimately the jpg writer does not support metadata. If it could, that would be the most ideal solution for at least the narrow case. (Though this is not at all specific to jpg, while many of the most common formats such as png, pdf, or svg do accept metadata, not all do)

I could see an argument for failing a bit earlier/catching and raising earlier in the stack, but honestly an error that says "unexpected keyword argument 'metadata'" with a call stack that shows `**kwargs` an every step back to what you typed is relatively informative. I would lean towards not making changes for this, but not super strong in that opinion.

I do not think that silently ignoring metadata is actually a good answer, as that would lead to users who expect their metadata to be in the saved file to be mistaken (perhaps in not super recoverable/immediately discovered ways), thus I think an error message is warranted (this is less true in the specific case of passing `metadata={}`, but not interested in doing value inspection here)

I do think the docs could be a little more explicit (they _do_ mention that which keys are supported is a function of backend and output format, but don't explicitly state that some combinations do not accept metadata at all).
Some further investigations:

Adding `metadata` as a kwarg to `print_jpg` (and then passing to `_print_pil` which ultimately calls `mpl.image.imsave`) does silence the exception, however any metadata in that dictionary is silently dropped.

In fact, the `metadata` argument to `imsave` is _only_ used in handling for `png` (some formats, such as pdf, svg, and eps/ps also handle metadata, but do not go via `imsave` as they are vector formats)
I may suggest at least a warning for passing (non-empty?, just do `if metadata:`) for non-png formats there, if not some more extensive adding metadata. I'd be satisfied by such a warning combined with passing through the `metadata` argument so its not an exception before it gets there. (And that would be an appropriate warning for anybody calling `imsave` directly, too) 

JPEG, unlike PNG, does not have an arbitrary string-keyed key-value metadata store (at least exposed by Pillow, not like I went and read the JPEG standard to come to that determination)

There does exist EXIF tags that could in principle be added to JPEG (and are not in the `savefig` pipeline/`imsave` in particular). But EXIF is not arbitrary string keys (it is actually something more like integer keyed, with an external mapping of integers to the key names, so the keys are pretty static, not arbitrary)

I would not be opposed to adding supported tags from metadata (and warning or erroring on invalid tag, not sure which) but working with Pillow's EXIF datatypes is not as easy (or well documented) as I'd like.

Pillow has an `image.info` dict-like attribute, but _most_ of that is simply ignored on writing for most file formats (silently) and behavior varies by output format significantly.


Summary of current behavior (using `agg` based backends, calling `savefig`):

- PNG (filters to `imsave`/Pillow): basically fully works, arbitrary string keys
- PDF (filters to PDF backend): Mostly works, but warns on unrecognized keys, but still puts them there
- JPG, WebP, Tiff (filters to `imsave`/Pillow): Error similar to above if any metadata is passed, possibly could add EXIF fields (not yet implemented)
- SVG (filters to backend_svg): Limited keys, errors on unrecognized keys
- eps/ps (filters to backend_ps): Only accept `"Creator"`, all other keys silently ignored (As documented in `savefig` docstring)
- raw/rgba: no fields for metadata, currently error similar to JPEG, but no path to add metadata as the file is literally just the rgba image bytes
- pgf (filters to backend_pgf): currently errors similar to JPEG, in principle supports EXIF, I think, but does _not_ go through Pillow, so solution would be separately implemented
