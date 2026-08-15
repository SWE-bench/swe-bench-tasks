Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Has anyone gotten a chance to look at this and recreate the issue? I played around with numpy.allclose which is cited as the function fitsdiff uses here:

rtol[float](https://docs.python.org/3/library/functions.html#float), optional
The relative difference to allow when comparing two float values either in header values, image arrays, or table columns (default: 0.0). Values which satisfy the expression

|𝑎−𝑏|>atol+rtol⋅|𝑏|
are considered to be different. The underlying function used for comparison is [numpy.allclose](https://numpy.org/doc/stable/reference/generated/numpy.allclose.html#numpy.allclose).
(from: https://docs.astropy.org/en/stable/io/fits/api/diff.html)

and using numpy.allclose the results are what I would expect them to be for the numbers in my original post:


Python 3.8.5 (default, Sep  4 2020, 07:30:14) 
[GCC 7.3.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.01,atol=0.0, equal_nan=False)
True
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.001,atol=0.0, equal_nan=False)
True
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.0001,atol=0.0, equal_nan=False)
True
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.00001,atol=0.0, equal_nan=False)
True
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.000001,atol=0.0, equal_nan=False)
True
>>> numpy.allclose(-1.3716944e-11,-1.3716938e-11,rtol=0.0000001,atol=0.0, equal_nan=False)
False
Indeed there is a bug for multidimensional columns (which is the case for FLUX here). The code identifies the rows where the diff is greater than atol/rtol, and then delegates the printing to `report_diff_values` which doesn't use atol/rtol :
https://github.com/astropy/astropy/blob/2f4b3d2e51e22d2b4309b9cd74aa723a49cfff99/astropy/utils/diff.py#L46