Is there an api we can use instead?
Cool idea. I can't really comment on the cost (if any) of distributing another relatively large data file.

Some thoughts: the technical improvement to modeling would be minor: the only use of 'altitude' is to estimate air pressure for a clear-sky model or for adjusting geometric solar position to apparent position. But there's an intangible benefit from not having to look up a value, or having to explain why the default 0m is good enough. To me the intangible benefit is likely greater than the improvement in model results.

As alternatives, several of the weather data sources (PSM3, others), but not all, return altitude. 
Could file size be reduced by omitting the ocean bathymetry data?  I'm not really familiar with h5 files.  If accuracy is not so important, maybe cutting the values down to 8 bits would be acceptable. 

> Cool idea

Yes!  Makes me wonder if there are other such datasets we should consider. 
> Accuracy is not so important

Good point. Altitude rounded to 100m increments is probably good enough.
I'm unsure about packaging an elevation map with pvlib. But a higher resolution data set could be useful for shading. I thought there were some PR discussions along those lines.
I think getting altitude is probably something we can outsource to an API like the Google Maps maybe, ESRI, or MapQuest? Seems a lot easier than adding 10 mb to the package maybe?
Found these:
* [Google map elevation API](https://developers.google.com/maps/documentation/elevation/start), [guide](https://developers.google.com/maps/documentation/elevation/overview)
* [open elevation api](https://open-elevation.com/)
* [Air Map API](https://developers.airmap.com/docs/elevation-api)
* [open topo data api](https://www.opentopodata.org/)
* [DEM.NET](https://elevationapi.com/faq) EG

    > This URL will give you (quickly!) the elevation near Notre-Dame de Paris (39 meters), using SRTM GL3 dataset : 
[`https://api.elevationapi.com/api/Elevation?lat=48.854624&lon=2.3436793&dataSet=SRTM_GL3`](https://api.elevationapi.com/api/Elevation?lat=48.854624&lon=2.3436793&dataSet=SRTM_GL3)

And more… I googled “elevation api lookup”
I tried the suggestions to reduce the size of the altitude lookup map.
If I set the oceans data to zero, it compresses much better and goes down to `3.9 mb`.
I also tried encoding the remaining land data as `uint8` in `35m` increments.
This `uint8` version is `1.2 mb` after gzip compression.

I agree that an API would be good for high-resolution use cases like shading. 
But I think having a fallback built-in is still valid.
An external API has more friction; You need API keys, there can be costs or limits, and it adds more latency.
Also, where I got the original data can be helpful in high-resolution use-cases. It is hosted for free by aws in their [open data initiative](https://registry.opendata.aws/terrain-tiles/).
You can fetch terrain tiles using [slippy tilenames](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) from this URL template
`https://elevation-tiles-prod.s3.amazonaws.com/v2/terrarium/{zoom}/{x}/{y}.png`.
And [here](https://github.com/tilezen/joerd/blob/master/docs/formats.md) are the docs for how to convert RGB -> meters
I'm -1 to having `Location.get_solarposition()` make web requests, if that's being proposed.  I'm cautiously open to bundling a local dataset if it's only a ~1MB expense (our [current dist](https://pypi.org/project/pvlib/#files) is ~30 MB).

I'm also open to `iotools` functions for elevation data, although I'm not sure I see a lot of value in it if the relevant API calls are as simple as `requests.get("url?lon=X&lat=Y").json()['elevation']`.  I think I'd rather see a gallery example showing how to DIY in that case. 
This discussion suggests there are two, perhaps complementary, enhancements:
- provide a low-resolution, low-accuracy altitude to supplement the current default of 0. for clearsky and solar position calculations.
- via iotools, provide access to an API for high-resolution elevation data for detailed modeling of shading, tracker steering, and (in future pvlib) spatially varying module orientation.

Access to an API for detailed elevation data will not relieve those who want a simple alternative to the current default. Similarly, a low-resolution file included with pvlib will not satisfy those looking for high accuracy elevation.

I'm not opposed to having all three (current default, low-resolution internal lookup, high resolution via API) in pvlib. 
I think it'd be great to have the option of something like this: 

    pvlib.location.Location(latitude=55, longitude=10, altitude='SRTM')

and then have the location object call an API (using a function from iotools) that retrieved the elevation.
It looks like the 1.2 mb version might be acceptable. I will make a pull request early next week and you can make the final decision then. I also will play with the encoding a bit, there might be ways to increase accuracy while staying ~1 mb.
I wonder if folks will start to cannibalize  pvlib for elevation data, and then send issues complaining that it's only accurate to 35m :rofl:
> I wonder if folks will start to cannibalize pvlib for elevation data, and then send issues complaining that it's only accurate to 35m 🤣

Assuredly, yes.