Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
Don't you want fractional pixels?
In general, yes. My specific use case is perhaps a bit silly. There are times where I want to use the output of the function as the input for the shape for a new array (which has to be of type `int`). Without specifying `dtype=int`, I have to do `.value.astype(int)`.

I just struck me as odd that I can create a `Quantity` with `dtype=int`, but that this does not play nicely with the `quantity_input` decorator.
@Cadair , didn't you originally implemented that decorator?
I don't think the problem is with the decorator, but in `Quantity`.

```python
x = u.Quantity(10, u.km, dtype=int)
x <<= u.pc
```

will raise the same error.
I changed the issue name to reflect the source of the error.
@mhvk I think all we need to do is upcast the dtype of the view?

```python
self.view(float, np.ndarray)[...] *= factor
```

The question is what dtype to upcast to. Maybe
```python
dtype = np.result_type(x.dtype, type(factor))
x.view(dtype, np.ndarray)[...] *= factor
```
As noted in #13638, I'm wondering about whether we should actually fix this.  The previous behaviour is that
```
q = <some quantity>
q2 = q
q <<= new_unit
q2 is q
# always True
```
Similarly with views of `q` (i.e., shared memory).

Above, the request is either to raise an exception if the units are of the wrong type. Currently, we do raise an error but I guess it is very unclear what the actual problem is. So, my preferred route would be to place the inplace multiplication in an `try/except` and `raise UnitsError(...) from exc`. (I guess for consistency we might then have to do the same inside the check for unit transformations via equivalencies...)
The problem appears to be that numpy can't change int<->float dtype without copying. If that were possible this wouldn't be an issue.

```python
>>> x = np.arange(10, dtype=int)
>>> y = x.astype(float, copy=False)  # it copies despite this, because int->float = 😭 

>>> np.may_share_memory(x, y)
False
```
So either we give up the assurance of shared memory, or this should error for most cases.
We can make this work for the case that the dtype of ``factor`` in https://github.com/astropy/astropy/issues/12964#issuecomment-1073295287 is can cast to the same type (e.g. ``(10 * u.km) <<= u.m``  )
Yes, numpy cannot change in-place since also the number of bytes is not quaranteed to be the same (`int32` can only be represented safely as `float64`).

On second thought about the whole issue, though, I think it may make more sense to give up the guarantee of shared memory. In the end, what the user wants is quite clear. And in a lot of python, if `a <<= b` does not work, it returns `NotImplemented`, and then one gets `b.__rlshift(a)` instead. Indeed, this is how `array <<= unit` is able to return a quantity.