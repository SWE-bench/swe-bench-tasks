This might be related to another issue reported in #7185 where adding two `HDUList`s also produces a `list` instead of another `HDUList`.
We should be able to fix this specific case by overriding `list.copy()` method with:
```python
class HDUList(list, _Verify):
    ...
    def copy(self):
        return self[:]
    ...
```

And the result:
```python
>>> type(HDUList().copy())
astropy.io.fits.hdu.hdulist.HDUList
```