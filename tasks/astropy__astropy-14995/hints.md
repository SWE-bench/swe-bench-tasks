Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
@bmorris3 , do you think this is related to that nddata feature you added in v5.3?
Hi @KathleenLabrie. I'm not sure this is a bug, because as far as I can tell the `mask` in NDData is assumed to be boolean: 

https://github.com/astropy/astropy/blob/83f6f002fb11853eacb689781d366be6aa170e0e/astropy/nddata/nddata.py#L51-L55

There are updates to the propagation logic in v5.3 that allow for more flexible and customizable mask propagation, see discussion in https://github.com/astropy/astropy/pull/14175.

You're using the `bitwise_or` operation, which is different from the default `logical_or` operation in important ways. I tested your example using `logical_or` and it worked as expected, with the caveat that your mask becomes booleans with `True` for non-zero initial mask values.
We are doing data reduction.  The nature of the "badness" of each pixel matters.  True or False does not cut it.  That why we need bits.  This is scientifically required.   A saturated pixel is different from a non-linear pixel, different from an unilliminated pixels, different .... etc. 

I don't see why a feature that had been there for a long time was removed without even a deprecation warning.
BTW, I still think that something is broken, eg.
```
>>> bmask = np.array([[True, False, False], [False, True, False], [False, False, True]])
>>> nref_bmask = NDDataRef(array, mask=bmask)
>>> nref_bmask.multiply(1.).mask
array([[True, None, None],
       [None, True, None],
       [None, None, True]], dtype=object)
```
Those `None`s should probably be `False`s not None's
There is *absolutely* a bug here. Here's a demonstration:

```
>>> data = np.arange(4).reshape(2,2)
>>> mask = np.array([[1, 0], [0, 1]]))
>>> nd1 = NDDataRef(data, mask=mask)
>>> nd2 = NDDataRef(data, mask=None)
>>> nd1.multiply(nd2, handle_mask=np.bitwise_or)
...Exception...
>>> nd2.multiply(nd1, handle_mask=np.bitwise_or)
NDDataRef([[0, 1],
           [4, 9]])
```

Multiplication is commutative and should still be here. In 5.2 the logic for arithmetic between two objects was that if one didn't have a `mask` or the `mask` was `None` then the output mask would be the `mask` of the other. That seems entirely sensible and I see no sensible argument for changing that. But in 5.3 the logic is that if the first operand has no mask then the output will be the mask of the second, but if the second operand has no mask then it sends both masks to the `handle_mask` function (instead of simply setting the output to the mask of the first as before).

Note that this has an unwanted effect *even if the masks are boolean*:
```
>>> bool_mask = mask.astype(bool)
>>> nd1 = NDDataRef(data, mask=bool_mask)
>>> nd2.multiply(nd1).mask
array([[False,  True],
       [ True, False]])
>>> nd1.multiply(nd2).mask
array([[None, True],
       [True, None]], dtype=object)
```
and, whoops, the `mask` isn't a nice happy numpy `bool` array anymore.

So it looks like somebody accidentally turned the lines

```
elif operand.mask is None:
            return deepcopy(self.mask)
```

into

```
elif operand is None:
            return deepcopy(self.mask)
```

@chris-simpson I agree that line you suggested above is the culprit, which was [changed here](https://github.com/astropy/astropy/commit/feeb716b7412c477c694648ee1e93be2c4a73700#diff-5057de973eaa1e5036a0bef89e618b1b03fd45a9c2952655abb656822f4ddc2aL458-R498). I've reverted that specific line in a local astropy branch and verified that the existing tests still pass, and the bitmask example from @KathleenLabrie works after that line is swapped. I'll make a PR to fix this today, with a new test to make sure that we don't break this again going forward. 
Many thanks for working on this, @bmorris3.

Regarding whether the `mask` is assumed to be Boolean, I had noticed in the past that some developers understood this to be the case, while others disagreed. When we discussed this back in 2016, however (as per the document you linked to in Slack), @eteq explained that the mask is just expected to be "truthy" in a NumPy sense of zero = False (unmasked) and non-zero = True (masked), which you'll see is consistent with the doc string you cited above, even if it's not entirely clear :slightly_frowning_face:.
Of course I think that flexibility is great, but I think intentional ambiguity in docs is risky when only one of the two cases is tested. 😬 
Indeed, I should probably have checked that there was a test for this upstream, since I was aware of some confusion; if only we could find more time to work on these important common bits that we depend on...