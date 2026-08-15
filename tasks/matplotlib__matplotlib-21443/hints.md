Tried updating to 3.4.3 and got the same plotting result.

```
The following NEW packages will be INSTALLED:

  charls             pkgs/main/win-64::charls-2.2.0-h6c2663c_0
  giflib             pkgs/main/win-64::giflib-5.2.1-h62dcd97_0
  imagecodecs        pkgs/main/win-64::imagecodecs-2021.6.8-py38he57d016_1
  lcms2              pkgs/main/win-64::lcms2-2.12-h83e58a3_0
  lerc               pkgs/main/win-64::lerc-2.2.1-hd77b12b_0
  libaec             pkgs/main/win-64::libaec-1.0.4-h33f27b4_1
  libdeflate         pkgs/main/win-64::libdeflate-1.8-h2bbff1b_5
  libwebp            pkgs/main/win-64::libwebp-1.2.0-h2bbff1b_0
  libzopfli          pkgs/main/win-64::libzopfli-1.0.3-ha925a31_0
  zfp                pkgs/main/win-64::zfp-0.5.5-hd77b12b_6

The following packages will be UPDATED:

  certifi                          2021.5.30-py38haa95532_0 --> 2021.10.8-py38haa95532_0
  cryptography                         3.4.7-py38h71e12ea_0 --> 3.4.8-py38h71e12ea_0
  dask                                2021.8.1-pyhd3eb1b0_0 --> 2021.9.1-pyhd3eb1b0_0
  dask-core                           2021.8.1-pyhd3eb1b0_0 --> 2021.9.1-pyhd3eb1b0_0
  decorator                              5.0.9-pyhd3eb1b0_0 --> 5.1.0-pyhd3eb1b0_0
  distributed                       2021.8.1-py38haa95532_0 --> 2021.9.1-py38haa95532_0
  ipykernel                            6.2.0-py38haa95532_1 --> 6.4.1-py38haa95532_1
  ipywidgets                             7.6.3-pyhd3eb1b0_1 --> 7.6.5-pyhd3eb1b0_1
  jupyter_core                         4.7.1-py38haa95532_0 --> 4.8.1-py38haa95532_0
  jupyterlab_server                      2.8.1-pyhd3eb1b0_0 --> 2.8.2-pyhd3eb1b0_0
  libblas                           3.9.0-1_h8933c1f_netlib --> 3.9.0-12_win64_mkl
  libcblas                          3.9.0-5_hd5c7e75_netlib --> 3.9.0-12_win64_mkl
  liblapack                         3.9.0-5_hd5c7e75_netlib --> 3.9.0-12_win64_mkl
  llvmlite                            0.36.0-py38h34b8924_4 --> 0.37.0-py38h23ce68f_1
  matplotlib                           3.4.2-py38haa95532_0 --> 3.4.3-py38haa95532_0
  matplotlib-base                      3.4.2-py38h49ac443_0 --> 3.4.3-py38h49ac443_0
  mkl                  pkgs/main::mkl-2021.3.0-haa95532_524 --> conda-forge::mkl-2021.4.0-h0e2418a_729
  mkl_fft                              1.3.0-py38h277e83a_2 --> 1.3.1-py38h277e83a_0
  networkx                               2.6.2-pyhd3eb1b0_0 --> 2.6.3-pyhd3eb1b0_0
  nltk                                   3.6.2-pyhd3eb1b0_0 --> 3.6.5-pyhd3eb1b0_0
  numba              pkgs/main::numba-0.53.1-py38hf11a4ad_0 --> conda-forge::numba-0.54.1-py38h5858985_0
  openpyxl                               3.0.7-pyhd3eb1b0_0 --> 3.0.9-pyhd3eb1b0_0
  pandas                               1.3.2-py38h6214cd6_0 --> 1.3.3-py38h6214cd6_0
  patsy                                        0.5.1-py38_0 --> 0.5.2-py38haa95532_0
  pillow                               8.3.1-py38h4fa10fc_0 --> 8.4.0-py38hd45dc43_0
  prompt-toolkit                        3.0.17-pyhca03da5_0 --> 3.0.20-pyhd3eb1b0_0
  prompt_toolkit                          3.0.17-hd3eb1b0_0 --> 3.0.20-hd3eb1b0_0
  pycurl                            7.43.0.6-py38h7a1dbc1_0 --> 7.44.1-py38hcd4344a_1
  pytz                                  2021.1-pyhd3eb1b0_0 --> 2021.3-pyhd3eb1b0_0
  qtconsole                              5.1.0-pyhd3eb1b0_0 --> 5.1.1-pyhd3eb1b0_0
  tbb                                     2020.3-h74a9793_0 --> 2021.4.0-h59b6b97_0
  tifffile           pkgs/main/win-64::tifffile-2020.10.1-~ --> pkgs/main/noarch::tifffile-2021.7.2-pyhd3eb1b0_2
  tk                                      8.6.10-he774522_0 --> 8.6.11-h2bbff1b_0
  traitlets                              5.0.5-pyhd3eb1b0_0 --> 5.1.0-pyhd3eb1b0_0
  urllib3                               1.26.6-pyhd3eb1b0_1 --> 1.26.7-pyhd3eb1b0_0
  wincertstore                                   0.2-py38_0 --> 0.2-py38haa95532_2
  zipp                                   3.5.0-pyhd3eb1b0_0 --> 3.6.0-pyhd3eb1b0_0

The following packages will be DOWNGRADED:

  fiona                         1.8.13.post1-py38hd760492_0 --> 1.8.13.post1-py38h758c064_0
  shapely                              1.7.1-py38h210f175_0 --> 1.7.1-py38h06580b3_0
```
The [docstring for `plt.axes`](https://matplotlib.org/stable/api/_as_gen/matplotlib.pyplot.axes.html) reads:

```
Add an axes to the current figure and make it the current axes.

Call signatures::

    plt.axes()
    plt.axes(rect, projection=None, polar=False, **kwargs)
    plt.axes(ax)

Parameters
----------
arg : None or 4-tuple
    The exact behavior of this function depends on the type:

    - *None*: A new full window axes is added using
      ``subplot(**kwargs)``.
    - 4-tuple of floats *rect* = ``[left, bottom, width, height]``.
      A new axes is added with dimensions *rect* in normalized
      (0, 1) units using `~.Figure.add_axes` on the current figure.
...
```

The `mpl.axes.Axes` constructor accepts a `position` parameter and so it shows it up in list of additional keyword arguments, but it's overridden by the handling of  `arg=None` in this interface function.

All *you* need to do is change your code to `plt.axes(pos)`, etc.

`plt.axes()` should probably at least warn that it's ignoring `position=` in this case.
Thank you. Is this a change in behavior? Writing the code as I had it above in Google Colab gives the behavior I had expected.
It's definitely a change. Whether it was on purpose or not I'm not quite sure. 
The default version on Colab is older (3.2.2) and does indeed work differently, but the documentation for the parameters is the same.
The changed in 261f7062860d   https://github.com/matplotlib/matplotlib/pull/18564  While I agree that one need not pass `position=rect`, I guess we shouldn't have broken this, and we should definitely not document this as something that is possible.  