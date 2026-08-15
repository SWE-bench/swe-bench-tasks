Actually, I just realized that the second version also does not work since it uses the index of the `coord` argument and not its values. I guess that was meant by "The 1D coordinate along which to evaluate the polynomial".

Would you be open to a PR that allows any DataArray as `coord` argument and evaluates the polynomial at its values? Maybe that would break backwards compatibility though.
> Would you be open to a PR that allows any DataArray as coord argument and evaluates the polynomial at its values? 

I think yes. Note https://github.com/pydata/xarray/issues/4375 for the inverse problem.