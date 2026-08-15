This may be a problem for #11886 given that SimpleImputer now handles
non-numerics

The issue is that `check_array` convert to `float64` object array. We need to turn `dtype=None` in case of `string` or `object` dtype to avoid the conversion.
> This may be a problem for #11886 given that SimpleImputer now handles non-numerics

It needs to be solved for the PR #12583 then.
If someone is going to work on this, I would like to add that for string types the error comes from the ```_get_mask``` function as discussed in #13028. This is in relation to numpy/numpy#5399
 
 I'm not sure that we want to support numpy string. 
                                                                                                                                      
 
                            
     
Sent from my phone - sorry to be brief and potential misspell. 

 

