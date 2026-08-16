Should that `if None` read `if ds.PatientName is None`?

I can see the inconsistency if assigning `None` - which results in an empty value instead of `None`. Assigning an empty string works as expected (has an empty string afterwards).
For other string tags `None` or `''` can be assigned, though I now wonder if this is the correct behavior, as there is no difference between an empty value and no value in DICOM for string VRs. IMHO, the correct behavior should be to assign no value, e.g. the following should be equivalent:
```python
ds.PatientName = ''
ds.PatientName = None
ds.PatientName = []
```
Currently, the first 2 result in VM=1, the last in VM=0 (which is correct).
@darcymason, @scaramallion - what do you think?
The `if None` was just to demonstrate how python behaves and hence how I naively expect an empty pydicom element value to behave.

I just want a simple consistent "does this element have a value" test, which means an element with `None` and `''` should both fail the test. Essentially if the element will end up encoded with zero-length it should fail. It works as I expect for simple text element values, but `PersonName3` and maybe some of the other VR classes might need `__bool__()` or `__len__()`?

```python
# I'd like this to work cleanly
for elem in ds:
   if elem.value:
       print(elem.value)
   else:
       print('(no value available)')
```

I've been playing around with printing out pretty datasets for pynetdicom and have run into a some problems with consistency in how element values are evaluated and printed.

I think you're right, they should be VM = 0. I think the last case gives you a `MultiValue` rather than a `PersonName3` which is probably why.
```python
#!/usr/bin/env python

from pydicom.dataset import Dataset
from pydicom.datadict import tag_for_keyword

VRs = {
    'AE' : 'Receiver',
    'AS' : 'PatientAge',
    'AT' : 'OffendingElement',
    'CS' : 'QualityControlSubject',
    'DA' : 'PatientBirthDate',
    'DS' : 'PatientWeight',
    'DT' : 'AcquisitionDateTime',
    'IS' : 'BeamNumber',
    'LO' : 'DataSetSubtype',
    'LT' : 'ExtendedCodeMeaning',
    'PN' : 'PatientName',
    'SH' : 'CodeValue',
    'ST' : 'InstitutionAddress',
    'TM' : 'StudyTime',
    'UC' : 'LongCodeValue',
    'UI' : 'SOPClassUID',
    'UR' : 'CodingSchemeURL',
    'UT' : 'StrainAdditionalInformation',
    'SL' : 'RationalNumeratorValue',
    'SS' : 'SelectorSSValue',
    'UL' : 'SimpleFrameList',
    'US' : 'SourceAcquisitionBeamNumber',
    'FD' : 'RealWorldValueLUTData',
    'FL' : 'VectorAccuracy',
    'OB' : 'FillPattern',
    'OD' : 'DoubleFloatPixelData',
    'OF' : 'UValueData',
    'OL' : 'TrackPointIndexList',
    'OW' : 'TrianglePointIndexList',
    #'OV' : '',
    'UN' : 'SelectorUNValue',
}

ds = Dataset()
for vr, kw in VRs.items():
    try:
        setattr(ds, kw, None)
    except:
        print('Failed assigning None', vr)
        continue

    elem = ds[tag_for_keyword(kw)]

    try:
        assert bool(elem.value) is False
    except:
        print('Failed empty value test', vr)

    try:
        assert elem.VM == 0
    except Exception as exc:
        print('Failed VM == 0', vr, elem.VM)
```
UI fails assignment using `None`, they all fail the VM == 0 test, PN fails the value test in Python 3.6, passes in 2.7.
PN in Python 2 is derived from `unicode`, so this is to be expected. So you agree that VM shall be 0 after assigning `None` or `''`?
> So you agree that VM shall be 0 after assigning None or ''?

As far as I can see the standard doesn't explicitly say so, but I think that's reasonable. DCMTK's `dcmdump` uses that convention.

What do you think @darcymason?
> I think you're right, they should be VM = 0. I think the last case gives you a MultiValue rather than a PersonName3 which is probably why.

Sorry, I overlooked that post. Yes, and that may be the easiest way to change this - assign an empty `MultiValue` (aka an empty list) in these cases instead of `None` or `''`.
There is also the question of how to represent empty values. Currently we get:
```
>>> ds.CodeValue = None
>>> ds.CodeValue
>>> print(ds.CodeValue)
None
>>> ds['CodeValue'].VM
1
>>> ds.CodeValue = []
>>> ds.CodeValue
['']
>>> ds['CodeValue'].VM
0
```
which is quite inconsistent. `None` for an empty value may make sense, or an empty list (other than a list with an empty string), not sure about this. Any ideas?
I think as long as `bool(value)` would normally evaluate as `False` then it should be considered empty.
```python
value = '' # or None or [] or b'' or whatever
if not value:
    print('Empty')
```
For `MultiValue` it should probably be an OR on `[bool(val) for val in MultiValue]`
> > So you agree that VM shall be 0 after assigning None or ''?
> 
> As far as I can see the standard doesn't explicitly say so, but I think that's reasonable. DCMTK's `dcmdump` uses that convention.
> 
> What do you think @darcymason?

Hmmm... just read quickly through, so apologies if I've repeated (or missed) something already said.  Haven't looked at any code yet.

One thought is that DICOM type 2 data elements allow blank values, which to me is a real valid value, different than a None.

Second thought is we've normally handled a non-existent value by just not having the attribute set, i.e. just don't set the attribute, or if it already exists, delete it.  You check for existence of values by `if keyword in ds`.

Third thought (the last in this comment I think) is that when we drop support for earlier python versions and can start typing pydicom, do we cause trouble by encouraging use of None?  We have not forbidden setting None, or even incorrect types in many cases, but this is in line with python's duck typing philosophy.  It may be that at some point more control over this could be automatically introduced via typing. Yes, we could Union everything with None, but I would foresee a whole lot of `if` statements to handle those cases.


I frequently use `None` for type 2 elements that are required to be present but may or may not have a value. It just seems to me that this is the 'obvious' thing to do when I want an element with no value. Does it make sense that you need to set an integer VR to `''` if you want an empty value?

`if keyword in ds` tests for the presence of the element in the dataset, not that the element has a value. 
Well, thinking this through some more, I may be coming around to your way of thinking...I suppose blank type 2 can be considered a zero-length (no value) data element.  Using a null (python None) value for those does have a certain logic to it, similar to Null in databases and so on.  And in that case, VM should be zero, although VM is a weak concept to me anyway, since it exists in dictionaries but not in actual DICOM files, so I'm not too invested in that one way or the other.
The other thing is that some elements don't encode properly with a value set to `None`, while others work as I expect.

```python
>>> from pydicom.dataset import Dataset
>>> from pynetdicom.dsutils import encode  # wrapper for filewriter.write_dataset
>>> ds = Dataset()
>>> ds.Receiver = None  # VR of AE
>>> type(ds.Receiver)
NoneType
>>> encode(ds, True, True)  # Works OK
b'\x00\x00\x00\x03\x00\x00\x00\x00'
>>> ds = Dataset()
>>> ds.BitsStored = None  # VR of US
>>> type(ds.BitsStored)
NoneType
>>> encode(ds, True, True)  # Fails to encode
>>>
```
So I think this has elevated to a larger conversation on "`None` support" in pydicom, make it consistent across all types, or raise exceptions if there are any types or situations where it should not be allowed.

I'll sleep on it for now, pick it up again tomorrow...

My current instinct is to:
- handle assigning `None`, `''` or `[]` to an element with a text VR as assigning an empty string (as they are all equivalent, and an empty string is most convienient for the user, and probably expected), return `False` as truth value, and have a VM of 0 (this is as implemented in the PR) 
- handle assigning `None` or `[]` to an element with a binary VR as assigning `None` (I think this better meets the expections for an element without a value), return `False` as truth value, and have a VM of 0 (in the PR I use a `MultiValue` object, which I would change)
- in the case of IS and DS (these are kind of in-between), we have to make sure they handle the empty string case by returning `None` instead of 0 if getting the numerical value (haven't checked the current behavior) 

Using `None` for text values, apart from not being upwards compatible, is a thing I have been burned with before. I used to write DICOM elements into a database and had used database `null` to represent elements without values. This turned out to be a big mistake, as there is actually no use case where you have to differentiate no value from an empty value for text values (and indeed there is no such distinction in DICOM itself for text VRs), and led to a lot of unnecessary checking for null values in the user code (and exceptions if they have been missing).
I've started a separate issue for the empty values discussion #896