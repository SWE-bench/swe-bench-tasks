Update get_cams protocol to https
According to an email sent out by Transvalor on May 12th 2022, the SoDa websites and services will switch from using "HTTP" to only "HTTPS". 

The existing HTTP endpoints will redirect to the correct HTTPS sites, hence without any changes the [`get_cams`](https://pvlib-python.readthedocs.io/en/stable/reference/generated/pvlib.iotools.get_cams.html) function will continue to work correctly (as the request package handles redirects automatically). However, for good practice and to avoid unnecessary redirects, updating the existing URLs and endpoints to HTTPS is surely a good idea:
https://github.com/pvlib/pvlib-python/blob/a0812b12584cfd5e662fa5aeb8972090763a671f/pvlib/iotools/sodapro.py#L188

<br>
For reference, here's a screen-shot of Transvalor email:

![image](https://user-images.githubusercontent.com/39184289/168595497-095c17c1-3fec-43c9-b6fd-49c928b51d78.png)

FYI: this is a good first issue to tackle to get familiar with contribution to pvlib :) 
