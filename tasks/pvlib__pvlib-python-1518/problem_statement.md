Altitude lookup table
Currently, altitude for `pvlib.location` based algorithms defaults to zero, but if we include a low-resolution altitude lookup, we can provide better results when altitude is not specified.
We can make this altitude lookup the same format as [LinkeTurbidities.h5](https://github.com/pvlib/pvlib-python/blob/master/pvlib/data/LinkeTurbidities.h5), so it wouldn't require that much new code or any new dependencies.
I was able to build an altitude map using [open data aggregated by tilezen](https://github.com/tilezen/joerd/blob/master/docs/data-sources.md). My test H5 file is currently `13 mb` using `4320x2160` resolution, `uint16` altitude, and `gzip` compression. We are free to distribute this data, but we do need to do is add [this attribution](https://github.com/tilezen/joerd/blob/master/docs/attribution.md) somewhere in the documentation.
Would you guys be interested in this feature? Should I make a pull request?

Here is a plot of my sample
![altitude](https://user-images.githubusercontent.com/17040442/182914007-aedbdd53-5f74-4657-b0cb-60158b6aa26d.png)
:
