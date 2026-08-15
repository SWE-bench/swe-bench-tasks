I support #1 of the two choices for reasons I mentioned in #5454.

In addition I want to mention that we already deviated from the FITS standard by adding the `d2im` distortion.

:+1: for solution 1, for the reasons explained by @nden in https://github.com/astropy/astropy/pull/5411#issuecomment-258138938

hm, I'm sure that #4662 does not contain the extended discussion.

@MSeifert04 I think the "long discussion" was in https://github.com/astropy/astropy/issues/4669
👍 for solution 1
Also 👍 for solution 1. Looking forward to having those keywords update when I slice...
With apologies to @nden (who asked to not start a discussion), I want to make a case for **option 2** (following discussion on e.g. https://github.com/astropy/astropy/pull/5455). But I'll keep it short.

WCS objects allow slicing, including by floating-point values. For instance, I can do:

```python
In [5]: wcs[::0.2333,::0.2333]
Out[5]: 
WCS Keywords

Number of WCS axes: 2
CTYPE : 'GLON-CAR'  'GLAT-CAR'  
CRVAL : 0.0  0.0  
CRPIX : 1282.6603086155164  1281.6573081868839  
NAXIS    : 599 599

In [6]: wcs[::0.2333,::0.2333].wcs.cdelt
Out[6]: array([-0.00038883,  0.00038883])

In [7]: wcs.wcs.cdelt
Out[7]: array([-0.00166667,  0.00166667])
```

I can see the motivation for this and it looks like people are relying on this. However, this causes issues when the image size is present in the WCS because it's no longer possible to necessarily scale the image size to an integer size. So the presence or not of image dimensions changes how slicing works.

Furthermore, another example where the presence/absence of image shape matters is negative indices. If I do ``wcs[::-1,::-1]``, this can only work if I have an image size.

Because the slicing behaves so differently between the two cases, I'm 👍 on **option 2** because it will allow the behavior to be more predictable and separates the two different use cases.

**Note:** I didn't say that ``WCS`` has to be the 'pure' class though. ``WCS`` could be the class with image shape if there is a superclass that does not (we'd just need to find a good name). So just to be clear, there's a difference between separating the classes versus which one should be the 'default'.
@astrofrog My main concern is giving an option to users to choose between two classes when they want to implement a WCS pipeline for an instrument. How would I choose which one to subclass?
@nden - I see your point. It seems I'm in the minority anyway, so I'd say just go with the majority opinion rather than try and get everyone to agree :)
It'd be good to coordinate the interface for this with the interface used in GWCS.