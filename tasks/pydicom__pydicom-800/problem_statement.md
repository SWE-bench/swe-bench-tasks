The function generate_uid() generates non-conforming “2.25 .” DICOM UIDs
<!-- Instructions For Filing a Bug: https://github.com/pydicom/pydicom/blob/master/CONTRIBUTING.md#filing-bugs -->

#### Description
It seems there was already a discussion about this function in the past (#125), but the current implementation generates non-conforming DICOM UIDs when called with prefix ‘none’ to trigger that the function generate_uid() should generate a UUID derived UID.

The DICOM Standard requires (see DICOM PS 3.5, B.2 that when a UUID derived UID is constructed it should be in the format “2.25.” + uuid(in its decimal representation string representation)
For example a UUID of f81d4fae-7dec-11d0-a765-00a0c91e6bf6 should become 2.25.329800735698586629295641978511506172918

The current implementation extends the uuid part to the remaining 59 characters. By not following the DICOM formatting rule, receiving systems that are processing DICOM instances created with this library are not capable of converting the generated “2.25” UID back to a UUID. Due to the extra sha512 operation on the UUID, the variant and version info of the UUID are also lost.

#### Steps/Code to Reproduce
- call generate_uid() to generate a "2.25." DICOM UID

#### Expected Results
A conforming unique DICOM UID is returned.

#### Actual Results
Non conforming UID is returned.
