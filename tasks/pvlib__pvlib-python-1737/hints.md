Interesting, did this come up during the 2023 PVPMC workshop? These functions are meant to read the legacy TMY files from the [NSRDB archives](https://nsrdb.nrel.gov/data-sets/archives), but because SolarAnywhere TGY files are similar, you may also be able to read them with `pvlib.iotools.read_tmy3()` but you might need to edit the SolarAnywhere file to match the NSRDB TMY3 file format more closely. Can you paste the exact error message you got when trying to read the SolarAnywhere file?
The error appeared when one of the hackathon participants tried to read [this SolarAnywhere](https://raw.githubusercontent.com/PVSC-Python-Tutorials/PVPMC_2023/main/data/SolarAnywhere%20Typical%20DNI%20Year%20Lat_40_75%20Lon_-111_85%20TMY3%20format.csv) file.

There was an unknown character in the `meta['USAF']` value that couldn't be converted to an int.

However, I cannot reproduce the error.  I wonder if it was caused by the way the participant saved that file locally.

I can't reproduce the error either.

@PGRenewables what version of pvlib were you using? You can check that by writing ``pvlib.__version__``.
Also, if you could upload the file you saved locally, that would be great.
Regardless, encoding problems are nightmarish at times, I wonder if we should dedicate a short troubleshooting section to it as perhaps we've already done for time zones?
@AdamRJensen 

PVLib Version  0.9.2

[PVLib Tutorial.zip](https://github.com/pvlib/pvlib-python/files/11456496/PVLib.Tutorial.zip)

I included the files that I was working with in this zip file.
@PGRenewables Thanks!  Can you upload the data file itself as well?  Since they can't reproduce the error with the original file, a next step is to check whether there is some difference between the original data file and the one you're using.  
Hi @kandersolar , this is the file that I was using. Thank you so much! 


[SolarAnywhere Typical DNI Year Lat_40_75 Lon_-111_85_TMY3_format.csv](https://github.com/pvlib/pvlib-python/files/11466930/SolarAnywhere.Typical.DNI.Year.Lat_40_75.Lon_-111_85_TMY3_format.csv)

`print(open(filename, 'r').read(5))` shows that the file @PGRenewables just uploaded differs from the original in that it starts with `ï»¿`, which google says is a [Byte Order Mark](https://en.wikipedia.org/wiki/Byte_order_mark#Byte_order_marks_by_encoding) for UTF-8.  I also notice that the date format inside the CSV data is different in this file (`01/01/2004` versus `1/1/2004`).  I speculate that the data got read into some tool that understands CSV (Excel?) and then re-exported before getting used with pvlib?

The internet suggests using `encoding='utf-8-sig'` for files with this BOM.  We could try to handle this case, but I'm nervous that `read_tmy3` will turn into a rat's nest if it keeps trying to handle encoding issues itself.  I still think exposing `encoding` as an optional parameter is worth considering (https://github.com/pvlib/pvlib-python/pull/1494#issuecomment-1194011363).