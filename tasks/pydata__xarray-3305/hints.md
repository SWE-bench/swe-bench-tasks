Looking at the code, I'm confused. The DataArray.quantile method creates a temporary dataset, copies the variable over, calls the Variable.quantile method, then assigns the attributes from the dataset to this new variable. At no point however are attributes assigned to this temporary dataset. My understanding is that Variable.quantile should have a `keep_attrs` argument, correct ?
> My understanding is that Variable.quantile should have a `keep_attrs` argument, correct ?

Yes, this makes sense to me.
Ok, I'll submit a PR shortly. 