OverflowError "VR of 'DS' must be <= 16 characters long" triggered when element is 16 characters long
**Describe the bug**

`OverflowError` triggered while accessing `PixelData`, which the values compliant with the standard. In the sample referenced in the example below, we have this, which satisfies DS VR:

```
(0028,0030) DS [.002006091181818\.002006091181818]      #  34, 2 PixelSpacing
```

But nevertheless the error is triggered while trying to access `PixelData`:

```
OverflowError: Values for elements with a VR of 'DS' must be <= 16 characters long, 
but the float provided requires > 16 characters to be accurately represented. Use a 
smaller string, set 'config.settings.reading_validation_mode' to 'WARN' to override 
the length check, or explicitly construct a DS object with 'auto_format' set to True
```

**Expected behavior**

`OverflowError` does not get triggered.

**Steps To Reproduce**

Follow the steps of this Colab notebook: https://colab.research.google.com/drive/1FcSgjBKazh0YN-jlJYdID0YUTh90CAvZ?usp=sharing

**Your environment**

```
module       | version
------       | -------
platform     | Linux-5.4.144+-x86_64-with-Ubuntu-18.04-bionic
Python       | 3.7.13 (default, Mar 16 2022, 17:37:17)  [GCC 7.5.0]
pydicom      | 2.3.0
gdcm         | _module not found_
jpeg_ls      | _module not found_
numpy        | 1.21.5
PIL          | 9.1.0
pylibjpeg    | _module not found_
openjpeg     | _module not found_
libjpeg      | _module not found_
```

Related issue: https://github.com/imi-bigpicture/wsidicom/issues/49

cc: @DanielaSchacherer @dclunie @hackermd 
