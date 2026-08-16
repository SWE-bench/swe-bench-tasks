pydicom produces invalid DICOM files if ds.EncapsulatedDocument contains byte array of odd length
**Bug Description**
When inserting a byte array of odd length into the ds.EncapsulatedDocument field, and saving this as a DICOM file, the DICOM file produced is not valid. This happens because the resulting file produced also have an odd number of bytes in the (0042,0011) OB Encapsulated Document DICOM tag which is not allowed according to the DICOM sepcification for Value Fields, http://dicom.nema.org/dicom/2013/output/chtml/part05/chapter_7.html

**Expected behavior**
Either pydicom could through and error specifying that the ds.EncapsulatedDocument field should contain an array of even length, or it could fix the problem by add and extra zero byte to the end of the ds.EncapsulatedDocument byte array when the length is odd.

**Steps To Reproduce**
I have written the following pdf2dcm.py command line utility to mimic the behaviour of pdf2dcm in the dcmtk suite:

```python
# inspired by: https://github.com/rohithkumar31/pdf2dicom

import argparse
import pydicom

EncapsulatedPDFStorage = '1.2.840.10008.5.1.4.1.1.104.1'


def generate_dicom_from_pdf(input_file, output_file, zero_pad=True):
    file_meta = pydicom.dataset.Dataset()

    # FileMetaInformationGroupLength only gets rewritten when saved if present
    file_meta.FileMetaInformationGroupLength = 206

    file_meta.MediaStorageSOPClassUID = EncapsulatedPDFStorage

    file_meta.MediaStorageSOPInstanceUID = pydicom.uid.generate_uid(pydicom.uid.PYDICOM_ROOT_UID)

    # from: https://pydicom.github.io/pydicom/dev/reference/uid.html
    file_meta.TransferSyntaxUID = pydicom.uid.ExplicitVRLittleEndian

    pydicom.dataset.validate_file_meta(file_meta, enforce_standard=True)

    # see: http://dicom.nema.org/dicom/2013/output/chtml/part10/chapter_7.html
    preamble = b"\0" * 128

    ds = pydicom.dataset.FileDataset(output_file, {}, file_meta=file_meta, preamble=preamble)
    # ds.fix_meta_info()

    ds.is_little_endian = True
    ds.is_implicit_VR = False

    ds.SpecificCharacterSet = 'ISO_IR 100'

    import datetime
    dt = datetime.datetime.now()
    ds.InstanceCreationDate = dt.strftime('%Y%m%d')
    ds.InstanceCreationTime = dt.strftime('%H%M%S')  # ('%H%M%S.%f')

    ds.SOPClassUID = EncapsulatedPDFStorage
    ds.SOPInstanceUID = file_meta.MediaStorageSOPInstanceUID
    ds.StudyDate = None
    ds.AcquisitionDateTime = None
    ds.StudyTime = None
    ds.ContentTime = None
    ds.ContentDate = None
    ds.AccessionNumber = None
    ds.Modality = 'DOC'  # document
    ds.ConversionType = 'WSD'  # workstation
    ds.Manufacturer = None
    ds.ReferringPhysicianName = None
    ds.PatientName = None
    ds.PatientID = None
    ds.PatientBirthDate = None
    ds.PatientSex = None
    ds.StudyInstanceUID = pydicom.uid.generate_uid()
    ds.SeriesInstanceUID = pydicom.uid.generate_uid()
    ds.StudyID = None
    ds.SeriesNumber = 1
    ds.InstanceNumber = 1
    ds.BurnedInAnnotation = 'YES'
    ds.ConceptNameCodeSequence = None
    # ConceptNameCodeSequence also sets: ds.SequenceDelimitationItem
    ds.DocumentTitle = None

    with open(input_file, 'rb') as f:
        pdf_file_as_bytes = f.read()

    # DICOM Value Fields must according to the
    # specification be an even number of bytes, see:
    # http://dicom.nema.org/dicom/2013/output/chtml/part05/chapter_7.html
    if zero_pad and len(pdf_file_as_bytes) % 2 != 0:
        pdf_file_as_bytes += b"\0"

    ds.EncapsulatedDocument = pdf_file_as_bytes
    ds.MIMETypeOfEncapsulatedDocument = 'application/pdf'

    ds.save_as(output_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--disable-zero-padding', action='store_false')
    parser.add_argument('-i', '--input-file')
    parser.add_argument('-o', '--output-file')
    args = parser.parse_args()

    generate_dicom_from_pdf(args.input_file, args.output_file, args.disable_zero_padding)
```

To reproduce the problem the --disable-zero-padding parameter can be added, and a pdf file of odd number of bytes in length can be used as input to the program, this will then product an output DICOM file containing an odd number of bytes in the (0042,0011) OB Encapsulated Document DICOM tag, which can be checked using the dciodvfy validation tool from the dicom3tools package:

```bash
wget http://dicom.nema.org/medical/dicom/current/output/pdf/part05.pdf
ls -l part05.pdf # should be odd number of bytes, currently 4676213 for this file
python pdf2dcm.py --disable-zero-padding -i part05.pdf -o part05.dcm

(0x0042,0x0011) OB Encapsulated Document  - Error - Bad Value Length - not a multiple of 2 - VL is 0x475a75 should be 0x475a76
Error - Dicom dataset read failed
```

**Environment**

```bash
$ python -m pydicom.env_info

module       | version
------       | -------
platform     | Linux-5.13.0-7614-generic-x86_64-with-glibc2.31
Python       | 3.9.5 (default, Jun  4 2021, 12:28:51)  [GCC 7.5.0]
pydicom      | 2.2.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.21.2
PIL          | _module not found_
pylibjpeg    | _module not found_
openjpeg     | _module not found_
libjpeg      | _module not found_
```

