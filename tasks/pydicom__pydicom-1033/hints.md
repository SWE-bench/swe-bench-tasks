Can you please check with pydicom 1.4? Binary data handling should have been fixed there. 
ok works now once I set the bulk_data_threshold value to a higher value. 

Thank you!
Ok, that may be an issue with the data size. Currently, the default for `bulk_data_threshold` is 1, if I remember correctly, which may not be the best value - meaning that all binary data larger than that expect a bulk data element handler. Setting the threshold to a large value shall fix this, if the data is encoded directly.
Ah, you already found that, ok!

yep. thanks, works now. 
@darcymason - json support is still flagged as alpha - I think we can consider it at least beta now, and add a small section in the documentation.
We may also rethink the `bulk_data_threshold` parameter - maybe just ignore it if no bulk data handler is set, and set the default value to some sensible value (1kB or something).
> @darcymason - json support is still flagged as alpha - I think we can consider it at least beta now, and add a small section in the documentation.
> We may also rethink the `bulk_data_threshold` parameter - maybe just ignore it if no bulk data handler is set, and set the default value to some sensible value (1kB or something).

I agree that updating the documentation is a good idea for this. As its pretty common to have binary image data in dicom files, and its guaranteed to fail with the default value for bulk_data_threshold

Thanks once again though!
Ping @pieper, @hackermd for comment about `bulk_data_threshold`.
> We may also rethink the bulk_data_threshold parameter - maybe just ignore it if no bulk data handler is set, and set the default value to some sensible value (1kB or something).

1k threshold makes sense to me.  👍 