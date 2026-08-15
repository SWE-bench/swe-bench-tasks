It took me a bit of time to figure out the issue, as I know almost nothing about VLA, and the `io.fits` code is so simple :grin: , but in the end I think that the issue is with your file: at the end of the header there are TDIM keywords for the 3 columns with VLA, and this mess up the representation of the data:
```
...
TTYPE22 = 'GAINELE1'           / [deg] Gain-elevation correction parameter 1    
TFORM22 = '1E      '           / format of field                                
TTYPE23 = 'GAINELE2'           / Gain-elevation correction parameter 2          
TFORM23 = '1E      '           / format of field                                
TDIM3   = '(1,1)   '           / dimension of field                             
TDIM4   = '(1,1)   '           / dimension of field                             
TDIM5   = '(1,1)   '           / dimension of field                             
CHECKSUM= 'AQDaCOCTAOCYAOCY'   / HDU checksum updated 2018-09-01T19:23:07       
DATASUM = '2437057180'         / data unit checksum updated 2018-09-01T19:20:09 
```
If I remove these keywords I can read the table correctly.
Hmm, reading the standard about TDIM, using it here should work, so this is maybe an issue in Astropy...
The idea of using `TDIM` here is probably to have the arrays reshaped accordingly. I think, what *should* come out is something like this

```python
data['USEFEED']
# _VLF([array([[1]], dtype=int32)], dtype=object)
```
i.e., the `TDIM=(1,1)` would be used to reshape the array.

However, I just realized that also the files, which I can read (e.g., [S60mm-ICPBE-FEBEPAR.fits.zip](https://github.com/astropy/astropy/files/2382157/S60mm-ICPBE-FEBEPAR.fits.zip)), may not work as intended in that sense. Also I get strange warnings:

```python
hdulist = fits.open('S60mm-ICPBE-FEBEPAR.fits')
data = hdulist[1].data

WARNING: VerifyWarning: Invalid keyword for column 3: The repeat count of the column format 'USEFEED' for column '1PJ(8)' is fewer than the number of elements per the TDIM argument '(8,1)'.  The invalid TDIMn value will be ignored for the purpose of formatting this column. [astropy.io.fits.column]
WARNING: VerifyWarning: Invalid keyword for column 4: The repeat count of the column format 'BESECTS' for column '1PJ(8)' is fewer than the number of elements per the TDIM argument '(8,1)'.  The invalid TDIMn value will be ignored for the purpose of formatting this column. [astropy.io.fits.column]
WARNING: VerifyWarning: Invalid keyword for column 5: The repeat count of the column format 'FEEDTYPE' for column '1PJ(8)' is fewer than the number of elements per the TDIM argument '(8,1)'.  The invalid TDIMn value will be ignored for the purpose of formatting this column. [astropy.io.fits.column]

data['USEFEED']
# _VLF([array([1, 1, 1, 1, 2, 2, 2, 2], dtype=int32)], dtype=object)
# should perhaps be
# _VLF([array([[1], [1], [1], [1], [2], [2], [2], [2]], dtype=int32)], dtype=object)
# or
# _VLF([array([[1, 1, 1, 1, 2, 2, 2, 2]], dtype=int32)], dtype=object)
```



I think I found the issue, see #7820 for the fix and explanation. With this I can print the column as expected. 
The PR will need a test, I will try to finalize this when I find the time.

```
In [3]: hdul[1].data
Out[3]: 
FITS_rec([(1, 1, [[[1]]], [[[1]]], [[[1]]], 0., 0., 1, 'N', -999., [[0.53]], [[0.78]], [[0.78]], [[1.]], [[1.]], [[1.]], 1., -999., [[0.]], [[1.]], [[1.]], 1., 1.)],
         dtype=(numpy.record, [('USEBAND', '>i4'), ('NUSEFEED', '>i4'), ('USEFEED', '>i4', (2,)), ('BESECTS', '>i4', (2,)), ('FEEDTYPE', '>i4', (2,)), ('FEEDOFFX', '>f8'), ('FEEDOFFY', '>f8'), ('REFFEED', '>i4'), ('POLTY', 'S1'), ('POLA', '>f4'), ('APEREFF', '>f4', (1, 1)), ('BEAMEFF', '>f4', (1, 1)), ('ETAFSS', '>f4', (1, 1)), ('HPBW', '>f4', (1, 1)), ('ANTGAIN', '>f4', (1, 1)), ('TCAL', '>f4', (1, 1)), ('BOLCALFC', '>f4'), ('BEGAIN', '>f4'), ('BOLDCOFF', '>f4', (1, 1)), ('FLATFIEL', '>f4', (1, 1)), ('GAINIMAG', '>f4', (1, 1)), ('GAINELE1', '>f4'), ('GAINELE2', '>f4')]))

In [4]: hdul[1].data['USEFEED']
Out[4]: _VLF([array([[[1]]], dtype=int32)], dtype=object)
```
Not sure about the "repeat count" warning for the other file, could you try with my branch to check if it is still there ? But I guess it's another issue.
From the FITS standard, about TDIM:
> The size must be less than or
equal to the repeat count in the TFORMn keyword, or, in the case
of columns that have a ’P’ or ’Q’ TFORMn data type, less than or
equal to the array length specified in the variable-length array de-
scriptor (see Sect. 7.3.5).

So the warning should not happen here.
Dear @saimn, thanks a lot for the quick help. I can confirm that I can read the first file with the changes made in the PR. As you expected, the warnings in the other case still remain. The columns in question are also not reshaped according to the `TDIM` keyword, which is not surprising as the warning tells you exactly this.
I had another look, but this seems really difficult to fix (supporting the VLA feature with TDIM and with a recarray is complicated :( ). The change in #7820 has other side effects, breaking the creation of a BinTableHDU with a VLA. 
> complicated... side effects...

Sounds about right for FITS. 😬 
I've noticed a few more problems besides those listed above. Specifically:

- Variable-length character arrays are read as the deprecated `chararray` type, and thus display poorly. In the `io.fits` interface, they interfere with the table being displayed at all. 
- Tables containing variable-length arrays cannot be written to disk in the `table` interface, and the `io.fits` interface writes them incorrectly.

I've noticed this issue on both Linux and Mac OS. Tested with python versions `3.6.0` and `3.7.2`, ipython version `3.7.2`, astropy version `3.1.1`, and numpy version `1.16.0`.

@saimn I'm not sure if you are still working on this, but if not I'm happy to hack on this and try to submit a patch.

---

To reproduce:

1. Use the attached `vla-example.fits` from [astropy-fits-bug.tar.gz](https://github.com/astropy/astropy/files/2784863/astropy-fits-bug.tar.gz), or use this program to generate it.
    ```c
    #include <fitsio.h>
    
    int main() {
        fitsfile *handle;
        int status = 0;
        fits_create_file(&handle, "!vla-example.fits", &status);
        char *colnames[3] = {"YEAR", "BEST_PICTURE", "BOX_OFFICE_GROSS"};
        char *colforms[3] = {"K", "1PA", "K"};
        fits_create_tbl(
            handle,
            BINARY_TBL, // table type
            3, // reserved rows
            3, // number of columns
            colnames, // column names
            colforms, // column forms
            NULL, // column units
            "BEST_PICTURE_WINNERS", // extension name
            &status
        );
        int year[3] = {2017, 2016, 2015};
        char *best_picture[3] = {"The Shape of Water", "Moonlight", "Spotlight"};
        int gross[3] = {195200000, 65300000, 98300000};
        fits_write_col(
            handle,
            TINT, // data type
            1, // col
            1, // first row
            1, // first element
            3, // number of elements
            year, // value to write
            &status
        );
        for (int i = 0; i < sizeof(best_picture) / sizeof(best_picture[0]); ++i) {
            // fits_write_col behaves a little strangely with VLAs
            // see https://heasarc.gsfc.nasa.gov/fitsio/c/c_user/node29.html
            fits_write_col(handle, TSTRING, 2, i+1, 1, 1, &best_picture[i], &status);
        }
        fits_write_col(handle, TINT, 3, 1, 1, 3, gross, &status);
        fits_close_file(handle, &status);
        if (status) {
            fits_report_error(stdout, status);
        }
    }
    ```
1. Try to read it using the `io.fits` interface.
    ```
    In [1]: import astropy                                                                                                                                         
    
    In [2]: astropy.__version__                                                                                                                                    
    Out[2]: '3.1.1'
    
    In [3]: from astropy.io import fits                                                                                                                            
    
    In [4]: handle = fits.open('vla-example.fits')                                                                                                                 
    
    In [5]: t = handle[1].data                                                                                                                                     
    
    In [6]: t                                                                                                                                                      
    Out[6]: ---------------------------------------------------------------------------
    TypeError                                 Traceback (most recent call last)
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/IPython/core/formatters.py in __call__(self, obj)
        700                 type_pprinters=self.type_printers,
        701                 deferred_pprinters=self.deferred_printers)
    --> 702             printer.pretty(obj)
        703             printer.flush()
        704             return stream.getvalue()
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/IPython/lib/pretty.py in pretty(self, obj)
        400                         if cls is not object \
        401                                 and callable(cls.__dict__.get('__repr__')):
    --> 402                             return _repr_pprint(obj, self, cycle)
        403 
        404             return _default_pprint(obj, self, cycle)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/IPython/lib/pretty.py in _repr_pprint(obj, p, cycle)
        695     """A pprint that just redirects to the normal repr function."""
        696     # Find newlines and replace them with p.break_()
    --> 697     output = repr(obj)
        698     for idx,output_line in enumerate(output.splitlines()):
        699         if idx:
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/fitsrec.py in __repr__(self)
        478         # Force use of the normal ndarray repr (rather than the new
        479         # one added for recarray in Numpy 1.10) for backwards compat
    --> 480         return np.ndarray.__repr__(self)
        481 
        482     def __getitem__(self, key):
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in _array_repr_implementation(arr, max_line_width, precision, suppress_small, array2string)                                                                                                                             
       1417     elif arr.size > 0 or arr.shape == (0,):
       1418         lst = array2string(arr, max_line_width, precision, suppress_small,
    -> 1419                            ', ', prefix, suffix=suffix)
       1420     else:  # show zero-length shape unless it is (0,)                                                                                                  
       1421         lst = "[], shape=%s" % (repr(arr.shape),)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in array2string(a, max_line_width, precision, suppress_small, separator, prefix, style, formatter, threshold, edgeitems, sign, floatmode, suffix, **kwarg)                                                              
        688         return "[]"
        689 
    --> 690     return _array2string(a, options, separator, prefix)
        691 
        692 
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in wrapper(self, *args, **kwargs)
        468             repr_running.add(key)
        469             try:
    --> 470                 return f(self, *args, **kwargs)
        471             finally:
        472                 repr_running.discard(key)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in _array2string(a, options, separator, prefix)
        503     lst = _formatArray(a, format_function, options['linewidth'],
        504                        next_line_prefix, separator, options['edgeitems'],
    --> 505                        summary_insert, options['legacy'])
        506     return lst
        507 
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in _formatArray(a, format_function, line_width, next_line_prefix, separator, edge_items, summary_insert, legacy)                                                                                                        
        816         return recurser(index=(),
        817                         hanging_indent=next_line_prefix,
    --> 818                         curr_width=line_width)
        819     finally:
        820         # recursive closures have a cyclic reference to themselves, which
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in recurser(index, hanging_indent, curr_width)
        770 
        771             for i in range(trailing_items, 1, -1):
    --> 772                 word = recurser(index + (-i,), next_hanging_indent, next_width)
        773                 s, line = _extendLine(
        774                     s, line, word, elem_width, hanging_indent, legacy)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in recurser(index, hanging_indent, curr_width)
        724 
        725         if axes_left == 0:
    --> 726             return format_function(a[index])
        727 
        728         # when recursing, add a space to align with the [ added, and reduce the
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in __call__(self, x)
       1301         str_fields = [
       1302             format_function(field)
    -> 1303             for field, format_function in zip(x, self.format_functions)
       1304         ]
       1305         if len(str_fields) == 1:
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in <listcomp>(.0)
       1301         str_fields = [
       1302             format_function(field)
    -> 1303             for field, format_function in zip(x, self.format_functions)
       1304         ]
       1305         if len(str_fields) == 1:
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in __call__(self, arr)
       1269     def __call__(self, arr):
       1270         if arr.ndim <= 1:
    -> 1271             return "[" + ", ".join(self.format_function(a) for a in arr) + "]"
       1272         return "[" + ", ".join(self.__call__(a) for a in arr) + "]"
       1273 
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in <genexpr>(.0)
       1269     def __call__(self, arr):
       1270         if arr.ndim <= 1:
    -> 1271             return "[" + ", ".join(self.format_function(a) for a in arr) + "]"
       1272         return "[" + ", ".join(self.__call__(a) for a in arr) + "]"
       1273 
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/numpy/core/arrayprint.py in __call__(self, x)
       1143 
       1144     def __call__(self, x):
    -> 1145         return self.format % x
       1146 
       1147 
    
    TypeError: %d format: a number is required, not str
    
    In [7]: t['BEST_PICTURE']                                                                                                                                      
    Out[7]: 
    _VLF([chararray(['T', 'h', 'e', '', 'S', 'h', 'a', 'p', 'e', '', 'o', 'f', '',
               'W', 'a', 't', 'e', 'r'], dtype='<U1'),
          chararray(['M', 'o', 'o', 'n', 'l', 'i', 'g', 'h', 't'], dtype='<U1'),
          chararray(['S', 'p', 'o', 't', 'l', 'i', 'g', 'h', 't'], dtype='<U1')],
         dtype=object)
    ```
1. Try to write it and look at the output
    ```
    In [8]: handle.writeto('output.fits')
    
    In [9]: # output.fits contains corrupted data, see attached.
    ```
1. Try to read it using the `table` interface. (Here I'm starting a new `ipython` session for clarity.)
    ```
    In [1]: import astropy                                                                                                                                         
    
    In [2]: astropy.__version__                                                                                                                                    
    Out[2]: '3.1.1'
    
    In [3]: from astropy import table                                                                                                                              
    
    In [4]: t = table.Table.read('vla-example.fits')                                                                                                               
    
    In [5]: t                                                                                                                                                      
    Out[5]: 
    <Table length=3>
     YEAR                              BEST_PICTURE                              BOX_OFFICE_GROSS
    int64                                 object                                      int64      
    ----- ---------------------------------------------------------------------- ----------------
     2017 ['T' 'h' 'e' '' 'S' 'h' 'a' 'p' 'e' '' 'o' 'f' '' 'W' 'a' 't' 'e' 'r']        195200000
     2016                                  ['M' 'o' 'o' 'n' 'l' 'i' 'g' 'h' 't']         65300000
     2015                                  ['S' 'p' 'o' 't' 'l' 'i' 'g' 'h' 't']         98300000
    ```
1.  Try to write it back out to a FITS file using the `table` interface.
    ```
    In [6]: t.write('output.fits')                                                                                                                                 
    ---------------------------------------------------------------------------
    ValueError                                Traceback (most recent call last)
    <ipython-input-6-ff1bebe517f2> in <module>
    ----> 1 t.write('output.fits')
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/table/table.py in write(self, *args, **kwargs)
       2592         serialize_method = kwargs.pop('serialize_method', None)
       2593         with serialize_method_as(self, serialize_method):
    -> 2594             io_registry.write(self, *args, **kwargs)
       2595 
       2596     def copy(self, copy_data=True):
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/registry.py in write(data, format, *args, **kwargs)
        558 
        559     writer = get_writer(format, data.__class__)
    --> 560     writer(data, *args, **kwargs)
        561 
        562 
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/connect.py in write_table_fits(input, output, overwrite)
        386     input = _encode_mixins(input)
        387 
    --> 388     table_hdu = table_to_hdu(input, character_as_bytes=True)
        389 
        390     # Check if output file already exists
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/convenience.py in table_to_hdu(table, character_as_bytes)
        495             col.null = fill_value.astype(table[col.name].dtype)
        496     else:
    --> 497         table_hdu = BinTableHDU.from_columns(np.array(table.filled()), header=hdr, character_as_bytes=character_as_bytes)
        498 
        499     # Set units and format display for output HDU
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/hdu/table.py in from_columns(cls, columns, header, nrows, fill, character_as_bytes, **kwargs)
        123         """
        124 
    --> 125         coldefs = cls._columns_type(columns)
        126         data = FITS_rec.from_columns(coldefs, nrows=nrows, fill=fill,
        127                                      character_as_bytes=character_as_bytes)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/column.py in __init__(self, input, ascii)
       1373         elif isinstance(input, np.ndarray) and input.dtype.fields is not None:
       1374             # Construct columns from the fields of a record array
    -> 1375             self._init_from_array(input)
       1376         elif isiterable(input):
       1377             # if the input is a list of Columns
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/column.py in _init_from_array(self, array)
       1408             cname = array.dtype.names[idx]
       1409             ftype = array.dtype.fields[cname][0]
    -> 1410             format = self._col_format_cls.from_recformat(ftype)
       1411 
       1412             # Determine the appropriate dimensions for items in the column
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/column.py in from_recformat(cls, recformat)
        271         """Creates a column format from a Numpy record dtype format."""
        272 
    --> 273         return cls(_convert_format(recformat, reverse=True))
        274 
        275     @lazyproperty
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/column.py in _convert_format(format, reverse)
       2398 
       2399     if reverse:
    -> 2400         return _convert_record2fits(format)
       2401     else:
       2402         return _convert_fits2record(format)
    
    ~/Programming/matcha/post-pipeline/python/matcha/lib/python3.7/site-packages/astropy/io/fits/column.py in _convert_record2fits(format)
       2361         output_format = repeat + NUMPY2FITS[recformat]
       2362     else:
    -> 2363         raise ValueError('Illegal format `{}`.'.format(format))
       2364 
       2365     return output_format
    
    ValueError: Illegal format `object`.
    ```
@devonhollowood - I'm not working on it, so it's great if you want to give it a try! 
Welcome to Astropy 👋 and thank you for your first issue!

A project member will respond to you as soon as possible; in the meantime, please double-check the [guidelines for submitting issues](https://github.com/astropy/astropy/blob/main/CONTRIBUTING.md#reporting-issues) and make sure you've provided the requested details.

GitHub issues in the Astropy repository are used to track bug reports and feature requests; If your issue poses a question about how to use Astropy, please instead raise your question in the [Astropy Discourse user forum](https://community.openastronomy.org/c/astropy/8) and close this issue.

If you feel that this issue has not been responded to in a timely manner, please leave a comment mentioning our software support engineer @embray, or send a message directly to the [development mailing list](http://groups.google.com/group/astropy-dev).  If the issue is urgent or sensitive in nature (e.g., a security vulnerability) please send an e-mail directly to the private e-mail feedback@astropy.org.
> Reading the FITS standard, I get the impression that multi-dimensional VLAs should be possible, so this seems like some unexpected behavior. At the very least, if multi-dimensional VLAs aren't meant to be supported, io.fits should be throwing errors. Right now it's simply failing silently.

Yes it's not clear from the Standard, it seems allowed but the problem is that only the number of elements is stored, so there is no way to store and retrieve the shape. So unless fitsio/cfitsio can do that (which doesn't seem to be the case) I guess we should raise an error in that case.
I gave the Standard another read and now I believe it intends to explicitly support this use-case, at least _partially_.

On section 7.3.5 (emphasis mine):
> Variable-length arrays are logically equivalent to regular static arrays, the only differences being 1) the length of the stored array can differ for different rows, and 2) the array data are not stored directly in the main data table. (...) **Other established FITS conventions that apply to static arrays will generally apply as well to variable-length arrays**.

Then, if we look at section 7.3.2, where the `TDIMn` keywords are described:
> The size must be less than or equal to the repeat count in the TFORMn keyword, or, in the case of columns that have a ’P’ or ’Q’ TFORMn data type, less than or equal to the array length specified in the variable-length array descriptor (see Sect. 7.3.5). In the special case where the variable-length array descriptor has a size of zero, then the TDIMn keyword is not applicable.

So it seems to me that, at the very least, the Standard intends to support defining a fixed shape for all VLAs in a column. However, attempting something like:

```python
col = fits.Column(name='test', format='PD(1000)', array=array, dim='(20,50)')
```

will result in:
```
astropy.io.fits.verify.VerifyError: The following keyword arguments to Column were invalid:
    The repeat count of the column format 'test' for column 'PD(1000)' is fewer than the number of elements per the TDIM argument '(20,50)'.  The invalid TDIMn value will be ignored for the purpose of formatting this column.
```

That said, I have no idea how the Standard intends us to interpret arrays that don't have enough elements to fill the shape. It does define what happens when we have more elements than necessary to fill the shape:

> If the number of elements in the array implied by the TDIMn is fewer than the allocated size of the array in the FITS file, then the unused trailing elements should be interpreted as containing undefined fill values.

To me it seems that if we defined a shape through `TDIMn`, in practice our VLAs would end up actually needing a fixed size to make any sense... and at that point why would we be using VLAs? Obviously, this could be worked around with something like a `TDIMn_i` keyword for every `i` row, or simply writing the shapes somewhere in the heap (with maybe a third integer added to the array descriptor?), but unfortunately the standard doesn't seem to acknowledge this need in any way. I'm very curious if there has ever been a project that attempts to solve this mess.
> To me it seems that if we defined a shape through TDIMn, in practice our VLAs would end up actually needing a fixed size to make any sense... and at that point why would we be using VLAs?

Right, this is quite confusing.  I agree with your interpretation of TDIM related to VLA, which I missed before, but then as you say it would mean that the arrays have a fixed shape so we loose the benefit of using a VLA.
Just to add on to this, when you deal with strings it's particularly easy to do something that looks like it should work, but really doesn't. For example:

```python
array = np.empty(2, dtype=np.object_)
array[0] = ['aa', 'bbb']
array[1] = ['c']

col = fits.Column(name='test', format='PA()', array=array)
fits.BinTableHDU.from_columns([col]).writeto('bug.fits', overwrite=True)

with fits.open('bug.fits') as hdus:
    print(hdus[1].columns.formats)
    print(hdus[1].data['test'])
```

outputs this:

```python
['PA(2)']
[chararray(['a', ''], dtype='<U1') chararray([''], dtype='<U1')]
```

And you can also completely corrupt the file with something like:

```python
array = np.empty(1, dtype=np.object_)
array[0] = ['a', 'b']*400

col = fits.Column(name='test', format='PA()', array=array)
fits.BinTableHDU.from_columns([col]).writeto('bug.fits', overwrite=True)

with fits.open('bug.fits') as hdus:
    print(hdus)
```

As far as I understand it, this is essentially the same issue, because in practice a list of strings is just a multi-dimensional array of characters. However, this may be especially hard to tell from the user side.
This seems to be related to #7810.
I've been thinking about this one for a long while, so I decided to put my thoughts into text in (hopefully) an organized manner. This will be very long so sorry in advance for the wall of text.

___

### What the standard actually says

It's clear to me that, if we strictly follow the current FITS Standard, it's impossible to support columns that contain arrays of variable dimensions. However, the Standard still **explicitly** allows the usage of `TDIMn` keywords for VLA columns. While this feature is defined in an extremely confusing manner, after reading the Standard (yet again) I now believe it actually satisfactorily specifies how multi-dimensional VLAs must be handled. I'm pretty confident that the interaction between VLA columns and `TDIMn` can be boiled down to 4 rules:
- **Entries in the same VLA column must be interpreted as having the same dimensions.**
	- Reasoning: This is unavoidable given that the standard only allows defining one `TDIM` per column and it does not define any way of storing shape information either on the heap area or array descriptor.
- **Entries cannot have fewer elements than the size** (that is, the product of the dimensions) **implied by TDIM.**
	- Reasoning: The standard mentions that "The size [implied by `TDIM`] must be (...), in the case of columns that have a `’P’` or `’Q’` `TFORMn` data type, less than or equal to the array length specified in the variable-length array descriptor". Since we have one "array descriptor" for each entry in a VLA column, this means we have to check `TDIM` against the length defined in every single row, in order to ensure it's valid.
- **Entries may have more elements than the product of the defined dimensions, in which case we essentially ignore the extra elements.**
	- Reasoning: The standard is very clear in saying that "If the number of elements in the array implied by the `TDIMn` is fewer than the allocated size of the array in the FITS file, then the unused trailing elements should be interpreted as containing undefined fill values."
- **The 3 rules above don't apply to entries that have no elements (length zero); those entries should just be interpreted as empty arrays.**
	- Reasoning: In the standard it's specified that "In the special case where the variable-length array descriptor has a size of zero, then the `TDIMn` keyword is not applicable". Well, if the `TDIMn` keyword is "not applicable", then we have to interpret that specific entry as we would if the keyword didn't exist... which is to just take it as an empty array.

So, in the first few readings of the Standard, the idea of using `TDIM` on VLAs felt pointless because it seemed like it would force you to have arrays of fixed length, which would defeat the entire purpose of having *variable*-length arrays. However, with these simplified "rules" in mind it seems clear to me that there's actually at least one scenario where using VLAs with `TDIM` may be preferred to just using a fixed-length array with `TDIM`: **VLAs allow empty entries, which enable significant file size reductions in cases where we're dealing with huge matrices**. I have a feeling this is essentially the one use-case envisioned by the Standard. (I can also imagine a second use-case, where we intentionally create arrays longer than the size of the matrix defined by `TDIM`, and where these "extra elements" can be used to store some relevant extra information... but this use-case seems very far-fetched and likely against what the standard intends.)

So with this in mind, let's look at a few examples of columns and their entries, and discuss if they are "legal" according to the Standard, and how they should be interpreted. Let's assume that `TFORMn = '1PJ(8)'` for all of these columns.
A (`TDIM1 = '(1,1)'`)| B (`TDIM2 = '(2,2)'`) | C (`TDIM3 = '(2,4)'`) | D (`TDIM4 = '(2,4)'`)
---                          | ---                           | ---                           | ---
[1]                          | [1, 2, 3, 4, 5, 6, 7, 8] | [1, 2, 3, 4, 5, 6, 7, 8]  | [1, 2, 3, 4, 5, 6, 7, 8]
[1]                          | [1, 2, 3, 4, 5]            | [1, 2, 3, 4, 5]             | [ ]

Column A was inspired by #7810 and it is legal. Each entry should be interpreted as a 2D matrix which only has one value... that's a bit weird but completely fine by the Standard. In Python, it should look something like this:
```python
>>> t.data['A']
[array([[1]]), array([[1]])]
```

Column B is legal, but both entries have a few extra elements that will be ignored. The expected result is two 2x2 matrices, which in Python would look like:
```python
>>> t.data['B']
[array([[1, 2],
       [3, 4]]), array([[1, 2],
       [3, 4]])]
```

Column C is illegal, because there are entries that do not have enough elements to fill the matrix defined by `TDIM `(in other words, the second row has length 5 while the matrix size is 2*4=8). There's no reasonable way to interpret this column other than by ignoring `TDIM`.

Since empty entries don't need to respect `TDIM`, Column D is also legal and the result in Python would be:
```python
>>> t.data['D']
[array([[1, 2],
       [3, 4],
       [5, 6],
       [7, 8]]), array([], dtype=int32)]
```

____

### How I think Astropy should handle this
Currently, `io.fits` doesn't handle `TDIMn` for VLAs at all, resulting in a crash in basically any scenario. Regardless of whether you think this feature is useful or not, it seems there's already code in the wild using this type of pattern (see issue #7810), so there would definitely be some direct benefit in implementing this. On top of that, as far as I can tell this is one of the last few hurdles for achieving full VLA support in Astropy, which would be a great thing in itself.

Keeping with the "tolerant with input and strict with output" philosophy, I think the behavior a user would expect for the example columns is something like this.
**Reading:**
Column A and D are correctly read without any issues. Column B is correctly read, but a warning is thrown informing the user that some arrays were larger than the size defined by `TDIMn`, and thus the trailing elements were ignored. Column C is read as a one-dimensional array, and the user is warned that `TDIMn` was ignored because it was invalid.
**Writing:**
Column A and D are written without any issues. The trailing elements of column B are not written to the file (or maybe Column object can't even be created with such an array), and the user is informed of that. Column C can never be written as it is illegal. 

___

### How other tools/libraries handle this
While #7810 has a file which contains columns similar to column A, I unfortunately don't have example files for any of the other columns, since I wouldn't be able to create them with Astropy. If someone could create something like that (or has any other example files), it would be immensely useful for testing. Regardless, for now I've tested only that file on a few libraries/tools.

Running [P190mm-PAFBE-FEBEPAR.fits.zip](https://github.com/astropy/astropy/files/8320234/P190mm-PAFBE-FEBEPAR.fits.zip) through [`fitsverify`](https://heasarc.gsfc.nasa.gov/docs/software/ftools/fitsverify/) returns no errors or warnings. The file is also correctly opened by the [`fv` FITS Viewer](https://heasarc.gsfc.nasa.gov/ftools/fv/), and exploring the binary table allows us to see that `USEFEED`, `BESECTS` and `FEEDTYPE` are all correctly interpreted as 2D images that contain a single pixel. Finally, opening the file with [`fitsio`](https://github.com/esheldon/fitsio) results in:
```python
[...]/venv/lib/python3.10/site-packages/fitsio/hdu/table.py:1157: FutureWarning: Passing (type, 1) or '1type' as a synonym of type is deprecated; in a future version of numpy, it will be understood as (type, (1,)) / '(1,)type'.
  dtype = numpy.dtype(descr)
Traceback (most recent call last):
  File "/usr/lib/python3.10/code.py", line 90, in runcode
    exec(code, self.locals)
  File "<input>", line 1, in <module>
  File "[...]/venv/lib/python3.10/site-packages/fitsio/hdu/table.py", line 714, in read
    data = self._read_all(
  File "[...]/venv/lib/python3.10/site-packages/fitsio/hdu/table.py", line 764, in _read_all
    array = self._read_rec_with_var(colnums, rows, dtype,
  File "[...]/venv/lib/python3.10/site-packages/fitsio/hdu/table.py", line 1388, in _read_rec_with_var
    array[name][irow][0:ncopy] = item[:]
TypeError: 'numpy.int32' object does not support item assignment
```
so evidently this is feature is also not supported by `fitsio`. I haven't tested using [`CFITSIO`](https://heasarc.gsfc.nasa.gov/fitsio/) directly so I am not aware if it supports any of this or not.  
____

I would really like to implement this but, having had a look at the source code, I doubt I'd be able to. This is a fairly large change that is very tricky to get right, so it seems to me you have to be extremely familiar with the current code to really understand all the pitfalls (which I am not). So @saimn, if you know anyone who might want to have a look at this, please point them here!