Hi!

I'm wondering if something as simple as this is sufficient or if you think it needs its own example altogether:
```python  
>>> import numpy as np
>>> converters = {'uint_col': [ascii.convert_numpy(np.uint)],
...               'float32_col': [ascii.convert_numpy(np.float32)],
...               'bool_col': [ascii.convert_numpy(bool)]}
>>> ascii.read('file.dat', converters=converters)
```

While we're at it should we update the preceding paragraph

> The type provided to [convert_numpy()](https://docs.astropy.org/en/stable/api/astropy.io.ascii.convert_numpy.html#astropy.io.ascii.convert_numpy) must be a valid [NumPy type](https://numpy.org/doc/stable/user/basics.types.html) such as numpy.int, numpy.uint, numpy.int8, numpy.int64, numpy.float, numpy.float64, or numpy.str.

 to use the regular python types for `string`, `int` and `bool` instead of the deprecated `np.string`, `np.int` and `np.bool`?
Thanks for looking into this @pjs902. I think the advantage of the original suggested workaround is that it will work for any table regardless of column names. I suspect that in most cases of tables with `True/False` strings, the user wants this applied to every column that looks like a bool.

Definitely :+1: on updating the docs to use regular Python types instead of the deprecated numpy versions.
@taldcroft Sorry if I wasn't clear, I had only changed the column names to make it obvious that we had columns with different types, not suggesting that we require certain column names for certain types, I could switch these back to the original column names which were just `col1`, `col2`, `col3`.
@pjs902 - I had a mistake in the original suggested workaround to document, which I have now fixed:
```
converters = {'*': [convert_numpy(typ) for typ in (int, float, bool, str)]}
```
With this definition of `converters`, there is no need to specify any column names at all since the `*` glob matches every column name.
@taldcroft Both solutions seem to work equally well, do you think it's better to switch the example in the docs to 

> converters = {'*': [convert_numpy(typ) for typ in (int, float, bool, str)]}

or better to leave the existing pattern as is, just including a boolean example? Something like this:

> converters = {'col1': [ascii.convert_numpy(np.uint)],
  ...      'col2': [ascii.convert_numpy(np.float32)],
  ...       'col3': [ascii.convert_numpy(bool)]}


 I think, for the documentation, I prefer the existing pattern where each column is individually specified as is. In the next paragraph, we explicitly go over the usage of `fnmatch` for matching glob patterns but I'm happy to defer to your judgement here. 
@pjs902 - hopefully you haven't started in on this, because this morning I got an idea to simplify the converter input to not require this whole `ascii.convert_numpy()` wrapper. So I'm just going to fold in this bool not str into my doc updates now.
@taldcroft No worries! Sounds like a much nicer solution!
I used [converters](https://docs.astropy.org/en/stable/io/ascii/read.html#converters) when I had to do this a long time ago. And I think it still works? 

```python
>>> converters = {
...     'ra': [ascii.convert_numpy(np.int)],
...     'dec': [ascii.convert_numpy(np.int)],
...     'objid': [ascii.convert_numpy(np.str)]}
>>> t = ascii.read(
...     indata, format='commented_header', header_start=2,
...     converters=converters, guess=False, fast_reader=False)
>>> t
<Table length=2>
  ra   dec  objid
int32 int32  str3
----- ----- -----
    1     2   345
    3     4   456
```

You might have to play around with it until you get the exact data type you want though. Hope this helps!
Oh, yes, indeed, this is exactly what I need. One minor comment though, it would be helpful to have the word `dtype` somewhere in the docs, as I was searching for `dtype` in that and many other docs pages without any useful results. (maybe it's just me, that case this can be closed without a docs change, otherwise this can be a good "first issue").

It's also not clear what the "previous section" is referred to in ``These take advantage of the convert_numpy() function which returns a two-element tuple (converter_func, converter_type) as described in the previous section.`` 
Yes, the `converters` mechanism is not that obvious and a perfect example of overdesign from this 10+ year old package.

It probably would be easy to add a `dtype` argument to mostly replace `converters`. This would pretty much just generate those `converters` at the point when needed.  Thoughts?
I agree that the `converters` API could be improved; I have a very old feature request at #4934  , which will be moot if you use a new API like `dtype=[np.int, np.int, np.str]` or `dtype=np.int` (the latter assumes broadcasting to all columns, which might or might not be controversial).
I've implemented this in a few lines of code. As always the pain is testing, docs etc. But maybe there will be a PR on the way.
```
In [2]: >>> ascii.read(indata, format='commented_header', header_start=2, dtype=('i8', 'i4', 'S10'), guess=False, fast_reader=False)
Out[2]: 
<Table length=2>
  ra   dec   objid 
int64 int32 bytes10
----- ----- -------
    1     2     345
    3     4     456
```
Thank you, this looks very good to me. I suppose converter is a bit like clobber for fits, makes total sense when you already know about it, but a bit difficult to discover. The only question whether dtype should also understand the list of tuples that include the column name to be consistent with numpy. I don't think that API is that great, still is worth some thinking about.
Do we... need an APE? 😸 
I was planning for the `dtype` to be consistent what `Table` accepts, which is basically just a sequence of simple dtypes. It starts getting complicated otherwise because of multiple potentially conflicting ways to provide the names. Allowing names in the dtype would also not fit in well with the current implementation in `io.ascii`.