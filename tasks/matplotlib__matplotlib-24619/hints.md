Matplotlib works using the 0-1 convention, not 0-255.  https://matplotlib.org/stable/api/colors_api.html#module-matplotlib.colors
I seem to recall it used to support this format in the for color specification in the past.
This is also the reason, I believe, the `dtype.kind - "i"` was in the first code piece I quoted.
That's not impossible, but if it did, that was a very ambiguous api.  Floats having one scaling and integers another is confusing and prone to errors.  I'm against any special magic to make this work.  
the byte value is also what image data usually uses, e.g., Pillow.  I think it would not be the worst idea having a consistent interface.  As I described above, some parts of it are in the code, maybe as a plan, maybe historic left-over.  I don;t think it would be a big change, but matplotlib code has grown too much of a jungle for me to work though in a few hours, better for someone to look into who is familiar with the current structures and interdependencies. 

I failed to get pcolorfast to work with current cartopy.  It just returns a blank image.  Any ideas?  Maybe some of their codes is not prepared for the extra dimension.  
> Matplotlib works using the 0-1 convention, not 0-255.

Actually imshow() supports 0-255 int inputs as well, so I think it would be reasonable for pcolorfast to support them too.
I just look up documentation for `pcolorfast`:
https://matplotlib.org/stable/api/_as_gen/matplotlib.axes.Axes.pcolorfast.html?highlight=pcolorfast#matplotlib.axes.Axes.pcolorfast
where it states
```
Carray-like
The image data. Supported array shapes are:
(M, N): an image with scalar data. The data is visualized using a colormap.
(M, N, 3): an image with RGB values (0-1 float or 0-255 int).
(M, N, 4): an image with RGBA values (0-1 float or 0-255 int), i.e. including transparency.
```
So I think the ints not working is at least a deviation from the doc (if not a bug).
(or my code has a bug - I had also tried with `uint8`, but as I mentioned, this fails because `u` was not listed as allowed `dtype.kind`.)  

Personally, I would also allow single int32 or int64 as color spec.  I believe Pillow does, or at least as one of the options.  It would be most efficient.
> I just look up documentation for pcolorfast:

That is a compelling arguement we should support [0,255] ints.  

-----

The issue with supporting int32 or int64 is that currently we use the dimensionality to determine if we want to go through the color mapping process (for ndim=2) or directly color map (for ndim=3).  The ambiguity there with the current imshow/pcolormesh API would be too much I think.
Yes, I can see the degenerate cases you worry about.  How to distinguish an N x 3 or N x 4 image in data type int from a (yet to be supported) byte 0-255 1D color image?   Should be rare on the inputs, but what I have seen from the deeper down guts of current matplotlib, I can see where thing can get more ambiguous down the line.  There could be a keyword.