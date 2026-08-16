Dataset.pixel_array doesn't change unless PixelData does
#### Description
Currently `ds.pixel_array` produces a numpy array that depends on element values for Rows, Columns, Samples Per Pixel, etc, however the code for `ds.pixel_array` only changes the returned array if the value for `ds.PixelData` changes. This may lead to confusion/undesirable behaviour if the values for related elements are changed after `ds.pixel_array` is called but not the underlying pixel data.

I can't think of any real use cases except maybe in an interactive session when debugging a non-conformant dataset, but I suggest we change the way `Dataset._pixel_id` is calculated so that it takes into account changes in related elements as well.

