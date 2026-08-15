I hope you don't mind me tagging you @taldcroft as it was your commit, maybe you can help me figure out if this is a bug or an evolution in `astropy.TimeSeries` that requires an alternative file format? I was pretty happy using ecsv formatted files to save complex data as they have been pretty stable, easy to visually inspect, and read in/out of scripts with astropy. 


[example_file.dat.txt](https://github.com/astropy/astropy/files/8043511/example_file.dat.txt)
(Also I had to add a .txt to the filename to allow github to put it up.)
@emirkmo - sorry, it was probably a mistake to make the reader be strict like that and raise an exception. Although that file is technically non-compliant with the ECSV spec, the reader should instead issue a warning but still carry on if possible (being liberal on input). I'll put in a PR to fix that.

The separate issue is that the `Time` object has a format of `datetime64` which leads to that unexpected numpy dtype in the output. I'm not immediately sure of what the right behavior for writing ECSV should be there. Maybe actually just `datetime64` as an allowed type, but that opens a small can of worms itself. Any thoughts @mhvk?

One curiosity @emirko is how you ended up with the timeseries object `time_bin_start` column having that `datetime64` format (`ts['time_bin_start'].format`). In my playing around it normally has `isot` format, which would not have led to this problem.
I would be happy to contribute this PR @taldcroft, as I have been working on it on a local copy anyway, and am keen to get it working. I currently monkey patched ecsv in my code to not raise, and it seems to work. If you let me know what the warning should say, I can make a first attempt. `UserWarning` of some sort? 

The `datetime64` comes through a chain:

 - Data is read into `pandas` with a `datetime64` index.
 - `TimeSeries` object is created using `.from_pandas`.
 - `aggregate_downsample` is used to turn this into a `BinnedTimeSeries`
 - `BinnedTimeSeries` object is written to an .ecsv file using its internal method.

Here is the raw code, although some of what you see may be illegible due to variable names. I didn't have easy access to the original raw data anymore, hence why I got stuck in trying to read it from the binned light curve. 
```
perday = 12
Tess['datetime'] = pd.to_datetime(Tess.JD, unit='D', origin='julian')
ts = TimeSeries.from_pandas(Tess.set_index('datetime'))
tsb = aggregate_downsample(ts, time_bin_size=(1.0/perday)*u.day, 
                           time_bin_start=Time(beg.to_datetime64()), n_bins=nbin)
tsb.write('../Photometry/Tess_binned.ecsv', format='ascii.ecsv', overwrite=True)
```
My PR above at least works for reading in the example file and my original file. Also passes my local tests on io module. 
Ouch, that is painful! Apart from changing the error to a warning (good idea!), I guess the writing somehow should change the data type from `datetime64` to `string`. Given that the format is stored as `datetime64`, I think this would still round-trip fine. I guess it would mean overwriting `_represent_as_dict` in `TimeInfo`.
> I guess it would mean overwriting _represent_as_dict in TimeInfo

That's where I got to, we need to be a little more careful about serializing `Time`. In some sense I'd like to just use `jd1_jd2` always for Time in ECSV (think of this as lossless serialization), but that change might not go down well.
Yes, what to pick is tricky: `jd1_jd2` is lossless, but much less readable.
As a user, I would expect the serializer picked to maintain the current time format in some way, or at least have a general mapping from all available  formats to the most nearby easily serializable ones if some of them are hard to work with. (Days as ISOT string, etc.)

ECSV seems designed to be human readable so I would find it strange if the format was majorly changed, although now I see that all other ways of saving the data use jd1_jd2. I assume a separate PR is needed for changing this.

Indeed, the other formats use `jd1_jd2`, but they are less explicitly meant to be human-readable.  I think this particular case of numpy datetime should not be too hard to fix, without actually changing how the file looks.
Agreed to keep the ECSV serialization as the `value` of the Time object.