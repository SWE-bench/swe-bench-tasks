Handle odd-sized dicoms with warning
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
<!-- Example: Attribute Error thrown when printing (0x0010, 0x0020) patient Id> 0-->

We have some uncompressed dicoms with an odd number of pixel bytes (saved by older versions of pydicom actually). 

When we re-open with pydicom 1.2.2, we're now unable to extract the image, due to the change made by https://github.com/pydicom/pydicom/pull/601

Would it be possible to emit a warning instead of rejecting the dicom for such cases?

#### Version
1.2.2
