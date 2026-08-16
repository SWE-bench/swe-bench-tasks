Memory leaks when accessing sequence tags with Dataset.__getattr__.
**Describe the bug**
Accessing sequences via `Dataset.__getattr__` seems to leak memory. The bug occurred for me when I was processing many DICOMs and manipulating some tags contained in sequences and each leaked a bit of memory, ultimately crashing the process.

**Expected behavior**
Memory should not leak. It works correctly when you replace the `__getattr__` call with `__getitem__` (by manually constructing the necessary tag beforehand).

Without being an expert in the codebase, one difference I think that could explain it is that `__getattr__` sets `value.parent = self` for sequences while `__getitem__` doesn't seem to do that. Maybe this loop of references somehow confuses Python's garbage collection?

**Steps To Reproduce**
This increases the memory consumption of the Python process by about 700 MB on my machine. The DICOM file I've tested it with is 27MB and has one item in `SourceImageSequence`. Note that the memory leak plateaus after a while in this example, maybe because it's the same file. In my actual workflow when iterating over many different files, the process filled all memory and crashed.

```python
import pydicom
for i in range(100):
  dcm = pydicom.dcmread("my_dicom.dcm")
  test = dcm.SourceImageSequence
```

For comparison, this keeps the memory constant. `(0x0008, 0x2112)` is `SourceImageSequence`: 

```python
import pydicom
import pydicom.tag
for i in range(100):
  dcm = pydicom.dcmread("my_dicom.dcm")
  test = dcm[pydicom.tag.TupleTag((0x0008, 0x2112))]
```

**Your environment**

```bash
Linux-4.15.0-72-generic-x86_64-with-Ubuntu-18.04-bionic
Python  3.6.8 (default, Jan 14 2019, 11:02:34)
pydicom  1.3.0
```

