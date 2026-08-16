`pvlib.iotools.get_pvgis_hourly`'s `surface_azimuth` parameter doesn't use pvlib's azimuth convention
Nearly everything in pvlib represents azimuth angles as values in [0, 360) clockwise from north, except `pvlib.iotools.get_pvgis_hourly`:

https://github.com/pvlib/pvlib-python/blob/3def7e3375002ee3a5492b7bc609d3fb63a8edb1/pvlib/iotools/pvgis.py#L79-L81

This inconsistency is a shame.  However, I don't see any way to switch it to pvlib's convention without a hard break, which is also a shame.  I wonder how others view the cost/benefit analysis here.

See also https://github.com/pvlib/pvlib-python/pull/1395#discussion_r1181853794


