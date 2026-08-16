Hi Alan,

I'm happy to look into this, but may need a file to work with.  But perhaps we can first have a look at the generated code, which normally immediately attaches any sequence it creates.  For example:

```
$ pydicom codify pydicom::rtplan.dcm
```
Gives lines like

```python
# Beam Sequence
beam_sequence = Sequence()
ds.BeamSequence = beam_sequence
```

and then proceeds to create a new Dataset, set its data elements, and eventually `append` it to the sequence:

```python
# Beam Sequence: Beam 1
beam1 = Dataset()
beam1.Manufacturer = 'Linac co.'
beam1.InstitutionName = 'Here'
.
.
.
beam_sequence.append(beam1)
```
Can you check your generated code for those kinds of patterns and let us know what you see?


Hi Darcy

Thanks for the guidance. Stepping through the code I've picked up two problems. The first has to do with nested content. Eg. if the DICOM file has:
![NestedContent](https://user-images.githubusercontent.com/34305581/185054806-ed2559c6-2e0f-46e5-a9de-085ada6e7753.png)

The second Content1 overwrites the first. See lines 121-191 in the attached file.

[rdsr.txt](https://github.com/pydicom/pydicom/files/9356766/rdsr.txt) Rename this file to rsdr.py.

The second problem is more puzzling. In lines 121-191 we have:

```
content_sequence = Sequence()
ds.ContentSequence = content_sequence

# Content Sequence: Content 1
content1 = Dataset()
content1.add_new((0x0040, 0x0000), 'UL', 512)
content1.RelationshipType = 'HAS CONCEPT MOD'
content1.ValueType = 'CODE'
.
.
.
content_sequence.append(content1)
```
After stepping though this ds.ContentSequence is still empty even though there are definitely items in content1 and the items were added to content_sequence. It is not related to the nested content as content2 (lines 193 - 223 in rdsr.py) which has no nested content shows the same behaviour.

If I shift the line "ds.ContentSequence = content_sequence" to just before the save statement at the end of the file the script crashes while saving with:
RecursionError: maximum recursion depth exceeded while calling a Python object
This suggests two things:
1) The previous code is generating a nested loop somewhere.
2) The line "ds.ContentSequence = content_sequence" appears to be creating a copy of content_sequence. My understanding of python is that an assigning objects should merely update pointers, but this does not appear to be the case.

I would suggest generating content names that reflect the content level if possible, eg. content1-1.

Regards
Alan
Alan, if you are unable to share your RDSR for testing, do you want to check the behaviour is the same with one of the OpenREM test RDSR files and use that for Darcy or anyone else to work on? One of the more straight forward ones, maybe [this Siemens Flash one](https://bitbucket.org/openrem/openrem/src/develop/openrem/remapp/tests/test_files/CT-RDSR-Siemens_Flash-TAP-SS.dcm)?
Hi Ed
I ran Codify on  CT-RDSR-Siemens_Flash-TAP-SS.dcm as you suggested. This gave the attached file:
[CT-RDSR-Siemens_Flash-TAP-SS.py.txt](https://github.com/pydicom/pydicom/files/9359044/CT-RDSR-Siemens_Flash-TAP-SS.py.txt) rename to .py
Running this file produces a dicom file 10 times smaller than the original file (attached)
[CT-RDSR-Siemens_Flash-TAP-SS_from_codify.dcm.txt](https://github.com/pydicom/pydicom/files/9359049/CT-RDSR-Siemens_Flash-TAP-SS_from_codify.dcm.txt) Rename to .dcm
Looking at this in a dicom viewer the sequence content is gone.
Hope this helps
Regards
Alan



> The second Content1 overwrites the first.
> ...
> I would suggest generating content names that reflect the content level if possible, eg. content1-1.

Right, it makes sense - the code didn't consider that a nested item could have the same name.  I can update that.


> RecursionError: maximum recursion depth exceeded while calling a Python object

Not too surprising - I think I hit recursion problems when I first wrote codify.

Thanks for the detailed investigation and example files (thanks also @edmcdonagh  for the suggestion).  I can set up some failing tests with those and then see about fixing them.  I've got some time in the next couple of days, hopefully it isn't too difficult and I can get a PR soon.