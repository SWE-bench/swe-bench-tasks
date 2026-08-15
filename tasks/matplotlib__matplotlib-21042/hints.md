Those were all removed in 3.4.2, and indeed are not loaded.  I expect you have a crossed install somehow, and maybe an old matplotlibrc kicking around.  
I thought that too at first, but I don't believe that is the case here.  

After more digging, it seems to be related to line 846 of [\_\_init\_\_.py'](https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/__init__.py#L846) which constructs the `rcParamsDefault` dictionary from the found matplotlibrc file AND the `_hardcoded_defaults` dictionary in [rcsetup.py](https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/rcsetup.py#L1222).  It seems that when the matplotlibrc is loaded in [rc_params_from_file()](https://github.com/matplotlib/matplotlib/blob/master/lib/matplotlib/__init__.py#L802) those deprecated params are injected behind the scenes with warnings depressed.

I suppose this is a feature to preserve behavior while in the deprecation period, but it is not expected (to me anyways).  This behavior has puzzled me for years as my library reads, manipulates, and then updates rcparams (pre mplstyle era).  I'd always find them even though my matplotlibrc and install was clean.  I eventually countered this by maintaining a list of deprecated rcparams and popping them before my update.  Not good for backward compatibility though.  But then time would pass and more would crop up as versions changed and more future deprecations occurred.  I finally posted here because it has become very cumbersome to manage. 


Importing just matplotlib produces no warnings.  It is only after the get and update.
For 3.4.2 the warning is:
```
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The animation.avconv_args rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The animation.avconv_path rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The animation.html_args rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The keymap.all_axes rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The savefig.jpeg_quality rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
/Users/jklymak/anaconda3/envs/matplotlibdev/lib/python3.9/_collections_abc.py:856: MatplotlibDeprecationWarning: 
The text.latex.preview rcparam was deprecated in Matplotlib 3.3 and will be removed two minor releases later.
  self[key] = other[key]
```

I think that is working as we would expect, yes those entries still need to be in the dict, and yes you will get the deprecation message if you update them.  I'm not sure we can do anything to fix this....
Seems like the conundrum for a fix was discussed in [#13118](https://github.com/matplotlib/matplotlib/issues/13118#issuecomment-451776450).  Now that I understand that behavior, it seems good. 

The "fix" is probably just using best practices like the `matplotlib.rc()` method or `matplotlib.rcParams["some key"] = "some value"` to change global state, at least in my case.  These create a warning if a deprecated parameter is set, which is good.  The copy then update method is not great if you don't want to manage those warnings.

Perhaps helpful to developers would be a clarification to the documentation for [matplotlib.rc_params()](https://matplotlib.org/stable/api/matplotlib_configuration_api.html#matplotlib.rc_params) and [matplotlib.rc_params_from_file()](https://matplotlib.org/stable/api/matplotlib_configuration_api.html#matplotlib.rc_params_from_file) indicating that deprecated rcparams will be inserted when loading from the matplotlibrc or other file to preserve behavior during the deprecation period.  Then point them to best practice for setting global parameters in the guide [here](https://matplotlib.org/stable/tutorials/introductory/customizing.html#matplotlib-rcparams)
@gibbycu would you be willing to open a PR making the changes to those docstrings that would have saved you here?