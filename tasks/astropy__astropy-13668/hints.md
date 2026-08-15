> `wcslint` calls an underlying function here:
> 
> https://github.com/astropy/astropy/blob/8c0581fc68ca1f970d7f4e6c9ca9f2b9567d7b4c/astropy/wcs/wcs.py#L3430
> 
> Looks like all it does is tries to create a `WCS` object with the header and report warnings, so the bug is either inside `WCS` or it is a matter of updating on how validator calls `WCS` in more complicated cases:
> 
> https://github.com/astropy/astropy/blob/8c0581fc68ca1f970d7f4e6c9ca9f2b9567d7b4c/astropy/wcs/wcs.py#L3530-L3534

Nope. _That_ is the bug here:
```python
     WCS(hdu.header,  # should become:
     WCS(hdu.header, hdulist,
```

This should fix ACS and WCS-TAB errors but not the memory errors in WFC3 images. Even that one is a bug in `wcslint` or validation function and not in `WCS` itself.
FWIW, my error for WFC3/UVIS with astropy 5.1 is slightly different:

```
$ wcslint iabj01a2q_flc.fits
corrupted size vs. prev_size
Aborted
```
Maybe things have changed: I used an old file lying around my file system while yours is likely a fresh baked one with some HAP stuff.
Try running `updatewcs.updatewcs(filename, use_db=False)` from `stwcs`.
The segfault is quite something else and it is not really from validation itself, so I am going to open a new issue for it. See https://github.com/astropy/astropy/issues/13667