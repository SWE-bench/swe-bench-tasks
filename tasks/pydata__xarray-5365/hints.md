Very useful :+1: 
I would add:
```
    try:
        c.attrs["units"] = a.attrs["units"] + '*' + b.attrs["units"]
    except KeyError:
        pass
```
to preserve units - but I am not sure that is in scope for xarray.
it is not, but we have been working on [unit aware arrays with `pint`](https://github.com/pydata/xarray/issues/3594). Once that is done, unit propagation should work automatically.