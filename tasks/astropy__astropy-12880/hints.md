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
I will try to nudge the CI workflow on my minor change tonight, but I was wondering if this is going to fix other related issues with ecsvs and Table read/write that I haven't directly mentioned. For example, `str` instead of `string` also fails after Astropy 4.3. 

1.  Now we will raise a warning, but should we really be raising a warning for `str` instead of `string`?
2. Should I add some tests to my PR to catch possible regressions like this, as these regressions didn't trigger any test failures? Especially since I see Table read/write and ecsv is being worked on actively, with several PRs.

An example error I just dug out:
`raise ValueError(f'datatype {col.dtype!r} of column {col.name!r} '
ValueError: datatype 'str' of column 'photfilter' is not in allowed values ('bool', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64', 'float16', 'float32', 'float64', 'float128', 'string')`

Works silently on astropy 4.2.1, but not later, and now will raise a warning instead.
(1) Do you know where the `str` example is coming from? This is actually an excellent case for the new warning because `str` is not an allowed ECSV `datatype` per the ECSV standard. So it means that some code is not doing the right thing when writing that ECSV file (and should be fixed).

(2) You can add optionally add a test for `str`, but I don't think it will help code coverage much since it falls in the same category of a valid numpy `dtype` which is NOT a valid ECSV `datatype`.

Note that ECSV has the goal of not being Python and Numpy-specific, hence the divergence in some of these details here.
<details>
<summary>Unnecessary detail, see next comment</summary>
In the simplest case, it is reading from an .ecsv file sent over as json (from a webserver with a get request) with a column that has `type` of `<class 'str'>`. This json is written to file and then read using `Table.read(<file>, format='ascii.ecsv')`. The .ecsv file itself is constructed from a postgre_sql database with an inbetween step of using an astropy Table. Read below if you want details.

So it's json (formatted as .ecsv) -> python write -> Table.read()


In detail:
For the case above, it's a get request to some webserver, that is storing this data in a database (postgre_sql), the request creates a .ecsv file after grabbing the right data from the database and putting it into a table, however this is done using an old version of astropy (as the pipeline environment that does this needs version locks), which is then sent as json formatted text. The pipeline that created the data is fixed to an old verison of astropy (maybe 4.2.1), and that is what is stored in postgre_sql database. Now, whatever code that is requesting it, turns it into json, writes to a file and then reads it into an astropy table using Table.read(format='ascii.ecsv'). The actual raw data for the column is that is intered into the database is a python string representing a photometric filter name. I don't have much insight into the database part, but I can find out if helpful.

It's this last step that fails after the update. I have a workaround of converting the json string, replacing 'str' with 'string', but it doesn't seem optimal. I see though that maybe if the json was read into an astropy table first, then saved, it would work. I just wasn't sure about the status of json decoding in astropy (and this seemed to work before).
</details>
I've had a look, and I think this may be code problems on our behalf when serializing python `str` data, or it could be just a very outdated astropy version as well. Although I wonder if 'str' could be used as an alias for 'string', so that codes that write .ecsv files from tabular data, maybe while skipping over astropy's own implementation? 

We probably never noticed the issues because prior to the checks, most things would just work rather robustly. 

Edit: Here's an example file:
```
# %ECSV 0.9
# ---
# datatype:
# - {name: time, datatype: float64, description: Time of observation in BMJD}
# - {name: mag_raw, datatype: float64, description: Target magnitude in raw science image}
# - {name: mag_raw_error, datatype: float64, description: Target magnitude error in raw science image}
# - {name: mag_sub, datatype: float64, description: Target magnitude in subtracted image}
# - {name: mag_sub_error, datatype: float64, description: Target magnitude error in subtracted image}
# - {name: photfilter, datatype: str, description: Photometric filter}
# - {name: site, datatype: int32, description: Site/instrument identifier}
# - {name: fileid_img, datatype: int32, description: Unique identifier of science image}
# - {name: fileid_diffimg, datatype: int32, description: Unique identifier of template-subtracted image}
# - {name: fileid_template, datatype: int32, description: Unique identifier of template image}
# - {name: fileid_photometry, datatype: int32, description: Unique identifier of photometry}
# - {name: version, datatype: str, description: Pipeline version}
# delimiter: ','
# meta: !!omap
# - keywords:
#   - {target_name: '2020svo'}
#   - {targetid: 130}
#   - {redshift: }
#   - {redshift_error: }
#   - {downloaded: '2022-02-17 01:04:27'}
# - __serialized_columns__:
#     time:
#       __class__: astropy.time.core.Time
#       format: mjd
#       scale: tdb
#       value: !astropy.table.SerializedColumn {name: time}
# schema: astropy-2.0
time,mag_raw,mag_raw_error,mag_sub,mag_sub_error,photfilter,site,fileid_img,fileid_diffimg,fileid_template,fileid_photometry,version
59129.1064732728991657,010101,,,H,9,1683,,,5894,master-v0.6.4
```
Our group has recently encountered errors very closely related to this.  In our case the ECSV 0.9 type is `object`.  I *think* the ECSV 1.0 equivalent is `string subtype: json`, but I haven't been able to to confirm that yet.

In general, what is the policy on backward-compatibility when reading ECSV files?
@weaverba137 if you don’t mind, would you be able to try my PR #12481 to see if it works for dtype object as well? We’re also interested in backwards compatibility.

(You can clone my branch, and pip install -e ., I don’t have a main so have to clone the PR branch)
@weaverba137 @emirkmo - sorry that the updates in ECSV reading are breaking back-compatibility, I am definitely sensitive to that. Perhaps we can do a bug-fix release which checks for ECSV 0.9 (as opposed to 1.0) and silently reads them without warnings. This will work for files written with older astropy.

@weaverba137 - ~~can you provide an example file with an `object` column?~~ [EDIT - I saw the example and read the discussion in the linked issue].  Going forward (astropy >= 5.0), `object` columns are written (and read) as described at https://github.com/astropy/astropy-APEs/blob/main/APE6.rst#object-columns. This is limited to object types that can be serialized to standard JSON (without any custom representations).
I would be highly supportive of a backwards compatibility bugfix for V0.9, and then an API change for V5.1 that changes the spec. I would be willing to work on a PR for it. 
@emirkmo - OK good plan, sorry again for the trouble. You can see this code here that is parsing the ECSV header. Currently nothing is done with the regex results but you can easily use it to check the version number and disable the current ValueError for ECSV < 1.0.
```
        # Validate that this is a ECSV file
        ecsv_header_re = r"""%ECSV [ ]
                             (?P<major> \d+)
                             \. (?P<minor> \d+)
                             \.? (?P<bugfix> \d+)? $"""

```
This new PR will likely introduce a merge conflict with the PR here, so #12840 would probably need to be on hold in lieu of the bug fix patch.
@taldcroft, good, sounds like you got what you need. That's a toy example of course, but I could provide something more realistic if necessary.