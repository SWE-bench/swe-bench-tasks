Related details: https://github.com/astropy/astroquery/issues/2440#issuecomment-1155588504
xref https://github.com/numpy/numpy/pull/21041
It was merged 4 days ago, so does this mean it went into the RC before it hits the "nightly wheel" that we tests against here?
ahh, good point, I forgot that the "nightly" is not in fact a daily build, that at least takes the confusion away of how a partial backport could happen that makes the RC fail but the dev still pass.
Perhaps Numpy could have a policy to refresh the "nightly wheel" along with RC to make sure last-minute backport like this won't go unnoticed for those who test against "nightly"? 🤔 
There you go: https://github.com/numpy/numpy/issues/21758
It seems there are two related problems.
1. When a column is unicode, a comparison with bytes now raises a `FutureWarning`, which leads to a failure in the tests. Here, we can either filter out the warning in our tests, or move to the future and raise a `TypeError`.
2. When one of the two is a `MaskedColumn`, the unicode sandwich somehow gets skipped. This is weird...
See https://github.com/numpy/numpy/issues/21770
Looks like Numpy is thinking to [undo the backport](https://github.com/numpy/numpy/issues/21770#issuecomment-1157077479). If that happens, then we have more time to think about this.
Are these errors related to the same numpy backport? Maybe we finally seeing it in "nightly wheel" and it does not look pretty (45 failures over several subpackages) -- https://github.com/astropy/astropy/runs/6918680788?check_suite_focus=true
@pllim - those other errors are actually due to a bug in `Quantity`, where the unit of an `initial` argument is not taken into account (and where units are no longer stripped in numpy). Working on a fix...
Well, *some* of the new failures are resolved by my fix - but at least it also fixes behaviour for all previous versions of numpy! See #13340.
The remainder all seem to be due to a new check on overflow on casting - we're trying to write `1e45` in a `float32` - see #13341
After merging a few PRs to fix other dev failures, these are the remaining ones in `main` now. Please advise on what we should do next to get rid of these 21 failures. Thanks!

Example log: https://github.com/astropy/astropy/runs/6936666794?check_suite_focus=true

```
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_pathlib
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_meta
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_noextension
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[False]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[True]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units[model11]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units[model22]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units_x_array[model11]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units_x_array[model22]
FAILED .../astropy/table/tests/test_column.py::test_col_unicode_sandwich_unicode
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[MaskedColumn-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-Column]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[str-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[list-MaskedColumn]
FAILED .../astropy/table/tests/test_init_table.py::TestInitFromTable::test_partial_names_dtype[True]
```
FWIW, I have #13349 that picked up the RC in question here and you can see there are only 17 failures (4 less from using numpy's "nightly wheel").

Example log: https://github.com/astropy/astropy/runs/6937240337?check_suite_focus=true

```
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_pathlib
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_meta
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_noextension
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[False]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[True]
FAILED .../astropy/io/misc/tests/test_hdf5.py::test_read_write_unicode_to_hdf5
FAILED .../astropy/table/tests/test_column.py::test_col_unicode_sandwich_unicode
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[MaskedColumn-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-Column]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[str-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[list-MaskedColumn]
```

So...

# In both "nightly wheel" and RC

```
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_pathlib
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_meta
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_simple_noextension
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_units[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[Table]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_with_format[QTable]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[False]
FAILED .../astropy/io/fits/tests/test_connect.py::TestSingleTable::test_character_as_bytes[True]
FAILED .../astropy/table/tests/test_column.py::test_col_unicode_sandwich_unicode
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[MaskedColumn-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[Column-Column]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[str-MaskedColumn]
FAILED .../astropy/table/tests/test_column.py::test_unicode_sandwich_compare[list-MaskedColumn]
```

# RC only

I don't understand why this one only pops up in the RC but not in dev. 🤷 

```
FAILED .../astropy/io/misc/tests/test_hdf5.py::test_read_write_unicode_to_hdf5
```

# "nightly wheel" only

```
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units[model11]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units[model22]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units_x_array[model11]
FAILED .../astropy/modeling/tests/test_models_quantities.py::test_models_evaluate_with_units_x_array[model22]
FAILED .../astropy/table/tests/test_init_table.py::TestInitFromTable::test_partial_names_dtype[True]
```
@pllim - with the corrections to the rc3, i.e., numpy 1.23.x (1.23.0rc3+10.gcc0e08d20), the failures in `io.fits`, `io.misc`, and `table` are all gone -- all tests pass! So, we can now move to address the problems in `numpy-dev`.
Will there be a rc4?
Looks like numpy released 1.23 🤞 
I am anxiously waiting for the "nightly wheel" to catch up. The other CI jobs passing even after the new release, so at least that is a good sign. 🤞 
I actually don't know that `-dev` was changed too - I think they just reverted the bad commit from 1.23, with the idea that for 1.24 there would be a fix (IIRC, https://github.com/numpy/numpy/pull/21812 would solve at least some of the problems)