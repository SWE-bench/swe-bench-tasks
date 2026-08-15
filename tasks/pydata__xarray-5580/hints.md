Why not just use:

```python
import xarray as xr
xr.set_options(display_max_rows=N)
```
where `N` is your wanted number of lines

The reasons for the restriction are laid out in https://github.com/pydata/xarray/issues/4736

Update: Fixed the call to `set_options`, stupid copy&paste error.
Why not increase that number to a more sensible value (as I suggested), or make it optional if people have problems?
If people are concerned and have problems, then this would be an option to fix that, not the other way around. This enforces such a low limit onto all others.
choosing default values is hard and always some kind of a tradeoff. In general we should strive to choose a default that is useful to most users (but how do you measure "useful to most users"?), and if that is not the case for a particular use case it should be configurable. I agree that having to remember to add the `set_options` call in every script / notebook / interpreter session is annoying, but there is not too much we can do (except adding a configuration file? but that might make the `set_options` code more complicated...)

For this particular setting I think the idea for the current value was that printing a lot of variables is slow and, most importantly, that the `repr` should provide an overview of the object, and in my opinion not being able to have all sections visible reduces the usefulness of the `repr` (which is why I tend to also set `display_expand_data=False` at the top of my notebooks). In the PR that introduced the setting we somewhat arbitrarily chose the number 12 but I don't think it should be much higher.

Thoughts, @pydata/xarray?

Disabling the restriction should be possible (but again, not the default), maybe `xr.set_options(display_max_rows=float("inf"))` works?
I switched off html rendering altogether because that *really* slows down the browser, haven't had any problems with the text output. The text output is (was) also much more concise and does not require additional clicks to open the dataset and see which variables are in there.

The problem with your suggestion is that this approach is not backwards compatible, which is not nice towards long-term users. A larger default would be a bit like meeting half-way. I also respectfully disagree about the purpose of `__repr__()`, see for example https://docs.python.org/3/reference/datamodel.html#object.__repr__ .
Cutting the output arbitrarily does not allow one to "recreate the object".
We need to cut some of the output, given a dataset has arbitrary size — same as numpy arrays / pandas dataframes.

If people feel strongly about a default > 12, that seems reasonable. Do people?
I think a bigger number than 12 would be appropriate. Personally I would almost always prefer to see the full output, even (especially?) if it's big. The only exception would be cases where variables are (mis)used instead of a dimension, e.g., `variable_1`, `variable_2`, etc, but these cases are relatively rare and are not what Xarray is primarily designed for.

There are plenty of examples of datasets/netCDF files with tens of distinct variables, and I think we should reveal these variables by default. For example, consider this xgcm example of ocean model output with 35 data varaibles: 
https://xgcm.readthedocs.io/en/latest/xgcm-examples/01_eccov4.html

I'm thinking that perhaps 50 or 100 would be a better default?
Hi @max-sixty

> We need to cut some of the output, given a dataset has arbitrary size — same as numpy arrays / pandas dataframes.

I thought about that too, but I believe these cases are slightly different. In numpy arrays you can almost guess how the full array looks like, you know the shape and get an impression of the magnitude of the entries (of course there can be exceptions which are not shown in the output). Similar for pandas series or dataframes, the skipped index values are quite easy to guess. The names of data variables in a dataset are almost impossible to guess, as are their dimensions and data types. The ellipsis is usually used to indicate some kind of continuation, which is not really the case with the data variables.

> If people feel strongly about a default > 12, that seems reasonable. Do people?

I can't speak for other people, but I do, sorry about that. @shoyer 's suggestion sounds good to me, from the top of my head 30-100 variables in a dataset seems to be around what I have come across as a typical case. Which does not mean that it *is* the typical case.
Great! I would have vote lower, since 100 cuts off much of a screen, but maybe there's a synthesis of 50 or so?
> > If people feel strongly about a default > 12, that seems reasonable. Do people?
> 
> I can't speak for other people, but I do, sorry about that.

Also, just to be clear as things can come across in the wrong tone when we're responding quickly on issues — I appreciate you raising the issue and would like to find the right answer — I had meant the original message as a friendly call for opinions!
If you want to fix your doctests results you can try out: https://github.com/max-sixty/pytest-accept

xarray was the odd one out having an infinite repr when comparing to other data science packages. numpy and pandas (the gold standard?) for example are limiting it. which also probably makes those reprs meaningless for some users that are making sure all the elements/columns/series have been processed correctly.

I like 12 rows because that fills up pretty much 80% of the screen. It was in inline with the guideline suggested by @shoyer of a repr should fit in 1 screen in #4736 and you don't have to waste too much time scrolling up to figure out your calculation error for the 100th time. 
I don't mind it being slightly larger but at around 16 rows I feel the scrolling starts to become rather annoying.

Some related ideas:
* If only variables are important there could be some prioritization logic so that as many variables are shown within some limited amount of rows. I think I considered this but dropped it because it requires a larger refactor.
* I think the `__repr__ `should be pretty short since it's easy that it gets accidentally triggered. `__str__` however could be longer because that requires some intention to display it, for example `print(ds)`.

Lets set up some examples:
```python
import numpy as np
import xarray as xr

a = np.arange(0, 2000)
data_vars = dict()
for i in a:
    data_vars[f"long_variable_name_{i}"] = xr.DataArray(
        name=f"long_variable_name_{i}",
        data=2*np.arange(25),
        dims=[f"long_coord_name"],
        coords={f"long_coord_name": 2*np.arange(25)},
    )
ds0 = xr.Dataset(data_vars)
ds0.attrs = {f"attr_{k}": 2 for k in a}
```

Now if you convert this to a Pandas dataframe and print it will look like this:
```python
df0 = ds0.to_dataframe()
print(df0)

                 long_variable_name_0  ...  long_variable_name_1999
long_coord_name                        ...                         
0                                   0  ...                        0
2                                   2  ...                        2
4                                   4  ...                        4
6                                   6  ...                        6
8                                   8  ...                        8
                              ...  ...                      ...
190                               190  ...                      190
192                               192  ...                      192
194                               194  ...                      194
196                               196  ...                      196
198                               198  ...                      198

[100 rows x 2000 columns]
```

The xarray dataset looks like this:
```python
print(ds0)

<xarray.Dataset>
Dimensions:                  (long_coord_name: 100)
Coordinates:
  * long_coord_name          (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
Data variables: (12/2000)
    long_variable_name_0     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_2     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_3     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_4     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_5     (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
                      ...
    long_variable_name_1994  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1995  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1996  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1997  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1998  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
    long_variable_name_1999  (long_coord_name) int32 0 2 4 6 ... 192 194 196 198
Attributes: (12/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
        ...
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

xarray shows a lot more information in fewer rows which is good and I think its size is still manageable.

Lets try some of the suggestions, I apologize for the long post but remember that this is the kind of scrolling you're going to have to do 100 times when figuring out where that invisible typo is:
```python
import numpy as np
import xarray as xr

a = np.arange(0, 2000)
data_vars = dict()
for i in a:
    data_vars[f"long_variable_name_{i}"] = xr.DataArray(
        name=f"long_variable_name_{i}",
        data=2*np.arange(25),
        dims=[f"long_coord_name_{np.mod(i, 25)}"],
        coords={f"long_coord_name_{np.mod(i, 25)}": 2*np.arange(25)},
    )
ds0 = xr.Dataset(data_vars)
ds0.attrs = {f"attr_{k}": 2 for k in a}
```

```python
with xr.set_options(display_max_rows=12):
    print(ds0)
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates: (12/25)
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (12/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_mame_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (12/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
        ...
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

```python
with xr.set_options(display_max_rows=16):
    print(ds0)
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates: (16/25)
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (16/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 9 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (16/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
        ...
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

```python
with xr.set_options(display_max_rows=20):
    print(ds0)

<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates: (20/25)
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_8        (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_9        (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
  * long_coord_name_15       (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_16       (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (20/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_8     (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_9     (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
                      ...
    long_variable_name_1990  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1991  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (20/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
    attr_8:     2
    attr_9:     2
        ...
    attr_1990:  2
    attr_1991:  2
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1966:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

```python
with xr.set_options(display_max_rows=24):
    print(ds0)
    
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates: (24/25)
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_8        (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_9        (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_10       (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_11       (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
                      ...
  * long_coord_name_13       (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_14       (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_15       (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_16       (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (24/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_varrable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_8     (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_9     (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_10    (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_11    (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
                      ...
    long_variable_name_1988  (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1989  (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1990  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1991  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (24/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
    attr_8:     2
    attr_9:     2
    attr_10:    2
    attr_11:    2
        ...
    attr_1988:  2
    attr_1989:  2
    attr_1990:  2
    attr_1991:  2
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

```python
with xr.set_options(display_max_rows=30):
    print(ds0)
    
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates:
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coood_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_8        (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_9        (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_10       (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_11       (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_12       (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_13       (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_14       (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_15       (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_16       (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (30/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_8     (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_9     (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_10    (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_11    (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_12    (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_13    (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_14    (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
                      ...
    long_variable_name_1985  (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1986  (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1987  (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1988  (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1989  (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1990  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1991  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (30/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
    attr_8:     2
    attr_9:     2
    attr_10:    2
    attr_11:    2
    attr_12:    2
    attr_13:    2
    attr_14:    2
        ...
    attr_1985:  2
    attr_1986:  2
    attr_1987:  2
    attr_1988:  2
    attr_1989:  2
    attr_1990:  2
    attr_1991:  2
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

There's a noticeable slow down around here:
```python
with xr.set_options(display_max_rows=50):
    print(ds0)
    
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates:
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_8        (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_9        (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_10       (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_11       (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_12       (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_13       (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_14       (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_15       (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_16       (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (50/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_8     (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_9     (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_10    (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_11    (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_12    (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_13    (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_14    (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_15    (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_16    (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_17    (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_18    (long_coord_name_18) int16 0 2 4 6 ... 42 44 46 48
    long_variable_name_19    (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_20    (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_21    (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_22    (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_23    (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_24    (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
                      ...
    long_variable_name_1975  (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1976  (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1977  (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1978  (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1979  (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1980  (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1981  (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1982  (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1983  (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1984  (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1985  (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1986  (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1987  (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1988  (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1989  (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1990  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1991  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (50/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
    attr_8:     2
    attr_9:     2
    attr_10:    2
    attr_11:    2
    attr_12:    2
    attr_13:    2
    attr_14:    2
    attr_15:    2
    attr_16:    2
    attr_17:    2
    attr_18:    2
    attr_19:    2
    attr_20:    2
    attr_21:    2
    attr_22:    2
    attr_23:    2
    attr_24:    2
        ...
    attr_1975:  2
    attr_1976:  2
    attr_1977:  2
    attr_1978:  2
    attr_1979:  2
    attr_1980:  2
    attr_1981:  2
    attr_1982:  2
    attr_1983:  2
    attr_1984:  2
    attr_1985:  2
    attr_1986:  2
    attr_1987:  2
    attr_1988:  2
    attr_1989:  2
    attr_1990:  2
    attr_1991:  2
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```

```python
with xr.set_options(display_max_rows=100):
    print(ds0)
    
<xarray.Dataset>
Dimensions:                  (long_coord_name_0: 25, long_coord_name_1: 25, long_coord_name_10: 25, long_coord_name_11: 25, long_coord_name_12: 25, long_coord_name_13: 25, long_coord_name_14: 25, long_coord_name_15: 25, long_coord_name_16: 25, long_coord_name_17: 25, long_coord_name_18: 25, long_coord_name_19: 25, long_coord_name_2: 25, long_coord_name_20: 25, long_coord_name_21: 25, long_coord_name_22: 25, long_coord_name_23: 25, long_coord_name_24: 25, long_coord_name_3: 25, long_coord_name_4: 25, long_coord_name_5: 25, long_coord_name_6: 25, long_coord_name_7: 25, long_coord_name_8: 25, long_coord_name_9: 25)
Coordinates:
  * long_coord_name_0        (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_1        (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_2        (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_3        (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_4        (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_5        (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_6        (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_7        (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_8        (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_9        (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
  * long_coord_name_10       (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_11       (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_12       (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_13       (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_14       (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_15       (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_16       (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_17       (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_18       (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_19       (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_20       (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_21       (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_22       (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_23       (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
  * long_coord_name_24       (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Data variables: (100/2000)
    long_variable_name_0     (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1     (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_2     (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_3     (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_4     (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_5     (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_6     (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_7     (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_8     (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_9     (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_10    (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_11    (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_12    (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_13    (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_14    (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_15    (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_16    (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_17    (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_18    (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_19    (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_20    (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_21    (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_22    (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_23    (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_24    (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_25    (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_26    (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_27    (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_28    (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_29    (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_30    (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_31    (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_32    (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_33    (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_34    (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_35    (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_36    (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_37    (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_38    (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_39    (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_40    (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_41    (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_42    (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_43    (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_44    (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_45    (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_46    (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_47    (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_48    (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_49    (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
                      ...
    long_variable_name_1950  (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1951  (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1952  (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1953  (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1954  (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1955  (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1956  (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1957  (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1958  (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1959  (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1960  (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1961  (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1962  (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1963  (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1964  (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1965  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1966  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1967  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1968  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1969  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1970  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1971  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1972  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1973  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1974  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1975  (long_coord_name_0) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1976  (long_coord_name_1) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1977  (long_coord_name_2) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1978  (long_coord_name_3) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1979  (long_coord_name_4) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1980  (long_coord_name_5) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1981  (long_coord_name_6) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1982  (long_coord_name_7) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1983  (long_coord_name_8) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1984  (long_coord_name_9) int32 0 2 4 6 8 ... 42 44 46 48
    long_variable_name_1985  (long_coord_name_10) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1986  (long_coord_name_11) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1987  (long_coord_name_12) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1988  (long_coord_name_13) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1989  (long_coord_name_14) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1990  (long_coord_name_15) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1991  (long_coord_name_16) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1992  (long_coord_name_17) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1993  (long_coord_name_18) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1994  (long_coord_name_19) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1995  (long_coord_name_20) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1996  (long_coord_name_21) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1997  (long_coord_name_22) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1998  (long_coord_name_23) int32 0 2 4 6 ... 42 44 46 48
    long_variable_name_1999  (long_coord_name_24) int32 0 2 4 6 ... 42 44 46 48
Attributes: (100/2000)
    attr_0:     2
    attr_1:     2
    attr_2:     2
    attr_3:     2
    attr_4:     2
    attr_5:     2
    attr_6:     2
    attr_7:     2
    attr_8:     2
    attr_9:     2
    attr_10:    2
    attr_11:    2
    attr_12:    2
    attr_13:    2
    attr_14:    2
    attr_15:    2
    attr_16:    2
    attr_17:    2
    attr_18:    2
    attr_19:    2
    attr_20:    2
    attr_21:    2
    attr_22:    2
    attr_23:    2
    attr_24:    2
    attr_25:    2
    attr_26:    2
    attr_27:    2
    attr_28:    2
    attr_29:    2
    attr_30:    2
    attr_31:    2
    attr_32:    2
    attr_33:    2
    attr_34:    2
    attr_35:    2
    attr_36:    2
    attr_37:    2
    attr_38:    2
    attr_39:    2
    attr_40:    2
    attr_41:    2
    attr_42:    2
    attr_43:    2
    attr_44:    2
    attr_45:    2
    attr_46:    2
    attr_47:    2
    attr_48:    2
    attr_49:    2
        ...
    attr_1950:  2
    attr_1951:  2
    attr_1952:  2
    attr_1953:  2
    attr_1954:  2
    attr_1955:  2
    attr_1956:  2
    attr_1957:  2
    attr_1958:  2
    attr_1959:  2
    attr_1960:  2
    attr_1961:  2
    attr_1962:  2
    attr_1963:  2
    attr_1964:  2
    attr_1965:  2
    attr_1966:  2
    attr_1967:  2
    attr_1968:  2
    attr_1969:  2
    attr_1970:  2
    attr_1971:  2
    att__1972:  2
    attr_1973:  2
    attr_1974:  2
    attr_1975:  2
    attr_1976:  2
    attr_1977:  2
    attr_1978:  2
    attr_1979:  2
    attr_1980:  2
    attr_1981:  2
    attr_1982:  2
    attr_1983:  2
    attr_1984:  2
    attr_1985:  2
    attr_1986:  2
    attr_1987:  2
    attr_1988:  2
    attr_1989:  2
    attr_1990:  2
    attr_1991:  2
    attr_1992:  2
    attr_1993:  2
    attr_1994:  2
    attr_1995:  2
    attr_1996:  2
    attr_1997:  2
    attr_1998:  2
    attr_1999:  2
```
By the way, I've added some typos in each of these, so you can haves some fun figuring out where they are as you're scrolling up and down the reprs. :)
Hi @Illviljan,
As I mentioned earlier, your "solution" is not backwards compatible, and it would be counterproductive to update the doctest. Which is also not relevant here and a different issue.

I am not sure what you are trying to show, your datasets look very different from what I am working with, and they miss the point. Then again they also prove my point, `pandas` and `numpy` shorten in a canonical way (except the finite number of columns, which may make sense, but I don't like that either and would rather have it wrap but show all columns). `xarray` doesn't because usually the variables are not simply numbered as in your example.

I am talking about medium sized datasets of a few 10 to maybe a few 100 non-canonical data variables. Have a look at http://cfconventions.org/ to get an impression of real-world variable names, or the example linked above in comment https://github.com/pydata/xarray/issues/5545#issuecomment-870109486.
There it would be nice to have an overview over *all* of them.

If too many variables are a problem, imo it would have been better to say:
"We keep it as it is, however, if it is a problem for your large dataset, here is an option to reduce the amount of output: ..." And put that into the docs or the wiki or FAQ or something similar.
Note that the initial point in the linked issue is about the *time* it takes to print all variables, not the *amount* that gets shown. And usually the number of coordinates and attributes is smaller than the number of data variables.
It also depends on what you call "screen", my terminal has currently 48 lines (about 56 in fullscreen, depending on fontsize), and a scrollback buffer of 5000 lines, I am also used to scrolling through long jupyter notebooks. Scrolling through your examples might be tedious (not for me actually), but I will never be able to find typos hidden in the three dots.

@max-sixty No worries, I understand that this is a minor cosmetic issue, actually I intended it as a feature request, not a bug. But that must have gone missing along the way.
I guess I could live with 50, any other opinions? I am sure someone else will complain about that too. ;)
@st-bender I don't imagine you intend it, but the first two paragraphs of your comment read as abrasive to me. Others should weigh in if they disagree with my assessment. 

FWIW I found @Illviljan 's examples very helpful to visualize the various options.

---

Back to the question: for me, 50 is longer than ideal; it spans my 27" portrait monitor. 20 seems good. We could also have fewer attrs (or coords too?). But as before, no strong view, and I'm rarely dealing with datasets like this
My 2 cents (no strong view either, I'm mostly using the HTML repr with a rather small number of variables):

I do agree with both arguments "fit the screen" vs "need to see all the variables", so why not have different display rules for the `Dataset`, `Dataset.data_vars` and `Dataset.coords` reprs?

For the `Dataset` repr, I think the motivation is mostly to get a quick overview of the whole dataset and basic answers on questions like:
  
- *What are the dimensions and their size?*
- *How many coordinates and data variables?*
- *Is the dataset fully loaded in memory or lazily loaded? Are the variables chunked? What's the type of arrays (dask vs. numpy)?*
- *Is there a lot of metadata or no metadata at all (global attributes)?*

All those questions can be answered with a short, truncated repr.

For the `Dataset.data_vars` and `Dataset.coords` reprs, it's more obvious that we want to see all of them, so I'd suggest not limiting the maximum of rows displayed (or have a much larger limit? but then we duplicate the display options, which is not very nice).


@max-sixty I apologize if I hurt someone, but it is hard to find a solution if we can't agree on the problem. Try the same examples with 50 or 100 instead of 2000 variables to understand what I mean.
And to be honest, I found your comments a bit dismissive and not exactly welcoming too, which is probably also not your intention.

From what I see in the examples by @Illviljan , setting `display_max_rows` affects everything equally, `coords`, `data_vars`, and `attrs`. So there would be no need to treat them separately. Or I misunderstood your comment.

Anyway, I think I made my point, I leave it up to you to decide what you are comfortable with.
> From what I see in the examples by @Illviljan , setting display_max_rows affects everything equally, coords, data_vars, and attrs. So there would be no need to treat them separately. Or I misunderstood your comment.

My suggestion is to ignore `display_max_rows` for the repr of the `Dataset.coords` and `Dataset.data_vars` properties, but not for the "coordinates" and "data variables" sections of the `Dataset` text-based repr. This way we could do `print(ds.data_vars)` to check that all variables made it into the data set correctly while keeping concise the output of `print(ds)`.
> For the `Dataset.data_vars` and `Dataset.coords` reprs, it's more obvious that we want to see all of them, so I'd suggest not limiting the maximum of rows displayed

IMO this would be an excellent synthesis of the tradeoffs, +1
@benbovy That sounds good to me. If I may add, I would leave `__repr__` and `__str__` to return the same things, since people seem to use them interchangeably, e.g. in tutorials, and probably in their own code and notebooks.
Great, I think we're decided!

@st-bender would you be interested in a PR to kick some of this off? It would be fine to do a subset (e.g. ignoring the limit for the `.coords` and `.data_vars` methods). I feel like we could parlay any tension above into a nice contribution. Also fine if not!