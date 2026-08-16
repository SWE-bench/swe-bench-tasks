Hello @Jacc0027 and welcome to this community.

I would welcome submission of a function implementing that model. It differs from the existing functions by including parameters for perovskite cells.

It would need to be coded as a function similar to [first_solar_spectral_correction](https://github.com/pvlib/pvlib-python/blob/f318c1c1527f69d9bf9aed6167ca1f6ce9e9d764/pvlib/atmosphere.py#L324) using the same parameter names, where possible.

The script isn't in a function format. The time series in the .csv file appear to be related to the SMARTS simulations used to set up this model, is that correct? If so, then these data don't need to come into pvlib.
My pleasure @cwhanse , thank you very much for the welcome.

No problem, I can adapt the code in a similar way to the one you attached, and assuming the same variables.

Yes, you are right, the script I attached is not made as a function, it was just a sample to verify the results. And again you are right, the time series in the .csv file are obtained through SMARTS simulations

Therefore, I will attach in this thread the modified code as we have just agreed.


Hi @cwhanse , please find attached the updated script, in which we have tried to meet the requested requirements.

I look forward to any comments you may have.

[AM_AOD_PW_spectral_correction.zip](https://github.com/pvlib/pvlib-python/files/6984688/AM_AOD_PW_spectral_correction.zip)

Hi Jacc0027, I have looked at the code in the attachment. Can you make a pull request? When there are some tests, I think we can start the review process.