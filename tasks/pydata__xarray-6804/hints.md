If pytorch implements overrides of NumPy's API via the [`__array_function__` protocol](https://www.numpy.org/neps/nep-0018-array-function-protocol.html), then this could work with minimal effort. We are already using this to support [sparse arrays](https://sparse.pydata.org/en/latest/) (this isn't an official release yet, but functionality is working in the development version).

I think there has been some discussion about this, but I don't know the current status (CC @rgommers). The biggest challenge for pytorch would be defining the translation layer that implements NumPy's API.

Personally, I think the most viable way to achieve seamless integration with deep learning libraries would be to support integration with [JAX](https://github.com/google/jax), which already implements NumPy's API almost exactly. I have an [experimental pull request](https://github.com/google/jax/pull/611) adding `__array_function__` to JAX, but it still needs a bit of work to finish it up, e.g., we probably want to hide this behind a flag at first.
> I think there has been some discussion about this, but I don't know the current status (CC @rgommers). 

The PyTorch team is definitely receptive to the idea of adding `__array_function__` and `__array_ufunc__`, as well as expanding the API for better NumPy compatibility.

Also, they want a `Tensor.__torch_function__` styled after `__array_function__` so they can make their own API overridable.

The tracking issue for all of this is https://github.com/pytorch/pytorch/issues/22402

> The biggest challenge for pytorch would be defining the translation layer that implements NumPy's API.

Agreed. No one is working on `__array_function__` at the moment. Implementing it has some backwards compat concerns as well, because people may be relying on `np.somefunc(some_torch_tensor)` to be coerced to `ndarray`. It's not a small project, but implementing a prototype with a few function in the `torch` namespace that are not exactly matching the NumPy API would be a useful way to start pushing this forward.
> Personally, I think the most viable way to achieve seamless integration with deep learning libraries would be to support integration with JAX, which already implements NumPy's API almost exactly.

Less familiar with that, but pytorch does have experimental XLA support, so that's a start. 
> Implementing it has some backwards compat concerns as well, because people may be relying on `np.somefunc(some_torch_tensor)` to be coerced to `ndarray`.

Yes, this is a concern for JAX as well. This is a definite downside of reusing NumPy's existing namespace.

It turns out even xarray was relying on this behavior with dask in at least one edge case: https://github.com/pydata/xarray/issues/3215
> This is a definite downside of reusing NumPy's existing namespace.

We didn't discuss an alternative very explicitly I think, but at least we'll have wide adoption fast. Hopefully the pain is limited ....
I haven't used JAX - but was just browsing through its documentation and it looks super cool. Any ideas on how it compares with Pytorch in terms of:

a) Cxecution speed, esp. on GPU
b) Memory management on GPUs. Pytorch has the 'Dataloader/Dataset' paradigm which uses background multithreading to shuttle batches of data back and forth - along with a lot of tips and tricks on efficient memory usage.
c) support for deep-learning optimization algorithms ?



Within a `jit` compiled function, JAX's execution speed should be quite competitive on GPUs. It uses the XLA compiler, which was recently enabled by default in TensorFlow.

For data loading and deep learning algorithms, take a look at the examples in the `notebooks` directory in the JAX repo. The APIs for deep learning in JAX are still undergoing rapid development, so APIs are not quite as stable/usable as pytorch or keras yet, but they are quite capable. See `jax.experimental.stax` and [`tensor2tensor.trax`](https://github.com/tensorflow/tensor2tensor/tree/master/tensor2tensor/trax) for examples.
While it is pretty straightforward to implement a lot of standard xarray operations with a pytorch / Jax backend (since they just fallback on native functions) - it will be interesting to think about how to implement rolling operations / expanding / exponential window in a way that is both efficient and maintains differentiability.

Expanding and exponential window operations would be easy to do leveraging RNN semantics - but doing rolling using convolutions is going to be very inefficient.

Do you have any thoughts on this? 

I have not thought too much about these yet. But I agree that they will
probably require backend specific logic to do efficiently.

On Fri, Aug 23, 2019 at 12:13 PM firdaus janoos <notifications@github.com>
wrote:

> While it is pretty straightforward to implement a lot of standard xarray
> operations with a pytorch / Jax backend (since they just fallback on native
> functions) - it will be interesting to think about how to implement rolling
> operations / expanding / exponential window in a way that is both efficient
> and maintains differentiability.
>
> Expanding and exponential window operations would be easy to do leveraging
> RNN semantics - but doing rolling using convolutions is going to be very
> inefficient.
>
> Do you have any thoughts on this?
>
> —
> You are receiving this because you commented.
> Reply to this email directly, view it on GitHub
> <https://github.com/pydata/xarray/issues/3232?email_source=notifications&email_token=AAJJFVWRVLTFNT3DYOZIJB3QGASFBA5CNFSM4ING6FH2YY3PNVWWK3TUL52HS4DFVREXG43VMVBW63LNMVXHJKTDN5WW2ZLOORPWSZGOD5A6IWY#issuecomment-524411995>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AAJJFVQ7JBUNO3CAIFGVJ63QGASFBANCNFSM4ING6FHQ>
> .
>

This might be a good time to revive this thread and see if there is wider interest (and bandwidth) in having xarray use CuPy (https://cupy.chainer.org/ ) as a backend (along with numpy). It appears to be a plug-and-play replacement for numpy - so it might not have all the issues that were brought up regarding pytorch/jax ?

Any thoughts ?
cc @mrocklin 
Just chiming in quickly. I think there's definitely interest in doing this through NEP-18.

It looks like CUDA has implemented `__array_function__` (https://docs-cupy.chainer.org/en/stable/reference/interoperability.html) so many things may "just work". There was some work earlier on plugging in `pydata/sparse`, and there is some ongoing work to plug in `pint`. With both these efforts, a lot of xarray's code should be "backend-agnostic" but its not perfect. 

Have you tried creating `DataArrays` with `cupy` arrays yet? I would just try things and see what works vs what doesn't.

Practically, our approach so far has been to add a number of xfailed tests (`test_sparse.py` and `test_units.py`) and slowly start fixing them. So that's one way to proceed if you're up for it.
@jacobtomlinson gave CuPy a go a few months back. I seem to remember that he ran into a few problems but it would be good to get those documented here. 
Yeah Jacob and I played with this a few months back. There were some issues, but my recollection is pretty hazy. If someone gives this another try, it would be interesting to hear how things go.
If you have any pointers on how to go about this - I can give it a try.

>
>

Well here's [a blogpost on using Dask + CuPy]( https://blog.dask.org/2019/03/18/dask-nep18 ). Maybe start there and build up to using Xarray.
> @jacobtomlinson gave CuPy a go a few months back. I seem to remember that he ran into a few problems but it would be good to get those documented here.


I've been test driving xarray objects backed by CuPy arrays, and one issue I keep running into is that operations (such as plotting) that expect numpy arrays fail due to xarray's implicit converstion to Numpy arrays via `np.asarray()`. CuPy decided not to allow implicit conversion to NumPy arrays (see https://github.com/cupy/cupy/pull/3421). 

I am wondering whether there is a plan for dealing with this issue?



Here's a small, reproducible example:

```python

[23]: ds.tmin.data.device
      <CUDA Device 0>
[24]: ds.isel(time=0, lev=0).tmin.plot() # Fails
```



<details>
<summary>Traceback</summary>

```python
---------------------------------------------------------------------------
ValueError                                Traceback (most recent call last)
<ipython-input-21-69a72de2b9fd> in <module>
----> 1 ds.isel(time=0, lev=0).tmin.plot()

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/plot/plot.py in __call__(self, **kwargs)
    444 
    445     def __call__(self, **kwargs):
--> 446         return plot(self._da, **kwargs)
    447 
    448     @functools.wraps(hist)

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/plot/plot.py in plot(darray, row, col, col_wrap, ax, hue, rtol, subplot_kws, **kwargs)
    198     kwargs["ax"] = ax
    199 
--> 200     return plotfunc(darray, **kwargs)
    201 
    202 

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/plot/plot.py in newplotfunc(darray, x, y, figsize, size, aspect, ax, row, col, col_wrap, xincrease, yincrease, add_colorbar, add_labels, vmin, vmax, cmap, center, robust, extend, levels, infer_intervals, colors, subplot_kws, cbar_ax, cbar_kwargs, xscale, yscale, xticks, yticks, xlim, ylim, norm, **kwargs)
    684 
    685         # Pass the data as a masked ndarray too
--> 686         zval = darray.to_masked_array(copy=False)
    687 
    688         # Replace pd.Intervals if contained in xval or yval.

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/core/dataarray.py in to_masked_array(self, copy)
   2325             Masked where invalid values (nan or inf) occur.
   2326         """
-> 2327         values = self.values  # only compute lazy arrays once
   2328         isnull = pd.isnull(values)
   2329         return np.ma.MaskedArray(data=values, mask=isnull, copy=copy)

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/core/dataarray.py in values(self)
    556     def values(self) -> np.ndarray:
    557         """The array's data as a numpy.ndarray"""
--> 558         return self.variable.values
    559 
    560     @values.setter

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/core/variable.py in values(self)
    444     def values(self):
    445         """The variable's data as a numpy.ndarray"""
--> 446         return _as_array_or_item(self._data)
    447 
    448     @values.setter

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/xarray/core/variable.py in _as_array_or_item(data)
    247     TODO: remove this (replace with np.asarray) once these issues are fixed
    248     """
--> 249     data = np.asarray(data)
    250     if data.ndim == 0:
    251         if data.dtype.kind == "M":

/glade/work/abanihi/softwares/miniconda3/envs/rapids/lib/python3.7/site-packages/numpy/core/_asarray.py in asarray(a, dtype, order)
     83 
     84     """
---> 85     return array(a, dtype, copy=False, order=order)
     86 
     87 

ValueError: object __array__ method not producing an array
```
</details>
@andersy005 I'm about to start working actively on `cupy` support in xarray. Would be great to get some of your input.

Cupy requests that instead of calling `__array__` you instead call their `.get` method for explicit conversion to numpy. So we need to add a little compatibility code for this.
> @andersy005 I'm about to start working actively on `cupy` support in xarray. Would be great to get some of your input.
> 
> Cupy requests that instead of calling `__array__` you instead call their `.get` method for explicit conversion to numpy. So we need to add a little compatibility code for this.

Do you have a sense of the overhead / effort of making  jax vs cupy as the gpu backend for xarrays ? One advantage of jax would be built in auto-diff functionality that would enable xarray to be plugged directly into deep learning pipelines. Downside is that it is not as numpy compatible as cupy. How much of a non-starter would this be ?
@fjanoos I'm afraid I don't. In [RAPIDS](https://rapids.ai/) we support cupy as our GPU array implementation. So this request has come from the desire to make xarray compatible with the RAPIDS suite of tools.

We commonly see folks using cupy to switch straight over to a tool like pytorch using DLPack. https://docs-cupy.chainer.org/en/stable/reference/interoperability.html#dlpack

But I don't really see #4212 as an effort to make cupy the GPU backend for xarray. I see it as adding support for another backend to xarray. The more the merrier!
I'd like to cast my vote in favor of getting this functionality in. It would be nice to autodiff through xarray operations.

From reading this and related threads, I'm trying to determine a gameplan to make this happen. I'm not familiar with xarray code, so any guidance would be much appreciated. This is what I'm thinking :

1) Create a custom subclass of PyTorch's Tensors which meets the [duck array](http://xarray.pydata.org/en/latest/internals.html) required methods and attributes. Since this isn't officially supported, looks like I could run into issues getting this subclass to persist through tensor operations.
2) Implement the [\_\_array_function\_\_ protocol](https://blog.christianperone.com/2019/07/numpy-dispatcher-when-numpy-becomes-a-protocol-for-an-ecosystem/) for PyTorch similar to how is demo-ed [here](https://blog.christianperone.com/2019/07/numpy-dispatcher-when-numpy-becomes-a-protocol-for-an-ecosystem/).
3) Pass this custom class into data array constructors and hope the `.grad` attribute works.

My first attempts at this haven't been successful. Whatever custom class I make and past to the `DataArray` constructor gets converted to something xarray can handle with this line :

https://github.com/pydata/xarray/blob/bc35548d96caaec225be9a26afbbaa94069c9494/xarray/core/dataarray.py#L408

Any suggestions would be appreciated. I'm hoping to figure out the shortest path to a working prototype.
> No one is working on __array_function__ at the moment. Implementing it has some backwards compat concerns as well, because people may be relying on np.somefunc(some_torch_tensor) to be coerced to ndarray. It's not a small project, but implementing a prototype with a few function in the torch namespace that are not exactly matching the NumPy API would be a useful way to start pushing this forward.

@rgommers Do you expect this solution to work with a PyTorch Tensor custom subclass? Or is monkey patching necessary?
> Create a custom subclass of PyTorch's Tensors which meets the [duck array](http://xarray.pydata.org/en/latest/internals.html) required methods and attributes. Since this isn't officially supported, looks like I could run into issues getting this subclass to persist through tensor operations.

If you use PyTorch 1.7.1 or later, then Tensor subclasses are much better preserved through pytorch functions and operations like slicing. So a custom subclass, adding the attributes and methods Xarray requires for a duck array should be feasible.

> `data = as_compatible_data(data)`

Looks like you need to patch that internally just a bit, probably adding pytorch to `NON_NUMPY_SUPPORTED_ARRAY_TYPES`.


Note that I do not expect anymore that we'll be adding `__array_function__` to `torch.Tensor`, and certainly not any time soon. My current expectation is that the "get the correct namespace from an array/tensor object directly" from https://numpy.org/neps/nep-0037-array-module.html#how-to-use-get-array-module and https://data-apis.github.io/array-api/latest/ will turn out to be a much better design long-term.


Note that your the main work in adding `__array_function__` is not the dispatch mechanism, but mapping to 100% compatible APIs. That job should have gotten a lot easier now compared to 9 months ago. PyTorch now has a completely matching `fft` module, and a ~70% complete `linalg` module in master. And functions in the main namespace have gained dtype keywords, integer-to-float promotion, and other NumPy compat changes. So it should be feasible to write your custom subclass.
@Duane321 
While it would be fantastic to have gpu-enabled auto-diff-able xarrays / DataArrays, an interesting development worth looking into are the named tensor in https://pytorch.org/docs/stable/named_tensor.html. This appears to be an attempt to bridge the gap from the that they are making pytorch tensors increasingly dataarray like. I would not be surprised if within the next few iterations they add indexes to the tensors closing the gap even further.
> While it would be fantastic to have gpu-enabled auto-diff-able xarrays / DataArrays, an interesting development worth looking into are the named tensor in https://pytorch.org/docs/stable/named_tensor.html. This appears to be an attempt to bridge the gap from the that they are making pytorch tensors increasingly dataarray like. I would not be surprised if within the next few iterations they add indexes to the tensors closing the gap even further.

I really hope so. I explored named_tensors at first, but the lack an index for each dimension was a non-starter. So, I'll keep an eye out.
> Note that your the main work in adding __array_function__ is not the dispatch mechanism, but mapping to 100% compatible APIs. That job should have gotten a lot easier now compared to 9 months ago. PyTorch now has a completely matching fft module, and a ~70% complete linalg module in master. And functions in the main namespace have gained dtype keywords, integer-to-float promotion, and other NumPy compat changes. So it should be feasible to write your custom subclass.

Glad to hear there's progress I can lean on. I'll come back with a minimum version that does the API matching for maybe 1-2 methods, just to get feedback on theoverall structure. If it works, I can brute through a lot of the rest 🤞 

> Looks like you need to patch that internally just a bit, probably adding pytorch to NON_NUMPY_SUPPORTED_ARRAY_TYPES.

Thank you, I hesitate to change xarray code but not anymore.

> Note that I do not expect anymore that we'll be adding __array_function__ to torch.Tensor, and certainly not any time soon. My current expectation is that the "get the correct namespace from an array/tensor object directly" from https://numpy.org/neps/nep-0037-array-module.html#how-to-use-get-array-module and https://data-apis.github.io/array-api/latest/ will turn out to be a much better design long-term.

Does this mean I shouldn't fill out `__array_function__` in my subclass? Or is this just a forward looking expectation?

> Looks like you need to patch that internally just a bit, probably adding pytorch to NON_NUMPY_SUPPORTED_ARRAY_TYPES.

defining `__array_function__` (and the other properties listed in the [docs](https://xarray.pydata.org/en/latest/internals.html)) should be enough: https://github.com/pydata/xarray/blob/a0c71c1508f34345ad7eef244cdbbe224e031c1b/xarray/core/variable.py#L232-L235

> Does this mean I shouldn't fill out `__array_function__` in my subclass? Or is this just a forward looking expectation?

No, adding it should be perfectly fine. The dispatch mechanism itself isn't going anywhere, it's part of numpy and it works. Whether or not `torch.Tensor` itself has an `__array_function__` method isn't too relevant for your subclass.
I've made some mild progress, but it raises a few questions. I've defined this simple Tensor subclass which meets the duck array criteria:

```
class XArrayTensor(torch.Tensor):
    def __new__(cls, data=None, requires_grad=False):
        if data is None:
            data = torch.Tensor()
        return torch.Tensor._make_subclass(cls, data, requires_grad)

    def __init__(self, data=None, dims: Tuple[str] = None):
        self.dims = dims

    def __array_function__(self, func, types, args, kwargs):
        if func not in IMPLEMENTED_FUNCTIONS or not (not all(issubclass(t, torch.Tensor) for t in types)):
            return NotImplemented
        return IMPLEMENTED_FUNCTIONS[func](*args, **kwargs)

    def __array_ufunc__(self, func, types, args, kwargs):
        if func not in IMPLEMENTED_FUNCTIONS or not (not all(issubclass(t, torch.Tensor) for t in types)):
            return NotImplementedError
        return IMPLEMENTED_FUNCTIONS[func](*args, **kwargs)
```

where `IMPLEMENTED_FUNCTIONS` holds a mapping from numpy functions to API compatible tensor operators (similar in style to [this](https://blog.christianperone.com/2019/07/numpy-dispatcher-when-numpy-becomes-a-protocol-for-an-ecosystem/))

I added a `torch_array_type` to `pycompat.py`, which allows DataArray's `.data` attribute to persist as an `XArrayTensor`:

```
xr_tsr = XArrayTensor(torch.rand(3, 2))

data_array = xr.DataArray(
    xr_tsr,
    coords=dict(a=["a1", "a2", "a3"], b=["b1", "b1"]),
    dims=["a", "b"],
    name="dummy",
    attrs={"grad": xr_tsr.grad},
)
print(type(data_array.data)) --> yields 'xarray_tensor.XArrayTensor'
```

The issue I'm running into is when I run an operation like `np.mean(data_array).` The operation gets dispatched to functions within `duck_array_ops.py`, which are the things I'd like to override. 

Also, I'd like to confirm something. If the API matching were complete, would the following be possible?

```
some_sum = data_array.sum()
some_sum.backward()
data_array.grad --> provides the gradient
```

I'm starting to suspect not because that would involve data_array being _both_ `DataArray` and a `Torch.Tensor` object. It seems what I'm in fact enabling is that `DataArray.data` is a `Torch.Tensor`.

 
> I'm starting to suspect not because that would involve data_array being _both_ `DataArray` and a `Torch.Tensor` object. It seems what I'm in fact enabling is that `DataArray.data` is a `Torch.Tensor`.

`some_sum` is still a `DataArray`, which doesn't have a `backward` method. You could use
```
data_array = xr.DataArray(
    xr_tsr,
    coords=dict(a=["a1", "a2", "a3"], b=["b1", "b1"]),
    dims=["a", "b"],
    name="dummy",
    attrs={"grad": xr_tsr.grad, "backward": xr_tsr.backward},
)
```
and your example should work (I assume you meant `.grad` not `.grid`).
> I added a `torch_array_type` to `pycompat.py`

`torch.Tensor` defines `values`, so the issue is this: https://github.com/pydata/xarray/blob/8cc34cb412ba89ebca12fc84f76a9e452628f1bc/xarray/core/variable.py#L221
@shoyer, any ideas?

For now, I guess we can remove it using `__getattribute__`. With that you will have to cast the data first if you want to access `torch.Tensor.values`:
```python
torch.Tensor(tensor).values()
```

Not sure if that's the best way, but that would look like this:

<details><summary><tt>pytorch</tt> wrapper class</summary>

```python
In [13]: import numpy as np
    ...: import torch
    ...: from typing import Tuple
    ...: import xarray as xr
    ...: import functools
    ...: 
    ...: def wrap_torch(f):
    ...:     @functools.wraps(f)
    ...:     def wrapper(*args, **kwargs):
    ...:         # TODO: use a dict comprehension if there are functions that rely on the order of the parameters
    ...:         if "axis" in kwargs:
    ...:             kwargs["dim"] = kwargs.pop("axis")  # torch calls that parameter 'dim' instead of 'axis'
    ...: 
    ...:         return f(*args, **kwargs)
    ...: 
    ...:     return wrapper
    ...: 
    ...: class DTypeWrapper:
    ...:     def __init__(self, dtype):
    ...:         self.dtype = dtype
    ...:         if dtype.is_complex:
    ...:             self.kind = "c"
    ...:         elif dtype.is_floating_point:
    ...:             self.kind = "f"
    ...:         else:
    ...:             # I don't know pytorch at all, so falling back to "i" might not be the best choice
    ...:             self.kind = "i"
    ...: 
    ...:     def __getattr__(self, name):
    ...:         return getattr(self.dtype, name)
    ...: 
    ...:     def __repr__(self):
    ...:         return repr(self.dtype)
    ...: 
    ...: IMPLEMENTED_FUNCTIONS = {
    ...:     np.mean: wrap_torch(torch.mean),
    ...:     np.nanmean: wrap_torch(torch.mean),  # not sure if pytorch has a separate nanmean function
    ...: }
    ...: 
    ...: class XArrayTensor(torch.Tensor):
    ...:     def __new__(cls, data=None, requires_grad=False):
    ...:         if data is None:
    ...:             data = torch.Tensor()
    ...:         return torch.Tensor._make_subclass(cls, data, requires_grad)
    ...: 
    ...:     def __init__(self, data=None, dims: Tuple[str] = None):
    ...:         self.dims = dims
    ...: 
    ...:     def __array_function__(self, func, types, args, kwargs):
    ...:         if func not in IMPLEMENTED_FUNCTIONS or any(not issubclass(t, torch.Tensor) for t in types):
    ...:             return NotImplemented
    ...:         return IMPLEMENTED_FUNCTIONS[func](*args, **kwargs)
    ...: 
    ...:     def __array_ufunc__(self, func, types, args, kwargs):
    ...:         if func not in IMPLEMENTED_FUNCTIONS or any(not issubclass(t, torch.Tensor) for t in types):
    ...:             return NotImplementedError
    ...:         return IMPLEMENTED_FUNCTIONS[func](*args, **kwargs)
    ...: 
    ...:     def __getattribute__(self, name):
    ...:         if name == "values":
    ...:             raise AttributeError(
    ...:                 "'values' has been removed for compatibility with xarray."
    ...:                 " To access it, use `torch.Tensor(tensor).values()`."
    ...:             )
    ...:         return object.__getattribute__(self, name)
    ...: 
    ...:     @property
    ...:     def shape(self):
    ...:         return tuple(super().shape)
    ...: 
    ...:     @property
    ...:     def dtype(self):
    ...:         return DTypeWrapper(super().dtype)
    ...: 
    ...: tensor = XArrayTensor(torch.rand(3, 2))
    ...: display(tensor)
    ...: display(tensor.shape)
    ...: display(tensor.dtype)
    ...: display(tensor.ndim)
    ...: 
    ...: da = xr.DataArray(tensor, coords={"a": ["a1", "a2", "a3"], "b": ["b1", "b2"]}, dims=["a", "b"])
    ...: display(da)
    ...: display(da.data)
    ...: display(da.mean(dim="a"))
```

</details>

with that, I can execute `mean` and get back a `torch.Tensor` wrapped by a `DataArray` without modifying the `xarray` code. For a list of features where duck arrays are not supported, yet, see [Working with numpy-like arrays](https://xarray.pydata.org/en/stable/duckarrays.html) (that list should be pretty complete, but if you think there's something missing please open a new issue).

For `np.mean(da)`: be aware that `DataArray` does not define `__array_function__`, yet (see #3917), and that with it you have to fall back to `np.mean(da, axis=0)` instead of `da.mean(dim="a")`.

> If the API matching were complete, would the following be possible?

no, it won't be because this is fragile: any new method of `DataArray` could shadow the methods of the wrapped object. Also, without tight integration `xarray` does not know what to do with the result, so you would always get the underlying data instead of a new `DataArray`.

Instead, we recommend extension packages ([extending xarray](https://xarray.pydata.org/en/stable/internals.html#extending-xarray)), so with a hypothetical `xarray-pytorch` library you would write `some_sum.torch.backward()` instead of `some_sum.backward()`. That is a bit more work, but it also gives you a lot more control. For an example, see [pint-xarray](https://github.com/xarray-contrib/pint-xarray).
Thank you very much @keewis - your code did what I was trying to do. big help!

One thing I noticed with the [missing features](https://xarray.pydata.org/en/stable/duckarrays.html) is the following : 

![image](https://user-images.githubusercontent.com/19956442/106342256-1771ac80-6255-11eb-8b25-4f61dbb43132.png)

This seems like a bit of a problem. Index-based selection is a primary reason to use xarray's. If that changes `.data` to a numpy array, then autodiff-ing through selection seems not possible. Is there another approach I'm not seeing?
I can't reproduce that:
```python
In [4]: da.loc["a1"]
Out[4]: 
<xarray.DataArray (b: 2)>
tensor([0.4793, 0.7493], dtype=torch.float32)
Coordinates:
    a        <U2 'a1'
  * b        (b) <U2 'b1' 'b2'
```
with
```
numpy: 1.19.5
xarray: 0.16.2
pytorch: 1.7.1.post2
pandas: 1.2.1
```
maybe this is a environment issue?

Edit: the missing feature list includes `loc` (and `sel`) because it is currently not possible to have a duck array in a dimension coordinate, so this:
```python
xr.DataArray(
    [0, 1, 2],
    coords={"x": XArrayTensor(torch.Tensor([10, 12, 14]))},
    dims="x",
).loc[{"x": XArrayTensor(torch.Tensor([10, 14]))}]
```
does not work, but
```python
xr.DataArray(
    XArrayTensor(torch.Tensor([0, 1, 2])),
    coords={"x": [10, 12, 14]},
    dims="x",
).loc[{"x": [10, 14]}]
```
should work just fine.
Thank again @keewis , that was indeed the case. It was due to my older PyTorch version (1.6.0)
@Duane321: with `xarray>=0.17.0` you should be able to remove the `__getattributes__` trick.
@Duane321 or @keewis do you have the full code example for making this work? I'm a novice on numpy ufuncs and am trying to use get gradients while keeping my xarray coords.
I don't, unfortunately (there's the partial example in https://github.com/pydata/xarray/issues/3232#issuecomment-769789746, though).

This is nothing usable right now, but the `pytorch` maintainers are currently looking into providing support for `__array_namespace__` (NEP47). Once there has been sufficient progress in both [`numpy`](https://github.com/numpy/numpy/pull/18585) and [`pytorch`](https://github.com/pytorch/pytorch/issues/58743) we don't have to change much in xarray (i.e. allowing `__array_namespace__` instead of `__array_ufunc__` / `_array_function__` for duck arrays) to make this work without any wrapper code.

You (or anyone interested) might still want to maintain a "pytorch-xarray" convenience library to allow something like `arr.torch.grad(dim="x")`.
Thanks for the prompt response. Would love to contribute but I have to climb the learning curve first.
changing the `xarray` internals is not too much work: we need to get `xarray.core.utils.is_duck_array` to return true if the object has either `__array_namespace__` or `__array_ufunc__` and `__array_function__` (or all three) defined, and we'd need a short test demonstrating that objects that implement only `__array_namespace__` survive unchanged when wrapped by a `xarray` object (i.e. something like `isinstance(xr.DataArray(pytorch_object).mean().data, pytorch.Tensor)`).

We might still be a bit too early with this, though: the PR which adds `__array_namespace__` to `numpy` has not been merged into `numpy:main` yet.
@keewis @shoyer now that numpy is merged in https://github.com/numpy/numpy/pull/18585 `__array_namespace__` support and pytorch is in the process of add `__array_namespace__` support https://github.com/pytorch/pytorch/issues/58743 is it worth exploring adding support through the `__array_namespace__` API?