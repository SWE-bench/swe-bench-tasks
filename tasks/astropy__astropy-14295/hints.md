Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
I have seen this issue discussed in https://github.com/astropy/astropy/issues/299 and https://github.com/astropy/astropy/issues/3559 with an fix in https://github.com/astropy/astropy/pull/1278 which was not perfect and causes the issue for me.

https://github.com/astropy/astropy/blob/966be9fedbf55c23ba685d9d8a5d49f06fa1223c/astropy/wcs/wcs.py#L708-L752

I'm using a CAR projection which needs the PV keywords.
By looking at the previous discussions and the implementation above some I propose some approaches to fix this.

1. Check if the project type is TAN or TPV. I'm not at all familiar with SCAMP distortions but I vaguely remember that they are used on TAN projection. Do correct me if I'm wrong.
2. As @stargaser suggested
> SCAMP always makes a fourth-order polynomial with no radial terms. I think that would be the best fingerprint.

Currently, https://github.com/astropy/astropy/pull/1278 only checks if any radial terms are present but we can also check if 3rd and 4th order terms are definitely present.
3. If wcslib supports SCAMP distortions now, then the filtering could be dropped altogether. I'm not sure whether it will cause any conflict between SIP and SCAMP distortions between wcslib when both distortions keyword are actually  present (not as projection parameters). 

@nden @mcara Mark Calabretta suggested you guys might be able to help with this.

I am not familiar with SCAMP but proposed suggestions seem reasonable, at least at the first glance. I will have to read more about SCAMP distortions re-read this issue, etc. I did not participate in the discussions from a decade ago and so I'll have to look at those too.

> I'm using a CAR projection which needs the PV keywords.

This is strange to me though. I modified your header and removed `SIP` (instead of `PV`). I then printed `Wcsprm`:

```python
header_dict = {
    'SIMPLE'  : True,
    'BITPIX'  : -32,
    'NAXIS'   :  2,
    'NAXIS1'  : 1024,
    'NAXIS2'  : 1024,
    'CRPIX1'  : 512.0,
    'CRPIX2'  : 512.0,
    'CDELT1'  : 0.01,
    'CDELT2'  : 0.01,
    'CRVAL1'  : 120.0,
    'CRVAL2'  : 29.0,
    'CTYPE1'  : 'RA---CAR',
    'CTYPE2'  : 'DEC--CAR',
    'PV1_1'   :120.0,
    'PV1_2'   :29.0,
    'PV1_0'   :1.0,
}
from astropy.wcs import WCS
w = WCS(header_dict)
print(w.wcs)
```

Here is an excerpt of what was reported:
```
   prj.*
       flag: 203
       code: "CAR"
         r0: 57.295780
         pv: (not used)
       phi0: 120.000000
     theta0: 29.000000
     bounds: 7

       name: "plate caree"
   category: 2 (cylindrical)
    pvrange: 0
```

So, to me it seems that `CAR` projection does not use `PV` and this contradicts (at first glance) the statement _"a CAR projection which needs the PV keywords"_.
`PV` keywords are not optional keywords in CAR projection to relate the native spherical coordinates with celestial coordinates (RA, Dec). By default they have values equal to zero, but in my case I need to define these parameters.
Also, from https://doi.org/10.1051/0004-6361:20021327 Table 13 one can see that `CAR` projection is not associated with any PV parameters.
> Table 13 one can see that CAR projection is not associated with any PV parameters.

Yes, that is true. 
But the description of Table 13 says that it only lists required parameters.

Also, PV1_1, and PV1_2 defines $\theta_0$ and $\phi_0$ which are accepted by almost all the projections to change the default value.
Yes, I should have read the footnote to Table 13 (and then Section 2.5).
Just commenting out https://github.com/astropy/astropy/blob/966be9fedbf55c23ba685d9d8a5d49f06fa1223c/astropy/wcs/wcs.py#L793
solves the issue for me.
But, I don't know if that would be desirable as we might be back to square one with the old PTF images.

Once the appropriate approach for fixing this is decided, I can try to make a small PR.
Looking at the sample listing for TPV - https://fits.gsfc.nasa.gov/registry/tpvwcs.html - I see that projection code is 'TPV' (in `CTYPE`). So I am not sure why we ignore `PV` if code is `SIP`. Maybe it was something that was dealing with pre-2012 FITS convention, with files created by SCAMP (pre-2012). How relevant is this nowadays? Maybe those who have legacy files should update `CTYPE`?

In any case, it looks like we should not be ignoring/deleting `PV` when `CTYPE` has `-SIP`.

It is not a good solution but it will allow you to use `astropy.wcs` with your file (until we figure out a permanent solution) if, after creating the WCS object (let's call it `w` as in my example above), you can run:

```python
w.wcs.set_pv([(1, 1, 120.0), (1, 0, 1.0), (1, 2, 29.0)])
w.wcs.set()
```
Your solution proposed above is OK too as a temporary workaround.
NOTE: A useful discussion can be found here: https://jira.lsstcorp.org/browse/DM-2883
> I see that projection code is 'TPV' (in CTYPE). So I am not sure why we ignore PV if code is SIP. Maybe it was something that was dealing with pre-2012 FITS convention, with files created by SCAMP (pre-2012).

Yes. Apparently pre-2012 SCAMP just kept the CTYPE as `TAN` .

> Maybe those who have legacy files should update CTYPE?

That would be my first thought as well instead of getting a pull request through. But, it's been in astropy for so long at this point.

> Your` solution proposed above is OK too as a temporary workaround.

By just commenting out, I don't have to make any change to my header update code or more accurately the header reading code and the subsequent pipelines for our telescope. By commenting the line, we could work on the files now and later an astropy update will clean up things in the background (I'm hoping).

From the discussion https://jira.lsstcorp.org/browse/DM-2883

> David Berry reports:
> 
> The FitsChan class in AST handles this as follows:
> 
> 1) If the CTYPE in a FITS header uses TPV, then the the PVi_j headers are interpreted according to the conventions of the distorted TAN paper above.
> 
> 2) For CTYPEs that use TAN, the interpretation of PVi_j values is controlled by the "PolyTan" attribute of the FitsChan. This can be set to an explicit value before reading the header to indicate the convention to use. If it is not set before reading the header, a heuristic is used to guess the most appropriate convention as follows:
> 
> If the FitsChan contains any PVi_m keywords for the latitude axis, or if it contains PVi_m keywords for the longitude axis with "m" greater than 4, then the distorted TAN convention is used. Otherwise, the standard convention is used.
> 

This seems like something that could be reasonable and it is a combination of my points 1 and 2 earlier.

If we think about removing `fix_scamp` altogether, then we would have to consider the following - 
1. How does the old PTF fits files (which contains both SIP and TPV keywords with TAN projection) behave with current wcslib.
2. How does other SCAMP fits files work with the current wcslib. I think if the projection is written as `TPV` then wcslib will handle it fine, I have no idea about CTYPE 'TAN'
The WCSLIB package ships with some test headers. One of the test header is about SIP and TPV.

>  FITS header keyrecords used for testing the handling of the "SIP" (Simple
>  Imaging Polynomial) and TPV distortions by WCSLIB.
> 
>  This header was adapted from a pair of FITS files from the Palomar Transient
>  Factory (IPAC) provided by David Shupe.  The same distortion was encoded in
>  two ways, the primary representation uses the SIP convention, and the 'P'
>  alternate the TPV projection.  Translations of both of these into other
>  distortion functions were then added as alternates.

In the examples given, the headers have a CTYPE for `RA--TAN-SIP` for SIP distortions and `RA---TPV` for SCAMP distortions. So, as long as the files from SCAMP are of `TPV` CTYPE they should just work.

The file - [SIPTPV.txt](https://github.com/astropy/astropy/files/10367722/SIPTPV.txt)
Also can be found at wcslib/C/test/SIPTPV.keyrec

Since I know nothing about SCAMP and do not know how these changes might affect those who do use SCAMP, I would like to hear opinions from those who might be affected by changes to SIP/SCAMP/TPV issue or from those who worked on the original issue: @lpsinger @stargaser @astrofrog 
Man, this takes me back. This was probably my first Astropy contribution.

Is anyone on this PR going to be at AAS in Seattle this week?
I'm attending the AAS in Seattle this week.

> 2. As @stargaser suggested
> 
> > SCAMP always makes a fourth-order polynomial with no radial terms. I think that would be the best fingerprint.
> 
> Currently, #1278 only checks if any radial terms are present but we can also check if 3rd and 4th order terms are definitely present. 3. If wcslib supports SCAMP distortions now, then the filtering could be dropped altogether. I'm not sure whether it will cause any conflict between SIP and SCAMP distortions between wcslib when both distortions keyword are actually present (not as projection parameters).

I think this would be the easiest solution that would satisfy the aims of #1278 to work with PTF files. I'm afraid it will not be possible to modify the headers of PTF files as the project has been over for several years now.

>  I'm afraid it will not be possible to modify the headers of PTF files as the project has been over for several years now.

I meant on a user level. Someone who is reading the PTF files can just remove the header keywords. 
Or maybe wcslib just handles it without issue now giving the intended wcs output? That has to be checked though.
Does anyone have any thoughts on this about how to proceed?

Also, @stargaser if you have access to the PTF files, could you just try to read them with the `fix_scamp` function removed? This might help us choose what route to take.
> > I'm afraid it will not be possible to modify the headers of PTF files as the project has been over for several years now.
> 
> I meant on a user level. Someone who is reading the PTF files can just remove the header keywords. Or maybe wcslib just handles it without issue now giving the intended wcs output? That has to be checked though.

I am of the same opinion. Those who use SCAMP that does not use correct CTYPE should fix the CTYPE manually. It is not that hard. It is impossible to design software that can deal with every possible interpretation of the same keyword.

True, in this case maybe we could have some sort of heuristic approach and "we can also check if 3rd and 4th order terms are definitely present" but really why do it at all? To me, the idea of FITS "standard" is not to have to guess anything, have heuristics, or software switches that "tell" the code (or "us") how to interpret things in a FITS file. IMO, the point of a standard and "archival format" is that things are unambiguous.

I think if there are no other comments or proposals you should go ahead and make a PR to remove `_fix_scamp()`.
Since this was an actual issue that users encountered, which after very considerable discussion we decided to fix, I think we cannot just remove it, but have to put a mechanism in place for telling the user how they can get back the previous behaviour -- e.g., by adding appropriate text to any error message that now arises. Or we could make the removal depend on a configuration item or so.
p.s. Of course, if at the present time, archives for PTF and other observatories do not have the issue any more, perhaps we can just remove it, but probably best to check that!